import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/AssetHelper.dart';
import 'package:zet_health/Screens/BookingScreen/BookingScreenController.dart';
import 'package:zet_health/Screens/GlobalChatScreen/normal_chat_conversation_screen.dart';
import 'package:zet_health/Screens/HomeScreen/HomeScreenController.dart';
import 'package:zet_health/Screens/InsightScreen/InsightScreen.dart';
import 'package:zet_health/Screens/MyReportScreen/MyReportScreenController.dart';
import 'package:zet_health/Screens/OfferScreen/OfferScreenController.dart';
import 'package:zet_health/push_notification.dart';
import '../CommonWidget/CustomWidgets.dart';
import '../Helper/ColorHelper.dart';
import '../Helper/StyleHelper.dart';
import 'AuthScreen/LoginScreen.dart';
import 'BookingScreen/BookingScreen.dart';
import 'DrawerView/NavigationDrawerController.dart';
import 'DrawerView/PrescriptionScreen/PrescriptionScreen.dart';
import 'HomeScreen/HomeScreen.dart';
import 'HomeScreen/TestScreen/SearchTest/SearchResultController.dart';
import 'MyReportScreen/MyReportScreen.dart';
import 'OfferScreen/OfferScreen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  List<Widget> pageScreenList = <Widget>[];
  NavigationDrawerController navigationDrawerController =
      Get.put(NavigationDrawerController());
  Function? loginListen;
  bool _isMenuOpen = false;

  Future<bool> _onWillPop() async {
    final searchCtrl = Get.find<SearchResultController>();

    if (searchCtrl.queryText.value.isNotEmpty) {
      searchCtrl.clearSearch();
      return false;
    }
    if (_isMenuOpen) {
      setState(() {
        _isMenuOpen = false;
      });
      return false;
    }
    return await Get.dialog(CommonDialog(
          title: 'Exit',
          description: 'Are you sure you want to exit from app ?',
          tapNoText: 'cancel'.tr,
          tapYesText: 'confirm'.tr,
          onTapNo: () => Get.back(),
          onTapYes: () {
            exit(0);
          },
        )) ??
        false;
  }

  checkFromNotification() async {
    var details = await PushNotificationManager.flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      if (details.notificationResponse != null &&
          details.notificationResponse!.payload != null) {
        Map<String, dynamic> message =
            json.decode(details.notificationResponse!.payload.toString());
        if (message['type'] == "UpdatePrescription") {
          AppConstants().loadWithCanBack(const PrescriptionScreen());
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkFromNotification();
    navigationDrawerController.isLogin.value = checkLogin();
    loginListen =
        AppConstants().getStorage.listenKey(AppConstants.USER_MOBILE, (value) {
      navigationDrawerController.isLogin.value = checkLogin();
    });
  }

  @override
  void dispose() {
    super.dispose();
    loginListen?.call();
  }

  Widget _buildFabMenu() {
    return Positioned(
      bottom: -70.h,
      left: 0,
      right: 0,
      child: Container(
        height: 250.h,
        child: Stack(
          children: [
            // WhatsApp - Top Left
            Positioned(
              left: MediaQuery.of(context).size.width * 0.15,
              bottom: 80.h,
              child: _buildCircularMenuButton(FontAwesomeIcons.whatsapp, "Whatsapp", () {
                if (AppConstants().getStorage.read(AppConstants.SUPPORT_MOBILE) !=
                        null &&
                    AppConstants()
                        .getStorage
                        .read(AppConstants.SUPPORT_MOBILE)
                        .isNotEmpty) {
                  final Uri launchUri = Uri.parse(
                      'https://wa.me/${AppConstants().getStorage.read(AppConstants.SUPPORT_MOBILE)}');
                  launchUrlInOtherApp(url: launchUri);
                }
                setState(() => _isMenuOpen = false);
              }),
            ),
            
            Positioned(
              left: MediaQuery.of(context).size.width * 0.5 - 35.w,
              bottom: 120.h,
              child: _buildCircularMenuButton(FontAwesomeIcons.brain, "AI Chat", () {
                if (checkLogin()) {
                  Get.to(() => const NormalChatConversationScreen(),
                      transition: Transition.rightToLeft);
                } else {
                  AppConstants().loadWithCanBack(LoginScreen(onLoginSuccess: () {
                    Get.to(() => const NormalChatConversationScreen(),
                        transition: Transition.rightToLeft);
                  }));
                }
                setState(() => _isMenuOpen = false);
              }),
            ),
            
            // Call - Top Right
            Positioned(
              right: MediaQuery.of(context).size.width * 0.15,
              bottom: 80.h,
              child: _buildCircularMenuButton(Icons.call, "Call", () {
                final Uri launchUri = Uri(
                  scheme: 'tel',
                  path: AppConstants().getStorage.read(AppConstants.SUPPORT_MOBILE),
                );
                launchUrlInOtherApp(url: launchUri);
                setState(() => _isMenuOpen = false);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularMenuButton(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70.w,
        height: 70.w,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: whiteColor, size: 24.w),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                  color: whiteColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(String icon, String label, int index) {
    bool isSelected = navigationDrawerController.pageIndex.value == index;
    return Expanded(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () => _onBottomNavItemTap(index),
        child: Container(
          height: 60.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                color: isSelected ? primaryColor : gray,
                height: 20.h,
                width: 20.h,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: isSelected ? mediumPrimary_12 : mediumGray_12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBottomNavItemTap(int index) {
    if (index == 0 && navigationDrawerController.pageIndex.value == 0) {
      HomeScreenController homeScreenController = Get.find<HomeScreenController>();
      homeScreenController.callHomeApi();
    } else if (index == 1 && navigationDrawerController.pageIndex.value == 1) {
      if (navigationDrawerController.isLogin.value) {
        BookingScreenController bookingScreenController =
            Get.find<BookingScreenController>();
        bookingScreenController.callGetBookingApi();
      }
    } else if (index == 3 && navigationDrawerController.pageIndex.value == 3) {
      if (navigationDrawerController.isLogin.value) {
        MyReportScreenController myReportScreenController =
            Get.find<MyReportScreenController>();
        myReportScreenController.callGetReportApi();
      }
    }
    navigationDrawerController.pageIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    pageScreenList = const [
      HomeScreen(),
      BookingScreen(),
      InsightsScreen(),
      MyReportScreen()
    ];
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: false,
          body: Stack(
            children: [
              Obx(() => pageScreenList[navigationDrawerController.pageIndex.value]),
              if (_isMenuOpen)
                GestureDetector(
                  onTap: () => setState(() => _isMenuOpen = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              if (_isMenuOpen) _buildFabMenu(),
            ],
          ),
          bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Container(
                height: 70.h,
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    // Home
                    _buildBottomNavItem(homeIcon, "Home", 0),
                    
                    // Booking
                    _buildBottomNavItem(bookingIcon, "Booking", 1),
                    
                    // Center FAB
                    Expanded(
                      child: Container(
                        height: 70.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50.w,
                              height: 50.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  _isMenuOpen ? Icons.close : Icons.call,
                                  color: whiteColor,
                                  size: 20.w,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isMenuOpen = !_isMenuOpen;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Insights
                    Expanded(
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => _onBottomNavItemTap(2),
                        child: Container(
                          height: 60.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insights,
                                color: navigationDrawerController.pageIndex.value == 2
                                    ? primaryColor
                                    : gray,
                                size: 20.h,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Insights",
                                textAlign: TextAlign.center,
                                style: navigationDrawerController.pageIndex.value == 2
                                    ? mediumPrimary_12
                                    : mediumGray_12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // My Reports
                    _buildBottomNavItem(reportIcon, "Reports", 3),
                  ],
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }
}