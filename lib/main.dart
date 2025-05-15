import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/routes/iv_router.dart';
import 'package:provider/provider.dart';
import 'injection.dart';
import 'core/theme/iv_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

Future<void> requestMicPermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    await Permission.microphone.request();
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // server endpoint address
  await initializeDateFormatting('ko_KR', null);
  await requestMicPermission();

  // 인터넷 체크
  final result = await Connectivity().checkConnectivity();
  final hasInternet = result != ConnectivityResult.none;

  if (!hasInternet) {
    runApp(NoInternetApp());
  } else {
    runApp(
      MultiProvider(
        providers: providers,
        child: InnerVoiceApp(),
      ),
    );  }

}
class NoInternetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: IVTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '인터넷 연결이 필요해요!',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    exit(0); // 사용자가 직접 종료
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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