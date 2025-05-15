import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api/login_api.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final Dio _dio = Dio();
  bool isAgreed = false;
  String? selectedRole; // CHILD 또는 PARENT
  void _updateState() => setState(() {});
  bool get _isFormValid {
    return emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        confirmPasswordController.text.trim().isNotEmpty &&
        selectedRole != null &&
        isAgreed;
  }
  @override
  void initState() {
    super.initState();
    emailController.addListener(_updateState);
    passwordController.addListener(_updateState);
    confirmPasswordController.addListener(_updateState);
  }
  void _onSignup() async {
    final name = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("모든 항목을 입력해주세요.");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("비밀번호가 일치하지 않습니다.");
      return;
    }

    if (selectedRole == null) {
      _showMessage("역할을 선택해주세요.");
      return;
    }

    try {
      final data = {
        'name': name,
        'password': password,
        'role': selectedRole!, // 'CHILD' 또는 'PARENT'
      };

      final response = await _dio.post(LoginApi.register, data: data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage("회원가입이 완료되었습니다.");
        context.go('/login');
      } else {
        _showMessage("회원가입 실패: 서버 응답 오류 (${response.statusCode})");
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? '회원가입 중 오류가 발생했습니다.';
      _showMessage(message);
      print('Dio 예외: ${e.response?.data}');
    } catch (e) {
      print('예외 발생: $e');
      _showMessage("알 수 없는 오류가 발생했습니다.");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    emailController.removeListener(_updateState);
    passwordController.removeListener(_updateState);
    confirmPasswordController.removeListener(_updateState);
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
            ClipOval(
              child: Image.asset(
                'assets/icons/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -12), // 위로 12픽셀 올림
              child: Image.asset(
                'assets/icons/pont2.png',
                width: 150,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '마음의 소리는 아이가 좋아하는 캐릭터와 대화하며\n부모와 자연스럽게 소통할 수 있도록 돕는 앱입니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInputField(emailController, '아이디 입력'),
            const SizedBox(height: 16),
            _buildInputField(passwordController, '비밀번호 입력', obscureText: true),
            const SizedBox(height: 4),
            // const Padding(padding: EdgeInsets.only(left: 4.0), child: Align(alignment: Alignment.centerLeft, child: Text('숫자+영문자+특수문자 조합으로 8자리 이상 입력해주세요.', style: TextStyle(fontSize: 12, color: Colors.red,),),),),
            const SizedBox(height: 16),
            _buildInputField(confirmPasswordController, '비밀번호 확인', obscureText: true),
            const SizedBox(height: 16),

            // 역할 선택
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              hint: const Text('역할 선택'),
              items: const [
                DropdownMenuItem(value: 'CHILD', child: Text('아이')),
                DropdownMenuItem(value: 'PARENT', child: Text('부모')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRole = value;
                });
              },
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAgreed = !isAgreed;
                    });
                  },
                  child: Icon(
                    isAgreed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
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
              onPressed: _isFormValid ? _onSignup : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('회원가입', style: TextStyle(fontSize: 16, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}