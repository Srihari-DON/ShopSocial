import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/group.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'data_service.dart';
import 'auth_service.dart';
import 'widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String groupId;

  const ChatScreen({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  bool _isLoading = false;
  Group? _group;
  List<User> _users = [];
  List<Message> _messages = [];
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final dataRepo = ref.read(dataRepositoryProvider);
      
      final group = await dataRepo.getGroupById(widget.groupId);
      final messages = await dataRepo.getMessagesForGroup(widget.groupId);
      final users = await dataRepo.getUsers();
      
      setState(() {
        _group = group;
        _messages = messages..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        _users = users;
        _isLoading = false;
      });
      
      // Scroll to bottom after messages load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading chat: ${e.toString()}')),
        );
      }
    }
  }

  User _getUserById(String userId) {
    return _users.firstWhere(
      (user) => user.id == userId,
      orElse: () => User(id: userId, name: 'Unknown', email: '', avatarUrl: ''),
    );
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;
    
    final currentUser = ref.read(authProvider).user;
    if (currentUser == null) return;
    
    final newMessage = Message(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUser.id,
      chatId: widget.groupId,
      content: messageText,
      createdAt: DateTime.now(),
    );
    
    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (_group != null) ...[
              Avatar(
                imageUrl: _group!.imageUrl,
                name: _group!.name,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(_group!.name),
            ] else
              const Text('Chat'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              context.go('/group/${widget.groupId}');
            },
          ),
        ],
      ),
      body: _isLoading || currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final sender = _getUserById(message.senderId);
                      final isMe = message.senderId == currentUser.id;
                      
                      return MessageBubble(
                        message: message.content,
                        timestamp: message.createdAt,
                        isMe: isMe,
                        senderName: sender.name,
                        senderAvatar: sender.avatarUrl,
                      );
                    },
                  ),
                ),
                
                // Message input
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
