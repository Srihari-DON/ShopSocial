import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';
import '../models/group.dart';
import 'avatar.dart';

/// A card widget that displays group information.
///
/// Used in the group list, search results, and recommendations.
class GroupCard extends StatelessWidget {
  /// Group data to display
  final Group group;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Whether to show the member count
  final bool showMemberCount;
  
  /// Whether to show a compact version of the card
  final bool compact;
  
  /// Whether to show the trailing arrow icon
  final bool showTrailingIcon;
  
  /// Optional additional actions for the card
  final List<Widget>? actions;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
    this.showMemberCount = true,
    this.compact = false,
    this.showTrailingIcon = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: compact ? AppSpacing.xs / 2 : AppSpacing.xs,
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
        child: Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Group Avatar
              Avatar(
                imageUrl: group.imageUrl,
                name: group.name,
                size: compact ? AvatarSize.small : AvatarSize.medium,
                shape: AvatarShape.rounded,
              ),
              
              const SizedBox(width: AppSpacing.sm),
              
              // Group Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Group Name
                    Text(
                      group.name,
                      style: compact ? AppTypography.subtitle2 : AppTypography.subtitle1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (!compact) const SizedBox(height: AppSpacing.xs / 2),
                    
                    // Group Description or Member Count
                    if (showMemberCount)
                      Text(
                        '${group.memberIds.length} ${group.memberIds.length == 1 ? 'member' : 'members'}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (!compact && group.description != null && group.description!.isNotEmpty)
                      Text(
                        group.description!,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              
              // Actions or trailing icon
              if (actions != null)
                ...actions!
              else if (showTrailingIcon)
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
