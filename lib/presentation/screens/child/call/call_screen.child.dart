import 'dart:async';
import 'package:flutter/material.dart';
import 'package:inner_voice/services/web_rtc_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../logic/providers/communication/call_session_provider.dart';
import '../../../../logic/providers/communication/call_request_provider.dart';
import '../../../../logic/providers/user/user_provider.dart';
import '../../../../data/models/user/user_model.dart';
import 'package:lottie/lottie.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with RouteAware {
  late final CallRequestProvider _callRequest;
  late final CallSessionProvider _callSession;
  late final WebRTCService _rtc;
  late final User _user;

  bool hasCallRequest = false;

  @override
  void initState() {
    super.initState();
    _callRequest = context.read<CallRequestProvider>();
    _callSession = context.read<CallSessionProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _user = context.read<UserProvider>().user!;
      _rtc = _callSession.rtcService;

      if (!_callRequest.isPolling) {
        debugPrint("🔄 configure() (initState에서 polling 꺼져 있음)");
        _callRequest.configure(
          child: int.parse(_user.userId),
          parent: int.parse(_user.userId),
        );
      }
    });
  }

  Future<void> acceptCallRequest() async {
    if (!mounted) return;
    await _callRequest.accept();

    if (!mounted) return;
    await _rtc.init(
      isCaller: false,
      roomId: _callRequest.roomId!,
      onMessage: (message) {
        if (mounted) _callSession.addMessage(message);
      },
      onDisconnected: () {
        if (mounted) {
          Future.microtask(() {
            context.go('/child/call/end');
          });
        }
      },
    );




    if (!mounted) return;
    setState(() {
      hasCallRequest = false;
    });

    if (mounted) context.push('/child/call/waiting');
  }

  @override
  void dispose() {
    _callRequest.stopPolling();
    hasCallRequest = false;
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final callRequest = context.watch<CallRequestProvider>();

    debugPrint("🆔 build() 안 Provider 인스턴스: ${identityHashCode(callRequest)}");

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Lottie.asset(
                'assets/animations/work_bear.json',
                fit: BoxFit.fitWidth,
                repeat: true,
                animate: true,
              ),
            ),
            const SizedBox(height: 40),
            const Spacer(),
            SizedBox(
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Lottie.asset(
                        'assets/animations/grass.json',
                        fit: BoxFit.fitWidth,
                        repeat: true,
                        animate: true,
                      ),
                    ),
                  ),
                  Consumer<CallRequestProvider>(
                    builder: (context, callRequest, _) {
                      final callExists = callRequest.id != null && !callRequest.isAccepted;
                      if (callExists)
                        return Stack(
                          children: [
                            Positioned(
                              top: -40,
                              right: 40,
                              child: SizedBox(
                                height: 80,
                                child: Lottie.asset(
                                  'assets/animations/mole.json',
                                  repeat: true,
                                  animate: true,
                                ),
                              ),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: acceptCallRequest,
                                child: SizedBox(
                                  height: 100,
                                  child: Lottie.asset(
                                    'assets/animations/call_button.json',
                                    fit: BoxFit.contain,
                                    repeat: true,
                                    animate: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      else
                        return Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade300,
                            child: Icon(
                              Icons.phone,
                              size: 40,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        );
                    },
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
