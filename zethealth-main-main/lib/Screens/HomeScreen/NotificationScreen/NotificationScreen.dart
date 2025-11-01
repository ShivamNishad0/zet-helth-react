import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/CommonWidget/full_screen_image.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/AssetHelper.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Models/NotificationModel.dart';
import 'package:intl/intl.dart';

import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../Helper/StyleHelper.dart';
import 'NotificationScreenCotroller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationScreenController notificationScreenController =
      Get.put(NotificationScreenController());

  @override
  void initState() {
    super.initState();
    notificationScreenController.callGetNotificationApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(
          centerTitle: true,
          isLeading: true,
          leading: Image.asset(backArrow),
          title: Text('notifications'.tr, style: semiBoldBlack_18),
        ),
        body: Obx(
          () => notificationScreenController.isLoading.value
              ? Container()
              : notificationScreenController.notificationList.isEmpty
                  ? NoDataFoundWidget(
                      title: 'no_notification_found'.tr, description: '')
                  : PaddingHorizontal15(
                      child: ListView.builder(
                        itemCount: notificationScreenController
                            .notificationList.length,
                        itemBuilder: (context, index) {
                          NotificationModel notificationModel =
                              notificationScreenController
                                  .notificationList[index];
                          return Container(
                            margin: EdgeInsets.only(top: 12.h),
                            padding: EdgeInsets.symmetric(
                                vertical: 8.h, horizontal: 14.w),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: borderColor2),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notificationModel.notificationTitle!,
                                        style: mediumBlack_16,
                                      ),
                                      Text(
                                        notificationModel.notificationMessage!,
                                        style: mediumGray_12,
                                      ),
                                      SizedBox(
                                        height: 8.h,
                                      ),
                                      Text(
                                        DateFormat('dd-MM-yyyy hh:mm a').format(
                                            DateTime.parse(notificationModel
                                                .createdDate!)),
                                        style: mediumGray_13,
                                      ),
                                    ],
                                  ),
                                ),
                                if (notificationModel.imagePath != null &&
                                    notificationModel.imagePath!.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(
                                        () => FullImageScreen(
                                            imageUrl: notificationModel
                                                .imagePath
                                                .toString()),
                                        transition: Transition.zoom,
                                        opaque: false,
                                        duration:
                                            const Duration(milliseconds: 300),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10.w),
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: CachedNetworkImage(
                                        imageUrl: AppConstants.IMG_URL +
                                            notificationModel.imagePath
                                                .toString(),
                                        fit: BoxFit.cover,
                                        height: 60.w,
                                        width: 60.w,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const ImageErrorWidget(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        )
        // Center(
        //   child: NoDataFoundWidget(
        //     title: 'no_notification_found'.tr,
        //     description: '',
        //   )
        );
  }
}
