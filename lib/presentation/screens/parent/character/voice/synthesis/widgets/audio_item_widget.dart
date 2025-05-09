import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:intl/intl.dart';

class AudioItemWidget extends StatelessWidget {
  final File file;
  final AudioPlayer player;
  final Duration? duration;

  const AudioItemWidget({
    super.key,
    required this.file,
    required this.player,
    required this.duration,
  });

  String formatDuration(Duration? duration) {
    if (duration == null) return "--:--";
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return NumberFormat('00').format(minutes) + ":" + NumberFormat('00').format(seconds);
  }

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split('/').last;

    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final current = snapshot.data ?? Duration.zero;
        final total = duration ?? Duration.zero;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Slider(
                    min: 0,
                    max: total.inMilliseconds.toDouble(),
                    value: current.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
                    onChanged: (value) {
                      player.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(current),
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_5, size: 24),
                            onPressed: () {
                              final back = player.position - const Duration(seconds: 5);
                              player.seek(back > Duration.zero ? back : Duration.zero);
                            },
                          ),
                          StreamBuilder<PlayerState>(
                            stream: player.playerStateStream,
                            builder: (context, snapshot) {
                              final isPlaying = snapshot.data?.playing ?? false;
                              return IconButton(
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 30,
                                ),
                                onPressed: () {
                                  isPlaying ? player.pause() : player.play();
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.forward_5, size: 24),
                            onPressed: () {
                              final forward = player.position + const Duration(seconds: 5);
                              player.seek(forward < total ? forward : total);
                            },
                          ),
                        ],
                      ),
                      Text(
                        formatDuration(total),
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}