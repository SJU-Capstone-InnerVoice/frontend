import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/routes/iv_router.dart';
import 'package:provider/provider.dart';
import 'injection.dart';
import 'package:audio_session/audio_session.dart';
import 'core/theme/iv_theme.dart';


Future<void> setupAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration.speech());
}
void main() async {
  await dotenv.load(fileName: ".env"); // server endpoint address
  await setupAudioSession();
  runApp(
    MultiProvider(
      providers: providers,
      child: InnerVoiceApp(),
    ),
  );
}

class InnerVoiceApp extends StatelessWidget {
  const InnerVoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: IVTheme.lightTheme,
      title: 'Inner Voice',
      routerConfig: IVRouter,
    );
  }
}