// lib/presentation/routes/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../logic/providers/user/user_provider.dart';
import '../../../core/constants/user/role.dart';
import '../../../data/models/user/user_model.dart';
import '../../../data/datasources/local/auth_local_datasource.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthLocalDataSource.getStoredUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          Future.microtask(() => context.go('/login'));
          return const Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox.expand(),
          );
        }

        final user = User(
          userId: data['id']!,
          role: data['role'] == 'parent' ? UserRole.parent : UserRole.child,
          childList: [],
          myParent: null,
        );

        context.read<UserProvider>().setUser(user);

        final redirectRoute =
        user.role == UserRole.parent ? '/parent/call' : '/child/call';

        Future.microtask(() => context.go(redirectRoute));

        return const Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.expand(),
        );
      },
    );
  }
}