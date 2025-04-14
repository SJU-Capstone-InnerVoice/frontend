import 'package:flutter/material.dart';
import 'presentation/routes/router.dart';

void main() {
  runApp(
    InnerVoiceApp(),
  );
}

class InnerVoiceApp extends StatelessWidget {
  const InnerVoiceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Inner Voice',
      routerConfig: IVRouter,
    );
  }
}