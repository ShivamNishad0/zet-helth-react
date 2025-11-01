import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zet_health/Screens/WalletScreen/wallet_screen_controller.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../CommonWidget/CustomAppbar.dart';
import '../../CommonWidget/CustomButton.dart';
import '../../CommonWidget/CustomTextField2.dart';
import '../../CommonWidget/CustomWidgets.dart';
import '../../Helper/AppConstants.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';

class AddWalletBalanceScreen extends StatefulWidget {
  const AddWalletBalanceScreen({super.key,required this.setAmount});
  final String setAmount;
  @override
  State<AddWalletBalanceScreen> createState() => _AddWalletBalanceScreenState();
}

class _AddWalletBalanceScreenState extends State<AddWalletBalanceScreen> {

  WalletScreenController walletScreenController = Get.put(WalletScreenController());
  FocusNode textFieldFocusNode = FocusNode();

  @override
  void initState() {
    walletScreenController.userModel = AppConstants().getUserDetails();
    walletScreenController.addBalanceController = TextEditingController();
    if(widget.setAmount.isNotEmpty){
      walletScreenController.addBalanceController.text = '₹${widget.setAmount.toString()}';
    }
    walletScreenController.razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, walletScreenController.handlePaymentSuccess);
    walletScreenController.razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, walletScreenController.handlePaymentError);
    walletScreenController.razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, walletScreenController.handleExternalWallet);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('add_balance'.tr,style: semiBoldBlack_18),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text('add_money_instantly'.tr, style: boldBlack_16),
                Text('get_instant_deposits_using_upi_or_netBanking'.tr, style: semiBoldBlack_14),
                CustomTextField2(
                  topMargin: 20.h,
                  bottomMargin: 20.h,
                  height: 60.h,
                  textAlign: TextAlign.center,
                  focusNode: textFieldFocusNode,
                  controller: walletScreenController.addBalanceController,
                  maxLength: 5,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: Platform.isIOS ? TextInputType.phone : TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textStyle: boldBlack_26,
                  hintStyle: boldGray_26,
                  hintText: '₹0'.tr,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      walletScreenController.addBalanceController.text = '₹${walletScreenController.addBalanceController.text}';
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        walletScreenController.addBalanceController.text = "₹1000";
                        textFieldFocusNode.requestFocus();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryColor)),
                        alignment: Alignment.center,
                        child: Text('₹ 1000', style: semiBoldBlack_12),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () {
                        walletScreenController.addBalanceController.text = "₹2000";
                        textFieldFocusNode.requestFocus();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryColor)),
                        alignment: Alignment.center,
                        child: Text('₹ 2000', style: semiBoldBlack_12),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () {
                        walletScreenController.addBalanceController.text = "₹3000";
                        textFieldFocusNode.requestFocus();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryColor)),
                        alignment: Alignment.center,
                        child: Text('₹ 3000', style: semiBoldBlack_12),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(color: lightGreen, borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(vertical: 8.h,horizontal: 12.w),
                  margin: EdgeInsets.only(top: 40.h),
                  child: Column(
                    children: [
                      Text('add_balance_message'.tr, style: semiBoldBlack_16, textAlign: TextAlign.center),
                      SizedBox(height: 10.h),
                      Text('add_balance_message_2'.tr, textAlign: TextAlign.center, style: semiBoldBlack_13),
                    ],
                  ),
                ),
                // CustomTextField(
                //     focusNode: FocusNode(),
                //     controller: walletScreenController.addBalanceController,
                //     topMargin: 5.h,
                //     bottomMargin: 15.h,
                //     maxLength: 10,
                //     inputFormatters: [
                //       FilteringTextInputFormatter.digitsOnly
                //     ],
                //     keyboardType: Platform.isIOS ? TextInputType.phone : TextInputType.number,
                //     textInputAction: TextInputAction.done,
                //     hintText: 'Enter Amount'.tr
                // ),
              ],
            ),

          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: CustomButton(
          horizontalMargin: 15.w,
          bottomMargin: 10.h,
          text: 'add_amount'.tr,
          onTap: () {
            FocusScope.of(context).unfocus();
            if (walletScreenController.addBalanceController.text.trim().isNotEmpty && double.parse(walletScreenController.addBalanceController.text.substring(1))>10000) {
              showToast(message: 'max_amount_message'.tr);
            }
            else if (walletScreenController.addBalanceController.text.trim().isNotEmpty && double.parse(walletScreenController.addBalanceController.text.substring(1))>0) {
              walletScreenController.getOrderKeyApi();
            }
            else {
              showToast(message: 'please_enter_amount'.tr);
            }
          }
        ),
      ),
    );
  }
}
