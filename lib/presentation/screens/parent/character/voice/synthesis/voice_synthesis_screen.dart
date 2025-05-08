import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class VoiceSynthesisScreen extends StatefulWidget {
  const VoiceSynthesisScreen({super.key});

  @override
  State<VoiceSynthesisScreen> createState() => _VoiceSynthesisScreenState();
}

class _VoiceSynthesisScreenState extends State<VoiceSynthesisScreen> {
  File? _audioFile;

  Future<void> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
      print('선택된 파일: ${_audioFile!.path}');
    } else {
      print('파일 선택 취소됨');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fileName = _audioFile != null
        ? _audioFile!.path.split('/').last
        : '선택된 파일 없음';

    return Scaffold(
      appBar: AppBar(
        title: const Text('음성 합성하기'),
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: SafeArea(

        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '음성 합성하기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              const Text(
                '모두 합쳐서 최소 40초 이상으로 음성을 녹음해주세요',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 음성 플레이어 박스
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.play_arrow, size: 30, color: Colors.black54),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '00:17',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 음성 파일 업로드 버튼
              ElevatedButton.icon(
                onPressed: pickAudioFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('음성 파일 업로드'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const Spacer(),

              // 하단 버튼들
              Row(
                children: [
                  // 음성 합성 시작 (비활성화)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('음성 합성 시작'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 음성 녹음 버튼
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // 녹음 로직
                      },
                      icon: const Icon(Icons.mic),
                      label: const Text('음성 녹음'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}