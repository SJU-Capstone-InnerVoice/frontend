// lib/logic/providers/summary/summary_provider.dart

import 'package:flutter/material.dart';
import '../../../services/summary_service.dart';
import '../../../data/models/summary/summary_model.dart';

class SummaryProvider extends ChangeNotifier {
  final SummaryService _service = SummaryService();

  final List<CounselingSummary> _summaries = [];
  bool _isLoading = false;
  String? _error;

  List<CounselingSummary> get summaries => List.unmodifiable(_summaries);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAndAddSummary({
    required String filePath,
    required int duration,
    required DateTime startAt,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.uploadAudioAndGetSummary(filePath);

    if (result != null) {
      final summary = CounselingSummary(
        title: result['title'] ?? '',
        content: result['content'] ?? '',
        duration: duration,
        startAt: startAt,
      );
      _summaries.add(summary);
    } else {
      _error = '요약 실패';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _summaries.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  /// ✅ 요약 리스트 콘솔에 출력
  void printSummaries() {
    if (_summaries.isEmpty) {
      print('📭 저장된 요약이 없습니다.');
      return;
    }

    print('📚 저장된 요약 리스트 (${_summaries.length}개):');
    for (int i = 0; i < _summaries.length; i++) {
      final s = _summaries[i];
      print('[$i]');
      print('  • 제목: ${s.title}');
      print('  • 내용: ${s.content}');
      print('  • 길이: ${s.duration}ms');
      print('  • 시작 시각: ${s.startAt}');
    }
  }
}