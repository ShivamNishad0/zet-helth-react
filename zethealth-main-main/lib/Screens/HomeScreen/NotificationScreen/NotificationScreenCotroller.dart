import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';

import '../../../Models/NotificationModel.dart';

class NotificationScreenController extends GetxController {
  RxList<NotificationModel> notificationList = <NotificationModel>[].obs;
  RxBool isLoading = false.obs;

  callGetNotificationApi() {
    notificationList.value = [];
    isLoading.value = true;
    WebApiHelper()
        .callGetApi(null, AppConstants.GET_NOTIFICATION_API, true)
        .then((response) {
      isLoading.value = false;
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if (statusModel.status!) {
          notificationList.addAll(statusModel.notificationList!);
        }
      }
    });
  }
}
