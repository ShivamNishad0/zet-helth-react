import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import '../../Models/DrawerModel.dart';
import '../../Models/UserDetailModel.dart';

class NavigationDrawerController extends GetxController {
  RxInt pageIndex = 0.obs;
  RxInt cartCounter = 0.obs;
  RxInt notificationCounter = 0.obs;
  Rx<UserDetailModel> userModel = AppConstants().getUserDetails().obs;
  final advancedDrawerController = AdvancedDrawerController();
  void showDrawer() => advancedDrawerController.showDrawer();
  void hideDrawer() => advancedDrawerController.hideDrawer();
  List<DrawerModel> drawerItemList = [];
  RxBool isLogin = false.obs;

// logoutUserApi() {
  //   WebApiHelper().callGetApi(null, AppConstants.logoutUser, true).then((response) {
  //     if(response != null) {
  //       StatusModel statusModel = StatusModel.fromJson(response);
  //       if(statusModel.status!) {
  //         Get.back();
  //         AppConstants().getStorage.write(AppConstants.USER_MOBILE, null);
  //         AppConstants().getStorage.erase();
  //       }
  //     }
  //   });
  // }
}
