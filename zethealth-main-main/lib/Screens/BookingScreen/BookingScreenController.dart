import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/BookingModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../CommonWidget/CustomWidgets.dart';
import '../../Models/UserDetailModel.dart';
import 'MapScreen/MapScreen.dart';

class BookingScreenController extends GetxController {

  RxList<BookingModel> bookingList = <BookingModel>[].obs;
  RxBool isLoading = false.obs;
  String? targetBookingId;

  callGetBookingApi() {
    isLoading.value = true;
    bookingList.value = [];
    Map<String, dynamic> params = {};

    WebApiHelper().callFormDataPostApi(null, AppConstants.GET_BOOKING_LIST_API, params, true).then((response) {
      isLoading.value = false;
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          if(statusModel.bookingList!.isNotEmpty) {
            bookingList.addAll(statusModel.bookingList!);
            // for(BookingModel bm in statusModel.bookingList!) {
            //   print(bm.toJson());
            // }
          }
        }
      }
    });
  }


  Razorpay razorpay = Razorpay();

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    callBookingAfterApi(response);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    showToast(message: "${response.message}");
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    // showToast(message: "EXTERNAL_WALLET: ${response.walletName}");
  }


  checkBalanceApi() {
    Map<String, dynamic> params = {
      "id": bookingId,
      'total_payable_amount': payableAmount,
    };
    WebApiHelper().callFormDataPostApi(null, AppConstants.checkBalanceWithPayment, params, true).then((response) {
      if(response != null) {
        Map<String,dynamic> result = json.decode(response);
        if(result['status']){
          if(result['payable_amount'].toString() == '0'){
            onBookSuccess();
          }
          else {
            rechargeAmount = result['payable_amount'].toString();
            getOrderKey(totalPayable: result['payable_amount'].toString());
          }
        }
        else {
          showToast(message: result['message'].toString());
        }
      }
    });
  }

  onBookSuccess() async {
    bookingId = '';
    payableAmount = '';
    rechargeAmount = '';
    await callGetBookingApi();

    if (bookingList.isNotEmpty) {
      Get.to(() => MapScreen(
        bookingModel: bookingList.first,
        showCongrats: true,
      ));
    } else {
      showToast(message: "Booking not found");
    }
  }

  getOrderKey({required String totalPayable}) {
    UserDetailModel userDetailModel = AppConstants().getUserDetails();
    Map<String, dynamic> params = {
      'is_live': AppConstants.isPaymentLive,
      'amount': totalPayable,
      'email': userDetailModel.userEmail,
      'mobile_no': userDetailModel.userMobile,
      'name': userDetailModel.userName
    };

    WebApiHelper().callFormDataPostApi(null, AppConstants.getOrderKey, params, true).then((response) {
      if(response != null) {
        Map<String,dynamic> result = json.decode(json.decode(response));
        if(result['status']){
          var options = {
            'key': result['order_data']['razorpayId'],
            'amount': double.parse(totalPayable)*100,
            'name': 'Zet Health',
            'order_id': result['order_data']['orderId'],
            'description': 'Payment',
            'prefill': {'contact': userDetailModel.userMobile.toString(), 'email': userDetailModel.userEmail.toString()},
          };
          try {
            razorpay.open(options);
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      }
    });
  }

  String bookingId = '';
  String payableAmount = '';
  String rechargeAmount = '';

  callBookingAfterApi(PaymentSuccessResponse? response) {
    Map<String, dynamic> params = {
      'id': bookingId,
      'total_payable_amount': rechargeAmount,
      'booking_amount': payableAmount,
      'transaction_response': response==null ? '-' : json.encode({
        'razorpay_signature': response.signature,
        'razorpay_order_id': response.orderId,
        'razorpay_payment_id': response.paymentId,
      }),
      'razorpay_signature': response==null ? '-' : response.signature,
      'razorpay_order_id': response==null ? '-' : response.orderId,
      'razorpay_payment_id': response==null ? '-' : response.paymentId,
    };

    WebApiHelper().callFormDataPostApi(null, AppConstants.BOOKING_AFTER_PAYMENT_API, params, true).then((response) {
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(json.decode(response));
        if(statusModel.status!) {
          onBookSuccess();
        }
      }
    });
  }
}