import 'package:flutter/material.dart';

class CallPollingProvider extends ChangeNotifier {
  List<dynamic> _polledData = [];

  List<dynamic> get polledData => _polledData;

  void updatePolledData(List<dynamic> newData) {
    _polledData = newData;
    notifyListeners();
  }

  void clear() {
    _polledData = [];
    notifyListeners();
  }
}