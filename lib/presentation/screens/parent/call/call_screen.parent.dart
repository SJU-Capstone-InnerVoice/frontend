import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:provider/provider.dart';
import '../../../../services/call_request_service.dart';
import '../../../../logic/providers/communication/call_polling_provider.dart';
import '../../../../logic/providers/communication/call_session_provider.dart';
import '../../../../logic/providers/user/user_provider.dart';
import '../../../../logic/providers/character/character_img_provider.dart';
import '../../../../logic/providers/network/dio_provider.dart';
import '../../../../data/models/user/user_model.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final User _user;
  // late final CallPollingService callPollingService;
  late final _dio;
  String? selectedCharacter;

  @override
  void initState() {
    super.initState();
    _user  = context.read<UserProvider>().user!;
    _dio = context.read<DioProvider>().dio;
    // callPollingService = CallPollingService(
    //   dio: _dio,
    //   characterId: 'char1',
    //   roomId: 'roomA',
    //   parentId: '1',
    //   childId: 'child001',
    // );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterImgProvider>().loadImagesFromServer(_user.userId);
    });
  }
  void selectCharacter(String name) {
    setState(() {

      selectedCharacter = name;
    });
  }
  Future<void> createCallRequest() async {


    // 요청 생성 기능만 남김
    if (selectedCharacter != null) {
      // await callPollingService.createCallRequest();
      print('Creating call request for $selectedCharacter');
    }
    final rtcService = context.read<CallSessionProvider>().rtcService;
    await rtcService.init(
      isCaller: true,
      roomId: 31,
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

    context.go('/parent/call/waiting');
  }

  Future<void> pollCallRequests(BuildContext context) async {
    // final data = await callPollingService.pollCallRequests();
    // context.read<CallPollingProvider>().updatePolledData(data);
  }

  Future<void> updateCallStatus(BuildContext context, String newStatus) async {
    // await callPollingService.updateCallStatus(newStatus);
    await pollCallRequests(context);
  }

  @override
  Widget build(BuildContext context) {
    final characters = context.watch<CharacterImgProvider>().getCharacters(_user.userId.toString());


    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                              child: Image.network(character.imageUrl, fit: BoxFit.cover),
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
                        context.go('/parent/character/add');
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
                              Text('직접 추가', style: TextStyle(color: Colors.orange)),
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
              onPressed: selectedCharacter == null ? null : createCallRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedCharacter == null ? Colors.grey : null,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('대화방 생성'),
            ),
          ],
        ),
      ),
    );
  }
}