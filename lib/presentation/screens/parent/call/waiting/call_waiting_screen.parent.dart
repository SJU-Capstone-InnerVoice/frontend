import 'dart:async';
import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inner_voice/presentation/widgets/show_flushbar.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../logic/providers/communication/call_request_provider.dart';

class CallWaitingScreen extends StatefulWidget {
  const CallWaitingScreen({super.key});

  @override
  State<CallWaitingScreen> createState() => _CallWaitingScreenState();
}

class _CallWaitingScreenState extends State<CallWaitingScreen> {
  late final Dio _dio;
  late final CallRequestProvider _callRequest;

  String _currentMessage = '아이의 연결을 기다리고 있어요!';
  Timer? _pollingTimer;
  Timer? _dotTimer;
  String _dots = '';
  final List<String> _dotStates = ['', '.', '..', '...'];
  int _dotIndex = 0;
  List<double> _dotOpacities = [0.0, 0.0, 0.0];
  Timer? _fadeTimer;
  @override
  void initState() {
    super.initState();

    _callRequest = context.read<CallRequestProvider>();
    _startPolling();
    _startDotAnimation();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final result = await _callRequest.query();

      if (result != null && result['isAccepted'] == true) {
        _pollingTimer?.cancel();
        _dotTimer?.cancel();
        if (context.mounted) {
          await _callRequest.delete();

          context.go('/parent/call/start');
        }
      }
    });
  }

  void _startDotAnimation() {
    int currentIndex = 0;
    bool ascending = true;
    bool waitAtZero = false;

    _fadeTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      setState(() {
        _dotOpacities = [0.0, 0.0, 0.0];
        for (int i = 0; i < currentIndex; i++) {
          _dotOpacities[i] = 1.0;
        }

        if (ascending) {
          currentIndex++;
          if (currentIndex > 3) {
            currentIndex = 2;
            ascending = false;
          }
        } else {
          if (currentIndex == 0) {
            if (waitAtZero) {
              currentIndex = 1;
              ascending = true;
              waitAtZero = false;
            } else {
              // 첫 0에서 멈춤
              waitAtZero = true;
            }
          } else {
            currentIndex--;
          }
        }
      });
    });
  }
  @override
  void dispose() {
    _pollingTimer?.cancel();
    _dotTimer?.cancel();
    _fadeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대기 중'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            setState(() {
              _currentMessage = '잠시만 기다려주세요!';
            });

            await _callRequest.delete();
            showIVFlushbar(
              context,
              '⏳ 잠시만 기다려주세요...',
              position: FlushbarPosition.BOTTOM,
              icon: const Icon(Icons.hourglass_top, color: Colors.white),
            );
            await Future.delayed(const Duration(milliseconds: 2000));
            context.pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return AnimatedOpacity(
                  opacity: _dotOpacities[i],
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '.',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      color: Colors.orange,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
