import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/api/socket_api.dart';

typedef OnMessageReceived = void Function(String message);

class WebRTCService {
  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCDataChannel? _dataChannel;
  WebSocketChannel? _channel;

  bool _isCaller = false;
  late String _roomId;
  late OnMessageReceived onMessageReceived; // callback

  RTCVideoRenderer get localRenderer => _localRenderer;

  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> init(
      {required bool isCaller,
      required String roomId,
      required OnMessageReceived onMessage}) async {
    _isCaller = isCaller;
    _roomId = roomId;
    onMessageReceived = onMessage;

    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    await _startLocalStream();
    await _connectWebSocket();
  }

  /// 디바이스 내부의 카메라 및 마이크 Stream을 localRenderer에 연결
  Future<void> _startLocalStream() async {
    final constraints = {
      'audio': true, // 마이크 on
      'video': {'facingMode': 'user'}, //  전면 카메라 영상
    };

    // 기기의 localStream에 미디어 설정
    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    // localRenderer에 위에서 설정한 조건을 등록
    _localRenderer.srcObject = _localStream;
  }

  /// WebSocket 연결
  Future<void> _connectWebSocket() async {
    // socket server 연결
    _channel = WebSocketChannel.connect(Uri.parse(SocketAPI.baseUrl));
    // room을 생성하거나 가입
    _channel!.sink.add(jsonEncode({'type': 'join', 'room': _roomId}));

    // 내 기기에서 스트림으로 들어오는 이벤트를 구독 (계속적)
    _channel!.stream.listen((message) async {
      // callback, message를 인자로 받아서 실행
      final data = jsonDecode(message);

      // switch문이지만 서로 양방향으로 순차적이게 이루어지는 구조
      switch (data['type']) {
        case 'new_peer': // 1
          _isCaller = true;
          await _createPeerConnection();
          await _createOffer();
          break;
        case 'offer': // 2
          await _createPeerConnection();
          await _handleOffer(data['sdp']);
          break;
        case 'answer': // 3
          await _handleAnswer(data['sdp']);
          break;
        case 'candidate': // 4
          await _handleCandidate(data['candidate']);
          break;
      }
    });
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
    if (!_isCaller) {
      _peerConnection!.onDataChannel = (channel) {
        _dataChannel = channel; // P2P로부터 들어오는 channel을 등록
        _setupDataChannel(channel); // WebRTC의 data channel에 등록
      };
    }

    /// 3. Track
    /// localStream에 담긴 Track들을 모두 PeerConnection에 등록 (Audio, Media)
    /// 그리고 상대에게 보내짐
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    /// 상대방이 addTrack을 통해 Track을 보낸 것이 내 PeerConnection에 도착했을 때,
    /// 그것을 remoteRenderer의 오브젝트로 등록을 해주는 작업
    /// 이를 통해 상대방 렌더링이 가능해진다.
    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject =
            event.streams[0]; // [0]은 영상, 음성 이 모두 포함되어 있음.
      }
    };

    /// 4. IceCandidate 설정
    /// candidate를 찾았으면 callback을 등록해주는데,
    /// socket에 candidate 정보를 상대방에게 송신하는 작업
    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        _channel?.sink.add(jsonEncode({
          'type': 'candidate',
          'cadidate': candidate.toMap(),
          'room': _roomId,
        }));
      }
    };
  }

  /// SDP 교환 1단계 : Offer 생성
  Future<void> _createOffer() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    _channel?.sink.add(jsonEncode({
      'type': 'offer',
      'sdp': offer.sdp,
      'room': _roomId,
    }));
  }

  /// SDP 교환 2단계 : 받은 Offer 등록 후 Answer 생성
  Future<void> _handleOffer(String sdp) async {
    await _peerConnection!
        .setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    _channel?.sink.add(jsonEncode({
      'type': 'answer',
      'sdp': answer.sdp,
      'room': _roomId,
    }));
  }

  /// SDP 교환 3단계 : 받은 Answer 등록
  Future<void> _handleAnswer(String sdp) async {
    await _peerConnection!
        .setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
  }

  /// SDP 교환 4단계 : 양측에 candidate 등록
  Future<void> _handleCandidate(Map<String, dynamic> data) async {
    final candidate = RTCIceCandidate(
        data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
    await _peerConnection!.addCandidate(candidate);
  }

  /// DataChannel 설정
  void _setupDataChannel(RTCDataChannel channel) {
    // callback 등록
    // onMessage가 callback인데 onMessageReceived도 callback
    // 그러면 이 DataChannel 객체에 .text에 문자열이 들어있다.
    // 그 텍스트를 다시 callback에 넣어서 호출될 수 있도록 해준다.
    channel.onMessage = (message){
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
