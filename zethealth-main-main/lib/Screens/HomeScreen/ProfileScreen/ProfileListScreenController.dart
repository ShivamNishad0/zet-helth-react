import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:zet_health/Models/CartModel.dart';
import 'package:zet_health/Models/ProfileModel.dart';

import '../../../Helper/AppConstants.dart';
import '../../../Models/PackageModel.dart';
import '../../../Models/StatusModel.dart';
import '../../../Network/WebApiHelper.dart';
import '../HomeScreenController.dart';

class ProfileListScreenController extends GetxController {
  RxList<NewPackageModel> profileList = <NewPackageModel>[].obs;
  RxList<NewPackageModel> filterList = <NewPackageModel>[].obs;
  RxList<CartModel> cartList = <CartModel>[].obs;
  RxBool isLoading = false.obs;

  callGetProfileListApi(BuildContext context, String type) {
    profileList.value = [];
    filterList.value = [];
    isLoading.value = true;

    Map<String, dynamic> params = {"type": type};

    // WebApiHelper()
    //     .callFormDataPostApi(
    //         context, AppConstants.GET_TEST_PROFILE_API, params, true)
    //     .then((response) {
    //   isLoading.value = false;
    //
    //   if (response != null) {
    //     StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
    //     if (statusModel.status!) {
    //       if (statusModel.profileList!.isNotEmpty) {
    //         profileList.addAll(statusModel.profileList!);
    //         filterList.addAll(statusModel.profileList!);
    //       }
    //       // callGetCartApi(context);
    //     }
    //   }
    // });

    Map<String, dynamic> nodeParams = {
      'pincode': AppConstants().getSelectedAddress()?.pincode ?? AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE),
    };

    WebApiHelper().callNewNodeApi(null, "tests/popular-profile", nodeParams, true).then((response) {
      isLoading.value = false;
      if (response != null) {
        print('Popular Package API Response: $response');
        PopularResponseNode popularResponse = PopularResponseNode.fromJson(response);
        if (popularResponse.status == true && popularResponse.packages != null) {
          profileList.addAll(popularResponse.packages!);
          filterList.addAll(popularResponse.packages!);
          print('Popular packages loaded: ${profileList.length}');
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

  // callAddToCartApi(BuildContext context, ProfileModel profileModel, type) {
  //   isLoading.value = true;
  //   List<Map<String, dynamic>> itemList = [];
  //
  //   List<int> testIds = [];
  //   if(profileModel.labTestIds!.isNotEmpty)
  //     testIds = profileModel.labTestIds!.split(",").map(int.parse).toList();
  //
  //   List<String> testIncludes = [];
  //   if(profileModel.testIncludes!.isNotEmpty)
  //     testIncludes = profileModel.testIncludes!.split(",");
  //
  //   for (int i = 0; i < testIds.length; i++) {
  //     Map<String, dynamic> item = {
  //       "item_name": testIncludes[i],
  //       "item_type": type,
  //       "item_id": testIds[i],
  //       "item_price": 0,
  //     };
  //     itemList.add(item);
  //   }
  //
  //   Map<String, dynamic> cartJson = {
  //     "name": profileModel.name,
  //     "type": "ProfileTest",
  //     "item": itemList,
  //     "price": profileModel.price
  //   };
  //
  //   String cartJsonString = jsonEncode(cartJson);
  //
  //   Map<String, dynamic> params = {
  //     "id": 0,
  //     "lab_id": profileModel.labId,
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
