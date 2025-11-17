import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter_sandbox/models/firestore_schema.dart';
import 'package:flutter_sandbox/models/product.dart';
import 'package:flutter_sandbox/pages/location_picker_page.dart';
import 'package:flutter_sandbox/providers/email_auth_provider.dart';
import 'package:flutter_sandbox/services/local_app_repository.dart';

class ProductCreatePage extends StatefulWidget {
  const ProductCreatePage({super.key});

  @override
  State<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlsController = TextEditingController();
  final _groupItemController = TextEditingController();
  final _groupMaxMembersController = TextEditingController();
  final _groupCurrentMembersController = TextEditingController(text: '1');
  final _groupPricePerPersonController = TextEditingController();
  final _groupMeetTextController = TextEditingController();

  ListingType _type = ListingType.market;
  ProductCategory _category = ProductCategory.digital;
  DateTime? _orderDeadline;
  List<AppGeoPoint> _selectedLocations = [];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlsController.dispose();
    _groupItemController.dispose();
    _groupMaxMembersController.dispose();
    _groupCurrentMembersController.dispose();
    _groupPricePerPersonController.dispose();
    _groupMeetTextController.dispose();
    super.dispose();
  }

  Future<void> _selectLocations() async {
    final initialLatLngs = _selectedLocations
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    final picked = await Navigator.push<List<LatLng>>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialLocations: initialLatLngs,
        ),
      ),
    );
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _selectedLocations = picked
            .map(
              (latLng) => AppGeoPoint(
                latitude: latLng.latitude,
                longitude: latLng.longitude,
              ),
            )
            .toList();
      });
    }
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _orderDeadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocations.isEmpty) {
      _showMessage('거래 위치를 한 곳 이상 선택해주세요.');
      return;
    }

    final user = context.read<EmailAuthProvider>().user;
    if (user == null) {
      _showMessage('로그인이 필요합니다.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final images = _imageUrlsController.text
          .split(',')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      GroupBuyInfo? groupInfo;
      if (_type == ListingType.groupBuy) {
        if (_groupItemController.text.trim().isEmpty ||
            _groupMaxMembersController.text.trim().isEmpty ||
            _groupPricePerPersonController.text.trim().isEmpty ||
            _groupMeetTextController.text.trim().isEmpty) {
          _showMessage('같이사요 정보를 모두 입력해주세요.');
          setState(() => _isSubmitting = false);
          return;
        }
        groupInfo = GroupBuyInfo(
          itemSummary: _groupItemController.text.trim(),
          maxMembers: int.tryParse(_groupMaxMembersController.text.trim()) ?? 0,
          currentMembers:
              int.tryParse(_groupCurrentMembersController.text.trim()) ?? 1,
          pricePerPerson:
              int.tryParse(_groupPricePerPersonController.text.trim()) ?? 0,
          orderDeadline: _orderDeadline ?? DateTime.now().add(const Duration(days: 1)),
          meetPlaceText: _groupMeetTextController.text.trim(),
        );
      }

      // 선택한 첫 번째 위치에 따라 실제 지역을 결정
      final primaryLocation = _selectedLocations.first;
      final actualRegion = LocalAppRepository.instance.getRegionByLocation(
        primaryLocation.latitude,
        primaryLocation.longitude,
      ) ?? user.region; // 지역을 찾지 못하면 사용자의 지역 사용

      await LocalAppRepository.instance.createListing(
        type: _type,
        title: _titleController.text.trim(),
        price: int.tryParse(_priceController.text.trim()) ?? 0,
        meetLocations: _selectedLocations,
        images: images.isEmpty ? ['lib/dummy_data/아이폰.jpeg'] : images,
        category: _category,
        region: actualRegion,
        universityId: user.universityId,
        seller: user,
        description: _descriptionController.text.trim(),
        groupBuy: groupInfo,
      );

      if (mounted) {
        _showMessage('상품이 등록되었습니다!', isError: false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showMessage('등록에 실패했습니다: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 등록'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 16),
              _buildCategorySelector(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? '제목을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '대표 가격 (원)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? '가격을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlsController,
                decoration: const InputDecoration(
                  labelText: '이미지 URL (쉼표로 구분)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: '상세 설명',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildLocationSelector(),
              const SizedBox(height: 16),
              if (_type == ListingType.groupBuy) _buildGroupBuyFields(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('상품 등록'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: ListingType.values.map((type) {
        final isSelected = _type == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _type = type),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                type == ListingType.market ? '중고거래' : '같이사요',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProductCategory.values.map((category) {
            final isSelected = _category == category;
            return ChoiceChip(
              label: Text(_categoryLabel(category)),
              selected: isSelected,
              onSelected: (_) => setState(() => _category = category),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '거래 위치',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _selectLocations,
              icon: const Icon(Icons.map),
              label: const Text('지도에서 선택'),
            ),
          ],
        ),
        if (_selectedLocations.isEmpty)
          const Text(
            '아직 선택된 위치가 없습니다.',
            style: TextStyle(color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedLocations.asMap().entries.map((entry) {
              return Chip(
                label: Text(
                  '${entry.key + 1}. ${entry.value.latitude.toStringAsFixed(4)}, ${entry.value.longitude.toStringAsFixed(4)}',
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildGroupBuyFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text(
          '같이사요 상세 정보',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _groupItemController,
          decoration: const InputDecoration(
            labelText: '상품/메뉴 요약',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _groupMaxMembersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '모집 인원',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _groupPricePerPersonController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '1인 금액',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _groupCurrentMembersController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '현재 참여 인원',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _groupMeetTextController,
          decoration: const InputDecoration(
            labelText: '만날 장소 설명',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('주문 마감 시간'),
          subtitle: Text(
            _orderDeadline == null
                ? '선택되지 않음'
                : DateFormat('yyyy-MM-dd HH:mm').format(_orderDeadline!),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDeadline,
          ),
        ),
      ],
    );
  }

  String _categoryLabel(ProductCategory category) {
    switch (category) {
      case ProductCategory.digital:
        return '전자기기';
      case ProductCategory.textbooks:
        return '전공책';
      case ProductCategory.daily:
        return '생활용품';
      case ProductCategory.housing:
        return '가구/주거';
      case ProductCategory.fashion:
        return '패션/잡화';
      case ProductCategory.hobby:
        return '취미/레저';
      case ProductCategory.etc:
        return '기타';
      case ProductCategory.groupBuy:
        return '같이사요';
    }
  }
}
