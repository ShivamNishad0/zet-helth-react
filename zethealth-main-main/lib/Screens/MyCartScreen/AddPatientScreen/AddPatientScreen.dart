import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomButton.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Screens/MyCartScreen/AddPatientScreen/AddPatientScreenController.dart';
import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomContainer.dart';
import '../../../CommonWidget/CustomTextField2.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../../Models/UserDetailModel.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key,this.patientList,required this.screenType});
  final UserDetailModel? patientList;
  final int screenType;

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {

  AddPatientScreenController addPatientScreenController = Get.put(AddPatientScreenController());
  FocusNode mobileFocus = FocusNode();
  FocusNode dobFocus = FocusNode();

  @override
  void initState() {
    addPatientScreenController.userDetailModel = AppConstants().getUserDetails();
    addPatientScreenController.clearData();
    addPatientScreenController.setData(widget.patientList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CustomAppbar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          isLeading: true,
          title: Text('add_patient'.tr,style: semiBoldBlack_18),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 15.w,vertical: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 12.h),
          decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.all(Radius.circular(16.r)),
              boxShadow: [
                BoxShadow(color: borderColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 5))
              ]
          ),
          child: SingleChildScrollView(
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // First Name & Last Name Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextField2(
                            controller: addPatientScreenController.firstNameController,
                            title: 'first_name'.tr,
                            hintText: 'enter_first_name'.tr,
                            topMargin: 5.h,
                            filled: true,
                            bottomMargin: 0,
                            textInputAction: TextInputAction.next,
                            ),
                          // Error text for first name
                          if (addPatientScreenController.firstNameError.value.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 5.h),
                              child: Text(
                                addPatientScreenController.firstNameError.value,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextField2(
                            controller: addPatientScreenController.lastNameController,
                            title: 'last_name'.tr,
                            hintText: 'enter_last_name'.tr,
                            topMargin: 5.h,
                            filled: true,
                            bottomMargin: 0,
                            textInputAction: TextInputAction.next,
                          ),
                          // Error text for last name
                          if (addPatientScreenController.lastNameError.value.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 5.h),
                              child: Text(
                                addPatientScreenController.lastNameError.value,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),

                // Relation Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('relation'.tr, style: semiBoldBlack_14),
                    SizedBox(height: 5.h),
                    Container(
                      height: 40.h,
                      width: Get.width,
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.all(Radius.circular(15.r)),
                        border: Border.all(
                          color: addPatientScreenController.relationError.value.isEmpty 
                              ? borderColor 
                              : Colors.red,
                          width: 1.w,
                        ), 
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: addPatientScreenController.selectedRelation.value.isEmpty 
                              ? null 
                              : addPatientScreenController.selectedRelation.value,
                          hint: Text(
                            'Select an option'.tr, 
                            style: mediumGray_15,
                          ),
                          icon: SvgPicture.asset(dropDownIcon, height: 18.h, width: 18.h),
                          items: addPatientScreenController.relationOptions.map((String items) {
                            return DropdownMenuItem<String>(
                              value: items,
                              child: Text(items, style: mediumBlack_12),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            addPatientScreenController.selectedRelation.value = value!;
                            addPatientScreenController.relationError.value = "";
                          },
                        ),
                      ),
                    ),
                    // Error text for relation
                    if (addPatientScreenController.relationError.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Text(
                          addPatientScreenController.relationError.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 15.h),

                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField2(
                      controller: addPatientScreenController.emailController,
                      title: 'email'.tr,
                      hintText: 'enter_email'.tr,
                      topMargin: 5.h,
                      filled: true,
                      bottomMargin: 0, // Remove bottom margin
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    // Error text for email
                    if (addPatientScreenController.emailError.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Text(
                          addPatientScreenController.emailError.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 15.h),

                // Mobile Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField2(
                      focusNode: mobileFocus,
                      controller: addPatientScreenController.mobileController,
                      title: 'number'.tr,
                      hintText: 'enter_number'.tr,
                      topMargin: 5.h,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      filled: true,
                      keyboardType: Platform.isIOS ? TextInputType.phone : TextInputType.number,
                      bottomMargin: 0, // Remove bottom margin
                      textInputAction: TextInputAction.next,
                    ),
                    if (addPatientScreenController.mobileError.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Text(
                          addPatientScreenController.mobileError.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 15.h),

                // Date of Birth Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField2(
                      focusNode: dobFocus,
                      controller: addPatientScreenController.dobController,
                      title: 'dob'.tr,
                      hintText: "dd/MM/yyyy",
                      topMargin: 5.h,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
                        LengthLimitingTextInputFormatter(10),
                        CustomDateTextFormatter()
                      ],
                      filled: true,
                      keyboardType: Platform.isIOS ? TextInputType.phone : TextInputType.number,
                      bottomMargin: 0, // Remove bottom margin
                      textInputAction: TextInputAction.done,
                      suffixIcon: GestureDetector(
                        onTap: () async {
                          String? selectedDate = await AppConstants().openCalender(context, DateTime(1900), DateTime.now(), true);
                          if (selectedDate != null) {
                            addPatientScreenController.dobController.text = selectedDate;
                            addPatientScreenController.dobError.value = "";
                          }
                        },
                        child: PaddingHorizontal15(child: Icon(FontAwesomeIcons.calendarDay, size: 20.sp, color: primaryColor)),
                      ),
                    ),
                    if (addPatientScreenController.dobError.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Text(
                          addPatientScreenController.dobError.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 15.h),

                // Gender Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('gender'.tr, style: semiBoldBlack_14),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Expanded(
                          child: CustomContainer(
                              topPadding: 6.h,
                              bottomPadding: 6.h,
                              leftPadding: 6.w,
                              rightPadding: 6.w,
                              color: addPatientScreenController.selectedGender.value == 0 ? borderColor : cardBgColor,
                              radius: 16.r,
                              onTap: () {
                                addPatientScreenController.selectedGender.value = 0;
                                addPatientScreenController.genderError.value = "";
                              },
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
                                          color: addPatientScreenController.selectedGender.value == 0 ? primaryColor : cardBgColor,
                                          borderRadius: BorderRadius.circular(38.r),
                                        ),
                                      )
                                  ),
                                  SizedBox(width: 8.w),
                                  Text('male'.tr, style: mediumBlack_14),
                                ],
                              )
                          ),
                        ),
                        SizedBox(width: 6.w,),
                        Expanded(
                          child: CustomContainer(
                              topPadding: 6.h,
                              onTap: () {
                                addPatientScreenController.selectedGender.value = 1;
                                addPatientScreenController.genderError.value = "";
                              },
                              bottomPadding: 6.h,
                              leftPadding: 6.w,
                              rightPadding: 6.w,
                              color: addPatientScreenController.selectedGender.value == 1 ? borderColor : cardBgColor,
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
                                          color: addPatientScreenController.selectedGender.value == 1 ? primaryColor : cardBgColor,
                                          borderRadius: BorderRadius.circular(38.r),
                                        ),
                                      )
                                  ),
                                  SizedBox(width: 8.w,),
                                  Text('female'.tr, style: mediumBlack_14),
                                ],
                              )
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: CustomContainer(
                              topPadding: 6.h,
                              onTap: () {
                                addPatientScreenController.selectedGender.value = 2;
                                addPatientScreenController.genderError.value = "";
                              },
                              bottomPadding: 6.h,
                              leftPadding: 6.w,
                              rightPadding: 6.w,
                              color: addPatientScreenController.selectedGender.value == 2 ? borderColor : cardBgColor,
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
                                          color: addPatientScreenController.selectedGender.value == 2 ? primaryColor : cardBgColor,
                                          borderRadius: BorderRadius.circular(38.r),
                                        ),
                                      )
                                  ),
                                  SizedBox(width: 8.w,),
                                  Text('other'.tr, style: mediumBlack_14),
                                ],
                              )
                          ),
                        ),
                      ],
                    ),
                    // Error text for gender
                    if (addPatientScreenController.genderError.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 5.h),
                        child: Text(
                          addPatientScreenController.genderError.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                  ],
                ),

                // Save Button
                CustomButton(
                  topMargin: 30.h,
                  borderRadius: 20.r,
                  height: 39.h,
                  text: 'save_changes'.tr,
                  onTap: () {
                    if(addPatientScreenController.isValidate()) {
                      addPatientScreenController.callAddPatientApi(screenType:widget.screenType,patientList: widget.patientList);
                    }
                  }
                )
              ],
            )),
          )
        ),
      ),
    );
  }
}