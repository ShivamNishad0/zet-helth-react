import 'dart:convert';

import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/LabModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';

import '../../../Models/CityModel.dart';

class LabScreenController extends GetxController {

  CityModel? selectedCity;

  RxList<LabModel> labList = <LabModel>[].obs;
  RxList<LabModel> filterList = <LabModel>[].obs;
  RxBool isLoading = false.obs;

  callGetLabListApi({String? type}) {
    isLoading.value = true;
    labList.value = [];
    filterList.value = [];
    Map<String, dynamic> params = {
      "type": type,
      "city_name": selectedCity != null ? selectedCity!.id : "",
    };

    WebApiHelper().callFormDataPostApi(null, AppConstants.GET_LAB_LIST_API, params, true).then((response) {
      isLoading.value = false;
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          if(statusModel.labList!.isNotEmpty) {
            labList.addAll(statusModel.labList!);
            filterList.addAll(statusModel.labList!);
          }
        }
      }
    });
  }

}