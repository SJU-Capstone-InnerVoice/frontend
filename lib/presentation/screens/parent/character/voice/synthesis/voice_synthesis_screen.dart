import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';

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

  String formatDuration(Duration? duration) {
    if (duration == null) return "--:--";
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return NumberFormat('00').format(minutes) + ":" + NumberFormat('00').format(seconds);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '음성 합성하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                '모두 합쳐서 최소 40초 이상으로 음성을 녹음해주세요',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 오디오 리스트
              Expanded(
                child: ListView.builder(
                  itemCount: _audioFiles.length,
                  itemBuilder: (context, index) {
                    return _buildAudioItem(index); // 수정된 buildAudioItem 호출
                  },
                ),
              ),
              // 파일 업로드 버튼
              ElevatedButton.icon(
                onPressed: pickAudioFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('음성 파일 업로드'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
              const SizedBox(height: 16),

              // 하단 버튼
              Row(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioItem(int index) {
    final player = _players[index];
    final fileName = _audioFiles[index].path.split('/').last;
    final duration = _durations[index] ?? Duration.zero;

    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final current = snapshot.data ?? Duration.zero;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(fileName,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),

              Slider(
                min: 0,
                max: duration.inMilliseconds.toDouble(),
                value: current.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                onChanged: (value) {
                  player.seek(Duration(milliseconds: value.toInt()));
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(current),
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  Text(formatDuration(duration),
                      style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_5),
                    onPressed: () {
                      final back = player.position - const Duration(seconds: 5);
                      player.seek(back > Duration.zero ? back : Duration.zero);
                    },
                  ),
                  StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data?.playing ?? false;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          isPlaying ? player.pause() : player.play();
                        },
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_5),
                    onPressed: () {
                      final forward = player.position + const Duration(seconds: 5);
                      player.seek(forward < duration ? forward : duration);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
