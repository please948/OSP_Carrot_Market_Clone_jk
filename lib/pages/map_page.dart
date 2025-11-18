import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle, rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sandbox/models/firestore_schema.dart';
import 'package:flutter_sandbox/models/product.dart';
import 'package:flutter_sandbox/pages/product_detail_page.dart';
import 'package:flutter_sandbox/services/local_app_repository.dart';
import 'package:flutter_sandbox/providers/location_provider.dart';
import 'package:flutter_sandbox/config/app_config.dart';

class MapScreen extends StatefulWidget {
  final bool moveToCurrentLocationOnInit;
  
  const MapScreen({Key? key, this.moveToCurrentLocationOnInit = false}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final LocalAppRepository _repository = LocalAppRepository.instance;

  final List<_ListingPin> _pins = [];
  final Map<String, BitmapDescriptor> _markerCache = {};

  final LatLng kumoh = const LatLng(36.1461, 128.3939); //금오공대 위치
  static const double _searchRadiusMeters = 1000;

  @override
  void initState() {
    super.initState();
    // 초기 위치 설정 (지도 표시를 위해 필요)
    _currentPosition = kumoh;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // 지도가 생성된 후 현재 위치로 이동해야 하는 경우
    if (widget.moveToCurrentLocationOnInit) {
      _moveToCurrentLocation(false);
    } else {
      // LocationProvider의 필터 설정에 따라 지도 업데이트
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.isLocationFilterEnabled &&
          locationProvider.filterLatitude != null &&
          locationProvider.filterLongitude != null) {
        final filterCenter = LatLng(
          locationProvider.filterLatitude!,
          locationProvider.filterLongitude!,
        );
        _currentPosition = filterCenter;
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: filterCenter,
              zoom: 17,
            ),
          ),
        );
        _refreshListings(filterCenter, locationProvider);
      }
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // GPS 켜져있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS가 꺼져 있습니다. 설정에서 켜주세요.')),
      );

      await Geolocator.openLocationSettings();
      return false;
    }

    // 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _moveToCurrentLocation(bool isBack) async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

  // 금오공대로 복귀하는 경우
    if (isBack) {
      setState(() {
        _currentPosition = kumoh;
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 17,
          ),
        ),
      );
    final locationProvider = context.read<LocationProvider>();
    _refreshListings(kumoh, locationProvider);
    return;
  }

  // 현재 위치로 이동하는 경우
    late Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('현재 위치를 가져올 수 없습니다.')),
        );
      }
      return;
    }

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentPosition!,
          zoom: 17,
        ),
      ),
    );

    final locationProvider = context.read<LocationProvider>();
    _refreshListings(LatLng(position.latitude, position.longitude), locationProvider);
   }


  Future<void> _refreshListings(LatLng center, LocationProvider locationProvider) async {
    final pins = <_ListingPin>[];
    
    // LocationProvider의 검색 반경 사용 (필터가 활성화된 경우)
    final searchRadius = locationProvider.isLocationFilterEnabled
        ? locationProvider.searchRadius
        : _searchRadiusMeters;
    
    if (AppConfig.useFirebase) {
      // Firebase 모드: Firestore에서 상품 가져오기
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('products')
            .get();
        
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final location = data['location'] as GeoPoint?;
          final meetLocations = data['meetLocations'] as List?;
          
          if (location == null) continue;
          
          // Listing 객체로 변환
          final listing = Listing(
            id: doc.id,
            type: data['type'] == 'market' ? ListingType.market : ListingType.groupBuy,
            title: data['title'] as String? ?? '',
            price: (data['price'] as int?) ?? 0,
            location: AppGeoPoint(
              latitude: location.latitude,
              longitude: location.longitude,
            ),
            meetLocations: meetLocations?.map((loc) {
              final geoPoint = loc as GeoPoint;
              return AppGeoPoint(
                latitude: geoPoint.latitude,
                longitude: geoPoint.longitude,
              );
            }).toList() ?? [],
            images: List<String>.from(data['images'] ?? []),
            category: ProductCategory.values[data['category'] as int? ?? 0],
            status: ListingStatus.values[data['status'] as int? ?? 0],
            region: Region(
              code: (data['region'] as Map?)?['code'] as String? ?? '',
              name: (data['region'] as Map?)?['name'] as String? ?? '',
              level: ((data['region'] as Map?)?['level'] as int?)?.toString() ?? 
                     (data['region'] as Map?)?['level'] as String? ?? '0',
              parent: (data['region'] as Map?)?['parent'] as String?,
            ),
            universityId: data['universityId'] as String? ?? '',
            sellerUid: data['sellerUid'] as String? ?? '',
            sellerName: data['sellerName'] as String? ?? '',
            sellerPhotoUrl: data['sellerPhotoUrl'] as String?,
            likeCount: data['likeCount'] as int? ?? 0,
            viewCount: data['viewCount'] as int? ?? 0,
            description: data['description'] as String? ?? '',
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            likedUserIds: Set<String>.from(data['likedUserIds'] ?? []),
            groupBuy: data['groupBuy'] != null ? GroupBuyInfo(
              itemSummary: (data['groupBuy'] as Map)['itemSummary'] as String? ?? '',
              maxMembers: (data['groupBuy'] as Map)['maxMembers'] as int? ?? 0,
              currentMembers: (data['groupBuy'] as Map)['currentMembers'] as int? ?? 1,
              pricePerPerson: (data['groupBuy'] as Map)['pricePerPerson'] as int? ?? 0,
              orderDeadline: ((data['groupBuy'] as Map)['orderDeadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
              meetPlaceText: (data['groupBuy'] as Map)['meetPlaceText'] as String? ?? '',
            ) : null,
          );
          
          final points = listing.meetLocations.isEmpty 
              ? [listing.location] 
              : listing.meetLocations;
          
          for (var i = 0; i < points.length; i++) {
            final point = points[i];
            final distance = Geolocator.distanceBetween(
              center.latitude,
              center.longitude,
              point.latitude,
              point.longitude,
            );
            if (distance <= searchRadius) {
              pins.add(
                _ListingPin(
                  listing: listing,
                  point: point,
                  markerId: '${listing.id}_$i',
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('지도 상품 로드 실패: $e');
      }
    } else {
      // 로컬 모드
      final listings = _repository.getAllListings();
      
      for (final listing in listings) {
        final points =
            listing.meetLocations.isEmpty ? [listing.location] : listing.meetLocations;
        for (var i = 0; i < points.length; i++) {
          final point = points[i];
          final distance = Geolocator.distanceBetween(
            center.latitude,
            center.longitude,
            point.latitude,
            point.longitude,
          );
          if (distance <= searchRadius) {
            pins.add(
              _ListingPin(
                listing: listing,
                point: point,
                markerId: '${listing.id}_$i',
              ),
            );
          }
        }
      }
    }
    
    setState(() {
      _pins
        ..clear()
        ..addAll(pins);
    });
    await _preloadMarkerIcons();
  }

  Future<void> _preloadMarkerIcons() async {
    for (final pin in _pins) {
      if (_markerCache.containsKey(pin.markerId)) continue;
      final firstImage =
          pin.listing.images.isNotEmpty ? pin.listing.images.first : null;
      final icon = await CustomMarkerHelper.createCustomMarker(
        title: pin.listing.title,
        price: NumberFormat.simpleCurrency(locale: 'ko_KR', name: '')
            .format(pin.listing.price),
        imageUrl: firstImage,
      );
      if (!mounted) return;
      setState(() {
        _markerCache[pin.markerId] = icon;
      });
    }
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    if (_currentPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('my_location'),
        position: _currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: '내 위치'),
      ));
    }

    for (final pin in _pins) {
      final position = LatLng(pin.point.latitude, pin.point.longitude);
      markers.add(Marker(
        markerId: MarkerId(pin.markerId),
        position: position,
        icon: _markerCache[pin.markerId] ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => _ListingBottomSheet(pin: pin),
          );
        },
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        // LocationProvider가 변경될 때마다 지도 업데이트
        if (locationProvider.isLocationFilterEnabled &&
            locationProvider.filterLatitude != null &&
            locationProvider.filterLongitude != null) {
          final filterCenter = LatLng(
            locationProvider.filterLatitude!,
            locationProvider.filterLongitude!,
          );
          if (_currentPosition != filterCenter) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _currentPosition = filterCenter;
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: filterCenter,
                    zoom: 17,
                  ),
                ),
              );
              _refreshListings(filterCenter, locationProvider);
            });
          }
        } else if (!widget.moveToCurrentLocationOnInit && _currentPosition == kumoh) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _refreshListings(kumoh, locationProvider);
          });
        }
        
        return Scaffold(
          appBar: AppBar(title: const Text('내 주변 보기')),
          body: _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition:
                      CameraPosition(target: _currentPosition!, zoom: 17),
                  myLocationEnabled: true,
                  markers: _buildMarkers(),
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(

            mainAxisSize: MainAxisSize.min,
            children:[

              FloatingActionButton(
                onPressed: (){



                  _moveToCurrentLocation(false);
                },
                child: const Icon(Icons.my_location),
              ),
              FloatingActionButton(
                heroTag: "goBack",
                onPressed: ()async{

                  _mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      const CameraPosition(
                        target: LatLng(36.1461, 128.3939),
                        zoom: 17,   // 👍 여기 확대값 적용
                      ),
                    ),
                  );



                  _moveToCurrentLocation(true);
                },
                child: const Icon(Icons.school),
              ),
              const SizedBox(height: 12),
            ]
        ),
      ),
        );
      },
    );
  }
}

