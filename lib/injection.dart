import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'logic/providers/communication/call_polling_provider.dart';

/// provider, bloc 등 상태 관리 추가
final List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => CallPollingProvider()),
];