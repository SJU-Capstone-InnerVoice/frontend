import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../logic/providers/record/call_record_provider.dart';

class CallEndScreen extends StatefulWidget {
  const CallEndScreen({super.key});

  @override
  State<CallEndScreen> createState() => _CallEndScreenState();
}

class _CallEndScreenState extends State<CallEndScreen> {
  String? _mergedFilePath;

  @override
  void initState() {
    super.initState();
    _mergeRecording();
  }

  Future<void> _mergeRecording() async {
    final outputFileName = 'merged_${DateTime.now().millisecondsSinceEpoch}';

    final mergedPath = await context
        .read<CallRecordProvider>()
        .mergeRecordingsToSingleFile(outputFileName);

    setState(() {
      _mergedFilePath = mergedPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📼 통화 종료')),
      body: Center(
        child: _mergedFilePath == null
            ? const CircularProgressIndicator()
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text('병합 완료!'),
            const SizedBox(height: 8),
            Text(_mergedFilePath ?? '', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}