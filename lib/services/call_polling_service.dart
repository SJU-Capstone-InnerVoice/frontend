import 'dart:async';

class CallPollingService {
  final Duration interval;
  Timer? _timer;

  CallPollingService({this.interval = const Duration(seconds: 10)});

  /// 폴링 시작
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      await _poll();
    });
    print('📞 CallPollingService started');
  }

  /// 폴링 종료
  void stop() {
    _timer?.cancel();
    _timer = null;
    print('📴 CallPollingService stopped');
  }

  /// 내부 polling 로직
  Future<void> _poll() async {
    print('🔄 Checking for call requests...');
    await _fetchCallRequests();
    await _updateCallStatus();
  }

  /// 실제 통화 요청 목록을 서버에서 가져오기 (예: REST, Firebase 등)
  Future<void> _fetchCallRequests() async {
    // TODO: API 또는 소켓을 통해 통화 요청 데이터 가져오기
    print('📥 Fetching new call requests...');
  }

  /// 상태 갱신 (예: 수락 여부, 응답 상태 등 업데이트)
  Future<void> _updateCallStatus() async {
    // TODO: 상태 확인 및 변경 요청 전송 등
    print('🔧 Updating call status...');
  }

  /// 폴링이 동작 중인지 확인
  bool get isRunning => _timer != null;
}