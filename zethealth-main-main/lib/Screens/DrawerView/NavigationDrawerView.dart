import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AssetHelper.dart';
import 'package:zet_health/Helper/StyleHelper.dart';
import 'package:zet_health/Models/DrawerModel.dart';
import 'package:zet_health/Screens/AuthScreen/LoginScreen.dart';
import 'package:zet_health/Screens/BottomBarScreen.dart';
import 'package:zet_health/Screens/DrawerView/CMSScreen/CMSScreen.dart';
import 'package:zet_health/Screens/DrawerView/ContactUsScreen/ContactUsScreen.dart';
import 'package:zet_health/Screens/DrawerView/NavigationDrawerController.dart';
import 'package:share_plus/share_plus.dart';
import '../../CommonWidget/CustomWidgets.dart';
import '../../Helper/AppConstants.dart';
import '../../Helper/ColorHelper.dart';
import '../../main.dart';
import '../BranchScreen/branchListScreen.dart';
import '../HomeScreen/HomeScreenController.dart';
import 'MyAccountScreen/MyAccountScreen.dart';
import 'PartnerWithusScreen/PartnerWithusScreen.dart';

class NavigationDrawerView extends StatefulWidget {
  const NavigationDrawerView({super.key});

  @override
  State<NavigationDrawerView> createState() => _NavigationDrawerViewState();
}

class _NavigationDrawerViewState extends State<NavigationDrawerView> {
  NavigationDrawerController navigationDrawerController =
      Get.put(NavigationDrawerController());
  Function? userModelListen;
  Function? listListen;
  Function? cartCounterListen;

  @override
  void initState() {
    super.initState();
    checkDrawerMenu();

    // ever(homeScreenController.prescriptionList, (_) {
    //   navigationDrawerController.drawerItemList.clear();
    //   checkDrawerMenu();
    // });

    userModelListen =
        AppConstants().getStorage.listenKey(AppConstants.USER_DETAIL, (value) {
      setState(() {
        navigationDrawerController.userModel.value =
            AppConstants().getUserDetails();
      });
    });

    listListen =
        AppConstants().getStorage.listenKey(AppConstants.USER_MOBILE, (value) {
      setState(() {
        checkDrawerMenu();
      });
    });

    navigationDrawerController.cartCounter.value =
        AppConstants().getStorage.read(AppConstants.cartCounter) ?? 0;
    cartCounterListen =
        AppConstants().getStorage.listenKey(AppConstants.cartCounter, (value) {
      if (value != null) {
        navigationDrawerController.cartCounter.value = value;
      }
    });
  }

