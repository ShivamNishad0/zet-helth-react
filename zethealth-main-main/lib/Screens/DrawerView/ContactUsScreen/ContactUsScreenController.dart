import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Models/StatusModel.dart';

class ContactUsScreenController extends GetxController {

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  callContactUsApi(BuildContext context, String type) {
    Map<String, dynamic> params = {
      "name": nameController.text.trim(),
      "number": mobileController.text.trim(),
      "email": emailController.text.trim(),
      "subject": subjectController.text.trim(),
      "message": messageController.text.trim(),
      "type": type
    };

    WebApiHelper().callFormDataPostApi(context, AppConstants.CONTACT_US_API, params, true).then((response) {
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          Get.back();
          showToast(message: statusModel.message!);
        }
        else {
          showToast(message: statusModel.message!);
        }
      }
    });
  }

  bool isValidate(){
    if (nameController.text.trim().isEmpty) {
      showToast(message:"Please enter name");
      return false;
    }
    else if (emailController.text.trim().isEmpty) {
      showToast(message:"Please enter email address");
      return false;
    }
    else if (!AppConstants().isEmailValid(emailController.text.trim())) {
      showToast(message: 'Please enter valid email address');
      return false;
    }
    else if (mobileController.text.trim().isEmpty) {
      showToast(message: 'please_enter_mobile_number'.tr);
      return false;
    }
    else if (mobileController.text.trim().length < 10) {
      showToast(message: 'please_enter_valid_mobile_number'.tr);
      return false;
    }
    else if (subjectController.text.trim().isEmpty) {
      showToast(message: 'Please enter subject');
      return false;
    }
    else if (messageController.text.trim().isEmpty) {
      showToast(message: 'Please enter message');
      return false;
    }
    else {
      return true;
    }
  }

}