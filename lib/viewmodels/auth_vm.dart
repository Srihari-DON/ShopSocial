import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../services/user_service_mock.dart';

// Auth state class
class AuthState {
  final User? currentUser;
  final bool isLoading;
  final String? error;
  final bool hasSeenOnboarding;
  
  AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.hasSeenOnboarding = false,
  });
  
  AuthState copyWith({
    User? currentUser,
    bool? isLoading,
    String? error,
    bool? hasSeenOnboarding,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }
}

// Auth ViewModel (StateNotifier)
class AuthVM extends StateNotifier<AuthState> {
  final UserRepository _userRepository;
  
  AuthVM(this._userRepository) : super(AuthState()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Check if user has seen onboarding
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      
      // Try to get current user (might be null if not logged in)
      try {
        final user = await _userRepository.getCurrentUser();
        state = state.copyWith(
          currentUser: user,
          isLoading: false,
          error: null,
          hasSeenOnboarding: hasSeenOnboarding,
        );
      } catch (_) {
        state = state.copyWith(
          currentUser: null,
          isLoading: false,
          error: null,
          hasSeenOnboarding: hasSeenOnboarding,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _userRepository.loginWithEmail(email, password);
      state = state.copyWith(
        currentUser: user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> loginWithSocial(String provider) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _userRepository.loginWithSocial(provider);
      state = state.copyWith(
        currentUser: user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _userRepository.register(name, email, password);
      state = state.copyWith(
        currentUser: user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (state.currentUser == null) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedUser = await _userRepository.updateProfile(
        state.currentUser!.id,
        data,
      );
      
      state = state.copyWith(
        currentUser: updatedUser,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _userRepository.logout();
      state = state.copyWith(
        currentUser: null,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    state = state.copyWith(hasSeenOnboarding: true);
  }
}

// Providers
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(UserServiceMock());
});

final authVMProvider = StateNotifierProvider<AuthVM, AuthState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return AuthVM(userRepository);
});
