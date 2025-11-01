import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:zet_health/Helper/AssetHelper.dart';

import '../Helper/AppConstants.dart';
import '../Helper/ColorHelper.dart';
import '../Helper/StyleHelper.dart';
import '../Screens/AuthScreen/LoginScreen.dart';
import 'CustomContainer.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double? width;
  final double? height;
  final bool? isDisMissile;

  const CustomLoadingIndicator({
    super.key,
    this.width,
    this.height,
    this.isDisMissile = true,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => isDisMissile!,
        child: Center(
          // child: CircularProgressIndicator(color: primaryColor)
          child: Lottie.asset(
            'assets/load_animation.json',
            width: width ?? 100,
            height: height ?? 100,
            fit: BoxFit.contain,
          ),
        )
    );
  }
}

class NoDataFoundWidget extends StatelessWidget {
  final String title;
  final String? svgImage;
  final String description;

  const NoDataFoundWidget({
    super.key,
    this.svgImage,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(svgImage ?? noDataImg, height: 150.h),
          SizedBox(
            height: 5.h,
          ),
          Text(
            title.tr,
            style: semiBoldBlack_16,
            textAlign: TextAlign.center,
          ),
          Text(description.tr,
              style: mediumBlack_14, textAlign: TextAlign.center)
        ],
      ),
    );
  }
}

class NoLoginWidget extends StatelessWidget {
  const NoLoginWidget({super.key, required this.onLoginSuccess});
  final Function() onLoginSuccess;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(noLogin, width: Get.width / 2),
          Text('Not Login'.tr, style: semiBoldBlack_16),
          Text('Please Login First'.tr, style: mediumBlack_14),
          CustomContainer(
            onTap: () {
              AppConstants()
                  .loadWithCanBack(LoginScreen(onLoginSuccess: onLoginSuccess));
            },
            color: primaryColor,
            top: 10.h,
            topPadding: 10.h,
            bottomPadding: 10.h,
            leftPadding: 20.w,
            rightPadding: 20.w,
            radius: 20.r,
            borderWidth: 2.w,
            borderColor: whiteColor,
            child: Text('continue'.tr, style: boldWhite_16),
          ),
        ],
      ),
    );
  }
}
