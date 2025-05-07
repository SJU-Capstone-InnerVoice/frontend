import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/routes/iv_router.dart';
import 'package:provider/provider.dart';
import 'injection.dart';
import 'package:audio_session/audio_session.dart';


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
      title: 'Inner Voice',
      routerConfig: IVRouter,
    );
  }
}
//

//
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:dio/dio.dart';
// import 'package:audio_session/audio_session.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TTS 단독 테스트',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const TtsTestScreen(),
//     );
//   }
// }
//
// class ByteStreamSource extends StreamAudioSource {
//   final List<int> data;
//
//   ByteStreamSource(this.data);
//
//   @override
//   Future<StreamAudioResponse> request([int? start, int? end]) async {
//     start ??= 0;
//     end ??= data.length;
//     return StreamAudioResponse(
//       sourceLength: data.length,
//       contentLength: end - start,
//       offset: start,
//       stream: Stream.value(data.sublist(start, end)),
//       contentType: 'audio/wav',
//     );
//   }
// }
//
// class TtsTestScreen extends StatefulWidget {
//   const TtsTestScreen({super.key});
//
//   @override
//   State<TtsTestScreen> createState() => _TtsTestScreenState();
// }
//
// class _TtsTestScreenState extends State<TtsTestScreen> {
//   final Dio _dio = Dio();
//   AudioPlayer? _player;
//
//   @override
//   void initState() {
//     super.initState();
//     _configureAudioSession();
//   }
//
//   Future<void> _configureAudioSession() async {
//     final session = await AudioSession.instance;
//     await session.configure(AudioSessionConfiguration(
//       avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
//       avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
//       avAudioSessionMode: AVAudioSessionMode.voiceChat,
//     ));
//     await session.setActive(true);
//   }
//
//   Future<void> _speak(String text, String characterId) async {
//     try {
//       final response = await _dio.post(
//         'http://118.32.168.245:3001/tts',
//         data: {'text': text, 'characterId': characterId},
//         options: Options(responseType: ResponseType.bytes),
//       );
//
//       final audioBytes = response.data;
//
//       // 🔁 이전 플레이어 정리
//       await _player?.stop();
//       await _player?.dispose();
//
//       _player = AudioPlayer(handleAudioSessionActivation: false);
//       await _player!.setAudioSource(ByteStreamSource(audioBytes));
//       await _player!.setVolume(1.0);
//       await _player!.play();
//     } catch (e) {
//       print('❌ TTS 요청 실패: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _player?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const testText = '안녕하세요. 테스트 중입니다.';
//     const characterId = 'char001';
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('TTS 테스트')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => _speak(testText, characterId),
//           child: const Text('TTS 재생'),
//         ),
//       ),
//     );
//   }
// }