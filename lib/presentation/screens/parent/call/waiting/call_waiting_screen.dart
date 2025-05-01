import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../services/call_polling_service.dart';

class CallWaitingScreen extends StatefulWidget {
  const CallWaitingScreen({super.key});

  @override
  State<CallWaitingScreen> createState() => _CallWaitingScreenState();
}

class _CallWaitingScreenState extends State<CallWaitingScreen> {
  final CallPollingService _pollingService = CallPollingService(
    characterId: 'char1',
    roomId: 'roomA',
    parentId: 'parent001',
    childId: 'child001',
  );

  Timer? _pollingTimer;
  Timer? _dotTimer;
  String _dots = '';
  final List<String> _dotStates = ['', '.', '..', '...'];
  int _dotIndex = 0;

  @override
  void initState() {
    super.initState();
    _startPolling();
    _startDotAnimation();

  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final result = await _pollingService.pollCallRequests();

      if (result.any((e) => e['status'] == 'accepted')) {
        _pollingTimer?.cancel();
        _dotTimer?.cancel();
        if (context.mounted) {
          context.go('/parent/call/start');
          await _pollingService.deleteCallRequest();
        }
      }
    });
  }

  void _startDotAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      setState(() {
        _dotIndex = (_dotIndex + 1) % _dotStates.length;
        _dots = _dotStates[_dotIndex];
      });
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _dotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대기 중'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: ()  async {
            await _pollingService.deleteCallRequest();
            context.pop();
          },
        ),
      ),
      body: Center(
        child: Text(
          '아이가 응답을 기다리는 중입니다$_dots',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
