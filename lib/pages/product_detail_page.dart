/// 상품 상세 페이지
///
/// 당근 마켓의 상품 상세 정보를 표시하는 화면입니다.
/// 상품의 모든 정보와 판매자 정보, 채팅하기 등의 기능을 제공합니다.
///
/// 주요 기능:
/// - 상품 이미지 표시 (여러 장일 경우 슬라이더)
/// - 상품 상세 정보 표시
/// - 판매자 정보 표시
/// - 채팅하기 버튼
/// - 찜하기 기능
/// - 위치 정보
///
/// @author Flutter Sandbox
/// @version 1.0.0
/// @since 2024-01-01

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sandbox/models/product.dart';
import 'package:flutter_sandbox/pages/chat_page.dart';

/// 상품 상세 정보를 표시하는 페이지
class ProductDetailPage extends StatefulWidget {
  /// 표시할 상품 정보
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  /// 현재 이미지 인덱스 (여러 이미지인 경우)
  int _currentImageIndex = 0;

  /// 찜하기 상태
  bool _isLiked = false;

  /// 이미지 URL이 asset 경로인지 확인하는 메서드
  bool _isAssetImage(String imageUrl) {
    return imageUrl.contains('dummy_data') ||
        imageUrl.startsWith('lib/') ||
        imageUrl.startsWith('assets/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {
              // 공유 기능 (향후 구현)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('공유 기능은 준비 중입니다')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // 더보기 메뉴 (향후 구현)
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지 섹션
            _buildImageSection(),

            // 상품 정보 섹션
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 판매자 정보
                  _buildSellerInfo(),
                  const Divider(height: 32),

                  // 상품 제목
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 카테고리와 상태
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.product.categoryText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.product.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.product.statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(widget.product.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 가격
                  Text(
                    widget.product.formattedPrice,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 조회수와 찜 수
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '조회 ${widget.product.viewCount}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '찜 ${widget.product.likeCount}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // 상품 설명
                  const Text(
                    '상품 설명',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 위치 정보
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        widget.product.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateTime.now().difference(widget.product.createdAt).inDays}일 전',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// 상품 이미지 섹션을 생성하는 위젯
  Widget _buildImageSection() {
    final images = widget.product.imageUrls;
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 64, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // 이미지 페이지뷰
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imagePath = images[index];
              return _isAssetImage(imagePath)
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('상세 페이지 이미지 로드 실패: $imagePath');
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image,
                              size: 64, color: Colors.grey),
                        );
                      },
                    )
                  : Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image,
                              size: 64, color: Colors.grey),
                        );
                      },
                    );
            },
          ),

          // 이미지 인덱스 인디케이터
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 판매자 정보를 생성하는 위젯
  Widget _buildSellerInfo() {
    return Row(
      children: [
        // 판매자 프로필 이미지
        CircleAvatar(
          radius: 25,
          backgroundImage: widget.product.sellerProfileImageUrl != null
              ? NetworkImage(widget.product.sellerProfileImageUrl!)
              : null,
          child: widget.product.sellerProfileImageUrl == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 12),
        // 판매자 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.sellerNickname,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.location,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        // 판매자 프로필 보기 버튼
        OutlinedButton(
          onPressed: () {
            // 판매자 프로필 페이지 (향후 구현)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('판매자 프로필은 준비 중입니다')),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.teal,
            side: const BorderSide(color: Colors.teal),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('프로필 보기'),
        ),
      ],
    );
  }

  /// 하단 버튼 바를 생성하는 위젯
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 찜하기 버튼
            IconButton(
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isLiked = !_isLiked;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isLiked ? '찜 목록에 추가했습니다' : '찜을 취소했습니다'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),

            // 채팅하기 버튼
            Expanded(
              child: ElevatedButton(
                onPressed: widget.product.isAvailable
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              opponentName: widget.product.sellerNickname,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  widget.product.isAvailable ? '채팅하기' : widget.product.statusText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상품 상태에 따른 색상을 반환하는 메서드
  Color _getStatusColor(ProductStatus status) {
    switch (status) {
      case ProductStatus.onSale:
        return Colors.teal;
      case ProductStatus.reserved:
        return Colors.orange;
      case ProductStatus.sold:
        return Colors.grey;
    }
  }
}




