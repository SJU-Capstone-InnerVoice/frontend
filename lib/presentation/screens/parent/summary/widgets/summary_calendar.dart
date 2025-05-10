import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
class SummaryCalendar extends StatelessWidget {
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final List<DateTime> eventDays;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final Function(CalendarFormat format) onFormatChanged;
  final Function(DateTime newFocusedDay) onPageChanged;

  const SummaryCalendar({
    super.key,
    required this.calendarFormat,
    required this.focusedDay,
    required this.selectedDay,
    required this.eventDays,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });


  bool _hasEvent(DateTime day) {
    return eventDays.any(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final newDate = calendarFormat == CalendarFormat.week
                      ? focusedDay.subtract(const Duration(days: 7))
                      : DateTime(focusedDay.year, focusedDay.month - 1);
                  onPageChanged(newDate);
                },
              ),
              GestureDetector(
                onTap: () {
                  final newFormat = calendarFormat == CalendarFormat.month
                      ? CalendarFormat.week
                      : CalendarFormat.month;
                  onFormatChanged(newFormat);
                },
                child: Text(
                  DateFormat('MMMM yyyy').format(focusedDay),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final newDate = calendarFormat == CalendarFormat.week
                      ? focusedDay.add(const Duration(days: 7))
                      : DateTime(focusedDay.year, focusedDay.month + 1);
                  onPageChanged(newDate);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal:  30.0),
          child: TableCalendar(
            headerVisible: false,
            calendarFormat: calendarFormat,
            onFormatChanged: onFormatChanged,
            availableCalendarFormats: const {
              CalendarFormat.month: '월',
              CalendarFormat.week: '주',
            },

            /// 캘린더 언어 , ["en_US", "ko_KR"]
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) =>
                selectedDay != null && isSameDay(selectedDay!, day),
            onDaySelected: onDaySelected,

            /// 캘린더 전체 높이
            rowHeight: 40.0,

            /// 요일 설정
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              weekendStyle: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),

            /// 헤더 부분 스타일
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: true,
              titleTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMM(locale).format(date),
              leftChevronMargin: EdgeInsets.zero,
              rightChevronMargin: EdgeInsets.zero,
              leftChevronPadding: const EdgeInsets.only(left: 0),
              rightChevronPadding: const EdgeInsets.only(right: 0),
              formatButtonDecoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange),
              ),
              formatButtonTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            calendarStyle: CalendarStyle(
              /// 셀 간의 간격
              cellMargin: const EdgeInsets.only(bottom: 10),

              /// 글자 크기
              defaultTextStyle: const TextStyle(fontSize: 13),

              /// 오늘 날짜의 글자 크기
              todayTextStyle: const TextStyle(fontSize: 13),

              todayDecoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              markersOffset: const PositionedOffset(bottom: 0),
              markersAlignment: Alignment.bottomCenter,
            ),
            calendarBuilders: CalendarBuilders(
              /// 선택 날짜의 셀
              selectedBuilder: (context, day, focusedDay) {
                return Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              /// 기본 셀
              defaultBuilder: (context, day, focusedDay) {
                return Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              /// 해당 month가 아닌 셀 부분
              outsideBuilder: (context, day, focusedDay) {
                return Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },

              /// 오늘 날짜 셀
              todayBuilder: (context, day, focusedDay) {
                return Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(80),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },

              /// 셀에 마커
              markerBuilder: (context, day, events) {
                if (_hasEvent(day)) {
                  return Positioned(
                    bottom: 0,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
