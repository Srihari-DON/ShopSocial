import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'group_detail_screen.dart';
import 'event_detail_screen.dart';
import 'chat_screen.dart';
import 'create_menu_screen.dart';

class DemoApp extends ConsumerStatefulWidget {
  const DemoApp({Key? key}) : super(key: key);

  @override
  ConsumerState<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends ConsumerState<DemoApp> {
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(ref.read(authProvider.notifier)),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/group/:id',
          builder: (context, state) => GroupDetailScreen(
            groupId: state.params['id']!,
          ),
        ),
        GoRoute(
          path: '/event/:id',
          builder: (context, state) => EventDetailScreen(
            eventId: state.params['id']!,
          ),
        ),
        GoRoute(
          path: '/chat/:id',
          builder: (context, state) => ChatScreen(
            groupId: state.params['id']!,
          ),
        ),
        GoRoute(
          path: '/create',
          builder: (context, state) => const CreateMenuScreen(),
        ),
      ],
      redirect: (context, state) {
        final isLoggedIn = ref.read(authProvider).user != null;
        
        // If user is not logged in, only allow access to the login page
        if (!isLoggedIn && state.location != '/') {
          return '/';
        }
        
        // If user is logged in and they're on the login page, redirect to home
        if (isLoggedIn && state.location == '/') {
          return '/home';
        }
        
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShopSocial',
      theme: AppTheme.theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Stream notifier for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(AuthNotifier authNotifier) {
    _subscription = authNotifier.addListener((state) {
      notifyListeners();
    });
  }

  late final void Function() _subscription;

  @override
  void dispose() {
    _subscription();
    super.dispose();
  }
}
