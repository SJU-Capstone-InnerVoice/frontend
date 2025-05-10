import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api/summary_api.dart';
import 'widgets/summary_calendar.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  List<DateTime> eventDays = [];
  List<Map<String, dynamic>> summaries = [];
  List<Map<String, dynamic>> filteredSummaries = [];

  @override
  void initState() {
    super.initState();
    fetchDummyData();
  }

  Future<void> fetchDummyData() async {
    final dio = Dio();

    try {
      final response = await dio.get(SummaryApi.summary);
      final List<dynamic> data = response.data;

      setState(() {
        summaries = data.cast<Map<String, dynamic>>();
        eventDays =
            summaries.map((item) => DateTime.parse(item['startAt'])).toList();
        _filterSummariesBySelectedDay(); // 최초 필터링
      });
    } catch (e) {
      print('❌ 요청 실패: $e');
    }
  }

  void _filterSummariesBySelectedDay() {
    if (_selectedDay == null) return;

    filteredSummaries = summaries.where((item) {
      final start = DateTime.parse(item['startAt']);
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SummaryCalendar(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: Text('이름')),
                            height: 30,
                            width: 70,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Icon(Icons.menu_sharp),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredSummaries.length,
                        itemBuilder: (context, index) {
                          final summary = filteredSummaries[index];
                          final start = DateTime.parse(summary['startAt']);
                          final end =
                              start.add(Duration(minutes: summary['duration']));
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
                                      summary['title'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 40.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '${start.year}년 ${start.month}월 ${start.day}일\n'
                                            '${start.hour}:${start.minute.toString().padLeft(2, '0')} ~ '
                                            '${end.hour}:${end.minute.toString().padLeft(2, '0')} '
                                            '(${summary['duration']}분)',
                                            textAlign: TextAlign.end,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
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
                                      summary['content'] ?? '',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
