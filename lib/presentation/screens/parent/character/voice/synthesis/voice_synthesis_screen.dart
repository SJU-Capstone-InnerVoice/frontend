import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'widgets/audio_item_widget.dart';
import 'widgets/recording_bottom_sheet.dart';
import 'package:another_flushbar/flushbar.dart';

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

  void addRecordedAudio(File file, AudioPlayer player, Duration duration) {
    setState(() {
      _audioFiles.add(file);
      _players.add(player);
      _durations.add(duration);
    });
  }

  void _showRecordingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return RecordingBottomSheet(
          onRecordingComplete: (File file, Duration duration) async {
            final player = AudioPlayer();
            await player.setFilePath(file.path);
            addRecordedAudio(file, player, duration);
          },
        );
      },
    );
  }

  void _showDeleteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 700,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '삭제할 음성을 선택하세요',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _audioFiles.length,
                      itemBuilder: (context, index) {
                        final fileName =
                            _audioFiles[index].path.split('/').last;
                        return ListTile(
                          title:
                              Text(fileName, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setModalState(() {
                                removeAudio(index);
                              });
                              Flushbar(
                                message: "${fileName}이 삭제되었습니다.",
                                flushbarPosition: FlushbarPosition.TOP,
                                flushbarStyle: FlushbarStyle.FLOATING,
                                duration: const Duration(milliseconds: 1500),
                                animationDuration:
                                    const Duration(milliseconds: 1),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                borderRadius: BorderRadius.circular(12),
                                backgroundColor: Colors.black.withAlpha(200),
                                icon: const Icon(Icons.delete,
                                    color: Colors.white),
                              ).show(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
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
    final totalDuration = _durations
        .where((d) => d != null)
        .fold(Duration.zero, (prev, d) => prev + d!);

    final totalSeconds = totalDuration.inSeconds;
    final goalSeconds = 20;
    final progress = totalSeconds / goalSeconds;
    final isReadyToSynthesize = totalSeconds >= goalSeconds;

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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, size: 32),
              tooltip: '설정',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('삭제'),
                          onTap: () => _showDeleteBottomSheet(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () => _showRecordingBottomSheet(),
              icon: const Icon(Icons.mic, size: 32),
              tooltip: '음성 녹음',
            ),
            IconButton(
              onPressed: pickAudioFile,
              icon: const Icon(Icons.upload_file, size: 32),
              tooltip: '파일 업로드',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '합쳐서 최소 40초 이상으로 음성을 녹음해주세요!',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_audioFiles.length}개',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${totalSeconds}s / ${goalSeconds}s',
                        style: TextStyle(
                          fontSize: 14,
                          color: totalSeconds >= goalSeconds
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0, 1),
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                      color: totalSeconds >= goalSeconds
                          ? Colors.redAccent
                          : Colors.orangeAccent,
                    ),
                  ),
                ],
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isReadyToSynthesize ? () {
                    // ✅ 합성 실행 로직
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isReadyToSynthesize ? Colors.orange : Colors.grey[300],
                    foregroundColor: isReadyToSynthesize ? Colors.white : Colors.grey[600],
                  ),
                  child: const Text('음성 합성 시작'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
