import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';
import '../models/event.dart';
import '../models/user.dart';
import 'avatar.dart';

/// A card widget that displays event information.
///
/// Used in the event list, calendar, and recommendations.
class EventCard extends StatelessWidget {
  /// Event data to display
  final Event event;
  
  /// User data for the event creator
  final User creator;
  
  /// Optional list of attendee users to display
  final List<User>? attendees;
  
  /// Maximum number of attendees to show avatars for
  final int maxAttendeesToShow;
  
  /// Whether to show a compact version of the card
  final bool compact;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Optional additional actions for the card
  final List<Widget>? actions;

  const EventCard({
    super.key,
    required this.event,
    required this.creator,
    this.attendees,
    this.maxAttendeesToShow = 3,
    this.compact = false,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Format date and time for display
    final String formattedDate = _formatDate(event.startTime);
    final String formattedTime = _formatTime(event.startTime, event.endTime);
    
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: compact ? AppSpacing.xs / 2 : AppSpacing.sm,
        horizontal: 0,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        side: BorderSide(
          color: isDarkMode ? AppColors.surface : AppColors.outline,
          width: 1.0,
        ),
      ),
      color: isDarkMode ? AppColors.surface : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image if available
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty && !compact)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.sm),
                    topRight: Radius.circular(AppSpacing.sm),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(event.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
            // Event details
            Padding(
              padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event name and date
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar icon with date
                      if (!compact)
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.xs),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                event.startTime.day.toString(),
                                style: AppTypography.subtitle2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getMonthAbbreviation(event.startTime.month),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event name
                            Text(
                              event.name,
                              style: compact ? AppTypography.subtitle2 : AppTypography.subtitle1,
                              maxLines: compact ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: AppSpacing.xs),
                            
                            // Date and time
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.xs / 2),
                                Text(
                                  formattedDate,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Icon(
                                  Icons.access_time_outlined,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.xs / 2),
                                Text(
                                  formattedTime,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Description
                  if (!compact && event.description != null && event.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        event.description!,
                        style: AppTypography.body2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  // Creator and attendees
                  if (!compact)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Row(
                        children: [
                          // Creator
                          Row(
                            children: [
                              Avatar(
                                imageUrl: creator.profileImageUrl,
                                name: creator.name,
                                size: AvatarSize.extraSmall,
                              ),
                              const SizedBox(width: AppSpacing.xs / 2),
                              Text(
                                'Created by ${creator.name}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          
                          const Spacer(),
                          
                          // Attendees avatars
                          if (attendees != null && attendees!.isNotEmpty)
                            _buildAttendeeAvatars(),
                        ],
                      ),
                    ),
                    
                  // Actions
                  if (actions != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions!,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Format date for display
  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthAbbreviation(date.month)} ${date.year}';
  }
  
  // Format time for display
  String _formatTime(DateTime start, DateTime end) {
    String startTime = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    String endTime = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$startTime - $endTime';
  }
  
  // Get month abbreviation
  String _getMonthAbbreviation(int month) {
    const List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
  
  // Build attendee avatars stack
  Widget _buildAttendeeAvatars() {
    final displayedAttendees = attendees!.take(maxAttendeesToShow).toList();
    final remainingCount = attendees!.length - displayedAttendees.length;
    
    return Row(
      children: [
        // Stacked avatars
        SizedBox(
          width: 20.0 + (displayedAttendees.length - 1) * 10.0,
          height: 20.0,
          child: Stack(
            children: [
              for (int i = 0; i < displayedAttendees.length; i++)
                Positioned(
                  left: i * 10.0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 1.5,
                      ),
                    ),
                    child: Avatar(
                      imageUrl: displayedAttendees[i].profileImageUrl,
                      name: displayedAttendees[i].name,
                      size: AvatarSize.extraSmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Remaining count
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              '+$remainingCount',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
