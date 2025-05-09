import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class VoiceResultScreen extends StatefulWidget {
  const VoiceResultScreen({super.key});

  @override
  State<VoiceResultScreen> createState() => _VoiceResultScreenState();
}

class _VoiceResultScreenState extends State<VoiceResultScreen> {
  @override
  Widget build(BuildContext context) {
    final filePaths = GoRouterState.of(context).extra as List<String>;
    final files = filePaths.map((path) => File(path)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('음성 합성 결과'),
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            return Text(files[index].path);
          },
        ),
      ),
    );
  }
}
