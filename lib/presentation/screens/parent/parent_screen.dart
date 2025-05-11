import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inner_voice/logic/providers/summary/summary_provider.dart';
import 'package:inner_voice/logic/providers/user/user_provider.dart';
import 'package:provider/provider.dart';

class ParentScreen extends StatefulWidget {
  final Widget child;

  const ParentScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  int _selectedIndex = 0;
  final List<String> _routes = [
    '/parent/call',
    '/parent/character/info',
    '/parent/summary',
    '/parent/settings',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = context.read<UserProvider>().user?.userId ?? "-1";
      context.read<SummaryProvider>().fetchSummaries(int.parse(userId));
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    _selectedIndex = _routes.indexWhere((r) => location.startsWith(r));
    if (_selectedIndex == -1) _selectedIndex = 0;

    final hiddenRoutes = [
      '/parent/call/waiting',
      '/parent/call/start',
      // '/parent/character/info',
      '/parent/character/add',
      '/parent/character/voice/synthesis',
      '/parent/character/voice/result',
    ];
    final hideBottomNav = hiddenRoutes.any((path) => location.startsWith(path));

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: hideBottomNav
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.call),
                  label: '대화하기',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined),
                  label: '캐릭터 정보',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.summarize),
                  label: '일기',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: '설정',
                ),
              ],
            ),
    );
  }
}
