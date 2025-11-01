import 'dart:convert';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/CityModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Models/custom_cart_model.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import '../../../Helper/database_helper.dart';
import '../../../Models/LabModel.dart';

class AvailableLabsScreenController extends GetxController {

  CityModel? selectedCity;
  RxBool isLoading = false.obs;

  List<String> filterOptions = ['Sort By','Price','Name'];
  String selectedFilter = "Sort By";

  List<String> testTypeList = ['Test','Package','Profile'];
  String selectedTypeList = 'Test';
  final DBHelper dbHelper = DBHelper();


  RxList<LabModel> testWiseLabList = <LabModel>[].obs;
  RxList<LabModel> filterList = <LabModel>[].obs;

  RxList<CustomCartModel> cartList = <CustomCartModel>[].obs;

  callTestWiseLabApi() {
    isLoading.value = true;
    testWiseLabList.value = [];
    filterList.value = [];
    String testIds = cartList.where((package) => package.type == AppConstants.test).map((package) => package.id!).toList().join(',');
    String packageNames = cartList.where((package) => package.type == AppConstants.package).map((package) => package.name!).toList().join(',');
    String profileNames = cartList.where((package) => package.type == AppConstants.profile).map((package) => package.name!).toList().join(',');


    Map<String, dynamic> params = {
      "test_ids": testIds,
      "city_name": selectedCity != null ? selectedCity!.id : "1",
      "package_names": packageNames,
      "profile_names": profileNames,
      "sort_by": selectedFilter == "Sort By" ? "" : selectedFilter,
    };
    WebApiHelper().callFormDataPostApi(null, AppConstants.getLabListV2, params, true).then((response) {
      isLoading.value = false;
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          if(statusModel.labList!.isNotEmpty) {
            testWiseLabList.addAll(statusModel.labList!);
            filterList.addAll(statusModel.labList!);
          }
        }
      }
    });
  }

}