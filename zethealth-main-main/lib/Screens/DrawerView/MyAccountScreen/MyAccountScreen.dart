import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../EditProfileScreen/EditProfileScreen.dart';
import 'MyAccountScreenController.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  Widget buildAccountHeader(AccountScreenController controller) {
    return GestureDetector(
      onTap: () {
        AppConstants().loadWithCanBack(const EditProfileScreen());
      },
      child: Padding(
        padding: EdgeInsets.only(left: 15.w, top: 20.h, right: 20.w),
        child: Row(
          children: [
            Container(
              height: 70.h,
              width: 70.h,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 5.w),
                borderRadius: BorderRadius.circular(100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  imageUrl: AppConstants.IMG_URL +
                      controller.userModel.value.userProfile.toString(),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                  const ImageErrorWidget(),
                ),
              ),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: ClipPath(
                child: Container(
                  height: 70.h,
                  padding: EdgeInsets.only(left: 10.w, right: 10.w),
                  decoration: BoxDecoration(
                    color: home_package_clr3,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(50.r),
                      topRight: Radius.circular(50.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // User Info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.userModel.value.userName.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: semiBoldBlack_20,
                            ),
                            Text(
                              controller.userModel.value.userMobile.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: semiBoldBlack_14,
                            )
                          ],
                        ),
                      ),
                      // Edit Icon
                      SvgPicture.asset(
                        editProfileIcon,
                        height: 22.h,
                        width: 22.w,
                        color: primaryColor2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final AccountScreenController controller = Get.put(AccountScreenController());

    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('my_account'.tr, style: semiBoldBlack_18),
      ),
      body: Obx(() => Column(
        children: [
          buildAccountHeader(controller), // Profile header
          SizedBox(height: 20.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              itemCount: controller.accountItemList.length,
              physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = controller.accountItemList[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: item.onclick,
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: double.infinity,
                          // padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
                          child: Row(
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  color: cardBgColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: cardBgColor,
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  item.image,
                                  height: 22.h,
                                  width: 22.w,
                                  color: primaryColor2,
                                ),
                              ),
                              SizedBox(width: 25.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.label.tr, style: mediumBlack_14),
                                    Container(
                                      margin: EdgeInsets.only(top: 4.h),
                                      height: 1.h,
                                      width: Get.width,
                                      color: borderColor,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
            ),
          ),
        ],
      )),
    );
  }
}
