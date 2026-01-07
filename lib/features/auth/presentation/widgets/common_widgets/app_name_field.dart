import 'package:flutter/material.dart';
import 'app_text_field.dart';

class AppNameField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppNameField({
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
      label: label ?? 'Your name',
      hintText: hintText,
      keyboardType: TextInputType.name,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

