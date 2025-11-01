/// 카카오 로그인 상태 관리 Provider
///
/// Provider 패턴을 사용하여 카카오 로그인 상태를 관리하는 클래스입니다.
/// ChangeNotifier를 mixin하여 상태 변경 시 UI에 자동으로 알림을 보냅니다.
///
/// 주요 기능:
/// - 로그인 상태 관리
/// - 사용자 정보 저장 및 제공
/// - 로그인/로그아웃 액션 처리
/// - UI 상태 변경 알림
///
/// @author Flutter Sandbox
/// @version 1.0.0
/// @since 2024-01-01

import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_sandbox/services/kakao_login_service.dart';

/// 카카오 로그인 상태를 관리하는 Provider 클래스
///
/// ChangeNotifier를 mixin하여 상태 변경 시 구독자들에게 알림을 보냅니다.
/// KakaoLoginService를 사용하여 실제 로그인 로직을 처리합니다.
class KakaoLoginProvider with ChangeNotifier {
  /// 카카오 로그인 서비스 인스턴스
  /// 실제 로그인/로그아웃 로직을 처리하는 서비스
  final KakaoLoginService _service = KakaoLoginService();

  /// 현재 로그인된 사용자 정보
  /// null이면 로그인되지 않은 상태
  User? _user;

  /// 현재 로그인된 사용자 정보를 반환합니다.
  ///
  /// Returns:
  /// - [User?]: 로그인된 사용자 정보, 로그인되지 않은 경우 null
  User? get user => _user;

  /// 카카오 로그인을 수행합니다.
  ///
  /// KakaoLoginService를 통해 로그인을 시도하고,
  /// 성공 시 사용자 정보를 저장한 후 UI에 변경사항을 알립니다.
  ///
  /// 사용법:
  /// ```dart
  /// await loginProvider.login();
  /// ```
  Future<void> login() async {
    // 서비스를 통해 로그인 시도
    _user = await _service.login();

    // 상태 변경을 UI에 알림 (Consumer 위젯들이 리빌드됨)
    notifyListeners();
  }

  /// 카카오 로그아웃을 수행합니다.
  ///
  /// KakaoLoginService를 통해 로그아웃을 처리하고,
  /// 사용자 정보를 초기화한 후 UI에 변경사항을 알립니다.
  ///
  /// 사용법:
  /// ```dart
  /// await loginProvider.logout();
  /// ```
  Future<void> logout() async {
    // 서비스를 통해 로그아웃 처리
    await _service.logout();

    // 사용자 정보 초기화
    _user = null;

    // 상태 변경을 UI에 알림 (Consumer 위젯들이 리빌드됨)
    notifyListeners();
  }
}
