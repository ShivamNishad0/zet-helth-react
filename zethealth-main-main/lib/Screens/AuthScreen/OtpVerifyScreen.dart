import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import '../../CommonWidget/CustomContainer.dart';
import '../../CommonWidget/PinCodeTextField.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key,required this.countryCode,required this.statusModel,required this.onLoginSuccess});
  final String countryCode;
  final Function() onLoginSuccess;
  final StatusModel statusModel;
  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {

  late StatusModel statusModel;
  TextEditingController otpController = TextEditingController();
  RxInt start = 30.obs;
  late Timer timer;
  RxBool isTimerStopped = false.obs;

  @override
  void initState() {
    statusModel = widget.statusModel;
    startTimer();
    super.initState();
  }

  void startTimer() {
    start.value = 30;
    isTimerStopped.value = false;
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (start.value < 1) {
        timer.cancel();
        isTimerStopped.value = true;
      } else {
        start.value = start.value - 1;
      }
    });
  }

  String getFormattedTime(int seconds) {
    final Duration duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0'); // Ensure two-digit format
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Stack(
          children: [
            Positioned(left: 0, bottom: 0, child: RotatedBox(quarterTurns: 1, child: SvgPicture.asset(splashFooterImg))),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 53.h,),
                  Text('We have sent you',
                      style: boldBlack_35, textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false)
                  ),
                  Text('OTP', style: boldPrimary_35, textHeightBehavior: const TextHeightBehavior(applyHeightToFirstAscent: false)),
                  SizedBox(height: 7.h),
                  RichText(
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Please enter the verification code sent to',
                            style: TextStyle(fontFamily: regular,fontSize: 13.sp,color: greyColor2)
                          ),
                          TextSpan(
                            text: '\n${widget.countryCode} ${statusModel.userDetail!.userMobile} ',
                            style: TextStyle(fontFamily: semiBold,fontSize: 14.sp,color: greyColor2)
                          ),
                          TextSpan(
                            text: 'edit',
                            style: TextStyle(fontFamily: semiBold,fontSize: 14.sp,color: primaryColor,decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Get.back();
                            },
                          )
                        ]
                    ),
                  ),
                  SizedBox(height: 25.h),
                  pinCodeField(context),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 50.h,
                      width: 150.w,
                      margin: EdgeInsets.only(top: 10.h),
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(child: Image.asset(borderShape,fit: BoxFit.fill)),
                          Positioned.fill(
                            top: 4.h,
                            bottom: 4.h,
                            left: 4.h,
                            right: 4.h,
                            child: CustomContainer(
                              color: primaryColor,
                              radius: 18.r,
                              onTap: () {
                                onCompleteVerification();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Verify OTP'.toUpperCase(), style: boldWhite_14),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.arrow_forward, color: Colors.white,size: 14.sp)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),
                  Center(
                    child: Obx(()=> isTimerStopped.value ?
                      RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(text: 'did_not_receive_otp'.tr, style: TextStyle(fontFamily: regular,fontSize: 13.sp,color: greyColor2)),
                              TextSpan(text: ' Resend OTP',
                                style: boldPrimary_14,
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  callLoginApi();
                              })
                            ]
                        ),
                      ) :
                      RichText(
                        text: TextSpan(
                            children: [
                              TextSpan(text: 'did_not_receive_otp'.tr, style: TextStyle(fontFamily: regular,fontSize: 13.sp,color: greyColor2)),
                              TextSpan(text: ' ${getFormattedTime(start.value)}', style: boldPrimary_14)
                            ]
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  onCompleteVerification() async {
    if(isValidate()) {
      AppConstants().getStorage.write(AppConstants.TOKEN, statusModel.token);
      AppConstants().getStorage.write(AppConstants.USER_ID, statusModel.userDetail!.userId);
      AppConstants().getStorage.write(AppConstants.USER_DETAIL, json.encode(statusModel.userDetail));
      AppConstants().getStorage.write(AppConstants.USER_TYPE, statusModel.userDetail!.userType);
      AppConstants().getStorage.write(AppConstants.USER_MOBILE, statusModel.userDetail!.userMobile);
      AppConstants().getStorage.write(AppConstants.USER_NAME, statusModel.userDetail!.userName);
      AppConstants().getStorage.write(AppConstants.LOGIN_COUNT, 0);
      
      // Handle address setup after login
      await AppConstants().handleAddressAfterLogin();
      
      Get.back();
      Get.back();
      widget.onLoginSuccess.call();
      showToast(message: 'Log in successful', color: green);
    }
  }

  Widget pinCodeField(context) {
    return PaddingHorizontal15(
      child: PinCodeTextField(
        autoFocus: true,
        showCursor: false,
        keyboardType: TextInputType.number,
        appContext: context,
        length: 6,
        errorTextSpace: 30.w,
        onChanged: (value) {},
        controller: otpController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textStyle: TextStyle(fontFamily: semiBold, color: primaryColor, fontSize: 17.sp),
        pinTheme: PinTheme(
          inactiveFillColor: greyColor,
          selectedFillColor: Colors.black,
          shape: PinCodeFieldShape.underline,
          borderWidth: 1.w,
          borderRadius: BorderRadius.circular(15.sp),
          selectedColor: primaryColor,
          inactiveColor: greyColor,
          activeColor: primaryColor,
        ),
        onCompleted: (value) {
          otpController.text = value;
          onCompleteVerification();
        },
      ),
    );
  }

  isValidate() {
    if (otpController.text.trim().isEmpty) {
      showToast(message: 'please_enter_otp'.tr);
      return false;
    }
    else if (otpController.text.length < 6) {
      showToast(message: 'please_enter_valid_otp'.tr);
      return false;
    }
    else if (statusModel.lastOtp.toString() != otpController.text.trim()) {
      showToast(message: 'otp_invalid'.tr);
      return false;
    }
    else {
      return true;
    }
  }

  callLoginApi() {
    Map<String, dynamic> params = {
      "mobile_number": statusModel.userDetail!.userMobile.toString(),
      'user_type': 'User',
    };

    WebApiHelper().callFormDataPostApi(null, AppConstants.LOGIN_API, params, true).then((response) {
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
          if(statusModel.status!) {
            this.statusModel = statusModel;
            startTimer();
          }
          else {
            showToast(message: statusModel.message.toString());
          }
        }
      }
    );
  }

}

