import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class ModeScreen extends StatelessWidget {
  const ModeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "버전을 선택하세요.",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeButton(context, "아이"),
                    const SizedBox(height: 24), // space between buttons
                    _buildModeButton(context, "부모"),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(BuildContext context, String label) {
    return SizedBox(
      width: 120,
      height: 120,
      child: ElevatedButton(
        onPressed: () {
          if (label == "아이") {
            context.go('/child');
          } else if (label == "부모") {
            context.go('/parent');
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.black,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}