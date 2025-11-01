import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/Screens/AuthScreen/RegisterScreenController.dart';
import '../../CommonWidget/CustomContainer.dart';
import '../../CommonWidget/CustomTextField2.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';

class RegisterScreen extends StatefulWidget {
  final String mobileNo;
  const RegisterScreen(this.mobileNo, {super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  RegisterScreenController registerScreenController = Get.put(RegisterScreenController());
  FocusNode mobile = FocusNode();

  @override
  void initState() {
    super.initState();
    registerScreenController.mobileNoController.text = widget.mobileNo;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: Stack(
            children: [
              Positioned(
                  left: 0,
                  bottom: 0,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SvgPicture.asset(onBoardingHeaderImg),
                  )
              ),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 53.h,),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Zet',
                            style: boldPrimary_35,
                          ),
                          TextSpan(
                            text: ' Health',
                            style: boldBlack_35,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 7.h,),
                    Text('Enter Your Number and Book your\nTest now', style: TextStyle(fontFamily: medium, color: greyColor2, fontSize: 14.sp)),
                    SizedBox(height: 25.h,),
                    CustomTextField2(
                      controller: registerScreenController.nameController,
                      title: 'name'.tr,
                      hintText: 'enter_name'.tr,
                      topMargin: 5.h,
                      filled: true,
                      bottomMargin: 15.h,
                      textInputAction: TextInputAction.next,
                    ),
                    CustomTextField2(
                      controller: registerScreenController.emailController,
                      title: 'email'.tr,
                      hintText: 'enter_email'.tr,
                      topMargin: 5.h,
                      filled: true,
                      bottomMargin: 15.h,
                      textInputAction: TextInputAction.next,
                    ),
                    CustomTextField2(
                      focusNode: mobile,
                      controller: registerScreenController.mobileNoController,
                      title: 'number'.tr,
                      hintText: 'enter_number'.tr,
                      keyboardType: Platform.isIOS ? TextInputType.phone : TextInputType.number,
                      textInputAction: TextInputAction.done,
                      topMargin: 5.h,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      filled: true,
                      bottomMargin: 15.h,
                      prefix: GestureDetector(
                        onTap: (){},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 10.w),
                            Obx(() => Text(registerScreenController.countryCode.value, style: mediumBlack_14)),
                            SizedBox(width: 5.w),
                            SvgPicture.asset(dropDownIcon,height: 12.h),
                            SizedBox(width: 10.w),
                          ],
                        ),
                      )
                    ),
                    Text('gender'.tr, style: semiBoldBlack_14),
                    SizedBox(height: 5.h,),
                    Row(
                      children: [
                        Expanded(
                          child: CustomContainer(
                              topPadding: 6.h,
                              onTap: () {
                                setState(() {
                                  registerScreenController.selectedGender = 0;
                                });
                              },
                              bottomPadding: 6.h,
                              leftPadding: 6.w,
                              rightPadding: 6.w,
                              color: registerScreenController.selectedGender == 0 ? borderColor : cardBgColor,
                              radius: 16.r,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(38.r),
                                        border: Border.all(color: borderColor, width: 1.w),
                                      ),
                                      child: Container(
                                        width: 18.w,
                                        height: 16.h,
                                        decoration: BoxDecoration(
                                          color: registerScreenController.selectedGender == 0 ? primaryColor : cardBgColor,
                                          borderRadius: BorderRadius.circular(38.r),
                                        ),
                                      )
                                  ),
                                  SizedBox(width: 8.w,),
                                  Text('male'.tr, style: mediumBlack_14,),
                                ],
                              )
                          ),
                        ),
                        SizedBox(width: 6.w,),
                        Expanded(
                          child: CustomContainer(
                              topPadding: 6.h,
                              onTap: () {
                                setState(() {
                                  registerScreenController.selectedGender = 1;
                                });
                              },
                              bottomPadding: 6.h,
                              leftPadding: 6.w,
                              rightPadding: 6.w,
                              color: registerScreenController.selectedGender == 1 ? borderColor : cardBgColor,
                              radius: 16.r,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(38.r),
                                        border: Border.all(color: borderColor, width: 1.w),
                                      ),
                                      child: Container(
                                        width: 18.w,
                                        height: 16.h,
                                        decoration: BoxDecoration(
                                          color: registerScreenController.selectedGender == 1 ? primaryColor : cardBgColor,
                                          borderRadius: BorderRadius.circular(38.r),
                                        ),
                                      )
                                  ),
                                  SizedBox(width: 8.w,),
                                  Text('female'.tr, style: mediumBlack_14,),
                                ],
                              )
                          ),
                        ),
                        SizedBox(width: 6.w,),
                        Expanded(
                          child: CustomContainer(
                              topPadding: 6.h,
                              onTap: () {
                                setState(() {
                                  registerScreenController.selectedGender = 2;
                                });
                              },
                              bottomPadding: 6.h,
                              leftPadding: 6.w,
                              rightPadding: 6.w,
                              color: registerScreenController.selectedGender == 2 ? borderColor : cardBgColor,
                              radius: 16.r,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(38.r),
                                        border: Border.all(color: borderColor, width: 1.w),
                                      ),
                                      child: Container(
                                        width: 18.w,
                                        height: 16.h,
                                        decoration: BoxDecoration(
                                          color: registerScreenController.selectedGender == 2 ? primaryColor : cardBgColor,
                                          borderRadius: BorderRadius.circular(38.r),
                                        ),
                                      )
                                  ),
                                  SizedBox(width: 8.w,),
                                  Text('other'.tr, style: mediumBlack_14,),
                                ],
                              )
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 50.h,
                        width: 140.w,
                        margin: EdgeInsets.only(top: 30.h),
                        child: Stack(
                          fit: StackFit.expand,
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              child: Image.asset(borderShape,fit: BoxFit.fill)
                            ),
                            Positioned.fill(
                              top: 4.h,
                              bottom: 4.h,
                              left: 4.h,
                              right: 4.h,
                              child: CustomContainer(
                                color: primaryColor,
                                radius: 18.r,
                                onTap: () {
                                  if(registerScreenController.isValidate()) {
                                    registerScreenController.callRegisterApi(context);
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('register'.tr, style: boldWhite_14),
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
                    SizedBox(height: 35.h,),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        // AppConstants().loadWithCanNotAllBack(LoginScreen());
                      },
                      child: Center(
                          child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: 'Already have an account ?',
                                      style: mediumBlack_13
                                  ),
                                  TextSpan(
                                      text: ' Login',
                                      style: mediumPrimary_13
                                  )
                                ],
                              )
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
