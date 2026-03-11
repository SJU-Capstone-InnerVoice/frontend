import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:inner_voice/presentation/widgets/show_flushbar.dart';
import 'package:inner_voice/services/web_rtc_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../../../../logic/providers/communication/call_session_provider.dart';
import '../../../../logic/providers/character/character_img_provider.dart';
import '../../../../logic/providers/communication/call_request_provider.dart';
import '../../../../data/models/user/user_model.dart';
import '../../../../data/models/friend/friend_model.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final ScrollController _gridScroll = ScrollController();
  late final CallRequestProvider _callRequest;
  late final WebRTCService _rtc;
  late final User _user;
  String? selectedCharacter;
  bool isCreating = false;

  @override
  void initState() {
    super.initState();

    /// provider 초기화
    _user = context.read<UserProvider>().user!;
    _callRequest = context.read<CallRequestProvider>();
    _rtc = context.read<CallSessionProvider>().rtcService;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _gridScroll.dispose();
    super.dispose();
  }

  void selectCharacter(String name) {
    setState(() {
      selectedCharacter = name;
    });
  }

  Future<void> createCallRequest(int characterId, int childId) async {
    if (!mounted || isCreating) return;

    if (!mounted) return;
    setState(() {
      isCreating = true;
    });
    try {
      _callRequest.setRoomId();
      _callRequest.setCharacterId(characterId);
      _callRequest.setChildId(childId);
      _callRequest.setParentId(int.parse(_user.userId));

      await _callRequest.send();
      await _rtc.init(
        isCaller: true,
        roomId: _callRequest.roomId!,
        onMessage: (message) {
          print("📩 받은 메시지: $message");
        },
        onDisconnected: () {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && Navigator.of(context).canPop()) {
              context.pop();
            }
          });
        },
      );
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) context.push('/parent/call/waiting');
    } catch (e) {
      debugPrint('❌ 대화방 생성 실패: $e');
    } finally {
      if (mounted) {
        setState(() {
          isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _user.userId.toString();
    final characters =
        context.watch<CharacterImgProvider>().getCharacters(userId);
    final userProvider = context.watch<UserProvider>();
    final childList = userProvider.user?.childList ?? [];
    final activeChildId = userProvider.activeChildId;
    final bool isChildSelected = activeChildId != null;

    Friend? activeChild;
    try {
      activeChild = childList.firstWhere(
        (c) => c.friendId.toString() == activeChildId,
      );
    } catch (_) {
      activeChild = null;
    }

    final activeChildName = activeChild?.friendName ?? '선택하러가기';

    if (characters.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;

        final provider = context.read<CharacterImgProvider>();

        try {
          await provider.loadImagesFromServer(userId);
        } catch (e) {
          if (mounted) {
            debugPrint('❌ 캐릭터 이미지 로딩 실패: $e');
          }
        }
      });
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[100]),
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(
                    scrollbars: false,
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final provider = context.read<CharacterImgProvider>();
                      final characters = provider.getCharacters(userId);

                      try {
                        // 1. 캐시 삭제
                        for (final character in characters) {
                          await CachedNetworkImage.evictFromCache(
                              character.imageUrl);
                        }

                        // 2. 다시 로드 가능하게 설정
                        provider.resetLoadState();

                        // 3. 서버에서 새로 불러오기
                        await provider.loadImagesFromServer(userId);

                        // 4. ✅ 하단에 알림 띄우기
                        if (mounted) {
                          showIVFlushbar(
                            context,
                            '캐릭터 목록을 새로 불러왔습니다.',
                            position: FlushbarPosition.BOTTOM,
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          debugPrint('❌ 캐릭터 이미지 새로고침 실패: $e');
                          showIVFlushbar(
                            context,
                            '새로고침 실패 😢 다시 시도해주세요.',
                            position: FlushbarPosition.BOTTOM,
                            icon: const Icon(Icons.error, color: Colors.white),
                          );
                        }
                      }
                    },
                    child: characters.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                '아직 캐릭터가 없어요.\n아래 + 버튼을 눌러 만들어보세요!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            controller: _gridScroll,
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: characters.length + 1,
                            itemBuilder: (context, index) {
                              if (index < characters.length) {
                                final character = characters[index];
                                final isSelected =
                                    selectedCharacter == character.id;
                                return GestureDetector(
                                  onTap: () => selectCharacter(character.id),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 7.5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.orange
                                              : Colors.transparent,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            flex: 5,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(5),
                                                topRight: Radius.circular(5),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              child: Stack(
                                                children: [
                                                  SizedBox(
                                                    width: double.infinity,
                                                    height: 100,
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          character.imageUrl,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          Shimmer.fromColors(
                                                        baseColor:
                                                            Colors.grey[300]!,
                                                        highlightColor:
                                                            Colors.grey[100]!,
                                                        child: Container(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const Icon(
                                                              Icons.error),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5.0, bottom: 5.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    character.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () =>
                        context.push('/parent/character/create/progress'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(80),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child:
                              Icon(Icons.add, color: Colors.orange, size: 32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      context.push('/parent/friend/list');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isChildSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3)
                              : const Color(0xFFE5E6E8),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.child_care,
                            size: 24,
                            color: isChildSelected
                                ? Theme.of(context).colorScheme.primary
                                : const Color(0xFFB0B3B8),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            activeChildName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isChildSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color(0xFF4B4E54),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Color(0xFFB0B3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: (selectedCharacter == null || activeChildId == null || isCreating)
                        ? null
                        : () => createCallRequest(
                      int.parse(selectedCharacter!),
                      int.parse(activeChildId!),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isCreating
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      '대화방 생성',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