class _ListingPin {
  const _ListingPin({
    required this.listing,
    required this.point,
    required this.markerId,
  });

  final Listing listing;
  final AppGeoPoint point;
  final String markerId;
}

class _ListingBottomSheet extends StatelessWidget {
  const _ListingBottomSheet({required this.pin});

  final _ListingPin pin;

  @override
  Widget build(BuildContext context) {
    final listing = pin.listing;
    final priceText = NumberFormat.simpleCurrency(
      locale: 'ko_KR',
      name: '',
    ).format(listing.price);
    final imageUrl = listing.images.isNotEmpty ? listing.images.first : null;

    Widget imageWidget;
    if (imageUrl == null) {
      imageWidget = Container(
        height: 200,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 48, color: Colors.grey),
      );
    } else if (imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 200,
        width: double.infinity,
      );
    } else {
      imageWidget = Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        height: 200,
        width: double.infinity,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageWidget,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceText,
                      style: const TextStyle(
                        color: Colors.teal,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, listing);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailPage(
                        product: LocalAppRepository.instance
                            .getProductById(listing.id)!,
                      ),
                    ),
                  );
                },
                child: const Text('상세보기'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            listing.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            '거래 위치: (${pin.point.latitude.toStringAsFixed(4)}, ${pin.point.longitude.toStringAsFixed(4)})',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class CustomMarkerHelper {
  static Future<BitmapDescriptor> createCustomMarker({
    required String title,
    required String price,
    String? imageUrl,
  }) async {
    final bytes = await _loadImageBytes(imageUrl);
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: 150,
      targetHeight: 150,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    const double width = 180;
    const double height = 210;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final background = Paint()..color = Colors.white;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(18),
    );
    canvas.drawRRect(rrect, background);

    paintImage(
      canvas: canvas,
      rect: const Rect.fromLTWH(10, 10, 160, 120),
      image: image,
      fit: BoxFit.cover,
    );

    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 160);

    final pricePainter = TextPainter(
      text: TextSpan(
        text: price,
        style: const TextStyle(
          color: Colors.teal,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: 160);

    titlePainter.paint(canvas, const Offset(10, 140));
    pricePainter.paint(canvas, const Offset(10, 160));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final pngBytes =
        (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  static Future<ByteData> _loadImageBytes(String? imageUrl) async {
    if (imageUrl == null) {
      return rootBundle.load('lib/dummy_data/아이폰.jpeg');
    }
    if (imageUrl.startsWith('http')) {
      return await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
    }
    return await rootBundle.load(imageUrl);
  }
}
