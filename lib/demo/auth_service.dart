import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

// Auth state class
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Load mock users
      final String jsonString = await rootBundle.loadString('lib/mock_data/users.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final users = jsonList.map((json) => User.fromJson(json)).toList();
      
      // Find user with matching email
      final user = users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );
      
      // In a real app, we'd check the password here
      
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a new user
      final user = User(
        id: 'new_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        avatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random',
        bio: '',
      );
      
      // In a real app, we'd save the user to the backend
      
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void logout() {
    state = const AuthState();
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
