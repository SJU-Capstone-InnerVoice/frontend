import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    '/parent/character-info',
    '/parent/summary',
    '/parent/settings'
  ];

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
      '/parent/call/call-waiting',
      '/parent/call/call-start',
      // '/parent/character-info/add'
    ];
    final hideBottomNav = hiddenRoutes.any((path) => location.startsWith(path));

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: hideBottomNav ? null :BottomNavigationBar(
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
