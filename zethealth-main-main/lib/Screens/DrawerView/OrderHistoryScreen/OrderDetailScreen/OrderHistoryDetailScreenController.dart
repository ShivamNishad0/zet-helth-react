import 'dart:convert';
import 'package:get/get.dart';
import '../../../../Helper/AppConstants.dart';
import '../../../../Models/order_detail_model.dart';
import '../../../../Network/WebApiHelper.dart';

class OrderHistoryDetailScreenController extends GetxController {

  Rx<OrderDetailModel> orderDetailModel = OrderDetailModel().obs;

  getBookingDetailsApi({required String bookingId}) {
    orderDetailModel.value = OrderDetailModel();
    Map<String, dynamic> params = {
      'booking_id': bookingId
    };
    WebApiHelper().callFormDataPostApi(null, AppConstants.getBookingDetails, params, true).then((response) {
      if(response != null) {
        OrderDetailModel statusModel = OrderDetailModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          orderDetailModel.value = statusModel;
        }
      }
    });
  }
}