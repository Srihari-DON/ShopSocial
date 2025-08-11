import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'avatar.dart';

/// A message bubble widget for chat conversations.
///
/// Displays text messages, images, or other content with appropriate styling.
class MessageBubble extends StatelessWidget {
  /// Message data to display
  final Message message;
  
  /// User who sent the message
  final User sender;
  
  /// Whether the message was sent by the current user
  final bool isMine;
  
  /// Whether to show the sender's name
  final bool showSenderName;
  
  /// Whether to show the sender's avatar
  final bool showAvatar;
  
  /// Whether this is the first message in a group
  final bool isFirstInGroup;
  
  /// Whether this is the last message in a group
  final bool isLastInGroup;
  
  /// Optional callback when the message is tapped
  final VoidCallback? onTap;
  
  /// Optional callback when the message is long pressed
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.sender,
    required this.isMine,
    this.showSenderName = false,
    this.showAvatar = true,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Determine bubble color based on who sent it
    final Color bubbleColor = isMine
        ? AppColors.primary
        : isDarkMode 
            ? AppColors.surface
            : AppColors.surfaceLighter;
    
    // Determine text color based on bubble color
    final Color textColor = isMine 
        ? Colors.white
        : isDarkMode 
            ? Colors.white
            : AppColors.textPrimary;
    
    // Calculate bubble border radius
    final BorderRadius borderRadius = _getBorderRadius();
    
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? AppSpacing.sm : AppSpacing.xs / 2,
        bottom: isLastInGroup ? AppSpacing.sm : AppSpacing.xs / 2,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar (only shown for received messages and if enabled)
          if (!isMine && showAvatar && isLastInGroup)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Avatar(
                imageUrl: sender.profileImageUrl,
                name: sender.name,
                size: AvatarSize.small,
              ),
            )
          else if (!isMine && showAvatar)
            const SizedBox(width: 32 + AppSpacing.xs), // Space for avatar
          
          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender name (if enabled and not the current user)
                if (showSenderName && !isMine && isFirstInGroup)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                      bottom: 2.0,
                    ),
                    child: Text(
                      sender.name,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                
                // Message bubble
                GestureDetector(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: borderRadius,
                    ),
                    child: _buildMessageContent(context, textColor),
                  ),
                ),
                
                // Timestamp
                if (isLastInGroup)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 4.0,
                      left: 4.0,
                      right: 4.0,
                    ),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: AppTypography.overline.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Space for avatar on the right (for sent messages)
          if (isMine && showAvatar)
            const SizedBox(width: 32 + AppSpacing.xs),
        ],
      ),
    );
  }
  
  // Build the appropriate content based on message type
  Widget _buildMessageContent(BuildContext context, Color textColor) {
    // Handle different message types
    switch (message.type) {
      case MessageType.text:
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            message.content,
            style: AppTypography.body2.copyWith(color: textColor),
          ),
        );
        
      case MessageType.image:
        return ClipRRect(
          borderRadius: _getBorderRadius(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              AspectRatio(
                aspectRatio: 16 / 9, // Default aspect ratio
                child: Image.network(
                  message.content,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surfaceDark,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Caption if available
              if (message.caption != null && message.caption!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Text(
                    message.caption!,
                    style: AppTypography.body2.copyWith(color: textColor),
                  ),
                ),
            ],
          ),
        );
        
      case MessageType.event:
      case MessageType.expense:
        // For shared events or expenses
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and label
              Row(
                children: [
                  Icon(
                    message.type == MessageType.event ? Icons.event : Icons.receipt_long,
                    color: textColor.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    message.type == MessageType.event ? 'Event' : 'Expense',
                    style: AppTypography.caption.copyWith(
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              
              // Title
              Text(
                message.content,
                style: AppTypography.subtitle2.copyWith(
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Description if available
              if (message.caption != null && message.caption!.isNotEmpty)
                Text(
                  message.caption!,
                  style: AppTypography.caption.copyWith(
                    color: textColor.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        );
        
      case MessageType.system:
        // System messages are centered and styled differently
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Text(
            message.content,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        );
    }
  }
  
  // Calculate border radius based on position in message group
  BorderRadius _getBorderRadius() {
    const double radius = 16.0;
    const double smallRadius = 4.0;
    
    if (isMine) {
      // For sent messages (right-aligned)
      return BorderRadius.only(
        topLeft: const Radius.circular(radius),
        topRight: isFirstInGroup 
            ? const Radius.circular(radius) 
            : const Radius.circular(smallRadius),
        bottomLeft: const Radius.circular(radius),
        bottomRight: isLastInGroup 
            ? const Radius.circular(radius) 
            : const Radius.circular(smallRadius),
      );
    } else {
      // For received messages (left-aligned)
      return BorderRadius.only(
        topLeft: isFirstInGroup 
            ? const Radius.circular(radius) 
            : const Radius.circular(smallRadius),
        topRight: const Radius.circular(radius),
        bottomLeft: isLastInGroup 
            ? const Radius.circular(radius) 
            : const Radius.circular(smallRadius),
        bottomRight: const Radius.circular(radius),
      );
    }
  }
  
  // Format timestamp for display
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
