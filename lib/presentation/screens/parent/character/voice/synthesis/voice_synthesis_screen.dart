import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'widgets/audio_item_widget.dart';

class VoiceSynthesisScreen extends StatefulWidget {
  const VoiceSynthesisScreen({super.key});

  @override
  State<VoiceSynthesisScreen> createState() => _VoiceSynthesisScreenState();
}

class _VoiceSynthesisScreenState extends State<VoiceSynthesisScreen> {
  final List<File> _audioFiles = [];
  final List<AudioPlayer> _players = [];
  final List<Duration?> _durations = [];

  Future<void> pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          final audioFile = File(file.path!);
          final player = AudioPlayer();
          await player.setFilePath(audioFile.path);
          final duration = await player.duration;

          setState(() {
            _audioFiles.add(audioFile);
            _players.add(player);
            _durations.add(duration);
          });
        }
      }
    }
  }

  void removeAudio(int index) {
    _players[index].dispose();
    setState(() {
      _audioFiles.removeAt(index);
      _players.removeAt(index);
      _durations.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var player in _players) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('음성 합성하기'),
        leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Row(
          children: [
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
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // 녹음 기능 구현 예정
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
            ElevatedButton.icon(
              onPressed: pickAudioFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('음성 파일 업로드'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '모두 합쳐서 최소 40초 이상으로 음성을 녹음해주세요',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              /// 오디오 리스트
              Expanded(
                child: ListView.builder(
                  itemCount: _audioFiles.length,
                  itemBuilder: (context, index) {
                    return AudioItemWidget(
                      file: _audioFiles[index],
                      player: _players[index],
                      duration: _durations[index],
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
