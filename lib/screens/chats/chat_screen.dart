import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../constants/colors.dart';
import '../../constants/spacing.dart';
import '../../constants/strings.dart';
import '../../models/message.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/chat_vm.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_textfield.dart';
import '../../widgets/avatar.dart';
import '../../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  
  const ChatScreen({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    // Load chat messages
    Future.microtask(() async {
      await ref.read(chatVMProvider.notifier).loadChatMessages(widget.chatId);
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = _messageController.text.trim();
    _messageController.clear();
    
    await ref.read(chatVMProvider.notifier).sendMessage(
      chatId: widget.chatId,
      content: message,
      type: MessageType.text,
    );
    
    // Scroll to the bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatVMProvider);
    final currentUser = ref.watch(authVMProvider).currentUser;
    
    // Find the current chat
    final currentChat = chatState.chats.firstWhere(
      (chat) => chat.id == widget.chatId,
      orElse: () => throw Exception('Chat not found'),
    );
    
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 1,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Row(
          children: [
            Avatar(
              imageUrl: currentChat.imageUrl,
              name: currentChat.name,
              size: AvatarSize.small,
              badge: currentChat.isActive ? const OnlineBadge(isOnline: true) : null,
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentChat.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (currentChat.isActive)
                  Text(
                    'Online',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show chat info
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat info not implemented in demo'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : currentChat.messages.isEmpty
                    ? _buildEmptyChat()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: currentChat.messages.length,
                        itemBuilder: (context, index) {
                          final message = currentChat.messages[index];
                          final isMine = message.senderId == currentUser?.id;
                          
                          // Determine if this is part of a message group
                          bool isFirstInGroup = true;
                          bool isLastInGroup = true;
                          
                          if (index > 0) {
                            final prevMessage = currentChat.messages[index - 1];
                            if (prevMessage.senderId == message.senderId &&
                                message.timestamp.difference(prevMessage.timestamp).inMinutes < 2) {
                              isFirstInGroup = false;
                            }
                          }
                          
                          if (index < currentChat.messages.length - 1) {
                            final nextMessage = currentChat.messages[index + 1];
                            if (nextMessage.senderId == message.senderId &&
                                nextMessage.timestamp.difference(message.timestamp).inMinutes < 2) {
                              isLastInGroup = false;
                            }
                          }
                          
                          // Find sender (for demo, we'll use a placeholder)
                          final sender = currentUser ?? User(
                            id: message.senderId,
                            name: 'User',
                            email: 'user@example.com',
                          );
                          
                          return MessageBubble(
                            message: message,
                            sender: sender,
                            isMine: isMine,
                            showSenderName: !isMine && isFirstInGroup,
                            showAvatar: isLastInGroup,
                            isFirstInGroup: isFirstInGroup,
                            isLastInGroup: isLastInGroup,
                          );
                        },
                      ),
          ),
          
          // Message input
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Attachment functionality not implemented in demo'),
                      ),
                    );
                  },
                ),
                
                // Text field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.lg),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[200]
                          : Colors.grey[800],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Emoji picker not implemented in demo'),
                            ),
                          );
                        },
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                
                const SizedBox(width: AppSpacing.xs),
                
                // Send button
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Messages Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Be the first to send a message in this conversation!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
