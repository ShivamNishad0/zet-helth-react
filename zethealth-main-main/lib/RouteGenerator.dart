import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Screens/DrawerView/NavigationDrawerView.dart';

import 'package:zet_health/Screens/MyReportScreen/MyReportScreen.dart';

import 'Screens/SplashScreen.dart';

class RouteGenerator {
  int duration = 300;

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.SPLASH_SCREEN:
        return GetPageRoute(
            routeName: settings.name,
            page: () => const SplashScreen(),
            transition: Transition.rightToLeft,
            transitionDuration: Duration(milliseconds: duration));

      case AppConstants.HOME_SCREEN:
        return GetPageRoute(
            routeName: settings.name,
            page: () => const NavigationDrawerView(),
            transition: Transition.rightToLeft,
            transitionDuration: Duration(milliseconds: duration));

      case AppConstants.REPORT_SCREEN:
        return GetPageRoute(
            routeName: settings.name,
            page: () => const MyReportScreen(),
            transition: Transition.rightToLeft,
            transitionDuration: Duration(milliseconds: duration));

      default:
        return GetPageRoute(
            routeName: settings.name,
            page: () => const SplashScreen(),
            transition: Transition.rightToLeft,
            transitionDuration: Duration(milliseconds: duration));
    }
  }
}
