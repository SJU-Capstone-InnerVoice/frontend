

import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요약'),
      ),
      body: const Center(
        child: Text(
          '임시 요약 화면입니다.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}