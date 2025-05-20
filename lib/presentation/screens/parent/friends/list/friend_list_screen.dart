import 'package:another_flushbar/flushbar_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/network/dio_provider.dart';
import 'package:inner_voice/presentation/widgets/show_flushbar.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:provider/provider.dart';
import '../../../../../../logic/providers/user/user_provider.dart';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = context.read<DioProvider>().dio;
    context.read<UserProvider>().setChildList(_dio);
  }

  @override
  Widget build(BuildContext context) {
    final childList = context.watch<UserProvider>().user?.childList ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('아이 목록'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '새로고침',
              onPressed: () {
                final dio = context.read<DioProvider>().dio;
                context.read<UserProvider>().setChildList(dio);
                showIVFlushbar(
                  context,
                  '자녀 목록을 새로 불러왔습니다.',
                  position: FlushbarPosition.BOTTOM,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/parent/friend/request');
                },
                child: Text('자녀 등록하기'),
              ),
            ),
            SizedBox(height: 10),
            const Divider(height: 1),
            SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final dio = context.read<DioProvider>().dio;
                  await context.read<UserProvider>().setChildList(dio);
                  showIVFlushbar(
                    context,
                    '자녀 목록을 새로 불러왔습니다.',
                    position: FlushbarPosition.BOTTOM,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  );
                },
                child: childList.isEmpty
                    ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          '아직 자녀가 등록되지 않았어요.\n위의 등록하기 버튼으로 추가해볼까요?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    : ListView.builder(
                        itemCount: childList.length,
                        itemBuilder: (context, index) {
                          final child = childList[index];
                          final userProvider = context.watch<UserProvider>();
                          final activeChildId = userProvider.activeChildId;
                          final isActive =
                              child.friendId.toString() == activeChildId;

                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: InkWell(
                              onTap: () {
                                final userProvider =
                                    context.read<UserProvider>();
                                final isAlreadyActive =
                                    child.friendId.toString() ==
                                        userProvider.activeChildId;

                                if (isAlreadyActive) {
                                  userProvider.setActivateChild(null); // 비활성화
                                  showIVFlushbar(
                                    context,
                                    "${child.friendName}의 선택을 취소했습니다.",
                                    position: FlushbarPosition.BOTTOM,
                                    icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.white),
                                  );
                                } else {
                                  userProvider.setActivateChild(
                                      child.friendId.toString()); // 활성화
                                  showIVFlushbar(
                                    context,
                                    "${child.friendName}을(를) 선택했습니다.",
                                    position: FlushbarPosition.BOTTOM,
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.white),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isActive
                                        ? Colors.orange
                                        : const Color(0xFFF2F3F5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        child.friendName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: isActive
                                              ? Colors.orange
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
    );
  }
}
