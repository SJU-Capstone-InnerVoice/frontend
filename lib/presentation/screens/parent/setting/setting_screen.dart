import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: const Center(
        child: Text(
          '임시 설정 화면입니다.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
