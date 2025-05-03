import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.controller,
    this.textInputAction,
    this.focusNode,
    this.keyboardType,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.keyboardType ?? TextInputType.text,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      focusNode: widget.focusNode,
      controller: widget.controller,
      obscureText: widget.isPassword && !_isPasswordVisible,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.isPassword
            ? InkWell(
          onTap: _togglePasswordVisibility,
          child: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
        )
            : null,
      ),
    );
  }
}
