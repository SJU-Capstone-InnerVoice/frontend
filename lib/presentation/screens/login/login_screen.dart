import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text("Logo", style: TextStyle(fontSize: 18, color: Colors.black54)),
              ),
            ),
            const SizedBox(height: 40),
            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/mode');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("로그인", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            // Sign Up Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.go('/signup');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.black),
                ),
                child: const Text("회원가입", style: TextStyle(fontSize: 16, color: Colors.black)),
              ),
            ),
            const SizedBox(height: 24),
            // Continue as Guest
            TextButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text("비회원으로 계속하기", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}