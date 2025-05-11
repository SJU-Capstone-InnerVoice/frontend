import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:inner_voice/services/web_rtc_service.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
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

class _CallScreenState extends State<CallScreen> with RouteAware {
  final ScrollController _gridScroll = ScrollController();
  late final CallRequestProvider _callRequest;
  late final WebRTCService _rtc;
  late final User _user;
  Set<String> _renderedCharacterIds = {};
  bool _allImagesRendered = false;
  late final GoRouterDelegate _routerDelegate;
  bool _didLoadImages = false;
  String? selectedCharacter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _routerDelegate = GoRouter.of(context).routerDelegate;
      _routerDelegate.addListener(_onRouteChange);
    });

    /// provider 초기화
    _user = context.read<UserProvider>().user!;
    _callRequest = context.read<CallRequestProvider>();
    _rtc = context.read<CallSessionProvider>().rtcService;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetRenderedImages();
  }

  void _onRouteChange() {
    final location = GoRouter.of(context).state.path;
    if (location == '/parent/call') {
      _resetRenderedImages();
    }
  }

  void _resetRenderedImages() => setState(() {
        _renderedCharacterIds.clear();
        _allImagesRendered = false;
      });

  @override
  void dispose() {
    _routerDelegate.removeListener(_onRouteChange);
    _gridScroll.dispose();
    super.dispose();
  }

  void selectCharacter(String name) {
    setState(() {
      selectedCharacter = name;
    });
  }

  Future<void> createCallRequest(int characterId, int childId) async {
    if (!mounted) return;

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
        Future.microtask(() {
          if (mounted && Navigator.of(context).canPop()) {
            context.pop();
          }
        });
      },
    );
    await Future.delayed(Duration(milliseconds: 100));
    context.push('/parent/call/waiting');
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
      Future.microtask(() {
        if (!mounted) return;
        context.read<CharacterImgProvider>().loadImagesFromServer(userId);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  clipBehavior: Clip.none,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(
                      scrollbars: false,
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: GridView.builder(
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
                          final isSelected = selectedCharacter == character.id;
                          return GestureDetector(
                            onTap: () => selectCharacter(character.id),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1)
                                      : null,
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 5,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Stack(
                                            children: [
                                              // 이미지
                                              SizedBox(
                                                width: 100,
                                                height: 100,
                                                child: Image.network(
                                                  character.imageUrl,
                                                  fit: BoxFit.cover,
                                                  frameBuilder: (context, child,
                                                      frame, wasSyncLoaded) {
                                                    if (frame != null &&
                                                        !_renderedCharacterIds
                                                            .contains(
                                                                character.id)) {
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        if (mounted) {
                                                          setState(() {
                                                            _renderedCharacterIds
                                                                .add(
                                                                    character.id);
                                                            if (_renderedCharacterIds
                                                                    .length ==
                                                                characters
                                                                    .length) {
                                                              _allImagesRendered =
                                                                  true;
                                                            }
                                                          });
                                                        }
                                                      });
                                                    }
                                                    return child;
                                                  },
                                                ),
                                              ),

                                              // 시머 오버레이
                                              if (!_allImagesRendered)
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                    ),
                                                    child: Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300]!,
                                                      highlightColor:
                                                          Colors.grey[100]!,
                                                      child: Container(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            character.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: GestureDetector(
                              onTap: () {
                                context.push('/parent/character/create/progress');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Container(
                                      color: Colors.white,
                                      child: const Icon(Icons.add,
                                          color: Colors.orange, size: 32),
                                    ),
                                  ),
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
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  context.push('/parent/friend/list');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isChildSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                          : const Color(0xFFE5E6E8), // 연회색
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
                            : const Color(0xFFB0B3B8), // 연회색
                      ),
                      const SizedBox(width: 10),
                      Text(
                        activeChildName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isChildSelected
                              ? Theme.of(context).colorScheme.primary
                              : const Color(0xFF4B4E54), // 중간 회색
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
                onPressed: selectedCharacter == null || activeChildId == null
                    ? null
                    : () => createCallRequest(
                          int.parse(selectedCharacter!),
                          int.parse(activeChildId!),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedCharacter == null ? Colors.grey : null,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('대화방 생성'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
