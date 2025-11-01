import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Models/PackageModel.dart';
import '../../../Models/ProfileModel.dart';
import '../../../Models/StatusModel.dart';
import '../../../Models/TestModel.dart';
import '../../../Network/WebApiHelper.dart';

class LabDetailScreenController extends GetxController {

  RxList<TestModel> testList = <TestModel>[].obs;
  RxList<TestModel> tempTestList = <TestModel>[].obs;
  RxList<PackageModel> packageList = <PackageModel>[].obs;
  RxList<PackageModel> tempPackageList = <PackageModel>[].obs;
  RxList<ProfileModel> profileList = <ProfileModel>[].obs;
  RxList<ProfileModel> tempProfileList = <ProfileModel>[].obs;
  CroppedFile? prescriptionImg;

  callGetLabWiseTestApi({required int labId,required String sortBy}) {

    testList.value = [];
    tempTestList.value = [];

    packageList.value = [];
    tempPackageList.value = [];

    profileList.value = [];
    tempProfileList.value = [];

    Map<String, dynamic> params = {
      "lab_id": labId,
      "sort_by": sortBy,
    };

    WebApiHelper().callFormDataPostApi(null, AppConstants.GET_LAB_WISE_TEST_API, params, true).then((response) {
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          if(statusModel.labWiseTestList!=null && statusModel.labWiseTestList!.isNotEmpty) {
            testList.addAll(statusModel.labWiseTestList!);
            tempTestList.addAll(statusModel.labWiseTestList!);
          }
          if(statusModel.packageList!=null && statusModel.packageList!.isNotEmpty) {
            packageList.addAll(statusModel.packageList!);
            tempPackageList.addAll(statusModel.packageList!);
          }
          if(statusModel.profileList!=null && statusModel.profileList!.isNotEmpty) {
            profileList.addAll(statusModel.profileList!);
            tempProfileList.addAll(statusModel.profileList!);
          }
        }
      }
    });
  }

  callUploadPrescriptionApi(BuildContext context) async {
    Map<String, dynamic> params = {
      "document": prescriptionImg
    };

    WebApiHelper().callFormDataPostApi(
        context,
        AppConstants.UPLOAD_PRESCRIPTION_API,
        params, true,
        file: prescriptionImg?.path
    ).then((response) {
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          showToast(message: 'Uploaded Successfully!');
        }
        else {
          showToast(message: 'Please try again!');
        }
      }
    });
  }

}