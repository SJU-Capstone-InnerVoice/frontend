import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/routes/iv_router.dart';
import 'package:provider/provider.dart';
import 'injection.dart';
import 'package:audio_session/audio_session.dart';

Future<void> configureAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
    avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.defaultToSpeaker,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
  ));
  await session.setActive(true);
}

void main() async {
  await dotenv.load(fileName: ".env"); // server endpoint address
  await configureAudioSession();
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
      title: 'Inner Voice',
      routerConfig: IVRouter,
    );
  }
}
//
