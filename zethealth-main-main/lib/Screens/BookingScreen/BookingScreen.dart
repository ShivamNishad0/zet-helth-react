import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomLoadingIndicator.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Screens/BookingScreen/BookingScreenController.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../CommonWidget/CustomAppbar.dart';
import '../../CommonWidget/CustomContainer.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/StyleHelper.dart';
import '../../Models/BookingModel.dart';
import '../../main.dart';
import '../DrawerView/NavigationDrawerController.dart';
import '../DrawerView/OrderHistoryScreen/OrderDetailScreen/OrderDetailScreen.dart';
import 'MapScreen/MapScreen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  NavigationDrawerController navigationDrawerController =
      Get.find<NavigationDrawerController>();
  BookingScreenController bookingScreenController =
      Get.isRegistered<BookingScreenController>()
          ? Get.find<BookingScreenController>()
          : Get.put(BookingScreenController());

  @override
  void initState() {
    super.initState();
    if (navigationDrawerController.isLogin.value) {
      bookingScreenController.callGetBookingApi();
      bookingScreenController.razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
          bookingScreenController.handlePaymentSuccess);
      bookingScreenController.razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
          bookingScreenController.handlePaymentError);
      bookingScreenController.razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
          bookingScreenController.handleExternalWallet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
          centerTitle: true,
          leading: CustomSquareButton(
            backgroundColor: whiteColor,
            leftMargin: 15.w,
            icon: drawerIcon,
            shadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              )
            ],
            onTap: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [NotificationButtonCommon(), CartButtonCommon()],
          isLeading: false,
          title: Text('my_bookings'.tr, style: semiBoldBlack_18),
        ),
        body: Obx(
          () => navigationDrawerController.isLogin.value
              ? bookingScreenController.isLoading.value
                  ? Container()
                  : bookingScreenController.bookingList.isEmpty
                      ? NoDataFoundWidget(
                          title: 'no_booking_found'.tr,
                          description: '',
                        )
                      : _handleTargetBooking(context)
              : NoLoginWidget(onLoginSuccess: () {
                  setState(() {
                    bookingScreenController.callGetBookingApi();
                  });
                }),
        ));
  }

  Widget _handleTargetBooking(BuildContext context) {
    if (bookingScreenController.targetBookingId != null &&
        bookingScreenController.targetBookingId!.isNotEmpty) {
      final booking = bookingScreenController.bookingList.firstWhereOrNull(
        (b) => b.id.toString() == bookingScreenController.targetBookingId,
      );

      if (booking != null) {
        // reset so it doesn't re-trigger on rebuild
        final id = bookingScreenController.targetBookingId;
        bookingScreenController.targetBookingId = '';

        // open MapScreen *after* this frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppConstants().loadWithCanBack(
            MapScreen(
              bookingModel: booking,
              showCongrats: true,
            ),
          );
        });
      }
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
      itemCount: bookingScreenController.bookingList.length,
      itemBuilder: (context, index) {
        BookingModel bookingModel = bookingScreenController.bookingList[index];
        return GestureDetector(
          onTap: () {
            if (bookingModel.bookingStatus == 'Accepted' &&
                bookingModel.isOriginal == 1) {
              AppConstants().loadWithCanBack(
                MapScreen(
                  bookingModel: bookingModel,
                  showCongrats: false,
                ),
              );
            } else {
              Get.to(() => OrderDetailScreen(bookingModel: bookingModel));
            }
          },
          child: _buildBookingCard(bookingModel),
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel bookingModel) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bookingModel.bookingName!, style: semiBoldBlack_13),
          SizedBox(
            height: 7.h,
          ),
          Row(
            children: [
              if (bookingModel.bookingStatus != null &&
                  bookingModel.bookingStatus!.isNotEmpty)
                CustomContainer(
                  right: 5.w,
                  borderColor: bookingModel.bookingStatus == "Pending"
                      ? pendingBorderColor
                      : bookingModel.bookingStatus == "CancelByAdmin"
                          ? peachPuffColor
                          : completeBorderColor,
                  radius: 18.r,
                  leftPadding: 6.w,
                  rightPadding: 6.w,
                  topPadding: 2.h,
                  borderWidth: 1.w,
                  bottomPadding: 2.h,
                  color: bookingModel.bookingStatus == "Pending"
                      ? pendingColor
                      : bookingModel.bookingStatus == "CancelByAdmin"
                          ? orangeAlphaColor
                          : completeColor,
                  child: Text('${bookingModel.bookingStatus}',
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
                    TextSpan(text: '#', style: semiBoldPrimary_12),
                    TextSpan(
                        text: ' ${bookingModel.bookingNo?.substring(1)}',
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
                Icon(Icons.business_outlined, color: primaryColor, size: 14.sp),
                SizedBox(width: 2.w),
                Text(
                  bookingModel.labName!,
                  style: mediumBlack_10,
                )
              ],
            ),
          ),
          Row(
            children: [
              if (bookingModel.bookingStatus != "CancelByAdmin")
                GestureDetector(
                  onTap: () {
                    if (bookingModel.paymentStatus == "Pending") {
                      Get.dialog(CommonDialog(
                        title: 'Book Lab',
                        description: 'Are you sure you want to book ?',
                        tapNoText: 'cancel'.tr,
                        tapYesText: 'confirm'.tr,
                        onTapNo: () => Get.back(),
                        onTapYes: () {
                          Get.back();
                          bookingScreenController.bookingId =
                              bookingModel.id.toString();
                          bookingScreenController.payableAmount =
                              bookingModel.totalPayableAmount.toString();
                          bookingScreenController.checkBalanceApi();
                        },
                      ));
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10.w),
                    padding: EdgeInsets.all(2.sp),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: bookingModel.paymentStatus == "Paid"
                                ? completeBorderColor
                                : pendingBorderColor,
                            width: 1.w)),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: bookingModel.paymentStatus == "Paid"
                            ? completeColor
                            : pendingColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                          bookingModel.paymentStatus == "Paid"
                              ? "paid".tr
                              : "pay_now".tr,
                          style: semiBoldBlack_12),
                    ),
                  ),
                ),
              Expanded(
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(customDateFormat(bookingModel.createdDate!),
                          style: mediumGray_10))),
            ],
          )
        ],
      ),
    );
  }
}
