import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/OfferModel.dart';
import 'package:zet_health/Screens/OfferScreen/OfferScreenController.dart';
import '../../CommonWidget/CustomAppbar.dart';
import '../../CommonWidget/CustomLoadingIndicator.dart';
import '../../CommonWidget/CustomWidgets.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';
import '../../main.dart';

class OfferScreen extends StatefulWidget {
  const OfferScreen({super.key, this.onSelectOffer, required this.labId});
  final Function(OfferModel)? onSelectOffer;
  final String labId;

  @override
  State<OfferScreen> createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  OfferScreenController offerScreenController =
      Get.put(OfferScreenController());

  @override
  void initState() {
    super.initState();
    offerScreenController.callGetOfferCouponApi(labId: widget.labId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        isLeading: widget.onSelectOffer != null,
        centerTitle: true,
        title: Text('Offers', style: semiBoldBlack_18),
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
      ),
      body: Obx(() => offerScreenController.isLoading.value
          ? Container()
          : offerScreenController.offerList.isEmpty
              ? Center(
                  child: NoDataFoundWidget(
                      title: 'no_offer_found'.tr, description: ''),
                )
              : ListView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  itemCount: offerScreenController.offerList.length,
                  itemBuilder: (context, index) {
                    OfferModel offerModel =
                        offerScreenController.offerList[index];
                    return GestureDetector(
                      onTap: () {
                        if (widget.onSelectOffer != null) {
                          Get.back();
                          widget.onSelectOffer?.call(offerModel);
                        }
                      },
                      child: Container(
                        height: offerModel.labModel != null ? 185.h : 125.h,
                        margin: EdgeInsets.only(bottom: 15.h),
                        width: double.infinity,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 9,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 15.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.r),
                                    bottomLeft: Radius.circular(20.r),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (offerModel.labModel != null)
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              height: 30.h,
                                              width: 30.h,
                                              imageUrl: AppConstants.IMG_URL +
                                                  offerModel
                                                      .labModel!.userProfile
                                                      .toString(),
                                              placeholder: (context, url) =>
                                                  const CustomLoadingIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const ImageErrorWidget(),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    offerModel
                                                        .labModel!.userName
                                                        .toString(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: semiBoldBlack_13),
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 2.h),
                                                  child: Text(
                                                      "${offerModel.labModel!.address}",
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: semiBoldBlack_10),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (offerModel.labModel != null)
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.h),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                                offerModel.itemType ==
                                                        AppConstants.test
                                                    ? test
                                                    : offerModel.itemType ==
                                                            AppConstants.package
                                                        ? package
                                                        : profile),
                                            SizedBox(width: 10.w),
                                            Text(offerModel.itemName.toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: semiBoldBlack_13),
                                          ],
                                        ),
                                      ),
                                    if (offerModel.couponTitle != null)
                                      Text('${offerModel.couponTitle}',
                                          style: semiBoldBlack_14, maxLines: 1),
                                    SizedBox(height: 3.h),
                                    if (offerModel.couponDescription != null)
                                      Text('${offerModel.couponDescription}',
                                          maxLines: 2, style: regularBlack_12),
                                    GestureDetector(
                                      onTap: () async {
                                        await Clipboard.setData(ClipboardData(
                                                text:
                                                    "${offerModel.couponCode}"))
                                            .then((_) {
                                          showToast(message: 'code_copied'.tr);
                                        });
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 5.h),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5.h, horizontal: 5.w),
                                        decoration: BoxDecoration(
                                            color: borderColor,
                                            borderRadius:
                                                BorderRadius.circular(18.r)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 5.w,
                                            ),
                                            Text('Code :',
                                                style: regularBlack_11),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(left: 5.w),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2.h,
                                                  horizontal: 6.w),
                                              decoration: BoxDecoration(
                                                  color: whiteColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.r)),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    '${offerModel.couponCode}',
                                                    style: semiBoldPrimary_10,
                                                  ),
                                                  SizedBox(
                                                    width: 5.w,
                                                  ),
                                                  SvgPicture.asset(copyIcon)
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Center(
                                        child: Text(
                                      '*Valid till ${AppConstants().formatDateWithOrdinal(DateTime.parse(offerModel.expiryDate!))} ',
                                      style: regularGray_8,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Stack(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(color: cardBgColor),
                                      ),
                                      Expanded(
                                        child: Container(color: primaryColor),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        transform: Matrix4.translationValues(
                                            0, -12, 0),
                                        width: 20.w,
                                        height: 20.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                              Border.all(color: borderColor),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        transform:
                                            Matrix4.translationValues(0, 12, 0),
                                        width: 20.w,
                                        height: 20.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                              Border.all(color: borderColor),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: Get.height,
                                color: primaryColor,
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: SvgPicture.asset(percentageIcon),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  })),
    );
  }
}
