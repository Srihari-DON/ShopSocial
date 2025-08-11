import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/group.dart';
import '../models/event.dart';
import '../models/expense.dart';
import '../models/message.dart';

// Repository to load data from JSON files
class DataRepository {
  // Load users
  Future<List<User>> getUsers() async {
    final String jsonString = await rootBundle.loadString('lib/mock_data/users.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => User.fromJson(json)).toList();
  }
  
  // Get user by ID
  Future<User> getUserById(String id) async {
    final users = await getUsers();
    return users.firstWhere(
      (user) => user.id == id,
      orElse: () => throw Exception('User not found'),
    );
  }

  // Load groups
  Future<List<Group>> getGroups() async {
    final String jsonString = await rootBundle.loadString('lib/mock_data/groups.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Group.fromJson(json)).toList();
  }
  
  // Get group by ID
  Future<Group> getGroupById(String id) async {
    final groups = await getGroups();
    return groups.firstWhere(
      (group) => group.id == id,
      orElse: () => throw Exception('Group not found'),
    );
  }

  // Get groups for user
  Future<List<Group>> getGroupsForUser(String userId) async {
    final groups = await getGroups();
    return groups.where((group) => group.memberIds.contains(userId)).toList();
  }

  // Load events
  Future<List<Event>> getEvents() async {
    final String jsonString = await rootBundle.loadString('lib/mock_data/events.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Event.fromJson(json)).toList();
  }
  
  // Get event by ID
  Future<Event> getEventById(String id) async {
    final events = await getEvents();
    return events.firstWhere(
      (event) => event.id == id,
      orElse: () => throw Exception('Event not found'),
    );
  }

  // Get events for user
  Future<List<Event>> getEventsForUser(String userId) async {
    final events = await getEvents();
    // We'll treat createdBy as the attendee for simplicity in this demo
    return events.where((event) => event.createdBy == userId).toList();
  }

  // Get events for group
  Future<List<Event>> getEventsForGroup(String groupId) async {
    final events = await getEvents();
    return events.where((event) => event.groupId == groupId).toList();
  }

  // Load expenses
  Future<List<Expense>> getExpenses() async {
    final String jsonString = await rootBundle.loadString('lib/mock_data/expenses.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Expense.fromJson(json)).toList();
  }
  
  // Get expenses for group
  Future<List<Expense>> getExpensesForGroup(String groupId) async {
    final expenses = await getExpenses();
    // In our model, expenses are linked to events, so we'll get all events in the group first
    final events = await getEventsForGroup(groupId);
    final eventIds = events.map((e) => e.id).toList();
    return expenses.where((expense) => eventIds.contains(expense.eventId)).toList();
  }

  // Load messages
  Future<List<Message>> getMessages() async {
    final String jsonString = await rootBundle.loadString('lib/mock_data/messages.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Message.fromJson(json)).toList();
  }
  
  // Get messages for group
  Future<List<Message>> getMessagesForGroup(String groupId) async {
    final messages = await getMessages();
    // In our model, chatId is used instead of groupId
    return messages.where((message) => message.chatId == groupId).toList();
  }
}

// Provider
final dataRepositoryProvider = Provider<DataRepository>((ref) {
  return DataRepository();
});
