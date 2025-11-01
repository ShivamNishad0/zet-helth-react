import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';

import '../../../Models/UserDetailModel.dart';
import '../../MyCartScreen/MyCartScreenController.dart';

class FamilyMemberScreenController extends GetxController {

  RxList<UserDetailModel> patientList = <UserDetailModel>[].obs;
  RxBool isLoading = false.obs;


  Future<void> getPatientListApi({VoidCallback? onUpdated}) async {
    isLoading.value = true;
    patientList.value = [];
    final response = await WebApiHelper().callGetApi(null, AppConstants.getPatientList, onUpdated == null);
    isLoading.value = false;
    if (response != null) {
      StatusModel statusModel = StatusModel.fromJson(response);
      if (statusModel.status!) {
        patientList.addAll(statusModel.patientList!);
        if(patientList.isNotEmpty && Get.isRegistered<MyCartScreenController>()) {
          MyCartScreenController myCartScreenController = Get.find<MyCartScreenController>();
          if(myCartScreenController.getSelectedPatient() == null) {
            myCartScreenController.selectedPatient = patientList[0];
            myCartScreenController.saveSelectedPatient(patientList[0]);
            onUpdated?.call();
          }
        }
      }
    }
  }

  deletePatientApi({required String id}) {
    WebApiHelper().callGetApi(null, '${AppConstants.deletePatient}/$id', true).then((response) {
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if(statusModel.status!) {
          getPatientListApi();
        }
      }
    });
  }
}