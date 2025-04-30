import 'package:flutter/material.dart';

class CallStartScreen extends StatefulWidget {
  const CallStartScreen({super.key});

  @override
  State<CallStartScreen> createState() => _CallStartScreenState();
}

class _CallStartScreenState extends State<CallStartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // 🖼️ 가운데 랜덤 이미지
            Center(
              child: Container(
                width: 220,
                height: 304,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://picsum.photos/200/305',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const Spacer(),

            // 🔴 전화 끊기 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: IconButton(
                icon: const Icon(Icons.call_end, color: Colors.white),
                iconSize: 48,
                onPressed: () {
                  Navigator.pop(context);
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}