import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../services/call_request_service.dart';

class CallRequestProvider with ChangeNotifier {
  late final Dio _dio;
  late final CallRequestService _callRequestService;
  int? _id;
  int? _roomId;
  int? _childId;
  int? _parentId;
  int? _characterId;
  bool _isAccepted = false;

  // Getters
  int? get id => _id;
  int? get roomId => _roomId;
  int? get childId => _childId;
  int? get parentId => _parentId;
  int? get characterId => _characterId;
  bool get isAccepted => _isAccepted;

  CallRequestProvider(this._dio) {
    _callRequestService = CallRequestService(dio: _dio);
  }

  // Setters
  void setRoomId() {
    _roomId = Random().nextInt(900000) + 100000; // 100000 ~ 999999
    notifyListeners();
  }

  void setId(int id) {
    _id = id;
    notifyListeners();
  }

  void setChildId(int id) {
    _childId = id;
    notifyListeners();
  }

  void setParentId(int id) {
    _parentId = id;
    notifyListeners();
  }

  void setCharacterId(int id) {
    _characterId = id;
    notifyListeners();
  }

  void setAccept() {
    _isAccepted = true;
    notifyListeners();
  }

  void setReject() {
    _isAccepted = false;
    notifyListeners();
  }

  Future<void> send() async {
    if (_parentId == null || _childId == null || _characterId == null || _roomId == null) {
      debugPrint('❌ 필수 정보가 누락되었습니다.');
      return;
    }

    try {
      final data = await _callRequestService.createCallRequest(
        userId: _parentId!,
        receiverId: _childId!,
        characterId: _characterId!,
        roomId: _roomId!,
      );

      _id = data['id'];
      _parentId = data['senderId'];
      _childId = data['receiverId'];
      _characterId = data['characterImageId'];
      _roomId = data['roomId'];
      _isAccepted = data['isAccepted'] ?? false;

      debugPrint('📥 Provider에 통화 요청 응답 반영 완료');
      notifyListeners();
    } catch (e) {
      debugPrint('🚨 Provider send() 실패: $e');
    }
  }

  Future<Map<String, dynamic>?> query() async {
    if (_childId == null) {
      debugPrint('❌ 자식 ID가 설정되어 있지 않습니다.');
      return null;
    }

    try {
      final responses = await _callRequestService.queryCallRequest(userId: _childId!);

      if (responses.isEmpty) {
        debugPrint('📭 조회된 통화 요청이 없습니다.');
        return null;
      }

      final latest = responses.last;

      _id = latest['id'];
      _parentId = latest['senderId'];
      _childId = latest['receiverId'];
      _characterId = latest['characterImageId'];
      _roomId = latest['roomId'];
      _isAccepted = latest['isAccepted'] ?? false;

      debugPrint('📡 통화 요청 정보 갱신 완료');
      notifyListeners();
      return latest;
    } catch (e) {
      debugPrint('🚨 Provider query() 실패: $e');
      return null;
    }
  }

  Future<void> accept() async {
    if (_id == null) {
      debugPrint('❌ 수락할 요청 ID가 없습니다.');
      return;
    }

    try {
      await _callRequestService.acceptCallRequest(requestId: _id!);
      _isAccepted = true;
      notifyListeners();
      debugPrint('📥 요청 수락 후 상태 반영 완료');
    } catch (e) {
      debugPrint('🚨 Provider accept() 실패: $e');
    }
  }

  Future<void> delete() async {
    if (_id == null) {
      print('❌ 삭제할 요청 ID가 없습니다.');
      return;
    }

    try {
      await _callRequestService.deleteCallRequest(requestId: _id!);
      debugPrint('🗑️ 통화 요청 삭제 완료: ID=$_id');
      clearRoom();
    } catch (e) {
      debugPrint('🚨 통화 요청 삭제 실패: $e');
    }
  }
  void clearRoom() {
    _roomId = null;
    _id = null;
    _childId = null;
    _parentId = null;
    _characterId = null;
    _isAccepted = false;
    notifyListeners();
  }
}