import 'package:flutter/material.dart';
import '../../../services/web_rtc_service.dart';

class CallSessionProvider with ChangeNotifier {
  final WebRTCService _rtcService = WebRTCService();

  WebRTCService get rtcService => _rtcService;

  bool _isCaller = false;
  bool get isCaller => _isCaller;

  void init({required bool isCaller, required int roomId, required Function(String) onMessage}) async {
    _isCaller = isCaller;
    await _rtcService.init(
      isCaller: isCaller,
      roomId: roomId,
      onMessage: (msg) => onMessage(msg),
    );
    notifyListeners();
  }

  void disposeCall() {
    _rtcService.dispose();
    notifyListeners();
  }
}