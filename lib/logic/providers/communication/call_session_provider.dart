import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../services/web_rtc_service.dart';

class CallSessionProvider with ChangeNotifier {
  final WebRTCService _rtcService = WebRTCService();
  final List<String> _messages = [];

  WebRTCService get rtcService => _rtcService;

  bool _isCaller = false;

  bool get isCaller => _isCaller;
  List<String> get messages => List.unmodifiable(_messages);
  ValueNotifier<MediaStream?> get remoteStreamNotifier =>
      _rtcService.remoteStreamNotifier;

  void init({
    required bool isCaller,
    required int roomId,
    required Function(String) onMessage,
    required VoidCallback onRemoteDisconnected,
  }) async {
    _isCaller = isCaller;
    await _rtcService.init(
      isCaller: isCaller,
      roomId: roomId,
      onMessage: (msg) => onMessage(msg),
      onDisconnected: onRemoteDisconnected,
    );
    notifyListeners();
  }

  void disposeCall() {
    _rtcService.dispose();
  }

  void addMessage(String message) {
    _messages.add(message);
    print(_messages);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    print(_messages);
    notifyListeners();
  }
}
