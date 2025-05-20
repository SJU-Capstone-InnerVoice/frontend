import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:inner_voice/presentation/widgets/show_flushbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/summary/summary_model.dart';
import '../../../../logic/providers/summary/summary_provider.dart';
import 'widgets/summary_calendar.dart';
import 'package:flutter/cupertino.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool _isCalendarVisible = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  String _searchQuery = '';
  bool _isSearchMode = false;
  List<DateTime> eventDays = [];
  List<CounselingSummary> summaries = [];
  List<CounselingSummary> filteredSummaries = [];

  void _filterSummariesBySearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearchMode = true;
      _isCalendarVisible = false;
      filteredSummaries = summaries.where((item) {
        return item.title.contains(query) || item.content.contains(query);
      }).toList();
    });
  }

  @override
  void initState() {
    Future.microtask(() {
      final userId = context.read<UserProvider>().user?.userId ?? "-1";
      context.read<SummaryProvider>().fetchSummaries(int.parse(userId));
    });
  }

  void _exitSearchMode() {
    setState(() {
      _isSearchMode = false;
      _searchQuery = '';
      _isCalendarVisible = true;
      _filterSummariesBySelectedDay();
    });
  }

  void _showCupertinoDatePicker(BuildContext context) {
    DateTime tempSelectedDate = _focusedDay;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              // 완료 버튼에서 context 대신 외부 context 사용
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _focusedDay = tempSelectedDate;
                        _selectedDay = tempSelectedDate;
                        _filterSummariesBySelectedDay();
                        if (mounted) {
                          /// BottomSheet 스택이 2번 쌓임
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      });
                    },
                    child: const Text(
                      '완료',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _focusedDay,
                  minimumDate: DateTime(2000),
                  maximumDate: DateTime(2100),
                  onDateTimeChanged: (DateTime newDate) {
                    tempSelectedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _filterSummariesBySelectedDay() {
    if (_selectedDay == null) return;

    filteredSummaries = summaries.where((item) {
      final start = item.startAt;
      return start.year == _selectedDay!.year &&
          start.month == _selectedDay!.month &&
          start.day == _selectedDay!.day;
    }).toList();
  }

  bool _hasEvent(DateTime day) {
    return eventDays.any(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SummaryProvider>();
    final userId = context.read<UserProvider>().user?.userId ?? "-1";
    summaries = provider.summaries;

    // 선택된 날짜 필터 적용
    if (!_isSearchMode && _selectedDay != null) {
      filteredSummaries = summaries.where((s) {
        final d = s.startAt;
        return d.year == _selectedDay!.year &&
            d.month == _selectedDay!.month &&
            d.day == _selectedDay!.day;
      }).toList();
    }

    eventDays = summaries.map((s) => s.startAt).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_isSearchMode)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      '🔍 검색 결과 보기',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: '검색 종료',
                        onPressed: _exitSearchMode,
                      ),
                    ),
                  ],
                ),
              ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Visibility(
                visible: _isCalendarVisible,
                child: SummaryCalendar(
                  calendarFormat: _calendarFormat,
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  eventDays: eventDays,
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                      _filterSummariesBySelectedDay();
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (newFocusedDay) {
                    setState(() {
                      _focusedDay = newFocusedDay;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(
              color: Colors.orange,
              thickness: 2,
              height: 0,
            ),
            Expanded(
              child: Container(
                color: Colors.grey.shade200,
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          final provider = context.read<SummaryProvider>();
                          try {
                            await provider.fetchSummaries(int.parse(userId));
                            if (mounted) {
                              showIVFlushbar(
                                context,
                                '요약 목록을 새로 불러왔습니다.',
                                position: FlushbarPosition.BOTTOM,
                                icon: const Icon(Icons.refresh,
                                    color: Colors.white),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              showIVFlushbar(
                                context,
                                '새로 고침 실패 😢',
                                position: FlushbarPosition.BOTTOM,
                                icon: const Icon(Icons.error,
                                    color: Colors.white),
                              );
                            }
                          }
                        },
                        child: filteredSummaries.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text(
                                    '이 날에는 요약이 없어요.\n다른 날짜를 눌러볼까요?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredSummaries.length,
                                itemBuilder: (context, index) {
                                  final summary = filteredSummaries[
                                      filteredSummaries.length - 1 - index];
                                  final start = summary.startAt;
                                  final duration =
                                      Duration(milliseconds: summary.duration);
                                  final end = start.add(duration);
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Text(
                                              summary.title ?? '',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 40.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    '${start.year}년 ${start.month}월 ${start.day}일\n'
                                                    '${start.hour}:${start.minute.toString().padLeft(2, '0')} ~ '
                                                    '${end.hour}:${end.minute.toString().padLeft(2, '0')} '
                                                    '(${duration.inMinutes}분 ${duration.inSeconds % 60}초)',
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 40, vertical: 20),
                                            child: Text(
                                              summary.content ?? '',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isSearchMode
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.orange,
              child: const Icon(Icons.menu),
              onPressed: () {
                // 메뉴 열기, 예: showModalBottomSheet
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.search),
                          title: Text('검색'),
                          onTap: () {
                            Navigator.pop(context); // 기존 바텀시트 닫기

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (ctx) {
                                String query = '';
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        MediaQuery.of(ctx).viewInsets.bottom,
                                    left: 24,
                                    right: 24,
                                    top: 24,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '검색어 입력',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        onChanged: (value) {
                                          query = value;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: '검색어 입력',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _filterSummariesBySearch(query);
                                            Navigator.pop(ctx);
                                          },
                                          child: const Text('검색'),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.refresh),
                          title: const Text('새로 고침'),
                          onTap: () async {
                            final provider = context.read<SummaryProvider>();
                            try {
                              await provider.fetchSummaries(int.parse(userId));

                              if (mounted) {
                                Navigator.pop(context);
                                showIVFlushbar(
                                  context,
                                  '요약 목록을 새로 불러왔습니다.',
                                  position: FlushbarPosition.BOTTOM,
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                Navigator.pop(context);
                                showIVFlushbar(
                                  context,
                                  '새로 고침 실패 😢',
                                  position: FlushbarPosition.BOTTOM,
                                  icon: const Icon(Icons.error,
                                      color: Colors.white),
                                );
                              }
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.calendar_view_month),
                          // 캘린더 년도별 보기
                          title: const Text('날짜 지정 보기'),
                          onTap: () {
                            _showCupertinoDatePicker(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.today),
                          title: Text('오늘 보기'),
                          onTap: () {
                            setState(() {
                              final now = DateTime.now();
                              _focusedDay = now;
                              _selectedDay = now;
                              _filterSummariesBySelectedDay();
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(_isCalendarVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          title:
                              Text(_isCalendarVisible ? '캘린더 가리기' : '캘린더 보기'),
                          onTap: () {
                            setState(() {
                              _isCalendarVisible = !_isCalendarVisible;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
