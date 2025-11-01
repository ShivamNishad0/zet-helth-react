import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/CartModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Models/UserDetailModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:zet_health/Screens/HomeScreen/TestScreen/SearchTest/SearchResultController.dart';
import '../../Helper/database_helper.dart';
import '../../Models/AddressListModel.dart';
import '../HomeScreen/HomeScreenController.dart';
import 'AppointmentBookSuccessScreen.dart';

class MyCartScreenController extends GetxController {

  final DBHelper dbHelper = DBHelper();
  final SearchResultController searchResultController = Get.isRegistered<SearchResultController>() ? Get.find<SearchResultController>() : Get.put(SearchResultController());

  AddressList? selectedAddress;
  TextEditingController couponCodeController = TextEditingController();
  RxBool isCouponApplied = false.obs;
  RxDouble couponDiscountAmount = 0.0.obs;
  RxBool isWomenPhlebo = false.obs;

  RxList<CartModel> cartList = <CartModel>[].obs;
  Rx<CartModel> cartModel = CartModel().obs;

  UserDetailModel? selectedUser;
  UserDetailModel? selectedPatient;

  int selectedBookingType = 0;
  final selectedDate = AppConstants().currentDate().obs;
  final selectedTime = ''.obs;
  RxInt selectedIndex = RxInt(-1);
  CroppedFile? prescriptionImg;
  String bookingId = '';
  String serviceCharge = AppConstants().getStorage.read(AppConstants.serviceCharge)??'';
  String serviceChargeDisplay = AppConstants().getStorage.read(AppConstants.serviceChargeDisplay)??'';
  RxString payableAmount = ''.obs;
  RxString rechargeAmount = ''.obs;
  Rx<UserDetailModel> userModel = AppConstants().getUserDetails().obs;

  RxBool showClearCart = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedPatient = getSelectedPatient();
    print(AppConstants().getCartPincode());
  }

  void saveSelectedPatient(UserDetailModel patient) {
    AppConstants().getStorage.write('selected_patient', jsonEncode(patient.toJson()));
  }

  UserDetailModel? getSelectedPatient() {
    try {
      var storedData = AppConstants().getStorage.read('selected_patient');
      if(storedData != null) {
        return UserDetailModel.fromJson(jsonDecode(storedData));
      }
    } catch (e) {
      print('Error loading selected patient: $e');
    }
    return null;
  }

  void clearSelectedPatient() {
    AppConstants().getStorage.remove('selected_patient');
  }

  void loadLocalCart() {
    cartList.clear();
    cartModel.value = CartModel();

    if (searchResultController.cartList.isNotEmpty) {
      cartModel.value.itemList = List.from(searchResultController.cartList);
      showClearCart.value = true;
      double total = 0.0;
      for (var item in cartModel.value.itemList!) {
        total += double.parse(item.price ?? "0");
      }
      cartList.add(CartModel(subTotal: total.toString()));
      payableAmount.value = (total + double.parse(serviceCharge)).toString();
    }
    else {
      cartModel.value.itemList = [];
      showClearCart.value = false;
      // print("local Item List Empty: ${cartModel.value.itemList}");
    }
  }


