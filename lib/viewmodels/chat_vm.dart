import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/message.dart';
import '../models/user.dart';
import '../repositories/chat_repository.dart';
import '../repositories/user_repository.dart';
import '../services/chat_service_mock.dart';
import 'auth_vm.dart';

// Chat state
class ChatState {
  final List<Message> messages;
  final List<User> participants;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMoreMessages;
  final int totalMessages;
  
  ChatState({
    this.messages = const [],
    this.participants = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMoreMessages = true,
    this.totalMessages = 0,
  });
  
  ChatState copyWith({
    List<Message>? messages,
    List<User>? participants,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMoreMessages,
    int? totalMessages,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      participants: participants ?? this.participants,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      totalMessages: totalMessages ?? this.totalMessages,
    );
  }
}

// Chat ViewModel
class ChatVM extends StateNotifier<ChatState> {
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;
  final String chatId;
  final User? _currentUser;
  StreamSubscription<Message>? _messageSubscription;
  
  ChatVM(
    this._chatRepository,
    this._userRepository,
    this.chatId,
    this._currentUser,
  ) : super(ChatState()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    loadMessages();
    _subscribeToNewMessages();
  }
  
  void _subscribeToNewMessages() {
    _messageSubscription = _chatRepository.onNewMessage(chatId).listen((newMessage) {
      state = state.copyWith(
        messages: [newMessage, ...state.messages],
        totalMessages: state.totalMessages + 1,
      );
      
      // Update participants if needed
      if (!state.participants.any((user) => user.id == newMessage.senderId)) {
        _userRepository.getUserById(newMessage.senderId).then((user) {
          state = state.copyWith(
            participants: [...state.participants, user],
          );
        });
      }
    });
  }
  
  Future<void> loadMessages({int offset = 0, int limit = 20}) async {
    if (offset == 0) {
      state = state.copyWith(isLoading: true);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }
    
    try {
      final messages = await _chatRepository.getMessages(
        chatId,
        limit: limit,
        offset: offset,
      );
      
      // Get unique participant IDs
      final participantIds = <String>{};
      for (final message in messages) {
        participantIds.add(message.senderId);
      }
      
      // Get user details for participants
      final participants = await _userRepository.getUsersByIds(participantIds.toList());
      
      if (offset == 0) {
        state = state.copyWith(
          messages: messages,
          participants: participants,
          isLoading: false,
          error: null,
          hasMoreMessages: messages.length >= limit,
          totalMessages: messages.length,
        );
      } else {
        state = state.copyWith(
          messages: [...state.messages, ...messages],
          participants: [...state.participants, ...participants].toSet().toList(),
          isLoadingMore: false,
          error: null,
          hasMoreMessages: messages.length >= limit,
          totalMessages: state.totalMessages + messages.length,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || !state.hasMoreMessages) return;
    
    await loadMessages(offset: state.messages.length);
  }
  
  Future<void> sendMessage(String content, {String? attachmentUrl}) async {
    if (_currentUser == null) return;
    
    try {
      final newMessage = Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: _currentUser!.id,
        content: content,
        attachmentUrl: attachmentUrl,
        createdAt: DateTime.now(),
      );
      
      await _chatRepository.sendMessage(newMessage);
      // New message will come through subscription
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatRepository.deleteMessage(messageId);
      
      // Remove from local state
      final updatedMessages = state.messages.where((m) => m.id != messageId).toList();
      state = state.copyWith(
        messages: updatedMessages,
        totalMessages: state.totalMessages - 1,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  // Get user name by ID (helper method)
  String getUserName(String userId) {
    final user = state.participants.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(
        id: userId,
        name: 'Unknown User',
        email: '',
        avatarUrl: '',
        bio: '',
      ),
    );
    
    return user.name;
  }
  
  // Get user avatar by ID (helper method)
  String getUserAvatar(String userId) {
    final user = state.participants.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(
        id: userId,
        name: 'Unknown User',
        email: '',
        avatarUrl: '',
        bio: '',
      ),
    );
    
    return user.avatarUrl;
  }
  
  // Check if a message is from the current user
  bool isMessageFromCurrentUser(String senderId) {
    return _currentUser != null && senderId == _currentUser!.id;
  }
  
  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}

// Provider factory for ChatVM instances
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ChatServiceMock());
});

final chatVMProvider = StateNotifierProvider.family<ChatVM, ChatState, String>((ref, chatId) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final authState = ref.watch(authVMProvider);
  
  return ChatVM(
    chatRepository,
    userRepository,
    chatId,
    authState.currentUser,
  );
});
