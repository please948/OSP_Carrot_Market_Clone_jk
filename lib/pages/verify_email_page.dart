import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter_sandbox/providers/email_auth_provider.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<EmailAuthProvider>(context, listen: false);
    final User? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min, // Row의 가로 크기를 자식들(Text, IconButton) 크기만큼만 차지하도록 설정
          children: [
            const Text('로그아웃'),
            // 아이콘 버튼을 title의 Row 안으로 이동
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                authProvider.logout();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_read_outlined, size: 100, color: Colors.teal),
              const SizedBox(height: 24),
              const Text(
                '이메일을 확인해주세요',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '본인 인증을 위해 ${user?.email ?? '회원님의 이메일'}로\n전송된 링크를 클릭하세요.',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              /// 인증 이메일 재전송 버튼
              ElevatedButton.icon(
                icon: const Icon(Icons.send_outlined),
                label: const Text('인증 이메일 다시 보내기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    await user?.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('인증 이메일을 다시 전송했습니다.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('오류: ${e.toString()}')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}