import 'dart:math';
import 'package:flutter/material.dart';
import '../../../services/call_request_service.dart';

class CallRequestProvider with ChangeNotifier {
  CallRequestService _callRequestService = CallRequestService();
  int? _id;
  int? _roomId;
  String? _childId;
  String? _parentId;
  String? _characterId;
  bool _isAccepted = false;

  // Getters
  int? get id => _id;
  int? get roomId => _roomId;
  String? get childId => _childId;
  String? get parentId => _parentId;
  String? get characterId => _characterId;
  bool get isAccepted => _isAccepted;

  // Setters
  void setRoomId() {
    _roomId = Random().nextInt(900000) + 100000; // 100000 ~ 999999
    notifyListeners();
  }

  void setId(int id) {
    _id = id;
    notifyListeners();
  }

  void setChildId(String id) {
    _childId = id;
    notifyListeners();
  }

  void setParentId(String id) {
    _parentId = id;
    notifyListeners();
  }

  void setCharacterId(String id) {
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
    notifyListeners();
  }
  Future<void> query() async {
    notifyListeners();
  }
  Future<void> accept() async {
    notifyListeners();
  }
  Future<void> delete() async {
    clearRoom();
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