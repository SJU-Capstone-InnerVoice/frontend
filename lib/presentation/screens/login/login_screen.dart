import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:inner_voice/data/datasources/local/auth_local_datasource.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:inner_voice/presentation/widgets/error_dialog.dart';
import 'package:provider/provider.dart';
import '../../../data/models/user/user_model.dart';
import '../../../logic/providers/network/dio_provider.dart';
import '../../../core/constants/user/role.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  late final Dio _dio;
  late final User? _user;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    /// provider 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dio = context
          .read<DioProvider>()
          .dio;
      _user = context
          .read<UserProvider>()
          .user;
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final name = _idController.text.trim();
    final password = _pwController.text.trim();

    if (name.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = '아이디와 비밀번호를 모두 입력해주세요.';
        isLoading = false;
      });
      return;
    }

    try {
      final dio = context
          .read<DioProvider>()
          .dio;
      final userProvider = context.read<UserProvider>();

      await userProvider.handleLogin(dio, name, password);

      await userProvider.setChildList(dio);
      final user = userProvider.user;
      if (user != null) {
        await AuthLocalDataSource.saveUser(user.userId, user.role.name);
      }
      userProvider.user?.role == UserRole.parent
          ? context.go('/parent/call')
          : context.go('/child/call');
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) =>
            ErrorDialog(
              title: "로그인 실패",
              message: "아이디와 비밀번호를 다시 확인해주세요",
            ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          width: 180,
                          height: 180,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icons/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -12),
                          child: Image.asset(
                            'assets/icons/pont2.png',
                            width: 150,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _idController,
                          decoration:
                          const InputDecoration(labelText: '아이디'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pwController,
                          decoration:
                          const InputDecoration(labelText: '비밀번호'),
                          obscureText: true,
                        ),
                        const SizedBox(height: 5),
                        if (errorMessage != null)
                          Text(errorMessage!,
                              style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text("로그인",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              context.go('/login/sign-up');
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Colors.black),
                            ),
                            child: const Text("회원가입",
                                style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}