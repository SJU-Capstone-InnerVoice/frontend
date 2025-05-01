import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/character/character_img_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';

class AddCharacterScreen extends StatefulWidget {
  const AddCharacterScreen({super.key});

  @override
  State<AddCharacterScreen> createState() => _AddCharacterScreenState();
}

class _AddCharacterScreenState extends State<AddCharacterScreen> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = _image != null;
    // 임시 설정: 서버에 이미지 업로드 테스트
    final hasVoice = true;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 사진 선택 박스
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: hasImage ? Colors.orange : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasImage)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Icon(Icons.help_outline,
                            size: 40, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        hasImage ? '사진 다시 선택하기' : '사진 선택하기',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  // 음성 합성 로직
                  context.go('/parent/character-info/add/voice-synthesis');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('음성 합성하기'),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: (hasImage && hasVoice)
                    ? () {
                        print("이미지 업로드");
                        context.read<CharacterImgProvider>().uploadImage(
                              userId: "1",
                              name: "char001",
                              type: "USER",
                              file: _image!,
                            );
                      }
                    : null,
                style: (hasImage && hasVoice)
                    ? ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[300],
                        foregroundColor: Colors.orange[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      )
                    : ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                child: const Text('현재 캐릭터로 대화방 생성'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