  checkDrawerMenu() {
    navigationDrawerController.drawerItemList = [];
    if (checkLogin()) {
      navigationDrawerController.drawerItemList.addAll([
        DrawerModel(
            label: 'my_account',
            image: myAccountIcon,
            onclick: () {
              scaffoldKey.currentState?.closeDrawer();
              AppConstants().loadWithCanBack(const MyAccountScreen());
            }),
        DrawerModel(
            label: 'partner_with_us',
            image: partnerWithUsIcon,
            onclick: () {
              scaffoldKey.currentState?.closeDrawer();
              AppConstants().loadWithCanBack(const PartnerWithusScreen());
            }),
        DrawerModel(
          label: 'About Us',
          image: aboutUsIcon,
          onclick: () {
            scaffoldKey.currentState?.closeDrawer();
            AppConstants()
                .loadWithCanBack(const CMSScreen(AppConstants.ABOUT_US));
          },
        ),
        DrawerModel(
          label: 'contact_us',
          image: contactUsIcon,
          onclick: () {
            scaffoldKey.currentState?.closeDrawer();
            AppConstants().loadWithCanBack(const ContactUsScreen());
          },
        ),
        // DrawerModel(
        //   label: 'Branch list',
        //   image: contactUsIcon,
        //   onclick: () {
        //     scaffoldKey.currentState?.closeDrawer();
        //     AppConstants().loadWithCanBack(const BranchList());
        //   },
        // ),
        DrawerModel(
            label: 'Share App',
            image: shareAppIcon,
            onclick: () {
              try {
                Share.share(
                  'share_app_message'.tr,
                );
              } catch (e) {
                e.toString();
              }
            }),
        DrawerModel(
            label: 'Log out',
            image: logoutIcon,
            onclick: () {
              Get.dialog(CommonDialog(
                title: 'Logout'.tr,
                description: 'Are you sure you want to logout ?'.tr,
                tapNoText: 'cancel'.tr,
                tapYesText: 'confirm'.tr,
                onTapNo: () => Get.back(),
                onTapYes: () {
                  Get.back();
                  AppConstants().getStorage.write(AppConstants.TOKEN, null);
                  AppConstants().getStorage.write(AppConstants.USER_ID, null);
                  AppConstants()
                      .getStorage
                      .write(AppConstants.USER_DETAIL, null);
                  AppConstants().getStorage.write(AppConstants.USER_TYPE, null);
                  AppConstants().getStorage.write(AppConstants.USER_NAME, null);
                  AppConstants()
                      .getStorage
                      .write(AppConstants.USER_MOBILE, null);

                  AppConstants().getStorage.write(AppConstants.LOGIN_COUNT, null);

                  // Clear selected address on logout
                  AppConstants().clearSelectedAddress();

                  scaffoldKey.currentState?.closeDrawer();
                  HomeScreenController homeScreenController =
                      Get.find<HomeScreenController>();
                  homeScreenController.callHomeApi();
                  // navigationDrawerController.logoutUserApi();
                },
              ));
            })
      ]);
      setState(() {});
    } else {
      navigationDrawerController.drawerItemList.addAll([
        DrawerModel(
            label: 'login',
            image: logoutIcon,
            onclick: () {
              scaffoldKey.currentState?.closeDrawer();
              AppConstants().loadWithCanBack(LoginScreen(onLoginSuccess: () {
                checkDrawerMenu();
              }));
            }),
        DrawerModel(
            label: 'partner_with_us',
            image: partnerWithUsIcon,
            onclick: () {
              scaffoldKey.currentState?.closeDrawer();
              AppConstants().loadWithCanBack(const PartnerWithusScreen());
            }),
        DrawerModel(
            label: 'About Us',
            image: aboutUsIcon,
            onclick: () {
              scaffoldKey.currentState?.closeDrawer();
              AppConstants()
                  .loadWithCanBack(const CMSScreen(AppConstants.ABOUT_US));
            }),
        DrawerModel(
            label: 'contact_us',
            image: contactUsIcon,
            onclick: () {
              scaffoldKey.currentState?.closeDrawer();
              AppConstants().loadWithCanBack(const ContactUsScreen());
            }),
        DrawerModel(
            label: 'Share App',
            image: shareAppIcon,
            onclick: () {
              try {
                Share.share(
                  'share_app_message'.tr,
                );
              } catch (e) {
                e.toString();
              }
            }),
      ]);
    }
  }

