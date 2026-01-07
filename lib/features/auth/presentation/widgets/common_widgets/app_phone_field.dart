import 'package:flutter/material.dart';
import 'app_text_field.dart';

class AppPhoneField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppPhoneField({
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
      label: label ?? 'Phone Number',
      hintText: hintText ?? '+1234567890',
      keyboardType: TextInputType.phone,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!value.startsWith('+')) {
              return 'Phone number must include country code (e.g., +1)';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

