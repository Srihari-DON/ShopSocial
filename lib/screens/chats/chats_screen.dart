import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/colors.dart';
import '../../constants/spacing.dart';
import '../../constants/strings.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/chat_vm.dart';
import '../../widgets/avatar.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  @override
  void initState() {
    super.initState();
    // Load chats when the screen is created
    Future.microtask(() {
      ref.read(chatVMProvider.notifier).loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatVMProvider);
    final currentUser = ref.watch(authVMProvider).currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search functionality not implemented in demo'),
                ),
              );
            },
          ),
        ],
      ),
      body: chatState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatState.chats.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: chatState.chats.length,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final chat = chatState.chats[index];
                    
                    // Find last message
                    final lastMessage = chat.messages.isNotEmpty 
                        ? chat.messages.last 
                        : null;
                    
                    // Count unread messages
                    final unreadCount = chat.messages.where((m) => 
                        !m.isRead && m.senderId != currentUser?.id).length;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        side: BorderSide(
                          color: AppColors.outline,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        onTap: () => context.push('/chat/${chat.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              // Avatar with online indicator
                              Stack(
                                children: [
                                  Avatar(
                                    imageUrl: chat.imageUrl,
                                    name: chat.name,
                                    size: AvatarSize.medium,
                                  ),
                                  if (chat.isActive)
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: OnlineBadge(isOnline: true),
                                    ),
                                ],
                              ),
                              
                              const SizedBox(width: AppSpacing.md),
                              
                              // Chat info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Chat name and time
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Chat name
                                        Expanded(
                                          child: Text(
                                            chat.name,
                                            style: TextStyle(
                                              fontWeight: unreadCount > 0 
                                                  ? FontWeight.bold 
                                                  : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        
                                        // Last message time
                                        if (lastMessage != null)
                                          Text(
                                            _formatMessageTime(lastMessage.timestamp),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: unreadCount > 0 
                                                  ? AppColors.primary 
                                                  : AppColors.textHint,
                                            ),
                                          ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: AppSpacing.xs / 2),
                                    
                                    // Last message preview and unread count
                                    Row(
                                      children: [
                                        // Last message preview
                                        Expanded(
                                          child: Text(
                                            lastMessage != null
                                                ? _getMessagePreview(lastMessage)
                                                : 'No messages yet',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: unreadCount > 0 
                                                  ? AppColors.textPrimary 
                                                  : AppColors.textSecondary,
                                              fontWeight: unreadCount > 0 
                                                  ? FontWeight.w500 
                                                  : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        
                                        // Unread count badge
                                        if (unreadCount > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              unreadCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // In a real app, this would navigate to create new chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New chat functionality not implemented in demo'),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat),
      ),
    );
  }
  
  Widget _buildEmptyState() {
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
            'No Chats Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start a conversation with your shopping companions',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () {
              // In a real app, this would navigate to create new chat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New chat functionality not implemented in demo'),
                ),
              );
            },
            icon: const Icon(Icons.chat),
            label: const Text('Start a Chat'),
          ),
        ],
      ),
    );
  }
  
  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      // Show time for today's messages
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      // Show date for older messages
      return '${time.day}/${time.month}';
    }
  }
  
  String _getMessagePreview(Message message) {
    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return '📷 Photo';
      case MessageType.event:
        return '📅 Event: ${message.content}';
      case MessageType.expense:
        return '💰 Expense: ${message.content}';
      case MessageType.system:
        return message.content;
      default:
        return '';
    }
  }
}
