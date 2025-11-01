import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/UserDetailModel.dart';
import 'package:zet_health/push_notification.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'Helper/ColorHelper.dart';
import 'Helper/StringHelper.dart';
import 'RouteGenerator.dart';
import 'firebase_options.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await PushNotificationManager.notificationSetup();
    await AppConstants.getAppVersion();

    runApp(const MyApp());
    configLoading();
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

void configLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorWidget = Lottie.asset(
      'assets/load_animation.json',
      width: 100,
      height: 100,
      fit: BoxFit.contain,
    )
    ..maskType = EasyLoadingMaskType.black
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.transparent
    ..textColor = Colors.black;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        minTextAdapt: true,
        useInheritedMediaQuery: true,
        splitScreenMode: true,
        builder: (_, widget) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: primaryColor, // status bar bg
                statusBarIconBrightness: Brightness.dark, // Android status bar icons
                statusBarBrightness: Brightness.light, // iOS status bar

                systemNavigationBarColor: primaryColor, // nav bar bg
                systemNavigationBarIconBrightness: Brightness.dark, // nav bar icons
              ),
          child: GetMaterialApp(
            title: 'zet Health',
            debugShowCheckedModeBanner: false,
            translations: StringHelper(),
            locale: const Locale('en', 'US'),
            theme: ThemeData(
              fontFamily: 'Inter',
              scaffoldBackgroundColor: whiteColor,
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: primaryColor.withOpacity(0.6),
                selectionHandleColor: primaryColor,
              ),
            ),
            onGenerateRoute: RouteGenerator().generateRoute,
            useInheritedMediaQuery: true,
            builder: EasyLoading.init(),
            // builder: (BuildContext context, Widget? child) {
            //   return MediaQuery(
            //     data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            //     child: Builder(
            //       builder: (BuildContext context) {
            //         return EasyLoading.init()(context, child);
            //       },
            //     ),
            //   );
            // },
          ),
          );
        }
        );
  }
}
