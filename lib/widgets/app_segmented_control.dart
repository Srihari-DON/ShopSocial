import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

/// A segmented control widget for switching between options.
///
/// Similar to iOS segmented control or Material choice chip group.
class AppSegmentedControl<T> extends StatelessWidget {
  /// Current selected value
  final T selectedValue;
  
  /// List of available options
  final List<AppSegmentOption<T>> options;
  
  /// Callback when selection changes
  final ValueChanged<T> onValueChanged;
  
  /// Whether to fill the available width
  final bool fillWidth;
  
  /// Size variant of the control
  final SegmentedControlSize size;
  
  /// Whether to use primary color styling
  final bool primary;
  
  /// Optional tooltip for accessibility
  final String? tooltip;

  const AppSegmentedControl({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onValueChanged,
    this.fillWidth = true,
    this.size = SegmentedControlSize.medium,
    this.primary = true,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    // Determine colors based on theme and primary flag
    final Color selectedBgColor = primary 
        ? AppColors.primary 
        : isDarkMode 
            ? Colors.white 
            : Colors.black;
            
    final Color unselectedBgColor = isDarkMode 
        ? AppColors.surfaceDark 
        : AppColors.surfaceLighter;
        
    final Color selectedTextColor = primary 
        ? Colors.white 
        : isDarkMode 
            ? Colors.black 
            : Colors.white;
            
    final Color unselectedTextColor = isDarkMode 
        ? Colors.white70 
        : AppColors.textSecondary;
    
    // Determine heights based on size
    final double height = _getHeightForSize(size);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Semantics(
        toggled: true,
        hint: tooltip,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: unselectedBgColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: fillWidth 
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    children: _buildSegments(
                      context,
                      selectedBgColor,
                      unselectedBgColor,
                      selectedTextColor,
                      unselectedTextColor,
                    ),
                  )
                : IntrinsicWidth(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _buildSegments(
                        context,
                        selectedBgColor,
                        unselectedBgColor,
                        selectedTextColor,
                        unselectedTextColor,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
  
  // Build individual segments
  List<Widget> _buildSegments(
    BuildContext context,
    Color selectedBgColor,
    Color unselectedBgColor,
    Color selectedTextColor,
    Color unselectedTextColor,
  ) {
    return options.map((option) {
      final bool isSelected = option.value == selectedValue;
      
      return Expanded(
        flex: option.flex ?? 1,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onValueChanged(option.value);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? selectedBgColor : unselectedBgColor,
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: size == SegmentedControlSize.small ? AppSpacing.xs : AppSpacing.sm,
            ),
            child: DefaultTextStyle(
              style: _getTextStyleForSize(size).copyWith(
                color: isSelected ? selectedTextColor : unselectedTextColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (option.icon != null) ...[
                    Icon(
                      option.icon,
                      size: _getIconSizeForSize(size),
                      color: isSelected ? selectedTextColor : unselectedTextColor,
                    ),
                    SizedBox(width: size == SegmentedControlSize.small ? 4.0 : 8.0),
                  ],
                  Flexible(child: Text(option.label)),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
  
  // Get height based on size variant
  double _getHeightForSize(SegmentedControlSize size) {
    switch (size) {
      case SegmentedControlSize.small:
        return 32.0;
      case SegmentedControlSize.medium:
        return 40.0;
      case SegmentedControlSize.large:
        return 48.0;
    }
  }
  
  // Get text style based on size variant
  TextStyle _getTextStyleForSize(SegmentedControlSize size) {
    switch (size) {
      case SegmentedControlSize.small:
        return AppTypography.caption;
      case SegmentedControlSize.medium:
        return AppTypography.body2;
      case SegmentedControlSize.large:
        return AppTypography.body1;
    }
  }
  
  // Get icon size based on size variant
  double _getIconSizeForSize(SegmentedControlSize size) {
    switch (size) {
      case SegmentedControlSize.small:
        return 14.0;
      case SegmentedControlSize.medium:
        return 18.0;
      case SegmentedControlSize.large:
        return 20.0;
    }
  }
}

/// Option for the segmented control
class AppSegmentOption<T> {
  /// Value of this option
  final T value;
  
  /// Display label for this option
  final String label;
  
  /// Optional icon for this option
  final IconData? icon;
  
  /// Optional flex factor for this segment
  final int? flex;

  const AppSegmentOption({
    required this.value,
    required this.label,
    this.icon,
    this.flex,
  });
}

/// Size variants for segmented control
enum SegmentedControlSize {
  small,
  medium,
  large,
}
