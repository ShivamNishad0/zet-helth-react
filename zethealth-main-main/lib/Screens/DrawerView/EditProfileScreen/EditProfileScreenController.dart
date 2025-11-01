import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Models/UserDetailModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:zet_health/Screens/HomeScreen/HomeScreen.dart';

import '../../../Helper/AppConstants.dart';
import '../../SplashScreen.dart';

class EditProfileScreenController extends GetxController {
  List<String> genderOptions = ['Male', 'Female', 'Other'];
  RxInt selectedGender = (-1).obs;

  final bool fromDialog;
  EditProfileScreenController({this.fromDialog = false});

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  CroppedFile? profileImage;

  setValue(UserDetailModel userModel) {
    if (userModel.userName != null && userModel.userName != null) {
      nameController.text = userModel.userName.toString();
    }
    if (userModel.userEmail != null && userModel.userEmail != null) {
      emailController.text = userModel.userEmail.toString();
    }
    if (userModel.userMobile != null && userModel.userMobile != null) {
      mobileController.text = userModel.userMobile.toString();
    }
    if (userModel.userDob != null && userModel.userDob != null) {
      dobController.text =
          AppConstants().ddMMYYYYSlasDateFormat(userModel.userDob.toString());
    }

    if (userModel.userGender == 'Male') {
      selectedGender.value = 0;
    } else if (userModel.userGender == 'Female') {
      selectedGender.value = 1;
    } else {
      selectedGender.value = 2;
    }
  }

  callUpdateProfileApi(BuildContext context) {
    Map<String, dynamic> params = {
      "user_name": nameController.text.trim(),
      "user_email": emailController.text.trim(),
      "user_gender": selectedGender.value == 0
          ? 'Male'
          : selectedGender.value == 1
              ? 'Female'
              : 'Other',
      "user_dob": AppConstants().apiDateFormatFromSlas(dobController.text),
    };

    WebApiHelper()
        .callFormDataPostApi(
            context, AppConstants.UPDATE_PROFILE_API, params, true,
            imageKey: 'user_profile', file: profileImage?.path)
        .then((response) {
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if (statusModel.status!) {
          AppConstants().getStorage.write(
              AppConstants.USER_DETAIL, json.encode(statusModel.userDetail));
          if (fromDialog) {
            Get.offAll(() => const HomeScreen());
          } else {
            Get.back();
          }
          showToast(message: statusModel.message!);
        } else {
          showToast(message: statusModel.message!);
        }
      }
    });
  }

  deleteAccountApi() {
    WebApiHelper()
        .callGetApi(null, AppConstants.deleteAccount, true)
        .then((response) {
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if (statusModel.status!) {
          GetStorage().write(AppConstants.USER_MOBILE, null);
          AppConstants().loadWithCanNotAllBack(const SplashScreen());
        } else {
          showToast(message: statusModel.message!);
        }
      }
    });
  }

  bool isValidate() {
    String? date = dateValidate(dobController.text);
    if (nameController.text.trim().isEmpty) {
      showToast(message: "Please enter name");
      return false;
    } else if (emailController.text.trim().isEmpty) {
      showToast(message: "Please enter email address");
      return false;
    } else if (!AppConstants().isEmailValid(emailController.text.trim())) {
      showToast(message: 'Please enter valid email address');
      return false;
    } else if (date != null) {
      showToast(message: date.tr);
      return false;
    } else if (selectedGender.value == -1) {
      showToast(message: 'please_select_gender'.tr);
      return false;
    } else {
      return true;
    }
  }
}
