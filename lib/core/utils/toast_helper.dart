import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';

showErrorMessage (String text){
  BotToast.showCustomNotification(
    toastBuilder: (cancelFunc) => Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: Colors.white, size: 24.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyOpenSans.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    ),
    duration: Duration(seconds: 3),
  );
}
showSuccessMessage (String text){
  BotToast.showCustomNotification(
    toastBuilder: (cancelFunc) => Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 24.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyOpenSans.copyWith(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    ),
    duration: Duration(seconds: 3),
  );
}