import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/calendar/create_event_wizard.dart';
import 'screens/chats/chat_screen.dart';
import 'screens/chats/chats_screen.dart';
import 'screens/create/create_menu.dart';
import 'screens/home/event_detail_screen.dart';
import 'screens/home/group_detail_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'viewmodels/auth_vm.dart';

// GoRouter configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authVMProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final isLoggedIn = authState.currentUser != null;
      final isOnboarded = authState.hasSeenOnboarding;
      
      // If not onboarded, redirect to onboarding
      if (!isOnboarded && state.location != '/onboarding') {
        return '/onboarding';
      }
      
      // If not logged in, redirect to login
      if (!isLoggedIn && 
          state.location != '/auth/login' && 
          state.location != '/auth/register' &&
          state.location != '/onboarding') {
        return '/auth/login';
      }
      
      // If logged in and trying to access auth screens, redirect to home
      if (isLoggedIn && 
          (state.location == '/auth/login' || 
           state.location == '/auth/register' ||
           state.location == '/onboarding')) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      // Onboarding route
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Home route and nested routes
      GoRoute(
        path: '/',
        redirect: (_, __) => '/home',
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/group/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupDetailScreen(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/event/:eventId',
        builder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),
      
      // Calendar routes
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/calendar/create',
        builder: (context, state) {
          final groupId = state.uri.queryParameters['groupId'];
          return CreateEventWizard(groupId: groupId);
        },
      ),
      
      // Chat routes
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatsScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatScreen(chatId: chatId);
        },
      ),
      
      // Profile route
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      
      // Create menu route
      GoRoute(
        path: '/create',
        builder: (context, state) => const CreateMenu(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.location}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ),
  );
});