callGetCartApi() {
  selectedIndex = RxInt(-1);
  cartList.value = [];
  cartModel.value = CartModel();
  
  WebApiHelper().callGetApi(null, AppConstants.GET_CART_API, false).then((response) {
    if(response != null) {
      StatusModel statusModel = StatusModel.fromJson(response);
      if(statusModel.status!) {
        if(statusModel.cartList!.isNotEmpty) {
          cartList.addAll(statusModel.cartList!);
          
          // 🔥 DEBUG: Check the raw cart JSON
          debugPrint("🛒 Raw cartJson: ${cartList[0].cartJson}");
          
          try {
            final cartData = json.decode(cartList[0].cartJson!);
            debugPrint("🛒 Parsed cartData: $cartData");
            
            // Check the structure of cart data
            if (cartData['item'] != null) {
              debugPrint("🛒 Items in cart: ${cartData['item']}");
              for (var item in cartData['item']) {
                debugPrint("🛒 Item: ${item['name']}, Type: ${item['type']}");
                debugPrint("🛒 ItemDetail field: ${item['item_detail']}");
                debugPrint("🛒 ItemDetail type: ${item['item_detail']?.runtimeType}");
              }
            }
          } catch (e) {
            debugPrint("❌ Error parsing cart JSON: $e");
          }
          
          // Parse the cart data
          cartModel.value = CartModel.fromJson(json.decode(json.encode(cartList[0])));
          final cc = CartModel.fromJson(json.decode(cartList[0].cartJson!));
          
          cartModel.value.name = cc.name;
          cartModel.value.type = cc.type;
          cartModel.value.itemList = cc.itemList;
          
          // Debug: Check what we got after parsing
          if (cartModel.value.itemList != null) {
            for (var item in cartModel.value.itemList!) {
              debugPrint("🛒 After parsing - Cart Item: ${item.name}, Type: ${item.type}");
              debugPrint("🛒 After parsing - ItemDetail Count: ${item.itemDetail?.length ?? 0}");
              if (item.itemDetail != null) {
                for (var detail in item.itemDetail!) {
                  debugPrint("   - ${detail.name}");
                }
              } else {
                debugPrint("   - ItemDetail is NULL");
              }
            }
          }
          
          showClearCart.value = true;
          showClearCart.refresh();
          payableAmount.value = (double.parse(cartList[0].subTotal.toString()) + double.parse(serviceCharge)).toString();
        }
        else {
          cartModel.value.itemList = [];
          showClearCart.value = false;
          cartModel.refresh();
        }
      }
    }
  });
}

  callAddToCartApi() {
    if(!checkLogin()) {
      loadLocalCart();
      return;
    }
    double newPrice = 0.0;
    for(int i=0;i < cartModel.value.itemList!.length;i++){
      newPrice += double.parse(cartModel.value.itemList![i].price.toString());
    }
    Map<String, dynamic> params = {
      "id": 0,
      "lab_id": cartList[0].labModel!.labId!,
      "user_id": AppConstants().getStorage.read(AppConstants.USER_ID),
      "date_time": AppConstants().currentDateTimeApi(),
      "cart_json": json.encode({
        "price": newPrice,
        "item": cartModel.value.itemList
      }),
    };

    WebApiHelper().callFormDataPostApi(null, AppConstants.ADD_TO_CART_API, params, true).then((response) {
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          callGetCartApi();
        }
        else {
          showToast(message: statusModel.message!);
        }
      }
    });
  }

  callClearCartApi({String? type, showLoading = true}) {
    print("callClearCartApi");
    if(!checkLogin()) {
      Get.until((route) => route.isFirst);
      HomeScreenController homeScreenController = Get.put(HomeScreenController());
      homeScreenController.callHomeApi();
      SearchResultController searchResultController = Get.find();
      searchResultController.clearAllSelections();
      searchResultController.cartList.clear();
      searchResultController.cartCount.value = 0;
      searchResultController.clearSearch();
      AppConstants().getStorage.write(AppConstants.isCartExist,false);
      AppConstants().clearCartPincode();
      return;
    }
    WebApiHelper().callGetApi(null, AppConstants.GET_CLEAR_CART_API, showLoading).then((response) {
      if(response != null) {
        EasyLoading.dismiss();
        StatusModel statusModel = StatusModel.fromJson(response);
        if(statusModel.status!) {
          if(type != "Booking") {
            Get.until((route) => route.isFirst);
            HomeScreenController homeScreenController = Get.put(HomeScreenController());
            homeScreenController.callHomeApi();
          }
          AppConstants().getStorage.write(AppConstants.isCartExist,false);
          AppConstants().clearCartPincode();
          SearchResultController searchResultController = Get.find();
          searchResultController.cartList.clear();
          searchResultController.clearAllSelections();
          searchResultController.cartIds.clear();
          searchResultController.cartCount.value = 0;
          searchResultController.clearSearch();
          clearSelectedPatient();
        }
      }
    });

  }

  callUploadPrescriptionApi() async {
    Map<String, dynamic> params = {
      "document": prescriptionImg
    };

    WebApiHelper().callFormDataPostApi(
        null,
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

  void startPaymentThenBook() {
    // 1️⃣ Start payment first
    getOrderKey(
      totalPayableAmount: payableAmount.value,
      onSuccess: (PaymentSuccessResponse response) {
        // 2️⃣ If payment is successful, then create the booking
        handlePaymentSuccess(response);
      },
      onFailure: (PaymentFailureResponse response) {
        handlePaymentError(response); // existing method handles errors
      },
    );
  }

  getOrderKey({required String totalPayableAmount,
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure}) {
    UserDetailModel userDetailModel = AppConstants().getUserDetails();
    Map<String, dynamic> params = {
      'is_live': AppConstants.isPaymentLive,
      'amount': totalPayableAmount,
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
            'amount': double.parse(totalPayableAmount.toString())*100,
            'name': 'Zet Health',
            'order_id': result['order_data']['orderId'],
            'description': 'Payment',
            'prefill': {'contact': userDetailModel.userMobile.toString(), 'email': userDetailModel.userEmail.toString()},
          };
          try {
            // Get.back();
            razorpay.clear(); // Reset previous event handlers
            razorpay = Razorpay();
            razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
            razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
            razorpay.open(options);
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      }
    });
  }


  Razorpay razorpay = Razorpay();

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    // callBookingAfterApi(response);
    callBookNowApi(response);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    final message = response.message?.toLowerCase() ?? '';

    if (response.code == Razorpay.PAYMENT_CANCELLED ||
        message.contains('cancel') ||
        message.contains('cancelled by user')) {
      showToast(message: "Payment cancelled");
    } else if (response.code == Razorpay.NETWORK_ERROR) {
      showToast(message: "Network error. Please try again");
    } else {
      showToast(message: "Unexpected error occurred");
    }
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    // showToast(message: "EXTERNAL_WALLET: ${response.walletName}");
  }

  callBookNowApi(PaymentSuccessResponse? paymentResponse) {
    Map<String, dynamic> params = {
      "lab_id": cartList[0].labId,
      "cart_json": cartList[0].cartJson,
      "booking_at_type": selectedBookingType == 0 ? "BookNow" : "ChooseSlot",
      "user_id": userModel.value.userType == "Admin" ? selectedUser!.userId : "0",
      "patient_id": selectedPatient!.id,
      "date": AppConstants().apiDateFormat(selectedDate.value),
      "slot_time": selectedTime.value,
      // "slot_time": selectedSlot.isNotEmpty ? selectedSlot[0].time : "",
      "booking_type":  "Test",
      "landmark": selectedAddress!.landmark.toString(),
      "pickup_address": selectedAddress!.address.toString(),
      "from_longitude": selectedAddress!.longitude.toString(),
      "from_latitude": selectedAddress!.latitude.toString(),
      "to_latitude": cartList[0].labModel!.latitude,
      "to_longitude": cartList[0].labModel!.longitude,
      "delivery_address": cartList[0].labModel!.address,
      "coupon_code": isCouponApplied.value ? couponCodeController.text.trim() : "",
      "coupon_price": isCouponApplied.value ? couponDiscountAmount.value : "",
      "service_charge": serviceCharge,
      "is_women_phleboo": isWomenPhlebo.value ? '1' : '0',
      "hub_id": cartList[0].labModel!.labId,
      'total_payable_amount': payableAmount.value,
    };

    WebApiHelper().callFormDataPostApi(null, userModel.value.userType == "Admin" ? AppConstants.ADMIN_BOOK_NOW_API : AppConstants.BOOK_NOW_API, params, true).then((response) {
      if(response != null) {
        Map<String,dynamic> result = json.decode(response);
        if(result['status']){
          bookingId = result['booking_id'].toString();
          if(userModel.value.userType == "Admin" || result['payable_amount'].toString() == '0'){
            onBookSuccess();
          }
          else {
            rechargeAmount.value = result['payable_amount'].toString();
            // getOrderKey(totalPayableAmount: result['payable_amount'].toString());
            callBookingAfterApi(paymentResponse);
          }
          dbHelper.clearAllRecord();
          SearchResultController searchResultController = Get.find();
          searchResultController.cartList.clear();
          searchResultController.cartIds.clear();
          searchResultController.cartCount.value = 0;
          clearSelectedPatient();
        }
        else {
          showToast(message: result['message']);
        }
      }
    });
  }

  onBookSuccess(){
    Get.back();
    callClearCartApi(type: "Booking");
    Get.dialog(AppointmentBookSuccessScreen(
      selectedDate: AppConstants().apiDateFormat(selectedDate.value),
      selectedTime: const [],
      bookingId: bookingId,
    ));
  }

  callBookingAfterApi(PaymentSuccessResponse? response) {
    Map<String, dynamic> params = {
      'id': bookingId,
      'total_payable_amount': rechargeAmount.value,
      'booking_amount': payableAmount.value,
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

  applyCouponApi() {
    Map<String, dynamic> params = {
      'coupon_code': couponCodeController.text.trim(),
      'total_amount': payableAmount.value,
      'lab_id': cartList[0].labId,
      'any_id': cartModel.value.itemList![0].id,
      'type': cartModel.value.itemList!.length > 1 ? 'multi' : cartModel.value.itemList![0].type,
    };
    WebApiHelper().callFormDataPostApi(null, AppConstants.applyCoupon, params, true).then((response) {
      if(response != null) {
        Map<String,dynamic> result = json.decode(response);
        if (result['status']) {
          isCouponApplied.value = true;
          couponDiscountAmount.value = double.parse(result['discount_amount'].toString());
          calculateCouponAmount(isDiscountApply: true);
        }
        else {
          clearCoupon();
          showToast(message: result['message'].toString());
        }
      }
    });
  }

  calculateCouponAmount({required bool isDiscountApply}){
    if(isDiscountApply){
      payableAmount.value = (double.parse(payableAmount.value.toString()) - couponDiscountAmount.value).toString();
    } else {
      payableAmount.value = (double.parse(payableAmount.value.toString()) + couponDiscountAmount.value).toString();
      couponDiscountAmount.value = 0.0;
    }
    cartList.refresh();
  }

  clearCoupon(){
    couponCodeController = TextEditingController();
    isCouponApplied.value = false;
    calculateCouponAmount(isDiscountApply: false);
  }

  bool isValidate() {
    if(selectedBookingType != 0 && selectedTime.isEmpty) {
      showToast(message: 'please_select_time_slot'.tr);
      return false;
    }
    else if(userModel.value.userType == "Admin" && selectedUser == null && selectedPatient == null) {
      showToast(message: 'please_select_patient'.tr);
      return false;
    }
    else if(userModel.value.userType == "User" && selectedPatient == null) {
      showToast(message: 'please_select_patient'.tr);
      return false;
    }
    else if(selectedAddress == null) {
      showToast(message: 'please_enter_pickup_address'.tr);
      return false;
    }
    else {
      return true;
    }
  }
}