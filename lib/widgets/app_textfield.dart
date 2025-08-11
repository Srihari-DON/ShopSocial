import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

/// A customizable text field widget that follows the app's design system.
///
/// Supports various input types, validation, and styling options.
class AppTextField extends StatefulWidget {
  /// Label text displayed above the input field
  final String label;
  
  /// Optional hint text displayed inside the field when empty
  final String? hint;
  
  /// Text controller for the field
  final TextEditingController? controller;
  
  /// Optional initial value if no controller is provided
  final String? initialValue;
  
  /// Called when text changes
  final Function(String)? onChanged;
  
  /// Keyboard type (e.g., email, number)
  final TextInputType keyboardType;
  
  /// Whether to obscure text (for passwords)
  final bool obscureText;
  
  /// Whether to enable the field
  final bool enabled;
  
  /// Whether the field is required
  final bool required;
  
  /// Optional error message to display
  final String? errorText;
  
  /// Optional helper text displayed below the field
  final String? helperText;
  
  /// Maximum number of characters allowed
  final int? maxLength;
  
  /// Maximum number of lines for multiline input
  final int? maxLines;
  
  /// Minimum number of lines for multiline input
  final int minLines;
  
  /// Optional prefixIcon displayed at the start of the field
  final IconData? prefixIcon;
  
  /// Optional suffixIcon displayed at the end of the field
  final Widget? suffixIcon;
  
  /// Input formatters for restricting input
  final List<TextInputFormatter>? inputFormatters;
  
  /// Whether to autofocus on this field
  final bool autofocus;
  
  /// Focus node for controlling focus
  final FocusNode? focusNode;
  
  /// Called when user submits the field
  final Function(String)? onSubmitted;
  
  /// Text capitalization options
  final TextCapitalization textCapitalization;
  
  /// Called when the field gets focus
  final Function()? onTap;
  
  /// Whether the field is read-only
  final bool readOnly;
  
  /// Input action (e.g., next, done) for keyboard
  final TextInputAction? textInputAction;
  
  /// Validator function for form validation
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.required = false,
    this.errorText,
    this.helperText,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.prefixIcon,
    this.validator,
    this.suffixIcon,
    this.inputFormatters,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.onTap,
    this.readOnly = false,
    this.textInputAction,
  }) : assert(controller != null || initialValue != null || onChanged != null);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  bool _obscureText = false;
  
  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
  }
  
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Determine if we should show a toggle for password visibility
    final bool showObscureToggle = widget.obscureText;
    
    // Build suffix icon (either provided suffix or password toggle)
    Widget? suffixWidget = widget.suffixIcon;
    
    if (showObscureToggle) {
      suffixWidget = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textHint,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator if needed
        Row(
          children: [
            Text(
              widget.label,
              style: AppTypography.subtitle2.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.textPrimary
                    : Colors.white,
              ),
            ),
            if (widget.required)
              Text(
                ' *',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.danger,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: _controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          textCapitalization: widget.textCapitalization,
          readOnly: widget.readOnly,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          style: AppTypography.body1.copyWith(
            color: widget.enabled
                ? Theme.of(context).brightness == Brightness.light
                    ? AppColors.textPrimary
                    : Colors.white
                : AppColors.textHint,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            suffixIcon: suffixWidget,
            errorMaxLines: 2,
            helperMaxLines: 2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.inputHorizontalPadding,
              vertical: AppSpacing.inputVerticalPadding,
            ),
          ),
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
        ),
      ],
    );
  }
}
