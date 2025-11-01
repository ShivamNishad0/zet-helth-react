import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Models/review_rating_model.dart';
import '../../../../CommonWidget/CustomAppbar.dart';
import '../../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../../CommonWidget/CustomWidgets.dart';
import '../../../../CommonWidget/rating_bar.dart';
import '../../../../Helper/AppConstants.dart';
import '../../../../Helper/AssetHelper.dart';
import '../../../../Helper/StyleHelper.dart';
import '../../../../Network/WebApiHelper.dart';

class ReviewRatingScreen extends StatefulWidget {
  const ReviewRatingScreen({super.key, required this.labId});
  final String labId;
  @override
  State<ReviewRatingScreen> createState() => _ReviewRatingScreenState();
}

class _ReviewRatingScreenState extends State<ReviewRatingScreen> {
  Rx<ReviewRatingModel> reviewRatingModel = ReviewRatingModel().obs;

  @override
  void initState() {
    getRatingApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        leading: Image.asset(backArrow),
        title: Text('reviews_ratings'.tr, style: semiBoldBlack_18),
      ),
      body: Obx(
        () => reviewRatingModel.value.status == null
            ? const SizedBox()
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 10.h),
                      margin: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(15.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3.0,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Text(widget.productDetail.rating.toString(), style: StyleHelper.boldWhite_16),

                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: RatingBar(
                                  glow: true,
                                  allowHalfRating: true,
                                  ignoreGestures: true,
                                  tapOnlyMode: false,
                                  initialRating: double.parse('3'),
                                  direction: Axis.horizontal,
                                  itemCount: 5,
                                  itemSize: 14.sp,
                                  itemPadding: EdgeInsets.only(right: 5.w),
                                  ratingWidget: RatingWidget(
                                    full: Image.asset(starFull),
                                    half: Image.asset(starHalf),
                                    empty:
                                        Image.asset(starFull, color: greyColor),
                                  ),
                                  onRatingUpdate: (double value) {},
                                ),
                              ),
                              if (reviewRatingModel.value.totalCount != null)
                                Text(
                                    '(${reviewRatingModel.value.totalCount} reviews)',
                                    style: mediumBlack_12),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.w),
                            height: 70.h,
                            width: 0.8.w,
                            color: borderColor,
                          ),
                          if (reviewRatingModel.value.getRating != null)
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('5', style: mediumBlack_12),
                                      // SizedBox(width: 3.w),
                                      // Image.asset(starFull,height: 15),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: reviewRatingModel
                                                  .value.getRating![4].count! /
                                              reviewRatingModel
                                                  .value.totalCount!,
                                          minHeight: 5.h,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('4', style: mediumBlack_12),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: reviewRatingModel
                                                  .value.getRating![3].count! /
                                              reviewRatingModel
                                                  .value.totalCount!,
                                          minHeight: 5.h,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('3', style: mediumBlack_12),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: reviewRatingModel
                                                  .value.getRating![2].count! /
                                              reviewRatingModel
                                                  .value.totalCount!,
                                          minHeight: 5.h,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('2', style: mediumBlack_12),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: reviewRatingModel
                                                  .value.getRating![1].count! /
                                              reviewRatingModel
                                                  .value.totalCount!,
                                          minHeight: 5.h,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('1', style: mediumBlack_12),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: reviewRatingModel
                                                  .value.getRating![0].count! /
                                              reviewRatingModel
                                                  .value.totalCount!,
                                          minHeight: 5.h,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                    if (reviewRatingModel.value.ratingList != null &&
                        reviewRatingModel.value.ratingList!.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviewRatingModel.value.ratingList!.length,
                        itemBuilder: (context, index) {
                          final reviewList =
                              reviewRatingModel.value.ratingList![index];
                          return Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 15.w),
                              margin: EdgeInsets.only(bottom: 10.h),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 35.h,
                                        width: 35.h,
                                        margin: EdgeInsets.only(right: 10.w),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: const BoxDecoration(
                                            color: whiteColor,
                                            shape: BoxShape.circle),
                                        child: CachedNetworkImage(
                                          imageUrl: AppConstants.IMG_URL +
                                              reviewList.userProfile.toString(),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.bottomLeft,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const ImageErrorWidget(),
                                        ),
                                      ),
                                      Expanded(
                                          child: Text(
                                              reviewList.userName.toString(),
                                              style: semiBoldBlack_14,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.h),
                                    child: RatingBar(
                                      glow: true,
                                      allowHalfRating: true,
                                      ignoreGestures: true,
                                      tapOnlyMode: false,
                                      initialRating: double.parse(
                                          reviewList.rating.toString()),
                                      direction: Axis.horizontal,
                                      itemCount: 5,
                                      itemSize: 14.sp,
                                      itemPadding: EdgeInsets.only(right: 5.w),
                                      ratingWidget: RatingWidget(
                                        full: Image.asset(starFull),
                                        half: Image.asset(starHalf),
                                        empty: Image.asset(starFull,
                                            color: greyColor),
                                      ),
                                      onRatingUpdate: (double value) {},
                                    ),
                                  ),
                                  if (reviewList.review != null &&
                                      reviewList.review!.isNotEmpty)
                                    Text(reviewList.review.toString(),
                                        style: mediumBlack_12,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        formatDateString(
                                            'dd-MM-yyyy hh:mm a',
                                            'yyyy-MM-dd HH:mm:ss',
                                            '${reviewList.createdDate}'),
                                        style: regularBlack_10,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ));
                        },
                      )
                    else
                      NoDataFoundWidget(
                        title: 'no_review_found'.tr,
                        description: 'please_add_your_review'.tr,
                      )
                  ],
                ),
              ),
      ),
    );
  }

  getRatingApi() {
    reviewRatingModel.value = ReviewRatingModel();
    Map<String, dynamic> params = {
      'lab_id': widget.labId,
    };
    WebApiHelper()
        .callFormDataPostApi(null, AppConstants.rating, params, true)
        .then((response) {
      if (response != null) {
        ReviewRatingModel statusModel =
            ReviewRatingModel.fromJson(jsonDecode(response));
        if (statusModel.status!) {
          reviewRatingModel.value = statusModel;
        }
      }
    });
  }
}
