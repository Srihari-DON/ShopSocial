import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/user.dart';
import 'i_user_service.dart';

class UserServiceMock implements IUserService {
  late List<User> _users;
  User? _currentUser;
  
  UserServiceMock() {
    _loadUsers();
  }
  
  Future<void> _loadUsers() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/mock_data/users.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _users = jsonList.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      // If file doesn't exist yet, create placeholder data
      _users = [
        User(
          id: 'u1',
          name: 'Alex Rao',
          email: 'alex@example.com',
          avatarUrl: 'assets/images/avatar1.png',
          bio: 'Love planning movie nights.',
        ),
        User(
          id: 'u2',
          name: 'Maya Iyer',
          email: 'maya@example.com',
          avatarUrl: 'assets/images/avatar2.png',
          bio: '',
        ),
      ];
    }
  }
  
  @override
  Future<User> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    if (_currentUser != null) {
      return _currentUser!;
    }
    
    // Return default user if none is logged in
    _currentUser = _users.first;
    return _currentUser!;
  }
  
  @override
  Future<User> getUserById(String id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    final user = _users.firstWhere(
      (user) => user.id == id,
      orElse: () => throw Exception('User not found'),
    );
    
    return user;
  }
  
  @override
  Future<List<User>> getUsersByIds(List<String> ids) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    return _users.where((user) => ids.contains(user.id)).toList();
  }
  
  @override
  Future<User> loginWithEmail(String email, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(500) + 500));
    
    final user = _users.firstWhere(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('Invalid email or password'),
    );
    
    _currentUser = user;
    return user;
  }
  
  @override
  Future<User> loginWithSocial(String provider) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(500) + 500));
    
    // Return a random user
    final user = _users[Random().nextInt(_users.length)];
    _currentUser = user;
    return user;
  }
  
  @override
  Future<User> register(String name, String email, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(500) + 500));
    
    // Check if email already exists
    if (_users.any((user) => user.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('Email already in use');
    }
    
    // Create new user
    final newUser = User(
      id: 'u${_users.length + 1}',
      name: name,
      email: email,
      avatarUrl: 'assets/images/avatar${Random().nextInt(5) + 1}.png',
      bio: '',
    );
    
    _users.add(newUser);
    _currentUser = newUser;
    
    return newUser;
  }
  
  @override
  Future<User> updateProfile(String userId, Map<String, dynamic> data) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 300));
    
    final userIndex = _users.indexWhere((user) => user.id == userId);
    if (userIndex == -1) {
      throw Exception('User not found');
    }
    
    // Update user with new data
    final currentUser = _users[userIndex];
    final updatedUser = User(
      id: currentUser.id,
      name: data['name'] ?? currentUser.name,
      email: data['email'] ?? currentUser.email,
      avatarUrl: data['avatarUrl'] ?? currentUser.avatarUrl,
      bio: data['bio'] ?? currentUser.bio,
    );
    
    _users[userIndex] = updatedUser;
    
    // Update current user if it's the same
    if (_currentUser?.id == userId) {
      _currentUser = updatedUser;
    }
    
    return updatedUser;
  }
  
  @override
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    _currentUser = null;
  }
}
