import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../CommonWidget/CustomAppbar.dart';
import '../../Helper/AppConstants.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';
import '../AuthScreen/LoginScreen.dart';
import 'WelcomeScreenSlides.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final PageController pageController = PageController();
  int currentIndex = 0;
  bool welcomeCompleted = false;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        currentIndex = pageController.page!.round();
      });
    });
  }

  void onSkipPressed() {
    // AppConstants().loadWithCanBack(LoginScreen(onLoginSuccess: () {
    AppConstants().markWelcomeScreenAsShown();
    welcomeCompleted = true;
    Get.back();
    // }));
  }

  void onPreviousPressed() {
    if (currentIndex > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onNextPressed() {
    if (currentIndex < slideList.length - 1) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void getStarted() {
    AppConstants().loadWithCanBack(LoginScreen(onLoginSuccess: () {
      AppConstants().markWelcomeScreenAsShown();
      welcomeCompleted = true;
      Get.back();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false, // Prevents the default back navigation
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (!welcomeCompleted && Platform.isAndroid) {
          // Android, handles this to pop
          // Asked explicitly, to not go further without showing complete welcome slides
          SystemNavigator.pop();
        }
        // Don't need to do anything for iOS. A swipe to home will simply background the app, which is the correct behavior.
        // There is no hardware back button on iOS to trigger this.
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppbar(
          centerTitle: false,
          isLeading: false,
          // title: Text('Welcome to ', style: semiBoldBlack_26),
          backgroundColor: Colors.transparent,
          actions: [
            TextButton(
              onPressed: onSkipPressed,
              child: Text("Skip",
                  style: semiBoldBlack_16,
                  // style: TextStyle(color: primaryColor, fontSize: 16.sp)
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 0.63.sh, // 63% of screen height
                  width: double.infinity,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final dx = details.localPosition.dx;

                      // Works on tap
                      if (dx < screenWidth / 2) {
                        onPreviousPressed();
                      } else {
                        onNextPressed();
                      }
                    },
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: slideList.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          slideList[index].imageAsset,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),

                Expanded(child: SizedBox()),
              ],
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  // Works on Swipe
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! < 0) {
                      onNextPressed();
                    } else if (details.primaryVelocity! > 0) {
                      onPreviousPressed();
                    }
                  }
                },
                onTapUp: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final dx = details.localPosition.dx;

                  // Works on tap
                  if (dx < screenWidth / 2) {
                    onPreviousPressed();
                  } else {
                    onNextPressed();
                  }
                },
                child: Container(
                  height: 0.4.sh,  // 40% of screen height
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.r),
                      topRight: Radius.circular(25.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slideList[currentIndex].title,
                        style: boldPrimary_28,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        slideList[currentIndex].description,
                        style: regularGray_15,
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(slideList.length, (index) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                width: currentIndex == index ? 24.w : 8.w,
                                height: 8.h,
                                decoration: BoxDecoration(
                                  color: currentIndex == index
                                      ? primaryColor
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              );
                            }),
                          ),
                          ElevatedButton(
                            onPressed: currentIndex == slideList.length - 1
                                ? getStarted
                                : onNextPressed,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.r))),
                            child: Text(
                              currentIndex == slideList.length - 1
                                  ? "Get Started"
                                  : "Next",
                              style: boldWhite_12,
                            ),
                          ),
                        ],
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
}
