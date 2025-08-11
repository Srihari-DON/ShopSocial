import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/message.dart';
import 'i_chat_service.dart';

class ChatServiceMock implements IChatService {
  late List<Message> _messages;
  final _messageControllers = <String, StreamController<Message>>{};
  
  ChatServiceMock() {
    _loadMessages();
  }
  
  Future<void> _loadMessages() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/mock_data/messages.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _messages = jsonList.map((json) => Message.fromJson(json)).toList();
    } catch (e) {
      // If file doesn't exist yet, create placeholder data
      _messages = [
        Message(
          id: 'm1',
          chatId: 'e1', // Using event id as chatId
          senderId: 'u1',
          content: 'Hey, I\'m thinking we should watch Iron Man first. Thoughts?',
          createdAt: DateTime.now().subtract(Duration(days: 1, hours: 2)),
        ),
        Message(
          id: 'm2',
          chatId: 'e1',
          senderId: 'u2',
          content: 'I vote for starting with Captain America: The First Avenger, chronological order!',
          createdAt: DateTime.now().subtract(Duration(days: 1, hours: 1)),
        ),
        Message(
          id: 'm3',
          chatId: 'e2',
          senderId: 'u2',
          content: 'Everyone ready for the mountains? Remember to pack warm clothes!',
          createdAt: DateTime.now().subtract(Duration(hours: 5)),
        ),
        Message(
          id: 'm4',
          chatId: 'e2',
          senderId: 'u1',
          content: 'I\'ll bring some hiking snacks for everyone.',
          attachmentUrl: 'assets/images/hiking_snacks.png',
          createdAt: DateTime.now().subtract(Duration(hours: 4)),
        ),
      ];
    }
  }
  
  @override
  Future<List<Message>> getMessages(String chatId, {int limit = 20, int offset = 0}) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    // Find messages for this chat, sort by date descending
    final filteredMessages = _messages
        .where((message) => message.chatId == chatId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // Apply pagination
    final paginatedMessages = filteredMessages.skip(offset).take(limit).toList();
    
    // Return in chronological order (oldest first)
    return paginatedMessages.reversed.toList();
  }
  
  @override
  Future<Message> sendMessage(Message message) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(300) + 200));
    
    // Create new message with generated ID
    final newMessage = Message(
      id: 'm${_messages.length + 1}',
      chatId: message.chatId,
      senderId: message.senderId,
      content: message.content,
      attachmentUrl: message.attachmentUrl,
      createdAt: DateTime.now(),
    );
    
    _messages.add(newMessage);
    
    // Notify subscribers about new message
    _notifyNewMessage(newMessage);
    
    return newMessage;
  }
  
  @override
  Future<void> deleteMessage(String messageId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    _messages.removeWhere((message) => message.id == messageId);
  }
  
  @override
  Future<List<String>> getChatIds(String userId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: Random().nextInt(200) + 200));
    
    // Get unique chat IDs where this user has sent or received messages
    final chatIds = _messages
        .where((message) => message.senderId == userId)
        .map((message) => message.chatId)
        .toSet()
        .toList();
    
    return chatIds;
  }
  
  @override
  Stream<Message> onNewMessage(String chatId) {
    if (!_messageControllers.containsKey(chatId)) {
      _messageControllers[chatId] = StreamController<Message>.broadcast();
    }
    
    return _messageControllers[chatId]!.stream;
  }
  
  void _notifyNewMessage(Message message) {
    final controller = _messageControllers[message.chatId];
    if (controller != null) {
      controller.add(message);
    }
  }
  
  // Simulate typing and read receipts
  void simulateTyping(String chatId, String userId) {
    // In a real app, we would emit a typing event to the subscribers
  }
  
  void simulateReadReceipt(String messageId, String userId) {
    // In a real app, we would mark the message as read
  }
  
  // Method to clean up resources
  void dispose() {
    for (final controller in _messageControllers.values) {
      controller.close();
    }
  }
}
