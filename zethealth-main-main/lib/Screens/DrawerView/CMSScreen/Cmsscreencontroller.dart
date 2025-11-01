import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../Helper/AppConstants.dart';
import '../../../Models/CmsModel.dart';
import '../../../Models/StatusModel.dart';
import '../../../Network/WebApiHelper.dart';

class CmsScreencontroller extends GetxController {
  RxBool isLoading = true.obs;
  Rx<CmsModel?> cmsModel = Rx<CmsModel?>(null);

  callCMSApi(BuildContext context, String cmsType) {
    isLoading.value = true;

    Map<String, dynamic> params = {
      "slug": cmsType,
    };

    WebApiHelper()
        .callFormDataPostApi(context, AppConstants.CMS_API, params, true)
        .then((response) {
      isLoading.value = false;
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if (statusModel.status!) {
          if (statusModel.result != null &&
              statusModel.result.toString().isNotEmpty) {
            cmsModel.value = statusModel.result;
          }
        }
      }
    });
  }
}
