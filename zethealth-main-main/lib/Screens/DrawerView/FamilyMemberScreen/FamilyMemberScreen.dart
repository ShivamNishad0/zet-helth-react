import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomButton.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Screens/DrawerView/EditProfileScreen/EditProfileScreen.dart';
import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../../Models/UserDetailModel.dart';
import '../../MyCartScreen/AddPatientScreen/AddPatientScreen.dart';
import 'FamilyMemberScreenController.dart';

class FamilyMemberScreen extends StatefulWidget {
  const FamilyMemberScreen({super.key, this.selectedPatient});
  final Function(UserDetailModel)? selectedPatient;

  @override
  State<FamilyMemberScreen> createState() => _FamilyMemberScreenState();
}

class _FamilyMemberScreenState extends State<FamilyMemberScreen> {
  FamilyMemberScreenController familyMemberScreenController =
      Get.isRegistered<FamilyMemberScreenController>() ? Get.find<FamilyMemberScreenController>() : Get.put(FamilyMemberScreenController());

  @override
  void initState() {
    familyMemberScreenController.getPatientListApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('family_members'.tr, style: semiBoldBlack_18),
      ),
      body: Obx(
        () => familyMemberScreenController.isLoading.value
            ? Container()
            : familyMemberScreenController.patientList.isEmpty
                ? NoDataFoundWidget(
                    title: 'no_member_added_yet'.tr, description: '')
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    itemCount: familyMemberScreenController.patientList.length,
                    itemBuilder: (context, index) {
                      final patientList =
                          familyMemberScreenController.patientList[index];
                      String age = calculateAge('${patientList.dob}');
                      return GestureDetector(
                        onTap: () {
                          if (widget.selectedPatient != null) {
                            Get.back();
                            widget.selectedPatient?.call(patientList);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(16.r)),
                            boxShadow: [
                              BoxShadow(
                                color: borderColor.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 35.h,
                                    width: 35.h,
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(right: 10.w),
                                    decoration: BoxDecoration(
                                        color: cardBgColor,
                                        borderRadius:
                                            BorderRadius.circular(10.r)),
                                    child: Text(
                                      patientList.firstName
                                          .toString()
                                          .split(". ")
                                          .last
                                          .characters
                                          .first,
                                      style: TextStyle(
                                          fontFamily: semiBold,
                                          fontSize: 20.sp,
                                          color: primaryColor),
                                    ),
                                  ),
                                  Expanded(
                                      child: Text(
                                    '${patientList.firstName} ${patientList.lastName}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: semiBold,
                                        fontSize: 14.sp,
                                        color: greyColor2),
                                  )),
                                  SizedBox(width: 10.w),
                                    GestureDetector(
                                      onTap: () {
                                       if (patientList.relation == "My Self") {
                                            AppConstants().loadWithCanBack(const EditProfileScreen());
                                          } else {
                                            Get.to(() => AddPatientScreen(
                                              patientList: patientList,
                                              screenType: 1
                                            ));
                                          }
                                      },
                                      child: Container(
                                          height: 25.h,
                                          width: 25.h,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 3.h, horizontal: 3.h),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5.w),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: borderColor),
                                              borderRadius:
                                                  BorderRadius.circular(8.r)),
                                          child: Center(
                                              child: SvgPicture.asset(
                                                  renameIcon,
                                                  height: 15.h,
                                                  width: 15.h))),
                                    ),
                                  if (patientList.relation != "My Self")
                                    GestureDetector(
                                      onTap: () {
                                        Get.dialog(CommonDialog(
                                          title: 'Delete'.tr,
                                          description:
                                              'delete_family_member'.tr,
                                          tapNoText: 'cancel'.tr,
                                          tapYesText: 'confirm'.tr,
                                          onTapNo: () => Get.back(),
                                          onTapYes: () {
                                            Get.back();
                                            familyMemberScreenController
                                                .deletePatientApi(
                                                    id: patientList.id
                                                        .toString());
                                          },
                                        ));
                                      },
                                      child: Container(
                                          height: 25.h,
                                          width: 25.h,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: borderColor),
                                              borderRadius:
                                                  BorderRadius.circular(8.r)),
                                          child: Center(
                                            child: SvgPicture.asset(delete,
                                                height: 15.h, width: 15.h),
                                          )),
                                    ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                children: [
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 5.h, horizontal: 10.w),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        color: cardBgColor,
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                                text: 'Relationship : ',
                                                style: TextStyle(
                                                    fontFamily: semiBold,
                                                    fontSize: 10.sp,
                                                    color: greyColor2)),
                                            TextSpan(
                                                text: '${patientList.relation}',
                                                style: TextStyle(
                                                    fontFamily: semiBold,
                                                    fontSize: 12.sp,
                                                    color: greyColor2)),
                                          ],
                                        ),
                                      )),
                                  SizedBox(width: 10.w),
                                  if (age.isNotEmpty)
                                    Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.h, horizontal: 10.w),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          color: cardBgColor,
                                          borderRadius:
                                              BorderRadius.circular(15.r),
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: 'Age : ',
                                                  style: TextStyle(
                                                      fontFamily: semiBold,
                                                      fontSize: 10.sp,
                                                      color: greyColor2)),
                                              TextSpan(
                                                  text: age,
                                                  style: TextStyle(
                                                      fontFamily: semiBold,
                                                      fontSize: 12.sp,
                                                      color: greyColor2)),
                                            ],
                                          ),
                                        )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: SafeArea(
        child: CustomButton(
            horizontalMargin: 15.w,
            topMargin: 10.h,
            borderRadius: 10.r,
            text: 'add_new_member'.tr,
            onTap: () async {
              Get.to(() => const AddPatientScreen(screenType: 1));
            }),
      ),
    );
  }
}
