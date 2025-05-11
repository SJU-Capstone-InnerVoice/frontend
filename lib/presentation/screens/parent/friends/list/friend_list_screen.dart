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
              child: childList.isEmpty
                  ? const Center(child: Text('등록된 친구가 없습니다.'))
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
                              final userProvider = context.read<UserProvider>();
                              final isAlreadyActive = child.friendId.toString() == userProvider.activeChildId;

                              if (isAlreadyActive) {
                                userProvider.setActivateChild(null); // 비활성화
                                showIVFlushbar(
                                  context,
                                  "${child.friendName}의 선택을 취소했습니다.",
                                  position: FlushbarPosition.BOTTOM,
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                                );
                              } else {
                                userProvider.setActivateChild(child.friendId.toString()); // 활성화
                                showIVFlushbar(
                                  context,
                                  "${child.friendName}을(를) 선택했습니다.",
                                  position: FlushbarPosition.BOTTOM,
                                  icon: const Icon(Icons.check_circle, color: Colors.white),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActive ? Colors.orange : const Color(0xFFF2F3F5),
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
                                        color: isActive ? Colors.orange : Colors.black,
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
          ],
        ),
      ),
    );
  }
}
