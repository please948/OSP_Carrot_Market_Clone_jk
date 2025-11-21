# 서버 스텁 코드를 이용한 UI 발표
## 공통 컴포넌트 포함

---

## 📋 목차

1. [과제 개요](#과제-개요)
2. [팀 소개](#팀-소개)
3. [개발 목표](#개발-목표)
4. [구현 내용](#구현-내용)
5. [화면 구조](#화면-구조)
6. [개발 프로세스](#개발-프로세스)
7. [코드 예시](#코드-예시)
8. [결과 및 결론](#결과-및-결론)

---

## 🎯 과제 개요

**과제명**: 서버 스텁 코드를 이용한 UI 발표 (공통 컴포넌트 포함)

**목적**: 
- 가상 서버(Server Stub)를 사용하여 화면이 자동 생성되도록 개발
- 재사용 가능한 공통 컴포넌트를 정의하여 개발 효율성 향상
- 컴포넌트 기반 개발을 통한 코드 재사용성 및 유지보수성 개선

---

## 👥 팀 소개

| 학번 | 이름 | 전공 |
|------|------|------|
| 20210353 | 김현진 | 컴퓨터공학전공 |
| 20210503 | 박진섭 | 컴퓨터공학전공 |
| 20210900 | 이준기 | 컴퓨터공학전공 |
| 20211043 | 정석준 | 컴퓨터공학전공 |

---

## 🎯 개발 목표

### 1. 가상 서버 개발
- 실제 서버 없이도 UI 개발 및 테스트 가능
- Mock 데이터를 통한 빠른 프로토타이핑

### 2. 공통 컴포넌트 정의
- 재사용 가능한 UI 컴포넌트 설계
- 일관된 디자인 시스템 구축

### 3. 화면 자동 생성
- Server Stub을 활용한 데이터 기반 UI 생성
- 컴포넌트 조합을 통한 화면 구성

---

## 💻 구현 내용

### 1. Server Stub 클래스

**위치**: `lib/services/server_stub.dart`

**역할**: 가상 서버 역할을 수행하여 Mock 데이터 제공

**주요 메서드**:

```dart
class Server {
  // 상품 목록 조회
  List<Product> getProductList({Map<String, dynamic>? condition});
  
  // 상품 상세 조회
  Product? getProductById(String productId);
  
  // 카테고리별 상품 조회
  List<Product> getProductsByCategory(ProductCategory category);
  
  // 검색 기능
  List<Product> searchProducts(String keyword);
  
  // 사용자 정보 조회
  AppUserProfile? getUserById(String userId);
  
  // 상품 CRUD 작업
  String createProduct(Product product);
  bool updateProduct(String productId, Map<String, dynamic> updates);
  bool deleteProduct(String productId);
}
```

**특징**:
- ✅ Singleton 패턴으로 전역 접근 가능
- ✅ Mock 데이터를 통한 즉시 테스트 가능
- ✅ 실제 서버 API와 동일한 인터페이스 제공

---

### 2. 공통 컴포넌트

#### 📦 ProductCard
**위치**: `lib/widgets/product_card.dart`

**기능**: 상품 정보를 카드 형태로 표시

**포함 요소**:
- 상품 이미지
- 제목
- 가격
- 위치 정보
- 상태 표시 (판매중/예약중/판매완료)

**사용 예시**:
```dart
ProductCard(
  product: product,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  },
)
```

---

#### 🖼️ ProductImage
**위치**: `lib/widgets/product_image.dart`

**기능**: 상품 이미지를 표시하는 재사용 가능한 컴포넌트

**특징**:
- Asset 이미지 및 네트워크 이미지 지원
- 이미지 로드 실패 시 플레이스홀더 표시
- 크기 및 모서리 반경 커스터마이징 가능

---

#### 💰 PriceText
**위치**: `lib/widgets/price_text.dart`

**기능**: 가격을 포맷팅하여 표시

**특징**:
- 천 단위 구분자 자동 적용 (예: 1,000원)
- 가격이 0일 경우 "가격 미정" 표시
- 커스터마이징 가능한 텍스트 스타일

---

#### 📍 LocationBadge
**위치**: `lib/widgets/location_badge.dart`

**기능**: 위치 정보를 뱃지 형태로 표시

**특징**:
- 위치 아이콘과 함께 표시
- 작은 크기로 공간 효율적 사용
- 배경색 및 텍스트 스타일 커스터마이징 가능

---

#### 🏷️ CategoryChip
**위치**: `lib/widgets/category_chip.dart`

**기능**: 카테고리를 선택 가능한 칩 형태로 표시

**특징**:
- 선택 상태에 따라 스타일 자동 변경
- 클릭 이벤트 처리
- 일관된 디자인 적용

**사용 예시**:
```dart
CategoryChip(
  label: '전자기기',
  category: ProductCategory.digital,
  isSelected: _selectedCategory == ProductCategory.digital,
  onTap: () {
    setState(() {
      _selectedCategory = ProductCategory.digital;
    });
  },
)
```

---

## 📱 화면 구조

### 1. 로그인 화면
- **기능**: 이메일 로그인
- **UI 요소**: 로고, 환영 메시지, 로그인 버튼

### 2. 홈 화면 (메인)
- **기능**: 
  - 상품 목록 표시
  - 카테고리 필터링
  - 위치 기반 필터링
  - 상품 등록 버튼
- **사용 컴포넌트**: `ProductCard`, `CategoryChip`

### 3. 상품 상세 화면
- **기능**:
  - 상품 이미지 슬라이더
  - 상품 정보 표시
  - 판매자 정보
  - 채팅하기 기능
- **사용 컴포넌트**: `ProductImage`, `PriceText`, `LocationBadge`

### 4. 상품 등록 화면
- **기능**:
  - 상품 정보 입력
  - 이미지 업로드
  - 위치 설정

### 5. 채팅 화면
- **기능**: 실시간 채팅 기능

---

## 🔄 개발 프로세스

### Step 1: 대표 화면 선택
✅ **홈 화면 (상품 목록)** 선택
- 가장 기본적이고 자주 사용되는 화면
- 다양한 컴포넌트 조합 필요

### Step 2: 필요한 컴포넌트 정의
✅ **5개의 공통 컴포넌트** 정의
- `ProductCard`: 상품 카드
- `CategoryChip`: 카테고리 필터
- `ProductImage`: 상품 이미지
- `PriceText`: 가격 표시
- `LocationBadge`: 위치 뱃지

### Step 3: 가상 서버 개발
✅ **Server Stub 클래스** 구현
- Mock 데이터 제공
- 실제 API와 동일한 인터페이스

### Step 4: 화면 자동 생성
✅ **Server Stub을 활용한 화면 구성**
- 데이터 기반 UI 생성
- 컴포넌트 재사용

### Step 5: 다음 화면 개발
🔄 **반복 프로세스**
- 상품 상세 화면
- 상품 등록 화면
- 채팅 화면 등

---

## 💡 코드 예시

### Server Stub 사용 예시

```dart
// 1. 상품 목록 조회
final products = Server.instance.getProductList();

// 2. 카테고리별 상품 조회
final digitalProducts = Server.instance.getProductsByCategory(
  ProductCategory.digital
);

// 3. 상품 상세 조회
final product = Server.instance.getProductById('100');

// 4. 검색 기능
final searchResults = Server.instance.searchProducts('노트북');
```

### 공통 컴포넌트 조합 예시

```dart
// 상품 목록 화면
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    return ProductCard(
      product: products[index],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              product: products[index]
            ),
          ),
        );
      },
    );
  },
)
```

### 카테고리 필터 예시

```dart
// 카테고리 필터 바
Row(
  children: [
    CategoryChip(
      label: '전체',
      isSelected: _selectedCategory == null,
      onTap: () => setState(() => _selectedCategory = null),
    ),
    CategoryChip(
      label: '전자기기',
      category: ProductCategory.digital,
      isSelected: _selectedCategory == ProductCategory.digital,
      onTap: () => setState(() => 
        _selectedCategory = ProductCategory.digital
      ),
    ),
    // ... 더 많은 카테고리
  ],
)
```

---

## 📊 파일 구조

```
lib/
├── services/
│   └── server_stub.dart              # Server Stub 클래스
│
├── widgets/                           # 공통 컴포넌트
│   ├── product_card.dart              # 상품 카드
│   ├── product_image.dart             # 상품 이미지
│   ├── price_text.dart                # 가격 텍스트
│   ├── location_badge.dart           # 위치 뱃지
│   └── category_chip.dart            # 카테고리 칩
│
└── pages/
    ├── product_list_stub_page.dart    # Server Stub 사용 예시
    ├── home_page.dart                 # 홈 화면
    ├── product_detail_page.dart       # 상품 상세 화면
    └── ...
```

---

## ✅ 결과 및 결론

### 달성한 목표

1. ✅ **Server Stub 구현 완료**
   - Mock 데이터를 통한 빠른 개발 가능
   - 실제 서버 없이도 UI 테스트 가능

2. ✅ **공통 컴포넌트 정의 완료**
   - 5개의 재사용 가능한 컴포넌트 구현
   - 일관된 디자인 시스템 구축

3. ✅ **화면 자동 생성 구현**
   - Server Stub 데이터 기반 UI 생성
   - 컴포넌트 조합을 통한 화면 구성

### 개선 효과

- 🚀 **개발 속도 향상**: 공통 컴포넌트 재사용으로 개발 시간 단축
- 🎨 **일관성 유지**: 동일한 컴포넌트 사용으로 UI 일관성 보장
- 🔧 **유지보수 용이**: 컴포넌트 수정 시 모든 화면에 자동 반영
- 🧪 **테스트 용이**: Server Stub을 통한 독립적인 UI 테스트 가능

### 향후 계획

- [ ] 추가 화면에 Server Stub 및 공통 컴포넌트 적용
- [ ] 컴포넌트 라이브러리 확장
- [ ] 실제 서버 API 연동 시 Server Stub과의 호환성 유지

---

## 📝 참고 자료

- **과제 문서**: `STUB_SERVER_ASSIGNMENT.md`
- **Server Stub 코드**: `lib/services/server_stub.dart`
- **공통 컴포넌트**: `lib/widgets/`
- **예시 화면**: `lib/pages/product_list_stub_page.dart`

---

**작성일**: 2024-11-24  
**프로젝트**: 금오 마켓 (중고 거래 앱)

