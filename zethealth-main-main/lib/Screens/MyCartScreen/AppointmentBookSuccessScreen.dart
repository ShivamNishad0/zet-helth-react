import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/StyleHelper.dart';
import 'package:zet_health/Screens/BookingScreen/BookingScreenController.dart';
import '../../CommonWidget/CustomButton.dart';
import '../../CommonWidget/CustomWidgets.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/ColorHelper.dart';
import '../../Models/SlotModel.dart';
import '../DrawerView/NavigationDrawerController.dart';

class AppointmentBookSuccessScreen extends StatefulWidget {
  final String selectedDate;
  final List<SlotDetailsModel> selectedTime;
  final String bookingId;

  const AppointmentBookSuccessScreen(
      {super.key, required this.selectedDate, required this.selectedTime, required this.bookingId});

  @override
  State<AppointmentBookSuccessScreen> createState() =>
      _AppointmentBookSuccessScreenState();
}

class _AppointmentBookSuccessScreenState
    extends State<AppointmentBookSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: PaddingHorizontal20(
        child: Center(
          child: Material(
            borderRadius: BorderRadius.circular(20.r),
            color: whiteColor,
            child: PaddingHorizontal15(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(appointmentSuccessIcon, height: 100.h),
                  Text('congratulation'.tr, style: semiBoldBlack_20),
                  Text(
                    'msg_test_booked_success'.tr,
                    textAlign: TextAlign.center,
                    style: mediumGray_13,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 55.h,
                            width: 55.h,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SvgPicture.asset(calendarShape),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      formatDateString('d', 'yyyy-MM-dd',
                                          widget.selectedDate.toString()),
                                      style: boldPrimary_17,
                                    ),
                                    Text(
                                      formatDateString('EEE', 'yyyy-MM-dd',
                                          widget.selectedDate.toString()),
                                      style: semiBoldBlack_16,
                                    ),
                                  ],
                                )
                              ],
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                formatDateString(
                                    "MMMM", "yyyy-MM-dd", widget.selectedDate),
                                style: boldPrimary_15),
                            //◈ Fertility Specialist
                            Text(
                                formatDateString(
                                    "yyyy", "yyyy-MM-dd", widget.selectedDate),
                                style: semiBoldGray_15),
                            if (widget.selectedTime.isNotEmpty)
                              Text(widget.selectedTime[0].time.toString(),
                                  style: semiBoldGray_13)
                          ],
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    topMargin: 15.h,
                    bottomMargin: 15.h,
                    horizontalMargin: 15.w,
                    borderRadius: 20.r,
                    text: 'go_to_my_appointment'.tr,
                    onTap: () {
                      Get.until((route) => route.isFirst);
                      NavigationDrawerController navigationDrawerController =
                          Get.find<NavigationDrawerController>();
                      navigationDrawerController.pageIndex.value = 1;

                      if (!Get.isRegistered<BookingScreenController>()) {
                        Get.put(BookingScreenController());
                      }
                      BookingScreenController bookingController = Get.find<BookingScreenController>();
                      bookingController.targetBookingId = widget.bookingId;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
