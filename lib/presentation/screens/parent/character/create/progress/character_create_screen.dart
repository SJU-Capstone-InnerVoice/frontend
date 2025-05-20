import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/data/models/user/user_model.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:inner_voice/presentation/screens/parent/character/create/progress/widgets/audio_progress_widget.dart';
import 'package:inner_voice/presentation/screens/parent/character/create/progress/widgets/image_pick_box.dart';
import 'package:inner_voice/presentation/screens/parent/character/create/progress/widgets/section_title.dart';
import 'package:just_audio/just_audio.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inner_voice/logic/providers/character/character_img_provider.dart';
import 'package:provider/provider.dart';

import 'widgets/audio_item_widget.dart';
import 'widgets/recording_bottom_sheet.dart';

class VoiceSynthesisScreen extends StatefulWidget {
  const VoiceSynthesisScreen({super.key});

  @override
  State<VoiceSynthesisScreen> createState() => _VoiceSynthesisScreenState();
}

class _VoiceSynthesisScreenState extends State<VoiceSynthesisScreen> {
  /// 🎯 Controller
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// 🎧 Audio 관련 상태
  final List<File> _audioFiles = [];
  final List<AudioPlayer> _players = [];
  final List<Duration?> _durations = [];

  /// 🖼 이미지 상태
  File? _image;

  /// 변수
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user!;

    final hasImage = _image != null;
    final hasVoice = true;
    final hasName = _nameController.text.trim().isNotEmpty;

    final totalDuration = _durations
        .where((d) => d != null)
        .fold(Duration.zero, (prev, d) => prev + d!);

    final totalSeconds = totalDuration.inSeconds;
    const goalSeconds = 20;
    final progress = totalSeconds / goalSeconds;
    final isReadyToSynthesize = totalSeconds >= goalSeconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터 생성'),
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
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 75),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionTitle("캐릭터 사진"),
                // 사진 선택 박스
                ImagePickerBox(
                  hasImage: _image != null,
                  imageFile: _image,
                  onTap: _pickImage,
                ),
                const SizedBox(height: 24),
                const SectionTitle("캐릭터 이름"),
                // 이름 입력 필드
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: '6자 이내로 입력해주세요.',
                    border: OutlineInputBorder(),
                  ),
                  onTap: () {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                const SectionTitle("음성 등록"),

                const Text(
                  '합쳐서 최소 ${goalSeconds}초 이상으로 음성을 녹음해주세요!',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.start,
                ),
                const Text(
                  '하단의 마이크, 업로드 버튼을 통해 음성을 등록할 수 있습니다!',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 20),

                /// 오디오 음성 길이 및 개수
                AudioProgressWidget(
                  audioCount: _audioFiles.length,
                  totalSeconds: totalSeconds,
                  goalSeconds: goalSeconds,
                  progress: progress,
                ),
                const SizedBox(height: 24),

                /// 오디오 리스트
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _audioFiles.length,
                  itemBuilder: (context, index) {
                    return AudioItemWidget(
                      file: _audioFiles[index],
                      player: _players[index],
                      duration: _durations[index],
                    );
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (!_isUploading &&
                            isReadyToSynthesize &&
                                hasImage &&
                                hasVoice &&
                                hasName)
                        ? () async {
                            setState(() {
                              _isUploading = true;
                            });

                            print("이미지 업로드");
                            try {
                              await context
                                  .read<CharacterImgProvider>()
                                  .uploadImage(
                                    userId: user.userId,
                                    name: _nameController.text.trim(),
                                    type: "USER",
                                    file: _image!,
                                  );
                              await context
                                  .read<CharacterImgProvider>()
                                  .loadImagesFromServer(user.userId);
                              if (context.mounted) {
                                context.push(
                                  '/parent/character/create/result',
                                  extra:
                                      _audioFiles.map((f) => f.path).toList(),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isUploading = false;
                                });
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isReadyToSynthesize
                          ? Colors.orange
                          : Colors.grey[300],
                      foregroundColor:
                          isReadyToSynthesize ? Colors.white : Colors.grey[600],
                    ),
                    child: _isUploading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('캐릭터 생성'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

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
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
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
            Future.delayed(const Duration(milliseconds: 100), () {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
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
    _nameController.dispose();
    super.dispose();
  }
}
