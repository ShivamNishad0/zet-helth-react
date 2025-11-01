import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zet_health/Screens/DrawerView/OrderHistoryScreen/OrderHistoryScreenController.dart';

import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomContainer.dart';
import '../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../../Models/BookingModel.dart';
import 'OrderDetailScreen/OrderDetailScreen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  OrderHistoryScreenController orderHistoryScreenController =
      Get.put(OrderHistoryScreenController());

  @override
  void initState() {
    super.initState();
    orderHistoryScreenController.callGetBookingApi(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        leading: Image.asset(backArrow),
        title: Text('order_history'.tr, style: semiBoldBlack_18),
      ),
      body: Obx(
        () => orderHistoryScreenController.orderList.isEmpty
            ? const NoDataFoundWidget(
                title: 'Order History is Empty', description: '')
            : ListView.builder(
                itemCount: orderHistoryScreenController.orderList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  BookingModel bookingModel =
                      orderHistoryScreenController.orderList[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                          () => OrderDetailScreen(bookingModel: bookingModel));
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
                      padding:
                          EdgeInsets.only(left: 10.w, top: 10.h, bottom: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16.r)),
                        boxShadow: [
                          BoxShadow(
                              color: borderColor.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 5))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bookingModel.bookingName!,
                              style: semiBoldBlack_13),
                          SizedBox(
                            height: 7.h,
                          ),
                          Row(
                            children: [
                              if (bookingModel.bookingStatus != null &&
                                  bookingModel.bookingStatus!.isNotEmpty)
                                CustomContainer(
                                  right: 5.w,
                                  borderColor: bookingModel.bookingStatus ==
                                          "CancelByAdmin"
                                      ? peachPuffColor
                                      : completeBorderColor,
                                  radius: 18.r,
                                  leftPadding: 6.w,
                                  rightPadding: 6.w,
                                  topPadding: 2.h,
                                  borderWidth: 1.w,
                                  bottomPadding: 2.h,
                                  color: bookingModel.bookingStatus ==
                                          "CancelByAdmin"
                                      ? orangeAlphaColor
                                      : completeColor,
                                  child: Text(
                                      bookingModel.bookingStatus ==
                                              "CancelByAdmin"
                                          ? 'order_cancel'.tr
                                          : 'order_complete'.tr,
                                      style: mediumBlack_10),
                                ),
                              CustomContainer(
                                borderColor: borderColor,
                                radius: 18.r,
                                leftPadding: 6.w,
                                rightPadding: 6.w,
                                topPadding: 2.h,
                                bottomPadding: 2.h,
                                color: cardBgColor,
                                child: RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: '#', style: semiBoldPrimary_12),
                                    TextSpan(
                                        text:
                                            ' ${bookingModel.bookingNo!.replaceAll("#", "")}',
                                        style: mediumBlack_10)
                                  ]),
                                ),
                              ),
                            ],
                          ),
                          CustomContainer(
                            right: 5.w,
                            bottom: 10.h,
                            top: 5.h,
                            borderColor: borderColor,
                            radius: 18.r,
                            leftPadding: 6.w,
                            rightPadding: 6.w,
                            topPadding: 2.h,
                            bottomPadding: 2.h,
                            color: cardBgColor,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.business_outlined,
                                    color: primaryColor, size: 13.sp),
                                SizedBox(width: 2.w),
                                Text(bookingModel.labName!,
                                    style: mediumBlack_10)
                              ],
                            ),
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                  margin: EdgeInsets.only(right: 10.w),
                                  child: Text(
                                      '${ddMMYYYYDateFormat(bookingModel.bookingDate.toString())} ${bookingModel.bookingSlot != "" ? formatDateString('hh:mm a', 'hh:mm', bookingModel.bookingSlot.toString()) : formatDateString('hh:mm a', 'hh:mm', bookingModel.bookingTime.toString())}',
                                      style: mediumGray_10)))
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
