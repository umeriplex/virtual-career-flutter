import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:virtual_career/core/theme/app_text_styles.dart';

import '../../../core/theme/app_colors.dart';
import '../../../generated/assets.dart';

class PdfLoadingDialog extends StatelessWidget {
  final String message;

  const PdfLoadingDialog({
    super.key,
    this.message = "Generating PDF...",
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Lottie.asset(
                Assets.imagesPdfLoading,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              textAlign: TextAlign.center,
              message,
              style: AppTextStyles.titleOpenSans,
            ),
            const SizedBox(height: 15),
            LinearProgressIndicator(
              color: AppColor.buttonColor,
              minHeight: 2,
              backgroundColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}