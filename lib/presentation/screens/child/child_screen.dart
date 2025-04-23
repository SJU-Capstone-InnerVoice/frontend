import 'package:flutter/material.dart';

class ChildScreen extends StatelessWidget {
  const ChildScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아이 홈'),
      ),
      body: const Center(
        child: Text(
          '아이 홈 화면입니다.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}