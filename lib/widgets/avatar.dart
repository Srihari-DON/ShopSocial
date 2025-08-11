import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';

/// A customizable avatar widget that displays user avatars, group images, or placeholders.
///
/// Supports different sizes, shapes, and optional badge.
class Avatar extends StatelessWidget {
  /// The image URL to display, if null a placeholder will be shown
  final String? imageUrl;
  
  /// The user's or group's name, used for generating a fallback initial when no image is available
  final String name;
  
  /// Size variant of the avatar
  final AvatarSize size;
  
  /// Shape of the avatar (circle or rounded square)
  final AvatarShape shape;
  
  /// Optional badge to show (like online status or unread count)
  final Widget? badge;
  
  /// Badge position (defaults to bottom right)
  final BadgePosition badgePosition;
  
  /// Optional border for the avatar
  final bool showBorder;
  
  /// Border color, defaults to primary color
  final Color? borderColor;
  
  /// Placeholder background color when no image is available
  final Color? placeholderColor;
  
  /// Whether to show initials when no image is available
  final bool showInitials;
  
  /// Optional callback when the avatar is tapped
  final VoidCallback? onTap;

  const Avatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = AvatarSize.medium,
    this.shape = AvatarShape.circle,
    this.badge,
    this.badgePosition = BadgePosition.bottomRight,
    this.showBorder = false,
    this.borderColor,
    this.placeholderColor,
    this.showInitials = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the size dimensions
    final double diameter = _getSizeDiameter();
    
    // Get border radius based on shape
    final BorderRadius borderRadius = _getBorderRadius(diameter);
    
    // Determine border settings if enabled
    final Border? border = showBorder 
        ? Border.all(
            color: borderColor ?? Theme.of(context).colorScheme.primary,
            width: 2.0,
          )
        : null;
    
    // Calculate initial text (first letters of each word in name)
    final String initials = _getInitials();
    
    // Determine background color for placeholder
    final Color backgroundColor = placeholderColor ?? 
        _getColorFromName(name, context);
    
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Main avatar content
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: border,
              color: backgroundColor,
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Show initials if image fails to load
                      return _buildInitialsPlaceholder(initials);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      // Show progress indicator while loading
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  )
                : _buildInitialsPlaceholder(initials),
          ),
          
          // Badge (if provided)
          if (badge != null)
            Positioned(
              top: badgePosition == BadgePosition.topRight || 
                   badgePosition == BadgePosition.topLeft
                  ? 0
                  : null,
              bottom: badgePosition == BadgePosition.bottomRight || 
                      badgePosition == BadgePosition.bottomLeft
                  ? 0
                  : null,
              left: badgePosition == BadgePosition.topLeft || 
                   badgePosition == BadgePosition.bottomLeft
                  ? 0
                  : null,
              right: badgePosition == BadgePosition.topRight || 
                    badgePosition == BadgePosition.bottomRight
                  ? 0
                  : null,
              child: badge!,
            ),
        ],
      ),
    );
  }

  // Get the appropriate size diameter based on the size variant
  double _getSizeDiameter() {
    switch (size) {
      case AvatarSize.extraSmall:
        return 24.0;
      case AvatarSize.small:
        return 32.0;
      case AvatarSize.medium:
        return 40.0;
      case AvatarSize.large:
        return 56.0;
      case AvatarSize.extraLarge:
        return 80.0;
    }
  }
  
  // Get border radius based on shape and size
  BorderRadius _getBorderRadius(double diameter) {
    switch (shape) {
      case AvatarShape.circle:
        return BorderRadius.circular(diameter / 2);
      case AvatarShape.rounded:
        return BorderRadius.circular(AppSpacing.sm);
    }
  }
  
  // Extract initials from name (up to 2 characters)
  String _getInitials() {
    if (!showInitials) return '';
    
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '';
    
    if (nameParts.length == 1) {
      return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
    } else {
      String firstInitial = nameParts[0].isNotEmpty ? nameParts[0][0] : '';
      String lastInitial = nameParts.last.isNotEmpty ? nameParts.last[0] : '';
      return (firstInitial + lastInitial).toUpperCase();
    }
  }
  
  // Build the placeholder with initials
  Widget _buildInitialsPlaceholder(String initials) {
    if (!showInitials || initials.isEmpty) {
      return const SizedBox();
    }
    
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size == AvatarSize.extraSmall 
              ? 8 
              : size == AvatarSize.small 
                  ? 12 
                  : size == AvatarSize.medium 
                      ? 16 
                      : size == AvatarSize.large 
                          ? 20 
                          : 28,
        ),
      ),
    );
  }
  
  // Generate a consistent color based on the name
  Color _getColorFromName(String name, BuildContext context) {
    if (name.isEmpty) return AppColors.primary;
    
    // List of colors to choose from for avatars
    final List<Color> avatarColors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.accent1,
      AppColors.accent2,
      AppColors.success,
      AppColors.warning,
    ];
    
    // Use hash code to deterministically select a color based on the name
    final int hashCode = name.hashCode;
    return avatarColors[hashCode.abs() % avatarColors.length];
  }
}

/// Available avatar size variants
enum AvatarSize {
  extraSmall,
  small,
  medium,
  large,
  extraLarge,
}

/// Available avatar shape variants
enum AvatarShape {
  circle,
  rounded,
}

/// Badge position options
enum BadgePosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// A badge showing an online status indicator
class OnlineBadge extends StatelessWidget {
  final bool isOnline;
  final double size;

  const OnlineBadge({
    super.key,
    required this.isOnline,
    this.size = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? AppColors.success : AppColors.textHint,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2.0,
        ),
      ),
    );
  }
}

/// A badge showing a count (e.g., unread messages)
class CountBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;

  const CountBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.danger,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
