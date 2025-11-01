import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/CartModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';

import '../../../Models/PackageModel.dart';
import '../HomeScreenController.dart';

class PackageListScreenController extends GetxController {
  RxList<NewPackageModel> filterList = <NewPackageModel>[].obs;
  RxList<NewPackageModel> packageList = <NewPackageModel>[].obs;
  RxList<CartModel> cartList = <CartModel>[].obs;
  RxBool isLoading = false.obs;

  callGetPackageListApi(BuildContext context, String type) {
    packageList.value = [];
    filterList.value = [];
    isLoading.value = true;

    // Map<String, dynamic> params = {"type": type};
    //
    // WebApiHelper()
    //     .callFormDataPostApi(
    //         context, AppConstants.GET_PACKAGE_API, params, true)
    //     .then((response) {
    //   isLoading.value = false;
    //
    //   if (response != null) {
    //     StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
    //     if (statusModel.status!) {
    //       if (statusModel.packageList!.isNotEmpty) {
    //         packageList.addAll(statusModel.packageList!);
    //         filterList.addAll(statusModel.packageList!);
    //       }
    //       // callGetCartApi(context);
    //     }
    //   }
    // });

    Map<String, dynamic> nodeParams = {
      'pincode': AppConstants().getSelectedAddress()?.pincode ?? AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE),
    };

    WebApiHelper().callNewNodeApi(null, "tests/popular-package", nodeParams, true).then((response) {
      isLoading.value = false;
      if (response != null) {
        print('Popular Package API Response: $response');
        PopularResponseNode popularResponse = PopularResponseNode.fromJson(response);
        if (popularResponse.status == true && popularResponse.packages != null) {
          for(var element in popularResponse.packages!) {
            if(element.type == "Popular") {
              packageList.add(element);
              filterList.add(element);
            }
          }
          // packageList.addAll(popularResponse.packages!);
          // filterList.addAll(popularResponse.packages!);
          print('Popular packages loaded: ${packageList.length}');
        } else {
          print('No popular packages found or status false');
        }
      } else {
        print('Popular Package API returned null response');
      }
    }).catchError((error) {
      print('Error fetching popular packages: $error');
    });
  }

  // callAddToCartApi(BuildContext context, PackageModel packageModel, type) {
  //   isLoading.value = true;
  //
  //   // <-- include testList
  //   List<Map<String, dynamic>> testList = [];
  //   if(packageModel.labTestList!.isNotEmpty) {
  //     for (int i = 0; i < packageModel.labTestList!.length; i++) {
  //       Map<String, dynamic> item = {
  //         "id": packageModel.labTestList![i].id,
  //         "name": packageModel.labTestList![i].name,
  //         "is_free": packageModel.labTestList![i].isFree,
  //         "is_fast_required": packageModel.labTestList![i].isFastRequired,
  //         "price": packageModel.labTestList![i].price,
  //       };
  //       testList.add(item);
  //     }
  //   }
  //
  //   // <-- include profileList
  //   List<Map<String, dynamic>> profileTestList = [];
  //   if(packageModel.profileTestList!.isNotEmpty) {
  //     for (int i = 0; i < packageModel.profileTestList!.length; i++) {
  //
  //       List<Map<String, dynamic>> testList = [];
  //       for(int j = 0; j < packageModel.profileTestList![i].labTestsList!.length; j++) {
  //         Map<String, dynamic> item = {
  //           "id": packageModel.labTestList![j].id,
  //           "name": packageModel.labTestList![j].name,
  //           "is_free": packageModel.labTestList![j].isFree,
  //           "is_fast_required": packageModel.labTestList![j].isFastRequired,
  //           "price": packageModel.labTestList![j].price,
  //         };
  //         testList.add(item);
  //       }
  //
  //       Map<String, dynamic> item = {
  //         "id": packageModel.profileTestList![i].id,
  //         "name": packageModel.profileTestList![i].name,
  //         "is_free": packageModel.profileTestList![i].isFree,
  //         "is_fast_required": packageModel.profileTestList![i].isFastRequired,
  //         "price": packageModel.profileTestList![i].price,
  //         "lab_tests": testList
  //       };
  //       profileTestList.add(item);
  //     }
  //
  //   }
  //
  //   // <-- prepare cartJson
  //   String cartJsonString = jsonEncode({
  //     "name": packageModel.name,
  //     "price": packageModel.price,
  //     "type": "Package",
  //     "lab_tests": testList,
  //     "profile_test": profileTestList
  //   });
  //
  //   Map<String, dynamic> params = {
  //     "id": 0,
  //     "lab_id": packageModel.labId,
  //     "user_id": AppConstants().getStorage.read(AppConstants.USER_ID),
  //     "date_time": AppConstants().currentDateTimeApi(),
  //     "cart_json": cartJsonString,
  //   };
  //
  //   WebApiHelper().callFormDataPostApi(context, AppConstants.ADD_TO_CART_API, params, true).then((response) {
  //     isLoading.value = false;
  //     if(response != null) {
  //       StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
  //       if(statusModel.status!) {
  //         AppConstants().loadWithCanBack(MyCartScreen());
  //       }
  //       else {
  //         showToast(message: statusModel.message!);
  //       }
  //     }
  //   });
  //
  // }

  callGetCartApi(BuildContext context) async {
    isLoading.value = true;
    cartList.value = [];
    await WebApiHelper()
        .callGetApi(context, AppConstants.GET_CART_API, true)
        .then((response) {
      isLoading.value = false;
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if (statusModel.status!) {
          if (statusModel.cartList!.isNotEmpty) {
            cartList.addAll(statusModel.cartList!);
          }
        }
      }
    });
  }
}
