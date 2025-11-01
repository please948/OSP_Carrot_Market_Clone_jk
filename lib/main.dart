/// Flutter 앱의 진입점
///
/// 이 파일은 앱의 시작점으로, 다음과 같은 역할을 합니다:
/// 1. Flutter 바인딩 초기화
/// 2. 카카오 SDK 초기화
/// 3. Provider를 사용한 상태 관리 설정
/// 4. 메인 앱 위젯 실행
///
/// @author Flutter Sandbox
/// @version 1.0.0
/// @since 2024-01-01

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:flutter_sandbox/firebase_options.dart';
import 'package:flutter_sandbox/config/api_keys.dart';
import 'package:flutter_sandbox/providers/kakao_login_provider.dart';
import 'package:flutter_sandbox/providers/email_auth_provider.dart';
import 'package:flutter_sandbox/pages/home_page.dart';

/// 앱의 메인 진입점
///
/// Flutter 앱이 시작될 때 가장 먼저 실행되는 함수입니다.
/// 카카오 SDK를 초기화하고 Provider를 설정한 후 앱을 실행합니다.
///
// Firebase 기능 사용 여부 플래그 (false면 Firebase 비활성화)

//const bool kUseFirebase = false;

const bool kUseFirebase = true; //Firebase 활성화시 주석 제거

Future<void> main() async {
  // Flutter 바인딩을 초기화합니다.
  // 이는 Flutter 엔진과의 통신을 위한 필수 단계입니다.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (비활성화 시 건너뜀)
  if (kUseFirebase) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase 초기화 성공');
    } catch (e) {
      // 초기화 실패 시에도 앱이 구동되도록 경고만 출력
      print('⚠️ Firebase 초기화 실패: $e');
    }
  }

  // 카카오 SDK를 초기화합니다.
  // 네이티브 앱 키와 자바스크립트 앱 키를 설정합니다.
  // API 키는 lib/config/api_keys.dart 파일에서 관리됩니다.
  // (api_keys.dart는 .gitignore에 포함되어 Git에 올라가지 않습니다)

  KakaoSdk.init(
    nativeAppKey: ApiKeys.kakaoNativeAppKey,
    javaScriptAppKey: ApiKeys.kakaoJavaScriptAppKey,
    //restApiKey: ApiKeys.kakaoRestApiKey, // 필요시 주석 해제
  );

  // 앱을 실행합니다.
  // MultiProvider를 사용하여 여러 Provider를 앱 전체에 제공합니다.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => KakaoLoginProvider()),
        ChangeNotifierProvider(create: (context) => EmailAuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// 메인 앱 위젯
///
/// MaterialApp을 반환하여 앱의 기본 구조를 설정합니다.
/// 테마와 홈 화면을 지정합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '금오 마켓', // 앱 제목
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ), // 기본 테마 (청록색 기반)
      home: const HomePage(), // 홈 화면으로 HomePage 설정
    );
  }
}
