import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/call_polling_service.dart';
import '../../../../logic/providers/communication/call_polling_provider.dart';
class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final CallPollingService callPollingService;
  String? selectedCharacter;

  final List<Map<String, String>> characters = [
    {'name': '코끼리', 'image': 'https://picsum.photos/200/300'},
    {'name': '뽀로로', 'image': 'https://picsum.photos/200/301'},
    {'name': '하츄핑', 'image': 'https://picsum.photos/200/302'},
  ];

  @override
  void initState() {
    super.initState();
    callPollingService = CallPollingService(
      characterId: 'char1',
      roomId: 'roomA',
      parentId: 'parent001',
      childId: 'child001',
    );
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
                itemCount: characters.length + 1, // 직접 추가 버튼 포함
                itemBuilder: (context, index) {
                  if (index < characters.length) {
                    final character = characters[index];
                    final isSelected = selectedCharacter == character['name'];
                    return GestureDetector(
                      onTap: () => selectCharacter(character['name']!),
                      child: Card(
                        color: isSelected ? Colors.grey[300] : Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(character['image']!, width: 60, height: 60),
                            const SizedBox(height: 8),
                            Text(character['name']!),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        // TODO: 직접 추가 기능 구현 (선택사항)
                        print('직접 추가하기');
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