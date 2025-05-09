import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/child/call/start');
      }
    });
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