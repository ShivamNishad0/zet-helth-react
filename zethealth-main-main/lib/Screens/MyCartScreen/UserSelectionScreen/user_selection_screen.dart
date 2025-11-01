import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomButton.dart';
import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../../Models/UserDetailModel.dart';
import '../../MyCartScreen/AddPatientScreen/AddPatientScreen.dart';
import 'user_selection_screen_controller.dart';

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key,this.selectedPatient});
  final Function(UserDetailModel)? selectedPatient;

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  UserSelectionScreenController userSelectionScreenController = Get.put(UserSelectionScreenController());

  @override
  void initState() {
    userSelectionScreenController.adminGetCustomerApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('users'.tr, style: semiBoldBlack_18),
      ),
      body: Obx(() => Column(
        children: [
          PaddingHorizontal15(
            child: CupertinoTextField(
              suffixMode: OverlayVisibilityMode.always,
              minLines: 1,
              placeholder: 'search_user'.tr,
              style: semiBoldBlack_14,
              cursorColor: primaryColor,
              textAlign: TextAlign.start,
              onChanged: filterList,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              prefixMode: OverlayVisibilityMode.always,
              prefix: Padding(padding: EdgeInsets.symmetric(horizontal: 10.w), child: SvgPicture.asset(searchDotsIcon)),
              decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(16)), border: Border.all(color: borderColor, width: 1.w)),
            ),
          ),
          Expanded(
            child: userSelectionScreenController.isLoading.value ? Container() : userSelectionScreenController.patientList.isEmpty ?
              NoDataFoundWidget(title: 'no_user_found'.tr, description: '') :
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 10.h),
                itemCount: userSelectionScreenController.patientList.length,
                itemBuilder: (context, index) {
                  final patientList = userSelectionScreenController.patientList[index];
                  return GestureDetector(
                    onTap: (){
                      if(widget.selectedPatient!=null){
                        Get.back();
                        widget.selectedPatient?.call(patientList);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16.r)),
                        boxShadow: [BoxShadow(color: borderColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 35.h,
                            width: 35.h,
                            margin: EdgeInsets.only(right: 10.w),
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(10.r)),
                            child: CachedNetworkImage(
                              imageUrl: AppConstants.IMG_URL + patientList.userProfile.toString(),
                              fit: BoxFit.fill,
                              alignment: Alignment.topCenter,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => const ImageErrorWidget(),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(patientList.userName.toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontFamily: semiBold,fontSize: 14.sp,color: greyColor2),
                                ),
                                SizedBox(height: 3.h),
                                Text(patientList.userMobile.toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontFamily: medium,fontSize: 13.sp,color: greyColor2),
                                ),
                                SizedBox(height: 3.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ),
        ],
      )),
      
      bottomNavigationBar: SafeArea(
        child: CustomButton(
            horizontalMargin: 15.w,
            topMargin: 10.h,
            borderRadius: 10.r,
            text: 'add_new_member'.tr,
            onTap: () async {
              Get.to(()=> const AddPatientScreen(screenType: 1));
            }
        ),
      ),
    );
  }

  filterList(String query) {
    userSelectionScreenController.patientList.clear();
    if(query.trim().isEmpty) {
      setState(() {
        userSelectionScreenController.patientList.addAll(userSelectionScreenController.tempPatientList);
      });
    }
    else {
      for(int i=0; i < userSelectionScreenController.tempPatientList.length; i++) {
        if(userSelectionScreenController.tempPatientList[i].userName.toString().toLowerCase().contains(query.trim().toLowerCase()) ||
           userSelectionScreenController.tempPatientList[i].userMobile.toString().toLowerCase().contains(query.trim().toLowerCase())
        ) {
          userSelectionScreenController.patientList.add(userSelectionScreenController.tempPatientList[i]);
        }
      }
    }
    userSelectionScreenController.patientList.refresh();
  }
}
