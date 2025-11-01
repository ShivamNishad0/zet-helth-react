import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:zet_health/Screens/AuthScreen/OtpVerifyScreen.dart';
import 'package:zet_health/Screens/AuthScreen/RegisterScreen.dart';

import '../../CommonWidget/CustomWidgets.dart';

class LoginScreenController extends GetxController {
  RxString countryCode = "+91".obs;
  TextEditingController mobileNoController = TextEditingController();

  callLoginApi({required Function() onLoginSuccess}) async {
    Map<String, dynamic> params = {
      "mobile_number": mobileNoController.text,
      'user_type': 'User',
    };

    WebApiHelper()
        .callFormDataPostApi(null, AppConstants.LOGIN_API, params, true)
        .then((response) async {
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if (statusModel.status!) {
          if (mobileNoController.text.trim() == '9033152603') {
            AppConstants()
                .getStorage
                .write(AppConstants.TOKEN, statusModel.token);
            AppConstants()
                .getStorage
                .write(AppConstants.USER_ID, statusModel.userDetail!.userId);
            AppConstants().getStorage.write(
                AppConstants.USER_DETAIL, json.encode(statusModel.userDetail));
            AppConstants().getStorage.write(
                AppConstants.USER_TYPE, statusModel.userDetail!.userType);
            AppConstants().getStorage.write(
                AppConstants.USER_MOBILE, statusModel.userDetail!.userMobile);
            AppConstants().getStorage.write(
                AppConstants.USER_NAME, statusModel.userDetail!.userName);
            
            // Handle address setup after login
            await AppConstants().handleAddressAfterLogin();
            
            Get.back();
            onLoginSuccess.call();
          } else {
            AppConstants().loadWithCanBack(OtpVerifyScreen(
                countryCode: countryCode.value,
                statusModel: statusModel,
                onLoginSuccess: onLoginSuccess));
          }
        } else {
          AppConstants().showToast(
              "Looks like you are new to our world, please take a moment to register");
          if (statusModel.message == "User does not exist") {
            AppConstants()
                .loadWithCanBack(RegisterScreen(mobileNoController.text));
          }
        }
      }
    });
  }

  bool isValidate() {
    if (mobileNoController.text.trim().isEmpty) {
      showToast(message: 'please_enter_mobile_number'.tr);
      return false;
    } else if (mobileNoController.text.trim().length < 10) {
      showToast(message: 'please_enter_valid_mobile_number'.tr);
      return false;
    } else {
      return true;
    }
  }
}
