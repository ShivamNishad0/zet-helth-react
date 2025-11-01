import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../Helper/AppConstants.dart';
import '../Models/LabModel.dart';
import '../Models/StatusModel.dart';
import '../Network/WebApiHelper.dart';
import '../Screens/HomeScreen/HomeScreenController.dart';
import '../Screens/MyCartScreen/MyCartScreen.dart';
import 'CustomWidgets.dart';


getCartApi({required LabModel labModel, bool toViewCart = false}) async {
  await WebApiHelper().callGetApi(null, AppConstants.GET_CART_API, false).then((response) {
    if (response != null) {
      StatusModel statusModel = StatusModel.fromJson(response);
      if (statusModel.status!) {
        if (!toViewCart && statusModel.cartList != null && statusModel.cartList!.isNotEmpty) {
          // Show dialog only if toViewCart is false AND cartList has items
          // Get.dialog(CommonDialog(
          //   title: 'warning'.tr,
          //   description: 'msg_add_this_item_previously_added_test_will_removed'.tr,
          //   tapNoText: 'cancel'.tr,
          //   tapYesText: 'confirm'.tr,
          //   onTapNo: () => Get.back(),
          //   onTapYes: () {
          //     Get.back();
          //     addToCartApi(labModel: labModel);
          //   },
          // ));

          Get.back();
          addToCartApi(labModel: labModel, toViewCart: toViewCart);
        } else {
          // For toViewCart flow, ensure server cart reflects current selection only
          if (toViewCart) {
            WebApiHelper().callGetApi(null, AppConstants.GET_CLEAR_CART_API, false).then((_) {
              addToCartApi(labModel: labModel, toViewCart: toViewCart);
            });
          } else {
            // Skip dialog if cartList is empty
            addToCartApi(labModel: labModel, toViewCart: toViewCart);
          }
        }
      }
      else {
        EasyLoading.dismiss();
      }
    }
    else {
      EasyLoading.dismiss();
    }
  });
}



addToCartApi({required LabModel labModel, bool toViewCart = false}) {
  Map<String, dynamic> params = {
    "id": 0,
    "lab_id": labModel.labId!,
    "user_id": AppConstants().getStorage.read(AppConstants.USER_ID),
    "date_time": AppConstants().currentDateTimeApi(),
    "cart_json": jsonEncode({
      "price": labModel.totalPrice,
      "item": labModel.testPricesList
    }),
  };

  WebApiHelper().callFormDataPostApi(null, AppConstants.ADD_TO_CART_API, params, false).then((response) {
    if(response != null) {
      StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
      if(statusModel.status!) {
        // Only navigate to MyCartScreen if toViewCart is true
        if (toViewCart) {
          Get.until((route)=> route.isFirst);
          AppConstants().loadWithCanBack(const MyCartScreen());
          HomeScreenController homeScreenController = Get.put(HomeScreenController());
          homeScreenController.callHomeApi();
        } else {
          EasyLoading.dismiss();
          debugPrint("Cart updated successfully, skipped navigation because toViewCart=false");
        }
      } else {
        EasyLoading.dismiss();
        showToast(message: statusModel.message!);
      }
    }
    else {
      EasyLoading.dismiss();
    }
  });
}
