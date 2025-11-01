import 'dart:convert';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import '../../../../Models/StatusModel.dart';
import '../../../../Models/custom_cart_model.dart';

class PopularTestScreenController extends GetxController {

  RxList<CustomCartModel> testList = <CustomCartModel>[].obs;
  RxBool isLoading = false.obs;

  callGetLabTestListApi() {
    isLoading.value = true;
    testList.value = <CustomCartModel>[];

    Map<String, dynamic> params = {
      "type": "Popular",
      "lab_id": "0",
    };

    WebApiHelper().callFormDataPostApi(null, AppConstants.GET_LAB_TEST_API, params, false).then((response) async {
      if(response != null) {
        print("Popular test Response: $response");
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          testList.value = <CustomCartModel>[];
          for(int i=0; i< statusModel.labTestList!.length; i++){
            testList.add(
              CustomCartModel(
                id: statusModel.labTestList![i].id,
                name: statusModel.labTestList![i].name,
                type: AppConstants.test,
                price: statusModel.labTestList![i].price.toString(),
                image: statusModel.labTestList![i].image.toString(),
                isFastRequired: statusModel.labTestList![i].isFastRequired.toString(),
                testTime: statusModel.labTestList![i].testTime.toString(),
                isSelected: false,
                itemDetail: statusModel.labTestList![i].itemDetail,
                profilesDetail: statusModel.labTestList![i].profilesDetail,
                parametersCount: statusModel.labTestList![i].parametersCount,
                parameters: statusModel.labTestList![i].parameters,
              )
            );
          }
          isLoading.value = false;
        }
      }
    });
  }
}