import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChildScreen extends StatefulWidget {
  final Widget child;

  const ChildScreen({Key? key, required this.child}) : super(key: key);

  @override
  State<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends State<ChildScreen> {
  int _selectedIndex = 0;
  final List<String> _routes = ['/child/call', '/child/settings'];

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
      '/child/call/start',
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
                  icon: Icon(Icons.settings),
                  label: '설정',
                ),
              ],
            ),
    );
  }
}
