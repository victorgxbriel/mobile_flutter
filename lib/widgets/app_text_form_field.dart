import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppTextFormFieldLabelStyle {
  floating,
  fixed,
}

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.labelStyle = AppTextFormFieldLabelStyle.floating,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final AppTextFormFieldLabelStyle labelStyle;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      enabled: enabled,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText:
            labelStyle == AppTextFormFieldLabelStyle.floating ? label : null,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    if (labelStyle == AppTextFormFieldLabelStyle.fixed && label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          field,
        ],
      );
    }

    return field;
  }
}
