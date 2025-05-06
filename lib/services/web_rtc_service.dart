import 'dart:convert';
import 'dart:ui';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api/socket_api.dart';


typedef OnMessageReceived = void Function(String message);

class WebRTCService {
  final List<RTCIceCandidate> _pendingCandidates = [];

  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCDataChannel? _dataChannel;
  WebSocketChannel? _channel;

  bool _isCaller = false;
  bool _hasConnected = false;


  VoidCallback? onRemoteDisconnected;

  late int _roomId;
  late OnMessageReceived onMessageReceived; // callback

  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;
  bool get initialized =>
      remoteRenderer.textureId != null && localRenderer.textureId != null;
  final ValueNotifier<MediaStream?> remoteStreamNotifier = ValueNotifier(null);


  Future<void> init(
      {required bool isCaller,
      required int roomId,
      required OnMessageReceived onMessage,
      required VoidCallback onDisconnected,
      }) async {
    _isCaller = isCaller;
    _roomId = roomId;
    onMessageReceived = onMessage;
    onRemoteDisconnected = onDisconnected;
    _remoteRenderer = RTCVideoRenderer();
    await remoteRenderer.initialize();

    _localRenderer = RTCVideoRenderer();
    await localRenderer.initialize();

    await _startLocalStream();
    await _connectWebSocket();
  }

  /// 디바이스 내부의 카메라 및 마이크 Stream을 localRenderer에 연결
  Future<void> _startLocalStream() async {
    late final constraints;

    constraints = {
      'audio': true, // 마이크 on
      'video': {'facingMode': 'user'}, //  전면 카메라 영상
    };

    // 기기의 localStream에 미디어 설정
    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    // 스피커 루프백 방지
    if (_isCaller) {
      // _localStream!.getAudioTracks().forEach((t) => t.enabled = false);
    }
    print("🎥 Local stream obtained: ${_localStream?.id}");
    // localRenderer에 위에서 설정한 조건을 등록
    _localRenderer.srcObject = _localStream;
    print("✅ localRenderer connected to stream.");
  }

  /// WebSocket 연결
  Future<void> _connectWebSocket() async {
    print('🌐 WebSocket 연결 시도 중...');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(SocketAPI.socketUrl));
      print('✅ WebSocket 연결 성공');

      // 방 입장 메시지 전송
      _channel!.sink.add(jsonEncode({
        'type': 'join',
        'roomId': _roomId,
      }));
      print('📨 join 메시지 전송 완료: room=$_roomId');

