import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthTextField extends StatelessWidget {
  AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? errorText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: errorText != null ? AppColors.error : context.colors.inputBorder.withOpacity(0.38),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        cursorColor: context.colors.primary,
        style: TextStyle(
          color: context.colors.textMain,
          fontSize: 14,
          letterSpacing: 1,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: context.colors.textMain.withOpacity(0.4),
            fontSize: 13,
            letterSpacing: 1,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 12, right: 10),
            child: Icon(
              icon,
              color: context.colors.secondary,
              size: 20,
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 44,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
