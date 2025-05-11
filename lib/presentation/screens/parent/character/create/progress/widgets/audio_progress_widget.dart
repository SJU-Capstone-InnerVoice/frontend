import 'package:flutter/material.dart';

class AudioProgressWidget extends StatelessWidget {
  final int audioCount;
  final int totalSeconds;
  final int goalSeconds;
  final double progress;

  const AudioProgressWidget({
    super.key,
    required this.audioCount,
    required this.totalSeconds,
    required this.goalSeconds,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = totalSeconds >= goalSeconds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$audioCount개',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '$totalSeconds s / $goalSeconds s',
              style: TextStyle(
                fontSize: 14,
                color: isCompleted ? Colors.green : Colors.red,
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
            color: isCompleted ? Colors.orangeAccent : Colors.orangeAccent,
          ),
        ),
      ],
    );
  }
}