import 'package:go_router/go_router.dart';
import '../screens/login/login_screen.dart';
import '../screens/home/home_screen.dart';


final GoRouter IVRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);