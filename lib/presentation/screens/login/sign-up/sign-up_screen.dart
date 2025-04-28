import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isAgreed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('회원 가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.network(
              'https://picsum.photos/200/300',
              width: 120,
              height: 120,
              fit: BoxFit.cover, // (필요하면 추가) 꽉 채워서 예쁘게 맞출 수 있음
            ),
            const SizedBox(height: 20),
            const Text(
              '마음의 소리',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '마음의 소리는 아이가 좋아하는 캐릭터와 대화하며\n부모와 자연스럽게 소통할 수 있도록 돕는 앱입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInputField(emailController, '이메일(아이디) 입력'),
            const SizedBox(height: 16),
            _buildInputField(passwordController, '비밀번호 입력', obscureText: true),
            const SizedBox(height: 16),
            _buildInputField(confirmPasswordController, '비밀번호 확인', obscureText: true),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: '서비스 이용약관, 개인정보 취급방침',
                      style: const TextStyle(color: Colors.orange),
                      children: [
                        const TextSpan(
                          text: '에 동의합니다.',
                          style: TextStyle(color: Colors.orange, decoration: TextDecoration.none),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isAgreed ? _onSignup : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('회원가입', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _onSignup() {
    // TODO: 회원가입 로직 추가
    print('회원가입 시도: ${emailController.text}');
  }
}