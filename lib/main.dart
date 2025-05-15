import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/routes/iv_router.dart';
import 'package:provider/provider.dart';
import 'injection.dart';
import 'core/theme/iv_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';


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