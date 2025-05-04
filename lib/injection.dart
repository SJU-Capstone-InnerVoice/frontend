import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'logic/providers/communication/call_polling_provider.dart';
import 'logic/providers/communication/call_session_provider.dart';
import 'logic/providers/character/character_img_provider.dart';
import 'logic/providers/network/dio_provider.dart';
import 'logic/providers/record/call_record_provider.dart';

/// provider, bloc 등 상태 관리 추가
final List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => CallPollingProvider()),
  ChangeNotifierProvider(create: (_) => CallSessionProvider()),
  ChangeNotifierProvider(create: (_) => CallRecordProvider()),
  ChangeNotifierProvider(create: (_) => DioProvider()),

  // CharacterImgProvider는 DioProvider를 사용해야 해서 의존성 주입
  ChangeNotifierProxyProvider<DioProvider, CharacterImgProvider>(
    // create는 구조상 생성이 필요해서 만들어진 것이고,
    // update는 의존하고 있는 게 바뀔 때 계속해주어야 하기 때문
    create: (_) => CharacterImgProvider(Dio()),
    update: (_, dioProvider, __) => CharacterImgProvider(dioProvider.dio),
  ),
];

