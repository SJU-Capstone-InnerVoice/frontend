import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/routes/iv_router.dart';

void main() async {
  await dotenv.load(fileName: ".env");

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