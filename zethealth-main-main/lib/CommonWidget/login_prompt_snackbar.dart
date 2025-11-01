// widgets/login_prompt_snackbar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zet_health/Helper/ColorHelper.dart';

class LoginPromptSnackbar {
  static void show({
    required String message,
    VoidCallback? onLoginTap,
  }) {
    // Close any existing snackbar
    if (Get.isSnackbarOpen) {
      Get.back();
    }

    // Small delay to ensure previous snackbar is closed
    Future.delayed(Duration(milliseconds: 300), () {
      Get.snackbar(
        '',
        '',
        titleText: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Login Required',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              TextButton(
                onPressed: () {
                  if (Get.isSnackbarOpen) {
                    Get.back();
                  }
                  if (onLoginTap != null) {
                    onLoginTap();
                  } else {
                    _defaultLoginAction();
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        messageText: SizedBox.shrink(),
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 70.h),
        padding: EdgeInsets.zero,
        borderRadius: 10.r,
        duration: Duration(seconds: 6),
        backgroundColor: primaryColor,
        colorText: Colors.white,
        isDismissible: true,
        dismissDirection: DismissDirection.down,
        boxShadows: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      );
    });
  }

  static void _defaultLoginAction() {
    print('Navigate to login screen');
  }
}