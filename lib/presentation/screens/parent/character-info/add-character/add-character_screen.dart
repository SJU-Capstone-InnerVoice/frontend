import 'package:flutter/material.dart';

class AddCharacterScreen extends StatefulWidget {
  const AddCharacterScreen({super.key});

  @override
  State<AddCharacterScreen> createState() => _AddCharacterScreenState();
}

class _AddCharacterScreenState extends State<AddCharacterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 사진 선택 박스
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.help_outline, size: 40, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        '사진 선택하기',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 음성 합성하기 버튼
              ElevatedButton(
                onPressed: () {
                  // 음성 합성 로직
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('음성 합성하기'),
              ),

              const Spacer(),

              // 비활성화된 버튼
              ElevatedButton(
                onPressed: null, // 비활성화 상태
                style: ElevatedButton.styleFrom(
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
