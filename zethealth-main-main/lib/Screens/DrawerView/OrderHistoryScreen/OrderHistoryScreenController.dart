import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../Helper/AppConstants.dart';
import '../../../Models/BookingModel.dart';
import '../../../Models/StatusModel.dart';
import '../../../Network/WebApiHelper.dart';

class OrderHistoryScreenController extends GetxController {

  RxList<BookingModel> orderList = <BookingModel>[].obs;
  RxBool isLoading = false.obs;

  callGetBookingApi(BuildContext context) {
    orderList.value = [];
    isLoading.value = true;

    Map<String, dynamic> params = {
      'type': 'Dropped'
    };

    WebApiHelper().callFormDataPostApi(context, AppConstants.GET_BOOKING_LIST_API, params, true).then((response) {
      isLoading.value = false;

      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          if(statusModel.bookingList!.isNotEmpty) {
            orderList.addAll(statusModel.bookingList!);
          }
        }
      }
    });
  }

}