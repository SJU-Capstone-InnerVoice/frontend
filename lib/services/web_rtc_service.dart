import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? _peer;
  MediaStream? _localStream;

  Future<void> initConnection() async {
    // _peer = await createPeerConnection(_iceServers);
    _localStream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});
    _peer!.addStream(_localStream!);
  }

  Future<RTCSessionDescription> createOffer() async {
    final offer = await _peer!.createOffer();
    await _peer!.setLocalDescription(offer);
    return offer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription desc) async {
    await _peer!.setRemoteDescription(desc);
  }

  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _peer!.createAnswer();
    await _peer!.setLocalDescription(answer);
    return answer;
  }

  void addCandidate(RTCIceCandidate candidate) {
    _peer!.addCandidate(candidate);
  }
}