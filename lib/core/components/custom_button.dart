import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:virtual_career/core/theme/app_colors.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isLoading;
  final double verticalPadding;
  final bool isSecondButton;
  final Widget? prefixIcon;
  final Widget? suffixIcon; // Added suffixIcon

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.verticalPadding = 16,
    this.isSecondButton = false,
    this.prefixIcon,
    this.suffixIcon, // Added suffixIcon to constructor
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Full width
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondButton ? AppColor.buttonColor : Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: isLoading
            ? CupertinoActivityIndicator(color: isSecondButton ? Colors.black : Colors.white)
            : Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[
              prefixIcon!,
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: AppTextStyles.titlePoppins.copyWith(
                color: isSecondButton ? Colors.black : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (suffixIcon != null) ...[
              const SizedBox(width: 8),
              suffixIcon!,
            ],
          ],
        ),
      ),
    );
  }
}