      // WebSocket으로 들어오는 메시지 구독
      _channel!.stream.listen((message) async {
        print('📩 수신 메시지: $message');

        try {
          final data = jsonDecode(message);
          print('⚠️ 데이터 내용: $data');
          switch (data['type']) {
            case 'new_peer':
              print('🧑‍🤝‍🧑 new_peer 수신');
              _isCaller = true;
              await _createPeerConnection();
              await _createOffer();
              break;
            case 'offer':
              print('📜 offer 수신');
              await _createPeerConnection();
              await _handleOffer(data['sdp']);
              break;
            case 'answer':
              print('📜 answer 수신');
              await _handleAnswer(data['sdp']);
              break;
            case 'candidate':
              print('🧊 candidate 수신');
              await _handleCandidate(data['candidate']);
              break;
            default:
              print('⚠️ 알 수 없는 메시지 타입: ${data['type']}');
          }
        } catch (e) {
          print("❌ WebSocket message parsing error: $e");
        }
      }, onError: (error) {
        print('❌ WebSocket 오류 발생: $error');
      }, onDone: () {
        print('🛑 WebSocket 연결 종료됨');
      });

    } catch (e) {
      print('❌ WebSocket 연결 실패: $e');
    }
  }
  /// P2P 연결을 위한 초기화:
  /// STUN 연결
  /// DataStream 설정
  /// Track 설정
  /// IceCandidate 설정
  Future<void> _createPeerConnection() async {
    /// 1. STUN 연결
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': SocketAPI.stun}
      ]
    });

    /// 2. DataStream 등록
    /// Caller가 채널을 먼저 만든다
    if (_isCaller) {
      // data channel 생성
      _dataChannel = await _peerConnection!
          .createDataChannel('chat', RTCDataChannelInit());
      // WebRTC의 data channel에 등록
      _setupDataChannel(_dataChannel!);
    }

    /// Callee가 메시지를 받을 수 있도록 callback 등록
    _peerConnection!.onDataChannel = (channel) {
      _dataChannel = channel; // P2P로부터 들어오는 channel을 등록
      _setupDataChannel(channel); // WebRTC의 data channel에 등록
    };

    /// 3. Track
    /// localStream에 담긴 Track들을 모두 PeerConnection에 등록 (Audio, Media)
    /// 그리고 상대에게 보내짐
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      if (_isCaller) {
        for (final track in _localStream!.getAudioTracks()) {
          track.enabled = false;
          print("track.enabled: ${track.enabled}, kind: ${track.kind}");
        }
      }
    }

    /// 상대방이 addTrack을 통해 Track을 보낸 것이 내 PeerConnection에 도착했을 때,
    /// 그것을 remoteRenderer의 오브젝트로 등록을 해주는 작업
    /// 이를 통해 상대방 렌더링이 가능해진다.
    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject =
            event.streams[0]; // [0]은 영상, 음성 이 모두 포함되어 있음.
        remoteStreamNotifier.value = event.streams[0];
      }
    };

    /// 4. IceCandidate 설정
    /// candidate를 찾았으면 callback을 등록해주는데,
    /// socket에 candidate 정보를 상대방에게 송신하는 작업
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _channel?.sink.add(jsonEncode({
          'type': 'candidate',
          'candidate': candidate.toMap(),
          'roomId': _roomId,
        }));
      }
    };

    _peerConnection!.onConnectionState = (state) {
      print('🔌 연결 상태: $state');

      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _hasConnected = true;
      }

      if (_hasConnected &&
          (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
              state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
              state == RTCPeerConnectionState.RTCPeerConnectionStateClosed)) {
        print('💥 상대방 연결 끊김 감지됨!');
        onRemoteDisconnected?.call();
      }
    };
  }

  /// SDP 교환 1단계 : Offer 생성
  Future<void> _createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    print('_createOffer: $_roomId');
    _channel?.sink.add(jsonEncode({
      'type': 'offer',
      'sdp': offer.sdp,
      'roomId': _roomId,
    }));
  }

  /// SDP 교환 2단계 : 받은 Offer 등록 후 Answer 생성
  Future<void> _handleOffer(String sdp) async {
    await _peerConnection!
        .setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    for (final c in _pendingCandidates) {
      try {
        await _peerConnection!.addCandidate(c);
      } catch (e) {
        print("❌ 지연된 Candidate 추가 실패: $e");
      }
    }
    _pendingCandidates.clear();

    print('_handleOffer: $_roomId');
    _channel?.sink.add(jsonEncode({
      'type': 'answer',
      'sdp': answer.sdp,
      'roomId': _roomId,
    }));
  }

  /// SDP 교환 3단계 : 받은 Answer 등록
  Future<void> _handleAnswer(String sdp) async {
    await _peerConnection!
        .setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
    print('_handleAnswer: $_roomId');

  }

  /// SDP 교환 4단계 : 양측에 candidate 등록
  Future<void> _handleCandidate(Map<String, dynamic> data) async {
    if (_peerConnection == null) return;
    if (_peerConnection!.getRemoteDescription == null) {
      print("❌ Remote Description이 설정되지 않음. ICE Candidate 대기 중...");
      return;
    }

    final candidate = RTCIceCandidate(
      data['candidate'],
      data['sdpMid'],
      data['sdpMLineIndex'],
    );

    if (_peerConnection == null) {
      print("❌ PeerConnection이 아직 없음. Candidate 보류.");
      _pendingCandidates.add(candidate);
      return;
    }

    final remoteDesc = await _peerConnection!.getRemoteDescription();

    if (remoteDesc == null) {
      print("❌ Remote Description이 아직 없음. Candidate 보류.");
      _pendingCandidates.add(candidate);
      return;
    }

    try {
      await _peerConnection!.addCandidate(candidate);
      print("✅ ICE Candidate 추가 성공!");
    } catch (e) {
      print("❌ ICE Candidate 추가 실패: $e");
    }
  }

  /// DataChannel 설정
  void _setupDataChannel(RTCDataChannel channel) {
    // callback 등록
    // onMessage가 callback인데 onMessageReceived도 callback
    // 그러면 이 DataChannel 객체에 .text에 문자열이 들어있다.
    // 그 텍스트를 다시 callback에 넣어서 호출될 수 있도록 해준다.
    channel.onMessage = (message) {
      onMessageReceived(message.text);
    };
  }

  /// DataChannel로 메시지 전송
  void sendChatMessage(String text) {
    _dataChannel?.send(RTCDataChannelMessage(text));
    // 본인이 보낸 메시지도 본인이 볼 수 있도록 해준다.
    onMessageReceived("나: $text");
  }

  void dispose() {
    try {
      _channel?.sink.add(jsonEncode({'type': 'leave', 'room': _roomId}));
      _channel?.sink.close();
    } catch (_) {}
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
  }
}
