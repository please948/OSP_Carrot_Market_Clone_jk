import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle;

class LocalData {
  final LatLng position;
  final String imageUrl;
  final String title;
  final String price;
  final String description;

  LocalData({
    required this.position,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition;
  final Map<String, BitmapDescriptor> _markerIcons = {};

  final List<LocalData> mytownLocalData = [
    LocalData(
      position: LatLng(35.8580, 128.6020),
      imageUrl: 'https://codingapple1.github.io/app/img0.jpg',
      title: '냉장고 팝니다',
      price: '50,000원',
      description: '깨끗하게 사용한 삼성 냉장고입니다. 성능 좋고 소음 없습니다.',
    ),
    LocalData(
      position: LatLng(35.8565, 128.6005),
      imageUrl: 'https://codingapple1.github.io/app/img1.jpg',
      title: '의자 팔아요',
      price: '10,000원',
      description: '편안한 사무용 의자예요. 생활감 조금 있지만 튼튼합니다.',
    ),
    LocalData(
      position: LatLng(35.8578, 128.6000),
      imageUrl: 'https://codingapple1.github.io/app/img2.jpg',
      title: '책상 저렴히!',
      price: '25,000원',
      description: '원목 책상입니다. 가로 120cm, 세로 60cm. 상태 좋아요.',
    ),
    LocalData(
      position: LatLng(35.8570, 128.6025),
      imageUrl: 'https://codingapple1.github.io/app/img3.jpg',
      title: '전자렌지 판매',
      price: '30,000원',
      description: '1년 사용한 LG 전자렌지입니다. 정상 작동 확인했습니다.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadMarkerIcons();
  }

  Future<void> _getCurrentLocation() async {
    // 지금은 대구 수성구 기준 (임시)
    _currentPosition = const LatLng(35.8580, 128.6020);
    setState(() {});
  }

  Future<void> _loadMarkerIcons() async {
    for (int i = 0; i < mytownLocalData.length; i++) {
      final data = mytownLocalData[i];
      final icon = await CustomMarkerHelper.createCustomMarker(
        imageUrl: data.imageUrl,
        title: data.title,
        price: data.price,
      );
      _markerIcons['local_$i'] = icon;
    }
    setState(() {});
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('my_location'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: '내 위치'),
        ),
      );
    }

    for (int i = 0; i < mytownLocalData.length; i++) {
      final data = mytownLocalData[i];
      markers.add(
        Marker(
          markerId: MarkerId('local_$i'),
          position: data.position,
          icon:
              _markerIcons['local_$i'] ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => Container(
                padding: const EdgeInsets.all(16),
                height: 380,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        data.imageUrl,
                        fit: BoxFit.cover,
                        height: 200,
                        width: double.infinity,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.price,
                      style: const TextStyle(
                        color: Colors.teal,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 주변 보기')),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 15,
              ),
              myLocationEnabled: true,
              markers: _buildMarkers(),
            ),
    );
  }
}

/// 🔹 Helper 클래스: 사진 + 제목 + 가격을 마커 이미지로 그려주는 부분
class CustomMarkerHelper {
  static Future<BitmapDescriptor> createCustomMarker({
    required String imageUrl,
    required String title,
    required String price,
  }) async {
    final ByteData bytes = await NetworkAssetBundle(
      Uri.parse(imageUrl),
    ).load(imageUrl);
    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: 150,
      targetHeight: 150,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const double width = 160;
    const double height = 190;

    final paint = Paint()..color = Colors.white;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, width, height),
      const Radius.circular(16),
    );
    canvas.drawRRect(rrect, paint);

    paintImage(
      canvas: canvas,
      rect: const Rect.fromLTWH(5, 5, 150, 110),
      image: image,
      fit: BoxFit.cover,
    );

    final textPainter1 = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 140);

    final textPainter2 = TextPainter(
      text: TextSpan(
        text: price,
        style: const TextStyle(color: Colors.teal, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 140);

    textPainter1.paint(canvas, const Offset(10, 120));
    textPainter2.paint(canvas, const Offset(10, 140));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final pngBytes = (await img.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes);
  }
}
