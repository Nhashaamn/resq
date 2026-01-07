import 'package:flutter/material.dart';
import 'app_text_field.dart';

class AppEmailField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppEmailField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label ?? 'Email Address',
      hintText: hintText ?? 'abc@gmail.com',
      keyboardType: TextInputType.emailAddress,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

