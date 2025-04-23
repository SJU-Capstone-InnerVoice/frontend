import 'package:flutter/material.dart';

class ParentScreen extends StatelessWidget {
  const ParentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('부모 홈'),
      ),
      body: const Center(
        child: Text(
          '부모 홈 화면입니다.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
