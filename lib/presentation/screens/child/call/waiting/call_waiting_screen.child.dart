import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/character/character_img_provider.dart';
import 'package:inner_voice/logic/providers/communication/call_request_provider.dart';
import 'package:lottie/lottie.dart';

class CallWaitingScreen extends StatefulWidget {
  const CallWaitingScreen({super.key});

  @override
  State<CallWaitingScreen> createState() => _CallWaitingScreenState();
}

class _CallWaitingScreenState extends State<CallWaitingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final parentId = context.read<CallRequestProvider>().parentId.toString();

    await context
        .read<CharacterImgProvider>()
        .loadImagesFromServer(parentId)
        .catchError((e) {
      print("❌ 이미지 불러오기 실패: $e");
    });
    print("parentID: 123" + parentId);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      context.go('/child/call/start');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Lottie.asset(
            'assets/animations/loading_elephant.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
