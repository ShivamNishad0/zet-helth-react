import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/ColorHelper.dart';

import '../../../../CommonWidget/CustomAppbar.dart';
import '../../../../CommonWidget/CustomButton.dart';
import '../../../../CommonWidget/CustomContainer.dart';
import '../../../../CommonWidget/CustomTextField2.dart';
import '../../../../CommonWidget/CustomWidgets.dart';
import '../../../../CommonWidget/rating_bar.dart';
import '../../../../Helper/AppConstants.dart';
import '../../../../Helper/AssetHelper.dart';
import '../../../../Helper/StyleHelper.dart';
import '../../../../Models/order_detail_model.dart';
import '../../../../Network/WebApiHelper.dart';
import '../OrderDetailScreen/OrderHistoryDetailScreenController.dart';

class AddReviewScreen extends StatefulWidget {
  const AddReviewScreen({super.key, required this.bookingDetails});
  final BookingDetails bookingDetails;

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  RxDouble ratingStar = (-1.0).obs;
  TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        leading: Image.asset(backArrow),
        title: Text('add_review'.tr, style: semiBoldBlack_18),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              bottom: 20.h,
              radius: 16.r,
              leftPadding: 8.w,
              rightPadding: 8.w,
              topPadding: 8.h,
              bottomPadding: 8.h,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                )
              ],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10.r)),
                    child: CachedNetworkImage(
                      imageUrl: AppConstants.IMG_URL +
                          widget.bookingDetails.lab!.labProfile.toString(),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const ImageErrorWidget(),
                      width: 45.h,
                      height: 45.h,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bookingDetails.lab!.labName.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: semiBoldBlack_13,
                        ),
                        SizedBox(height: 2.h),
                        if (widget.bookingDetails.lab!.address != null)
                          Text(
                            removeHtmlTags(
                                widget.bookingDetails.lab!.address.toString()),
                            style: regularBlack_11,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: Get.width,
              margin: EdgeInsets.only(bottom: 15.h),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: const [
                    BoxShadow(color: borderColor, blurRadius: 1)
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('rate_your_experience'.tr, style: semiBoldBlack_12),
                  SizedBox(height: 10.h),
                  Obx(
                    () => RatingBar(
                      glow: false,
                      initialRating: ratingStar.value,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 30.sp,
                      itemPadding: EdgeInsets.only(right: 8.w),
                      ratingWidget: RatingWidget(
                        full: Image.asset(starFull),
                        half: Image.asset(starHalf),
                        empty: Image.asset(starFull, color: greyColor),
                      ),
                      onRatingUpdate: (rating) {
                        ratingStar.value = rating;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: const [
                    BoxShadow(color: borderColor, blurRadius: 1)
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField2(
                    maxLines: 5,
                    height: 80.h,
                    controller: reviewController,
                    title: 'review'.tr,
                    hintText: 'write_review_here'.tr,
                    topMargin: 5.h,
                    filled: true,
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomButton(
          horizontalMargin: 15.w,
          bottomMargin: 5.h,
          borderRadius: 10.r,
          text: 'submit_review'.tr,
          onTap: () async {
            if (isValidate()) {
              ratingReviewApi();
            }
          }),
    );
  }

  isValidate() {
    if (ratingStar.value <= 0) {
      showToast(message: 'please_select_star');
      return false;
    } else if (reviewController.text.trim().isEmpty) {
      showToast(message: 'please_write_review');
      return false;
    } else {
      return true;
    }
  }

  ratingReviewApi() {
    Map<String, dynamic> params = {
      'rating': ratingStar.value.toString(),
      'review': reviewController.text,
      'lab_id': widget.bookingDetails.lab!.labId,
      'booking_id': widget.bookingDetails.id,
    };
    WebApiHelper()
        .callFormDataPostApi(null, AppConstants.ratingReview, params, true)
        .then((response) {
      if (response != null) {
        OrderDetailModel statusModel =
            OrderDetailModel.fromJson(jsonDecode(response));
        if (statusModel.status!) {
          Get.back();
          showToast(message: statusModel.message.toString());
          OrderHistoryDetailScreenController
              orderHistoryDetailScreenController =
              Get.find<OrderHistoryDetailScreenController>();
          orderHistoryDetailScreenController.getBookingDetailsApi(
              bookingId: widget.bookingDetails.id.toString());
        }
      }
    });
  }
}
