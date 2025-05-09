// lib/presentation/routes/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/user/user_provider.dart';
import '../../../core/constants/user/role.dart';
import '../../../data/models/user/user_model.dart';
import '../../../data/datasources/local/auth_local_datasource.dart';
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.microtask(() async {
      if (_navigated) return;

      final data = await AuthLocalDataSource.getStoredUser();

      if (!mounted) return;

      if (data == null) {
        _navigated = true;
        context.go('/login');
        return;
      }

      final user = User(
        userId: data['id']!,
        role: data['role'] == 'parent' ? UserRole.parent : UserRole.child,
        childList: [],
        myParent: null,
      );

      final userProvider = context.read<UserProvider>();
      if (userProvider.user == null) {
        userProvider.setUser(user);
      }

      _navigated = true;
      final redirectRoute = user.role == UserRole.parent
          ? '/parent/call'
          : '/child/call';

      context.go(redirectRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}