  @override
  void dispose() {
    super.dispose();
    listListen?.call();
    userModelListen?.call();
    cartCounterListen?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        width: Get.width,
        backgroundColor: whiteColor,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      scaffoldKey.currentState?.closeDrawer();
                    },
                    child: Container(
                      height: 38.w,
                      width: 38.w,
                      padding: const EdgeInsets.all(8),
                      margin: EdgeInsets.only(top: 15.h, left: 15.w),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: SvgPicture.asset(closeIcon),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15.w, top: 15.h, right: 20.w),
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
                            child: checkLogin()
                                ? CachedNetworkImage(
                                    imageUrl: AppConstants.IMG_URL +
                                        navigationDrawerController
                                            .userModel.value.userProfile
                                            .toString(),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const ImageErrorWidget(),
                                  )
                                : Image.asset(appLogo)),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: ClipPath(
                          // clipper: InsideRadiusClipper(),
                          child: Container(
                            height: 70.h,
                            padding: EdgeInsets.only(left: 10.w),
                            decoration: BoxDecoration(
                              color: home_package_clr3,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(100.r),
                                  topRight: Radius.circular(10.r)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // if (checkLogin())
                                Text(
                                  checkLogin()
                                      ? navigationDrawerController
                                          .userModel.value.userName
                                          .toString()
                                      : 'guest'.tr,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: semiBoldBlack_20,
                                ),
                                if (checkLogin())
                                  Text(
                                    navigationDrawerController
                                        .userModel.value.userMobile
                                        .toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: semiBoldBlack_14,
                                  )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(left: 25.w, right: 45.w),
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        itemCount:
                            navigationDrawerController.drawerItemList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: navigationDrawerController
                                .drawerItemList[index].onclick,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
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
                                      navigationDrawerController
                                          .drawerItemList[index].image,
                                      height: 22.h,
                                      width: 22.w,
                                      color: primaryColor2,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Colors.transparent,
                                      margin: EdgeInsets.only(left: 25.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              navigationDrawerController
                                                  .drawerItemList[index]
                                                  .label
                                                  .tr,
                                              style: mediumBlack_14),
                                          Container(
                                            margin: EdgeInsets.only(top: 4.h),
                                            color: borderColor,
                                            width: Get.width,
                                            height: 1.h,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                      // App Logo + Version Below Options
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            appLogo,
                            width: 125.w,
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "Version: ${AppConstants.appVersion}",
                            style: regularGray_12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Positioned(
            //   left: 15.w,
            //   bottom: 10.h,
            //   child: Image.asset(
            //     appLogo,
            //     width: 125.w,
            //   ),
            // ),
            Positioned(
              right: 0,
              bottom: 0,
              child: RotatedBox(
                quarterTurns: 2,
                child: SvgPicture.asset(
                  onBoardingHeaderImg,
                  height: 80.h,
                ),
              ),
            ),
          ],
        ),
      ),
      body: const BottomBarScreen(),
    );
    // return AdvancedDrawer(
    //   controller: navigationDrawerController.advancedDrawerController,
    //   backdropColor: whiteColor,
    //     child: BottomBarScreen(),
    //     drawer: Stack(
    //       children: [
    //         Column(
    //           children: [
    //             SafeArea(
    //                 child: Container(
    //                   margin: EdgeInsets.only(left: 15.w,top: 50.h,bottom: 15.h),
    //                   child: Row(
    //                     children: [
    //                       Container(
    //                         height: 70.h,
    //                         width: 70.h,
    //                         decoration: BoxDecoration(
    //                           border: Border.all(color: borderColor, width: 5.w),
    //                           borderRadius: BorderRadius.circular(100),
    //                         ),
    //                         child: ClipRRect(
    //                           borderRadius: BorderRadius.circular(100),
    //                           child: CachedNetworkImage(
    //                             imageUrl: AppConstants.IMG_URL + navigationDrawerController.userModel.value.userProfile.toString(),
    //                             fit: BoxFit.cover,
    //                             alignment: Alignment.topCenter,
    //                             placeholder: (context, url) =>  const CircularProgressIndicator(),
    //                             errorWidget: (context, url, error) =>  const ImageErrorWidget(),
    //                           ),
    //                         ),
    //                       ),
    //                       SizedBox(width: 10.w),
    //                       Expanded(
    //                         child: ClipPath(
    //                           clipper: InsideRadiusClipper(),
    //                           child: Container(
    //                             height: 70.h,
    //                             decoration: BoxDecoration(
    //                               color: cardBgColor,
    //                               borderRadius: BorderRadius.only(bottomRight: Radius.circular(100.r), topRight: Radius.circular(10.r)),
    //                             ),
    //                             child: Column(
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 if(AppConstants().getStorage.read(AppConstants.USER_NAME) != null && AppConstants().getStorage.read(AppConstants.USER_NAME) != "")
    //                                 Text(
    //                                     '${AppConstants().getStorage.read(AppConstants.USER_NAME)}',
    //                                     // navigationDrawerController.userModel.value.userName.toString(),
    //                                     maxLines: 1,
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: semiBoldBlack_20,//StyleHelper.customStyle(fontSize: 18.sp,color: primaryColor,fontWeight: FontWeight.w500)
    //                                 ),
    //                                 if(AppConstants().getStorage.read(AppConstants.USER_MOBILE) != null && AppConstants().getStorage.read(AppConstants.USER_MOBILE) != "")
    //                                 Text(
    //                                     '${AppConstants().getStorage.read(AppConstants.USER_MOBILE)}',
    //                                     maxLines: 1,
    //                                     overflow: TextOverflow.ellipsis,
    //                                     style: semiBoldBlack_14,//StyleHelper.customStyle(fontSize: 13.sp,color: blackColor,fontWeight: FontWeight.w400)
    //                                 )
    //                               ],
    //                             ),
    //                           ),
    //                         ),
    //                       )
    //                     ],
    //                   ),
    //                 )
    //             ),
    //             SizedBox(height: 5.h),
    //             Row(
    //               children: [
    //                 Container(
    //                   width: 65.w,
    //                   child: ListView.builder(
    //                     shrinkWrap: true,
    //                     scrollDirection: Axis.vertical,
    //                     padding: EdgeInsets.only(bottom: 15.h),
    //                     physics: BouncingScrollPhysics(),
    //                     itemCount: navigationDrawerController.drawerItemList.length,
    //                     itemBuilder: (context, index) {
    //                       return Container(
    //                         margin: EdgeInsets.only(left: 15.w,),
    //                           padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 10.h),
    //                           decoration: BoxDecoration(
    //                               color: cardBgColor,
    //                               border: Border(
    //                                   right: BorderSide(color: whiteColor, width: 5.w),
    //                                   left: BorderSide(color: whiteColor, width: 5.w),
    //                                 top: index == 0 ? BorderSide(color: whiteColor, width: 5.w)
    //                                     : BorderSide(color: whiteColor, width: 0),
    //                                 bottom: index == navigationDrawerController.drawerItemList.length - 1 ? BorderSide(color: whiteColor, width: 5.w)
    //                                     : BorderSide(color: whiteColor, width: 0),
    //                               ),
    //                               // borderRadius: BorderRadius.only(
    //                               //   topLeft: Radius.circular(index == 0 ? 5 : 0),
    //                               //   topRight: Radius.circular(index == 0 ? 5 : 0),
    //                               //   bottomLeft: Radius.circular(index == navigationDrawerController.drawerItemList.length - 1 ? 5 : 0),
    //                               //   bottomRight: Radius.circular(index == navigationDrawerController.drawerItemList.length - 1 ? 5 : 0),
    //                               // ),
    //                               boxShadow: [
    //                                 BoxShadow(
    //                                   color: cardBgColor,
    //                                   blurRadius: 10,
    //                                   spreadRadius: 1,
    //                                   offset: Offset(0, 5),
    //                                 )
    //                               ]
    //                           ),
    //                           child: SvgPicture.asset(navigationDrawerController.drawerItemList[index].image, height: 22.h, width: 22.w, color: primaryColor2)
    //                       );
    //                       },
    //                   ),
    //                 ),
    //                 Expanded(
    //                   child: ListView.builder(
    //                     shrinkWrap: true,
    //                     scrollDirection: Axis.vertical,
    //                     physics: const BouncingScrollPhysics(),
    //                     padding: EdgeInsets.only(bottom: 10.h),
    //                     itemCount: navigationDrawerController.drawerItemList.length,
    //                     itemBuilder: (context, index) {
    //                       return GestureDetector(
    //                         onTap: navigationDrawerController.drawerItemList[index].onclick,
    //                         child: Container(
    //                           margin: EdgeInsets.only(bottom: 7.h),
    //                           padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 7.h),
    //                           child: Expanded(
    //                               child: Column(
    //                                 crossAxisAlignment: CrossAxisAlignment.start,
    //                                 children: [
    //                                   Text(navigationDrawerController.drawerItemList[index].label, style: mediumBlack_14),
    //                                   Container(margin: EdgeInsets.only(top: 4.h), color: borderColor, width: Get.width, height: 1.h,)
    //                                 ],
    //                               )
    //                           ),
    //                         ),
    //                       );},
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //         Positioned(
    //           left: 15.w,
    //           bottom: 5.h,
    //             child: Image.asset(appLogo, width: 120.w, )
    //         ),
    //         Spacer(),
    //         Positioned(
    //           right: 0,
    //           bottom: 0,
    //           child: RotatedBox(
    //               quarterTurns: 2,
    //               child: SvgPicture.asset(onBoardingHeaderImg, height: 80.h,)
    //           ),
    //         )
    //
    //       ],
    //     )
    // );
  }
}

class InsideRadiusClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 30.0; // Radius for inside curve
    Path path = Path();

    // Start from top-left
    path.moveTo(radius, 0);
    // Line to top-right
    path.lineTo(size.width, 0);
    // Line to bottom-right
    path.lineTo(size.width, size.height);
    // Line to bottom-left
    path.lineTo(radius, size.height);
    // Inside arc at bottom-left corner
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    // Line to bottom-left corner
    path.lineTo(0, radius);
    // Inside arc at top-left corner
    path.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // path.moveTo(0, 0);
    // path.lineTo(size.width - radius, 0);
    // path.arcToPoint(
    //   Offset(size.width, radius),
    //   radius: Radius.circular(radius),
    //   clockwise: false,
    // );
    // path.lineTo(size.width, size.height - radius);
    // path.arcToPoint(
    //   Offset(size.width - radius, size.height),
    //   radius: Radius.circular(radius),
    //   clockwise: false,
    // );
    // path.lineTo(radius, size.height);
    // path.arcToPoint(
    //   Offset(0, size.height - radius),
    //   radius: Radius.circular(radius),
    //   clockwise: false,
    // );
    // path.lineTo(0, radius);
    // path.arcToPoint(
    //   Offset(radius, 0),
    //   radius: Radius.circular(radius),
    //   clockwise: false,
    // );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
