import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../services/call_polling_service.dart';
import '../../../../logic/providers/communication/call_polling_provider.dart';
import '../../../../logic/providers/communication/call_session_provider.dart';
import '../../../../logic/providers/character/character_img_provider.dart';


class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final CallPollingService callPollingService;
  String? selectedCharacter;

  @override
  void initState() {
    super.initState();
    callPollingService = CallPollingService(
      characterId: 'char1',
      roomId: 'roomA',
      parentId: '1',
      childId: 'child001',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterImgProvider>().loadImagesFromServer('1');
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
      await callPollingService.createCallRequest();
      print('Creating call request for $selectedCharacter');
    }
    final rtcService = context.read<CallSessionProvider>().rtcService;
    await rtcService.init(
      isCaller: true,
      roomId: 1,
      onMessage: (message) {
        print("📩 받은 메시지: $message");
      },
    );

    context.go('/parent/call/waiting');
  }

  Future<void> pollCallRequests(BuildContext context) async {
    final data = await callPollingService.pollCallRequests();
    context.read<CallPollingProvider>().updatePolledData(data);
  }

  Future<void> updateCallStatus(BuildContext context, String newStatus) async {
    await callPollingService.updateCallStatus(newStatus);
    await pollCallRequests(context);
  }

  @override
  Widget build(BuildContext context) {
    final characterImgs = context.watch<CharacterImgProvider>().imageWidgets['1'] ?? {}; // userId에 맞게 수정
    final characterList = characterImgs.entries.toList();


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
                itemCount: characterList.length + 1,
                itemBuilder: (context, index) {
                  if (index < characterList.length) {
                    final entry = characterList[index];
                    final characterId = entry.key;
                    final imageWidget = entry.value;
                    final isSelected = selectedCharacter == characterId;

                    return GestureDetector(
                      onTap: () => selectCharacter(characterId),
                      child: Card(
                        color: isSelected ? Colors.grey[300] : Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 60, height: 60, child: imageWidget),
                            const SizedBox(height: 8),
                            Text(characterId), // 이름 대신 ID 표시, 필요시 이름 매핑 추가
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