import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomContainer.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Screens/AuthScreen/LoginScreenController.dart';
import '../../CommonWidget/CustomTextField2.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/StyleHelper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLoginSuccess});
  final Function() onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginScreenController loginScreenController =
      Get.put(LoginScreenController());
  FocusNode mobile = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
              right: 0, bottom: 0, child: SvgPicture.asset(splashFooterImg)),
          PaddingHorizontal20(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 53.h,
                ),
                Text('Zet Health',
                    style: boldPrimary_35,
                    textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false)),
                Text('Log In',
                    style: boldBlack_35,
                    textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false)),
                SizedBox(
                  height: 7.h,
                ),
                Text('Enter your mobile number',
                    style: TextStyle(
                        fontFamily: medium,
                        color: greyColor2,
                        fontSize: 14.sp)),
                SizedBox(
                  height: 25.h,
                ),
                CustomTextField2(
                    focusNode: mobile,
                    controller: loginScreenController.mobileNoController,
                    maxLength: 10,
                    hintText: 'enter_number'.tr,
                    textStyle: TextStyle(
                        fontFamily: medium, color: greyColor2, fontSize: 15.sp),
                    hintStyle: TextStyle(
                        fontFamily: bold,
                        color: gray.withOpacity(0.25),
                        fontSize: 18.sp),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    inputBorder: const UnderlineInputBorder(),
                    keyboardType: Platform.isIOS
                        ? TextInputType.phone
                        : TextInputType.number,
                    textInputAction: TextInputAction.done,
                    // contentPadding: EdgeInsets.only(left: 40.w, top: 10.h, bottom: 8.h, right: 10.w),
                    prefix: GestureDetector(
                      onTap: () {
                        // Get.dialog(CallBackDialogWithSearch(
                        //   type: 0,
                        //     callBack: (selectedCountryCode) {
                        //       loginScreenController.countryCode.value = selectedCountryCode;
                        //     },
                        // ));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 10.w),
                          Obx(() => Text(
                              loginScreenController.countryCode.value,
                              style: TextStyle(
                                  fontFamily: medium,
                                  color: greyColor2,
                                  fontSize: 15.sp))),
                          SizedBox(width: 5.w),
                          SvgPicture.asset(dropDownIcon),
                          SizedBox(width: 10.w),
                        ],
                      ),
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 50.h,
                    width: 130.w,
                    margin: EdgeInsets.only(top: 30.h),
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                            child: Image.asset(borderShape, fit: BoxFit.fill)),
                        Positioned.fill(
                          top: 4.h,
                          bottom: 4.h,
                          left: 4.h,
                          right: 4.h,
                          child: CustomContainer(
                            color: primaryColor,
                            radius: 18.r,
                            onTap: () {
                              if (loginScreenController.isValidate()) {
                                FocusScope.of(context).unfocus();
                                loginScreenController.callLoginApi(
                                    onLoginSuccess: widget.onLoginSuccess);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('continue'.tr, style: boldWhite_14),
                                SizedBox(width: 8.w),
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 14.sp)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // SizedBox(height: 35.h,),
                // GestureDetector(
                //   onTap: () {
                //     AppConstants().loadWithCanBack(RegisterScreen(''));
                //   },
                //   child: Center(
                //       child: RichText(
                //           text: TextSpan(
                //               children: [
                //                 TextSpan(
                //                     text: 'Don\'t have an account ?',
                //                     style: mediumBlack_13
                //                 ),
                //                 TextSpan(
                //                     text: ' Signup',
                //                     style: mediumPrimary_13
                //                 )
                //               ],
                //           )
                //       )
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
