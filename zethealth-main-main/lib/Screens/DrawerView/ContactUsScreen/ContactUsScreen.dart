import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zet_health/Screens/DrawerView/ContactUsScreen/ContactUsScreenController.dart';

import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomButton.dart';
import '../../../CommonWidget/CustomTextField2.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  ContactUsScreenController contactUsScreenController =
      Get.put(ContactUsScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('contact_us'.tr, style: semiBoldBlack_18),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15.w),
              margin: EdgeInsets.only(bottom: 15.h, top: 15.h),
              decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16.r)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'email'.tr,
                          style: boldBlack_20,
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          '◈ ${AppConstants().getStorage.read(AppConstants.SUPPORT_EMAIL)}'
                              .tr,
                          style: mediumBlack_12,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'phone'.tr,
                          style: boldBlack_20,
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                        Text(
                          '◈ ${AppConstants().getStorage.read(AppConstants.SUPPORT_MOBILE)}'
                              .tr,
                          style: mediumBlack_12,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
                width: Get.width,
                decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.all(Radius.circular(16.r)),
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      )
                    ]),
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField2(
                      controller: contactUsScreenController.nameController,
                      title: 'name'.tr,
                      hintText: 'enter_name'.tr,
                      topMargin: 5.h,
                      filled: true,
                      bottomMargin: 15.h,
                      textInputAction: TextInputAction.next,
                    ),
                    CustomTextField2(
                      controller: contactUsScreenController.emailController,
                      title: 'email'.tr,
                      hintText: 'enter_email'.tr,
                      topMargin: 5.h,
                      filled: true,
                      bottomMargin: 15.h,
                      textInputAction: TextInputAction.next,
                    ),
                    CustomTextField2(
                      focusNode: FocusNode(),
                      controller: contactUsScreenController.mobileController,
                      title: 'number'.tr,
                      hintText: 'enter_number'.tr,
                      topMargin: 5.h,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      filled: true,
                      keyboardType: Platform.isIOS
                          ? TextInputType.phone
                          : TextInputType.number,
                      bottomMargin: 15.h,
                      textInputAction: TextInputAction.next,
                    ),
                    CustomTextField2(
                      controller: contactUsScreenController.subjectController,
                      title: 'subject'.tr,
                      topMargin: 5.h,
                      filled: true,
                      bottomMargin: 15.h,
                      textInputAction: TextInputAction.next,
                    ),
                    CustomTextField2(
                      controller: contactUsScreenController.messageController,
                      title: 'message'.tr,
                      topMargin: 5.h,
                      maxLines: 3,
                      height: 75.h,
                      filled: true,
                      textInputAction: TextInputAction.next,
                    ),
                    CustomButton(
                        topMargin: 20.h,
                        borderRadius: 20.r,
                        height: 39.h,
                        text: 'submit'.tr,
                        onTap: () {
                          if (contactUsScreenController.isValidate()) {
                            contactUsScreenController.callContactUsApi(
                                context, "contactus");
                          }
                        })
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
