import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomAppbar.dart';
import 'package:zet_health/CommonWidget/CustomLoadingIndicator.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AssetHelper.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Helper/StyleHelper.dart';
import 'add_wallet_balance_screen.dart';
import 'wallet_screen_controller.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  WalletScreenController walletScreenController =
      Get.put(WalletScreenController());

  @override
  void initState() {
    super.initState();
    walletScreenController.getWalletHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
          centerTitle: true,
          isLeading: true,
          leading: Image.asset(backArrow),
          title: Text('wallet_history'.tr, style: semiBoldBlack_18),
        ),
        body: Obx(() {
          if (walletScreenController.walletTransaction.value.status == null) {
            return const Center(
                child: CustomLoadingIndicator(isDisMissile: true));
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  margin:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1,
                          offset: Offset(0, 1))
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('balance'.tr, style: mediumBlack_14),
                            Text(
                                '₹ ${walletScreenController.walletTransaction.value.walletBalance}',
                                style: semiBoldBlack_18),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() =>
                              const AddWalletBalanceScreen(setAmount: ''));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 8.h),
                          margin: EdgeInsets.only(left: 15.w),
                          decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(20.r)),
                          child: Row(
                            children: [
                              Text('add_balance'.tr, style: semiBoldWhite_14),
                              SizedBox(width: 8.w),
                              Icon(Icons.add, size: 20.sp, color: Colors.white)
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                PaddingHorizontal15(
                  child: Text('wallet_history'.tr,
                      style: TextStyle(
                          fontFamily: semiBold,
                          color: primaryColor,
                          fontSize: 16.sp,
                          decoration: TextDecoration.underline)),
                ),
                Expanded(
                    child: walletScreenController.walletTransaction.value
                                    .walletTransaction !=
                                null &&
                            walletScreenController.walletTransaction.value
                                .walletTransaction!.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: walletScreenController.walletTransaction
                                .value.walletTransaction?.length,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.only(
                                top: 15.h,
                                bottom: 15.h,
                                left: 15.w,
                                right: 15.w),
                            itemBuilder: (context, index) {
                              final walletTransaction = walletScreenController
                                  .walletTransaction
                                  .value
                                  .walletTransaction![index];
                              return Container(
                                // padding: EdgeInsets.symmetric(vertical: 8.h,horizontal: 12.w),
                                margin: EdgeInsets.only(bottom: 10.h),
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: walletTransaction.prefix == 'Plus'
                                      ? lightGreen
                                      : lightRed,
                                  borderRadius: BorderRadius.circular(10.r),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 1,
                                        offset: Offset(0, 1))
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: PaddingHorizontal15(
                                        top: 8.h,
                                        bottom: 8.h,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                walletTransaction.title
                                                    .toString(),
                                                style: semiBoldBlack_14),
                                            Text(
                                                walletTransaction.message
                                                    .toString(),
                                                style: mediumBlack_12,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            Text(
                                              formatDateString(
                                                  'dd-MM-yyyy hh:mm a',
                                                  'yyyy-MM-dd HH:mm:ss',
                                                  '${walletTransaction.createdDate}'),
                                              style: mediumGray_11,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(bottom: 5.h),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 5.h),
                                          decoration: BoxDecoration(
                                              color: shadowColor,
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(10.r),
                                                  bottomLeft:
                                                      Radius.circular(10.r))),
                                          child: Text(
                                              '${walletTransaction.type}',
                                              style: semiBoldBlack_13),
                                        ),
                                        Padding(
                                            padding:
                                                EdgeInsets.only(right: 10.w),
                                            child: Text(
                                                '${walletTransaction.prefix == 'Plus' ? '+' : '-'} ₹${walletTransaction.amount}',
                                                style: semiBoldBlack_15)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : NoDataFoundWidget(
                            title: 'no_transaction_found'.tr, description: '')),
              ],
            );
          }
        }));
  }
}
