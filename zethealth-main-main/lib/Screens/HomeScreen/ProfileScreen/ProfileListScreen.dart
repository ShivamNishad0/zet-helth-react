import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/Models/ProfileModel.dart';
import 'package:zet_health/Screens/HomeScreen/ProfileScreen/ProfileListScreenController.dart';

import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomContainer.dart';
import '../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../../Helper/database_helper.dart';
import '../../../Models/PackageModel.dart';
import '../../../Models/custom_cart_model.dart';
import '../ItemDetailScreen/ItemDetailScreen.dart';

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({super.key});

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  ProfileListScreenController profileListScreenController =
      Get.put(ProfileListScreenController());
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    profileListScreenController.callGetProfileListApi(context, "All");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('popular_profiles'.tr, style: semiBoldBlack_18),
        actions: [
          CartButtonCommon(
              callBack: () => profileListScreenController.profileList.refresh())
        ],
      ),
      body: SingleChildScrollView(
        child: Obx(
          () => Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 15.w, right: 15.w, top: 16.h, bottom: 20.h),
                child: CupertinoTextField(
                  suffixMode: OverlayVisibilityMode.always,
                  minLines: 1,
                  placeholder: 'search_profile'.tr,
                  style: semiBoldBlack_14,
                  cursorColor: primaryColor,
                  textAlign: TextAlign.start,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  prefixMode: OverlayVisibilityMode.always,
                  onChanged: filterList,
                  prefix: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: SvgPicture.asset(searchDotsIcon)),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      border: Border.all(color: borderColor, width: 1.w)),
                  onTap: () {},
                ),
              ),
              profileListScreenController.isLoading.value
                  ? Container()
                  : profileListScreenController.profileList.isEmpty
                      ? Center(
                          child: NoDataFoundWidget(
                              title: 'no_profile_found'.tr, description: ''))
                      : ListView.builder(
                          itemCount:
                              profileListScreenController.profileList.length,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            NewPackageModel profileModel =
                                profileListScreenController.profileList[index];
                            CustomCartModel cartModel = CustomCartModel(
                              id: profileModel.id,
                              name: profileModel.name,
                              type: AppConstants.profile,
                              price: profileModel.price.toString(),
                              image: profileModel.image.toString(),
                              isFastRequired:
                                  profileModel.isFastRequired.toString(),
                              testTime: profileModel.testTime.toString(),
                              itemDetail: profileModel.itemDetail,
                              // profilesDetail: profileModel.profilesDetail,
                            );
                            return FutureBuilder<bool>(
                                future: dbHelper.checkRecordExist(
                                    id: profileModel.id.toString(),
                                    type: AppConstants.profile),
                                builder: (context, snapshot) {
                                  return CustomContainer(
                                    onTap: () {
                                      Get.to(() => ItemDetailScreen(
                                          customCartModel: cartModel));
                                    },
                                    bottom: 15.h,
                                    left: 15.w,
                                    right: 15.w,
                                    radius: 18.r,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: borderColor.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 5),
                                      )
                                    ],
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15.w, vertical: 13.h),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.r)),
                                                child: CachedNetworkImage(
                                                  height: 50.h,
                                                  width: 55.w,
                                                  fit: BoxFit.cover,
                                                  imageUrl:
                                                      AppConstants.IMG_URL +
                                                          profileModel.image!,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const ImageErrorWidget(),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      profileModel.name!,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(
                                                      height: 3.h,
                                                    ),
                                                    Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 9.w,
                                                                vertical: 2.h),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: cardBgColor,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10.r)),
                                                        ),
                                                        child: Text(
                                                          '${profileModel.price} ₹',
                                                          style:
                                                              semiBoldPrimary_12,
                                                        )),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: CustomContainer(
                                            bottom: 2.h,
                                            right: 2.w,
                                            leftPadding: 15.w,
                                            rightPadding: 15.w,
                                            topPadding: 6.h,
                                            color: primaryColor,
                                            bottomPadding: 6.h,
                                            onTap: () async {
                                              if (snapshot.data != null &&
                                                  snapshot.data!) {
                                                await dbHelper
                                                    .deleteRecordFormCart(
                                                        id: profileModel
                                                            .id
                                                            .toString(),
                                                        type: AppConstants
                                                            .profile);
                                              } else {
                                                await dbHelper.insertRecordCart(
                                                    cartModel: cartModel);
                                              }
                                              profileListScreenController
                                                  .profileList
                                                  .refresh();
                                            },
                                            radius: 20.r,
                                            child: Center(
                                                child: Text(
                                              snapshot.data != null &&
                                                      snapshot.data!
                                                  ? 'remove_from_cart'.tr
                                                  : 'add_to_cart'.tr,
                                              style: boldWhite_12,
                                            )),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                });
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  filterList(String query) {
    query = query.trim().toLowerCase();
    profileListScreenController.profileList.clear();
    if (query.isEmpty) {
      setState(() {
        profileListScreenController.profileList
            .addAll(profileListScreenController.filterList);
      });
    } else {
      for (int i = 0; i < profileListScreenController.filterList.length; i++) {
        if (profileListScreenController.filterList[i].name
            .toString()
            .toLowerCase()
            .contains(query)) {
          profileListScreenController.profileList
              .add(profileListScreenController.filterList[i]);
        }
      }
    }
    setState(() {});
  }
}
