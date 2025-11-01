import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';

class RegisterScreenController extends GetxController {
  RxString countryCode = "+91".obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();

  List<String> genderOptions = ['Male', 'Female', 'Other'];
  int selectedGender = -1;

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      return iosInfo.identifierForVendor!;
    }
    return "unknown";
  }

  callRegisterApi(BuildContext context) async {
    String deviceId = await _getDeviceId();

    Map<String, dynamic> params = {
      "user_name": nameController.text,
      "user_email": emailController.text,
      "user_gender": selectedGender == 0
          ? 'Male'
          : selectedGender == 1
              ? 'Female'
              : 'Other',
      "mobile_number": mobileNoController.text,
      "device_id": deviceId
    };

    WebApiHelper()
        .callFormDataPostApi(context, AppConstants.REGISTER_API, params, true)
        .then((response) {
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if (statusModel.status!) {
          Get.back();
          showToast(message: statusModel.message!);
          // AppConstants().loadWithCanNotBack(LoginScreen());
        } else {
          showToast(message: statusModel.message!);
        }
      }
    });
  }

  bool isValidate() {
    if (nameController.text.trim().isEmpty) {
      showToast(message: 'please_enter_name'.tr);
      return false;
    } else if (emailController.text.trim().isEmpty) {
      showToast(message: 'please_enter_email_address'.tr);
      return false;
    }
    // else if (!RegExp(r'(^.*[a-zA-Z]+[\.\-]?[a-zA-Z0-9]+@\w+([\.-]?\w+)*(\.\w{2,3})+$)').hasMatch(emailController.text.trim())) {
    //   showToast(message: 'Please enter valid email address');
    //   return false;
    // }
    else if (!AppConstants().isEmailValid(emailController.text.trim())) {
      showToast(message: 'please_enter_valid_email_address'.tr);
      return false;
    } else if (mobileNoController.text.trim().isEmpty) {
      showToast(message: 'please_enter_mobile_number'.tr);
      return false;
    } else if (mobileNoController.text.trim().length < 10) {
      showToast(message: 'please_enter_valid_mobile_number'.tr);
      return false;
    } else if (selectedGender == -1) {
      showToast(message: 'please_select_gender'.tr);
      return false;
    } else {
      return true;
    }
  }
}
