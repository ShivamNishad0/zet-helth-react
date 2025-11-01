import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:zet_health/Screens/MyCartScreen/MyCartScreenController.dart';

import '../../../Models/UserDetailModel.dart';
import '../../DrawerView/FamilyMemberScreen/FamilyMemberScreenController.dart';

class AddPatientScreenController extends GetxController {
  List<String> relationOptions = ['My Self','Spouse','Son','Daughter','Brother','Sister','Mother','Father','Cousin','Uncle','Aunty','Other'];
  RxString selectedRelation = "".obs;
  RxInt selectedGender = (-1).obs;
  UserDetailModel userDetailModel = UserDetailModel();

  // Error messages for each field
  RxString firstNameError = "".obs;
  RxString lastNameError = "".obs;
  RxString relationError = "".obs;
  RxString emailError = "".obs;
  RxString mobileError = "".obs;
  RxString dobError = "".obs;
  RxString genderError = "".obs;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  setData(UserDetailModel? patientList){
    if(patientList!=null){
      firstNameController.text = patientList.firstName.toString();
      lastNameController.text = patientList.lastName.toString();
      emailController.text = patientList.email?.toString() ?? "";
      mobileController.text = patientList.mobile.toString();
      selectedRelation.value = patientList.relation.toString();
      dobController.text = AppConstants().ddMMYYYYSlasDateFormat(patientList.dob.toString());
      selectedGender.value = patientList.gender=="Male" ? 0 : patientList.gender=="Female" ? 1 : 2;
      
      // Clear errors when setting data
      clearErrors();
    }
  }

  clearData(){
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    mobileController.clear();
    dobController.clear();
    selectedRelation.value = "";
    selectedGender.value = -1;
    clearErrors();
  }

  clearErrors() {
    firstNameError.value = "";
    lastNameError.value = "";
    relationError.value = "";
    emailError.value = "";
    mobileError.value = "";
    dobError.value = "";
    genderError.value = "";
  }

  callAddPatientApi({UserDetailModel? patientList,required int screenType}) {
    Map<String, dynamic> params = {
      "id": patientList!=null ? patientList.id.toString() : '0',
      "first_name": firstNameController.text.trim(),
      "last_name": lastNameController.text.trim(),
      "relation": selectedRelation.value,
      "email": emailController.text.trim(),
      "mobile": mobileController.text.trim(),
      "dob": AppConstants().apiDateFormatFromSlas(dobController.text),
      "gender": selectedGender.value == 0 ? 'Male' : selectedGender.value == 1 ? 'Female' : 'Other',
    };

    WebApiHelper().callFormDataPostApi(null, AppConstants.ADD_PATIENT_API, params, true).then((response) {
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if (statusModel.status!) {
          Get.back();
          if(screenType == 0) {
            MyCartScreenController myCartScreenController = Get.find<MyCartScreenController>();
            myCartScreenController.callGetCartApi();
          } else if(screenType == 1) {
            FamilyMemberScreenController familyMemberScreenController = Get.find<FamilyMemberScreenController>();
            familyMemberScreenController.getPatientListApi();
          }
          showToast(message: '${statusModel.message}');
        } else {
          showToast(message: '${statusModel.message}');
        }
      }
    });
  }

  bool isValidate() {
    clearErrors();
    
    bool isValid = true;
    String? date = dateValidate(dobController.text);

    if (firstNameController.text.trim().isEmpty) {
      firstNameError.value = 'please_enter_first_name'.tr;
      isValid = false;
    }

    // Validate Last Name
    if (lastNameController.text.trim().isEmpty) {
      lastNameError.value = 'please_enter_last_name'.tr;
      isValid = false;
    }

    // Validate Relation
    if (selectedRelation.value.isEmpty) {
      relationError.value = 'Please Select Relation';
      isValid = false;
    }

    // Validate Mobile Number
    if (mobileController.text.trim().isEmpty) {
      mobileError.value = 'please_enter_mobile_number'.tr;
      isValid = false;
    } else if (mobileController.text.trim().length < 10) {
      mobileError.value = 'please_enter_valid_mobile_number'.tr;
      isValid = false;
    }

    // Validate Date of Birth
    if (dobController.text.trim().isEmpty) {
      dobError.value = 'Please Enter Date Of Birth';
      isValid = false;
    } else if (date != null) {
      dobError.value = date.tr;
      isValid = false;
    }

    // Validate Gender
    if (selectedGender.value == -1) {
      genderError.value = 'please_select_gender'.tr;
      isValid = false;
    }

    // Validate Email (Optional but if provided, should be valid)
    if (emailController.text.trim().isNotEmpty && !AppConstants().isEmailValid(emailController.text.trim())) {
      emailError.value = 'please_enter_valid_email_address'.tr;
      isValid = false;
    }

    return isValid;
  }

  // Add text change listeners to clear errors when user starts typing
  void initializeListeners() {
    firstNameController.addListener(() {
      if (firstNameError.value.isNotEmpty) {
        firstNameError.value = "";
      }
    });
    
    lastNameController.addListener(() {
      if (lastNameError.value.isNotEmpty) {
        lastNameError.value = "";
      }
    });
    
    mobileController.addListener(() {
      if (mobileError.value.isNotEmpty) {
        mobileError.value = "";
      }
    });
    
    dobController.addListener(() {
      if (dobError.value.isNotEmpty) {
        dobError.value = "";
      }
    });
    
    emailController.addListener(() {
      if (emailError.value.isNotEmpty) {
        emailError.value = "";
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    initializeListeners();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    dobController.dispose();
    super.onClose();
  }
}