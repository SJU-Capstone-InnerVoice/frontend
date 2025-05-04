// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'presentation/routes/iv_router.dart';
// import 'package:provider/provider.dart';
// import 'injection.dart';
//
// void main() async {
//   await dotenv.load(fileName: ".env"); // server endpoint address
//   runApp(
//     MultiProvider(
//       providers: providers,
//       child: InnerVoiceApp(),
//     ),
//   );
// }
//
// class InnerVoiceApp extends StatelessWidget {
//   const InnerVoiceApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'Inner Voice',
//       routerConfig: IVRouter,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'services/call_recording_service.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recording Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RecordingTestPage(),
    );
  }
}

class RecordingTestPage extends StatefulWidget {
  const RecordingTestPage({super.key});

  @override
  State<RecordingTestPage> createState() => _RecordingTestPageState();
}

class _RecordingTestPageState extends State<RecordingTestPage> {
  final CallRecordingService _recorder = CallRecordingService();
  bool _isRecording = false;
  String? _filePath;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playRecording() async {
    if (_filePath != null) {
      try {
        await _audioPlayer.setFilePath(_filePath!);
        await _audioPlayer.play();
      } catch (e) {
        print('🎧 재생 실패: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('재생 중 오류가 발생했습니다.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('녹음된 파일이 없습니다.')),
      );
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stopRecording();
      setState(() {
        _isRecording = false;
        _filePath = path;
      });
    } else {
      await _recorder.startRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎙️ iOS Recording Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_isRecording ? '🔴 녹음 중...' : '⏹️ 정지됨'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleRecording,
              child: Text(_isRecording ? '정지' : '녹음 시작'),
            ),
            const SizedBox(height: 20),
            if (_filePath != null) ...[
              Text('파일 저장됨:\n$_filePath'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _playRecording,
                child: const Text('▶️ 재생'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}