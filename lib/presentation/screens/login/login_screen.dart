import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/home');
          },
          child: const Text("로그인하기"),
        ),
      ),
    );
  }
}