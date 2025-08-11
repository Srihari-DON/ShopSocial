import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

/// A customizable button widget with different variants.
///
/// Supports primary (filled), secondary (outlined), and text variants
/// with customizable colors, loading state, and icon options.
class AppButton extends StatelessWidget {
  /// The button label text
  final String text;
  
  /// Called when button is pressed
  final VoidCallback? onPressed;
  
  /// Optional leading icon
  final IconData? leadingIcon;
  
  /// Optional trailing icon
  final IconData? trailingIcon;
  
  /// Button variant (primary, secondary, text)
  final AppButtonVariant variant;
  
  /// Whether to show a loading indicator
  final bool isLoading;
  
  /// Whether button should expand to fill width
  final bool expandWidth;
  
  /// Custom button color (overrides variant default)
  final Color? color;
  
  /// Custom text color (overrides variant default)
  final Color? textColor;
  
  /// Button height (defaults to standard)
  final AppButtonSize size;
  
  /// Whether the button is disabled
  final bool disabled;
  
  /// Border radius (defaults to standard)
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.expandWidth = false,
    this.color,
    this.textColor,
    this.size = AppButtonSize.medium,
    this.disabled = false,
    this.borderRadius = AppSpacing.cardBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Define size properties
    final double height;
    final double iconSize;
    final TextStyle textStyle;
    final EdgeInsets padding;
    
    switch (size) {
      case AppButtonSize.small:
        height = 36.0;
        iconSize = 16.0;
        textStyle = AppTypography.button.copyWith(fontSize: 14.0);
        padding = const EdgeInsets.symmetric(horizontal: 16.0);
        break;
      case AppButtonSize.medium:
        height = 48.0;
        iconSize = 20.0;
        textStyle = AppTypography.button;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.buttonHorizontalPadding);
        break;
      case AppButtonSize.large:
        height = 56.0;
        iconSize = 24.0;
        textStyle = AppTypography.button.copyWith(fontSize: 18.0);
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.buttonHorizontalPadding);
        break;
    }
    
    // Calculate colors based on variant and state
    final Color backgroundColor;
    final Color textCol;
    final Color borderCol;
    final bool useElevation;
    
    final isDisabled = disabled || isLoading;
    
    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = isDisabled 
            ? AppColors.primary.withOpacity(0.5)
            : color ?? AppColors.primary;
        textCol = textColor ?? AppColors.onPrimary;
        borderCol = Colors.transparent;
        useElevation = true;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = Colors.transparent;
        textCol = isDisabled 
            ? (color ?? AppColors.primary).withOpacity(0.5)
            : textColor ?? (color ?? AppColors.primary);
        borderCol = isDisabled 
            ? (color ?? AppColors.primary).withOpacity(0.5)
            : color ?? AppColors.primary;
        useElevation = false;
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        textCol = isDisabled 
            ? (color ?? AppColors.primary).withOpacity(0.5)
            : textColor ?? (color ?? AppColors.primary);
        borderCol = Colors.transparent;
        useElevation = false;
        break;
    }
    
    // Build button content
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: SizedBox(
              height: iconSize,
              width: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(textCol),
              ),
            ),
          )
        else if (leadingIcon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Icon(leadingIcon, size: iconSize, color: textCol),
          ),
        Text(
          text,
          style: textStyle.copyWith(color: textCol),
        ),
        if (trailingIcon != null && !isLoading)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Icon(trailingIcon, size: iconSize, color: textCol),
          ),
      ],
    );
    
    // Apply width constraints
    if (expandWidth) {
      content = Center(child: content);
    }
    
    // Build the appropriate button type based on variant
    switch (variant) {
      case AppButtonVariant.primary:
        return SizedBox(
          height: height,
          width: expandWidth ? double.infinity : null,
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textCol,
              padding: padding,
              elevation: useElevation ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              disabledBackgroundColor: backgroundColor,
              disabledForegroundColor: textCol,
            ),
            child: content,
          ),
        );
      case AppButtonVariant.secondary:
        return SizedBox(
          height: height,
          width: expandWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: textCol,
              padding: padding,
              side: BorderSide(color: borderCol),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              disabledForegroundColor: textCol,
            ),
            child: content,
          ),
        );
      case AppButtonVariant.text:
        return SizedBox(
          height: height,
          width: expandWidth ? double.infinity : null,
          child: TextButton(
            onPressed: isDisabled ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: textCol,
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              disabledForegroundColor: textCol,
            ),
            child: content,
          ),
        );
    }
  }
}

enum AppButtonVariant {
  primary,
  secondary,
  text,
}

enum AppButtonSize {
  small,
  medium,
  large,
}
