import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:inner_voice/services/web_rtc_service.dart';
import 'package:provider/provider.dart';
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
  late final CallRequestProvider _callRequest;
  late final WebRTCService _rtc;
  late final User _user;

  String? selectedCharacter;

  @override
  void initState() {
    super.initState();
    /// provider 초기화
    _user = context.read<UserProvider>().user!;
    _callRequest = context.read<CallRequestProvider>();
    _rtc = context.read<CallSessionProvider>().rtcService;
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
    await Future.delayed(Duration(milliseconds: 1000));
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

    Friend? activeChild;
    try {
      activeChild = childList.firstWhere(
            (c) => c.friendId.toString() == activeChildId,
      );
    } catch (_) {
      activeChild = null;
    }

    final activeChildName = activeChild?.friendName ?? '없음';


    if (characters.isEmpty) {
      Future.microtask(() {
        if (!mounted) return;
        context.read<CharacterImgProvider>().loadImagesFromServer(userId);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: (){
                  context.push('/parent/settings/friend/list');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(Icons.child_care,
                           size: 28),
                      const SizedBox(width: 12),
                      Text(
                        '아이 선택됨:${activeChildName}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: characters.length + 1,
                  itemBuilder: (context, index) {
                    if (index < characters.length) {
                      final character = characters[index];
                      final isSelected = selectedCharacter == character.id;

                      return GestureDetector(
                        onTap: () => selectCharacter(character.id),
                        child: Card(
                          color: isSelected ? Colors.grey[300] : Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: Image.network(character.imageUrl,
                                    fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 8),
                              Text(character.name), // 이제 이름으로 표시 가능
                            ],
                          ),
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          context.push('/parent/character/add');
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add, color: Colors.orange, size: 32),
                                SizedBox(height: 8),
                                Text('직접 추가',
                                    style: TextStyle(color: Colors.orange)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
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
                  backgroundColor: selectedCharacter == null ? Colors.grey : null,
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
