import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Models/PrescriptionModel.dart';
import '../../../Models/StatusModel.dart';
import '../../../Network/WebApiHelper.dart';

class PrescriptionScreenController extends GetxController {

  RxList<PrescriptionModel> prescriptionList = <PrescriptionModel>[].obs;
  RxBool isLoading = false.obs;

  callGetPrescriptionApi(BuildContext context) {
    prescriptionList.value = [];
    isLoading.value = true;

    WebApiHelper().callGetApi(context, AppConstants.GET_PRESCRIPTION_API, true).then((response) {
      isLoading.value = false;
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if(statusModel.status!) {
          if(statusModel.prescriptionList!.isNotEmpty) {
            prescriptionList.addAll(statusModel.prescriptionList!);
          }
        }
      }
    },);
  }
}