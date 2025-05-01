import 'package:flutter/material.dart';

class VoiceSynthesisScreen extends StatelessWidget {
  const VoiceSynthesisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Spacer(),
                    const Text(
                      '00:17',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
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