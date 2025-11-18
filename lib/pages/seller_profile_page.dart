/// 판매자 프로필 페이지
///
/// 판매자 정보와 판매 상품 목록을 표시하는 화면입니다.
///
/// 주요 기능:
/// - 판매자 기본 정보 표시
/// - 판매자가 등록한 상품 목록 표시
/// - 판매중/판매완료 탭 구분
///
/// @author Flutter Sandbox
/// @version 1.0.0
/// @since 2024-01-01

import 'package:flutter/material.dart';
import 'package:flutter_sandbox/models/product.dart';
import 'package:flutter_sandbox/pages/product_detail_page.dart';
import 'package:flutter_sandbox/data/mock_products.dart';
import 'package:flutter_sandbox/config/app_config.dart';
import 'package:flutter_sandbox/services/local_app_repository.dart';

/// 판매자 프로필 페이지를 나타내는 위젯
class SellerProfilePage extends StatefulWidget {
  /// 판매자 ID
  final String sellerId;
  
  /// 판매자 닉네임
  final String sellerNickname;
  
  /// 판매자 프로필 이미지 URL (선택사항)
  final String? sellerProfileImageUrl;

  const SellerProfilePage({
    super.key,
    required this.sellerId,
    required this.sellerNickname,
    this.sellerProfileImageUrl,
  });

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage>
    with SingleTickerProviderStateMixin {
  /// 상품 상태 탭 컨트롤러
  late TabController _tabController;

  /// 판매자가 등록한 상품 목록
  List<Product> _sellerProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSellerProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 판매자가 등록한 상품 목록을 로드하는 메서드
  void _loadSellerProducts() {
    // 실제로는 sellerId로 필터링하여 가져옵니다
    final products = AppConfig.useFirebase
        ? getMockProducts()
        : LocalAppRepository.instance
            .getProducts(viewerUid: null)
            .where((p) => p.sellerId == widget.sellerId)
            .toList();
    
    _sellerProducts = AppConfig.useFirebase
        ? getMockProducts().where((p) => p.sellerId == widget.sellerId).toList()
        : products;
    
    setState(() {});
  }

  /// 현재 선택된 탭에 해당하는 상품 목록을 반환하는 메서드
  List<Product> get _filteredProducts {
    final selectedIndex = _tabController.index;
    switch (selectedIndex) {
      case 0: // 판매중
        return _sellerProducts
            .where((p) => p.status == ProductStatus.onSale || 
                         p.status == ProductStatus.reserved)
            .toList();
      case 1: // 판매완료
        return _sellerProducts
            .where((p) => p.status == ProductStatus.sold)
            .toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '판매자 프로필',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 판매자 정보 섹션
          _buildSellerSection(),

          // 상품 상태 탭
          _buildTabBar(),

          // 상품 목록
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  /// 판매자 정보 섹션을 생성하는 위젯
  Widget _buildSellerSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 판매자 프로필 이미지
          CircleAvatar(
            radius: 40,
            backgroundImage: widget.sellerProfileImageUrl != null
                ? NetworkImage(widget.sellerProfileImageUrl!)
                : null,
            child: widget.sellerProfileImageUrl == null
                ? const Icon(Icons.person, color: Colors.grey, size: 40)
                : null,
          ),
          const SizedBox(height: 16),

          // 판매자 닉네임
          Text(
            widget.sellerNickname,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // 판매 상품 통계
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('판매중', _sellerProducts
                  .where((p) => p.status == ProductStatus.onSale || 
                               p.status == ProductStatus.reserved)
                  .length),
              const SizedBox(width: 24),
              _buildStatItem('판매완료', _sellerProducts
                  .where((p) => p.status == ProductStatus.sold)
                  .length),
            ],
          ),
        ],
      ),
    );
  }

  /// 통계 아이템을 생성하는 위젯
  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// 상품 상태 탭바를 생성하는 위젯
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.teal,
        labelColor: Colors.teal,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: '판매중'),
          Tab(text: '판매완료'),
        ],
        onTap: (index) {
          setState(() {});
        },
      ),
    );
  }

  /// 상품 그리드를 생성하는 위젯
  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  /// 상품 카드를 생성하는 위젯
  Widget _buildProductCard(Product product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: product.imageUrls.isNotEmpty
                      ? product.imageUrls.first.startsWith('lib/')
                            ? Image.asset(
                                product.imageUrls.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Image.network(
                                product.imageUrls.first,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 상품 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상품 제목
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 가격
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 상품 상태
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.status == ProductStatus.onSale
                          ? Colors.teal[50]
                          : product.status == ProductStatus.reserved
                          ? Colors.orange[50]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: product.status == ProductStatus.onSale
                            ? Colors.teal
                            : product.status == ProductStatus.reserved
                            ? Colors.orange
                            : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// 빈 상태를 표시하는 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _getEmptyMessage(),
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 빈 상태 메시지를 반환하는 메서드
  String _getEmptyMessage() {
    switch (_tabController.index) {
      case 0:
        return '판매중인 상품이 없습니다';
      case 1:
        return '판매 완료된 상품이 없습니다';
      default:
        return '';
    }
  }
}

