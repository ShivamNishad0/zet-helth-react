import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';

import '../../../Models/UserDetailModel.dart';

class UserSelectionScreenController extends GetxController {

  RxList<UserDetailModel> patientList = <UserDetailModel>[].obs;
  RxList<UserDetailModel> tempPatientList = <UserDetailModel>[].obs;
  RxBool isLoading = false.obs;

  adminGetCustomerApi() {
    isLoading.value = true;
    patientList.value = [];
    tempPatientList.value = [];
    WebApiHelper().callGetApi(null, AppConstants.adminGetCustomer, true).then((response) {
      isLoading.value = false;
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if(statusModel.status! && statusModel.customerList!=null) {
          patientList.addAll(statusModel.customerList!);
          tempPatientList.addAll(statusModel.customerList!);
        }
      }
    });
  }
}