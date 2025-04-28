import 'package:flutter/material.dart';
import 'package:flutter_advanced_calendar/flutter_advanced_calendar.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _calendarControllerCustom =
      AdvancedCalendarController(DateTime(2024, 4, 29));
  final events = <DateTime>[
    DateTime.now(),
    DateTime(2022, 10, 10),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AdvancedCalendar(
              controller: _calendarControllerCustom,
              events: events,
              weekLineHeight: 48.0,
              startWeekDay: 1,
              innerDot: true,
              keepLineSize: true,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text('요약'),
            ),
            Divider(
              color: Colors.orange,
              thickness: 2,
            ),
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
                    child: Center(
                      child: Text('이름'),
                    ),
                    height: 30,
                    width: 70,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Icon(
                    Icons.menu_sharp,
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      height: 400,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              '부모님의 잔소리 vs. 아이의 자유: 갈등 속에서 길을 찾다',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 40.0),
                            // 살짝 우측 여백 추가
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              // ✅ 오른쪽 정렬
                              children: [
                                Text(
                                  textAlign: TextAlign.end,
                                  '2025년 3월 15일\n16:37~17:25 (48분)',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                              vertical: 10.0,
                            ),
                            child: Divider(
                              color: Colors.grey.shade400,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            child: Text(
                              "오늘 상담에서는 부모님과 아이 사이의 갈등에 대해 깊이 있는 대화를 나누었습니다. 아이(15세, 중학생)는 최근 부모님과의 잦은 다툼으로 인해 감정적으로 지쳐 있으며, 부모님이 자신을 이해해주지 않는다고 느끼고 있었습니다. 반면, 부모님은 아이가 집안 규칙을 잘 따르지 않고, 스마트폰 사용 시간이 지나치게 길어 걱정된다고 하셨습니다.\n\n아이의 입장에서 본 갈등의 원인은 부모님의 잔소리가 많고, 본인의 감정을 무시당한다고 느끼는 것이었습니다. 특히, 시험 기간에도 부모님이 공부 방법에 대해 지적하거나 성적을 강조할 때 부담감을 크게 느낀다고 말했습니다. 부모님의 입장에서는 아이가 대화를 피하고, 혼자만의 시간을 가지려고 하는 모습이 더 걱정을 키웠습니다.",
                              style: TextStyle(
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
    );
  }
}
