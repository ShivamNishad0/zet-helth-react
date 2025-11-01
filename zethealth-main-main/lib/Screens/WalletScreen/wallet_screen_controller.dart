import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/wallet_transaction_model.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../Models/UserDetailModel.dart';

class WalletScreenController extends GetxController {

  UserDetailModel userModel = UserDetailModel();
  Rx<WalletTransactionModel> walletTransaction = WalletTransactionModel().obs;
  TextEditingController addBalanceController = TextEditingController();
  Razorpay razorpay = Razorpay();

  getWalletHistory() {
    walletTransaction.value = WalletTransactionModel();
    Map<String, dynamic> params = {
      'from_date': '',
      'to_date': '',
    };
    WebApiHelper().callFormDataPostApi(null, AppConstants.getWalletTransaction, params, false).then((response) {
      if(response != null) {
        WalletTransactionModel result = WalletTransactionModel.fromJson(json.decode(response));
        if(result.status!) {
          walletTransaction.value = result;
        }
      }
    });
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    rechargeWalletApi(response);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    showToast(message: "ERROR: ${response.code} - ${response.message}");
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    // showToast(message: "EXTERNAL_WALLET: ${response.walletName}");
  }

  getOrderKeyApi(){
    Map<String, dynamic> params = {
      'is_live': AppConstants.isPaymentLive,
      'amount': addBalanceController.text.substring(1).trim(),
      'email': userModel.userEmail.toString(),
      'mobile_no': userModel.userMobile.toString(),
      'name': userModel.userName.toString()
    };
    WebApiHelper().callFormDataPostApi(null, AppConstants.getOrderKey, params, true).then((response) {
      if (response!=null) {
        Map<String,dynamic> result = json.decode(json.decode(response));
        if(result['status']){
          var options = {
            'key': result['order_data']['razorpayId'],
            'amount': double.parse(addBalanceController.text.substring(1).trim())*100,
            'name': 'Zet Health',
            'order_id': result['order_data']['orderId'],
            'description': 'Payment',
            'prefill': {'contact': userModel.userMobile.toString(), 'email': userModel.userEmail.toString()},
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

  rechargeWalletApi(PaymentSuccessResponse paymentSuccessResponse){
    Map<String, dynamic> params = {
      'razorpay_signature': paymentSuccessResponse.signature,
      'razorpay_order_id': paymentSuccessResponse.orderId,
      'razorpay_payment_id': paymentSuccessResponse.paymentId,
      'razorpay_response': json.encode({
        'razorpay_signature': paymentSuccessResponse.signature,
        'razorpay_order_id': paymentSuccessResponse.orderId,
        'razorpay_payment_id': paymentSuccessResponse.paymentId,
      }),
      'amount': addBalanceController.text.substring(1).trim(),
      'is_live': AppConstants.isPaymentLive,
    };
    WebApiHelper().callFormDataPostApi(null, AppConstants.rechargeWallet, params, true).then((response) {
      if (response!=null) {
        Map<String,dynamic> result = json.decode(response);
        if(result['status']){
          addBalanceController = TextEditingController();
          Get.back();
          getWalletHistory();
        }
      }
    });
  }
}
