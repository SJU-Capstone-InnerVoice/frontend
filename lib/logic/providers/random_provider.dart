import 'dart:math';
import 'package:flutter/material.dart';

class RandomIdProvider extends ChangeNotifier {
  late final int _randomId;

  RandomIdProvider() {
    _randomId = 1005;
  }

  int get randomId => _randomId;
}