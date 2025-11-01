import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import '../../../../CommonWidget/CustomAppbar.dart';
import '../../../../CommonWidget/CustomContainer.dart';
import '../../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../../CommonWidget/CustomWidgets.dart';
import '../../../../Helper/AssetHelper.dart';
import '../../../../Helper/StyleHelper.dart';
import '../../../../Helper/database_helper.dart';
import '../../../../Models/custom_cart_model.dart';
import '../../ItemDetailScreen/ItemDetailScreen.dart';
import '../SearchTest/SearchTestScreen.dart';
import 'PopularTestScreenController.dart';

class PopularTestScreen extends StatefulWidget {
  const PopularTestScreen({super.key});

  @override
  State<PopularTestScreen> createState() => _PopularTestScreenState();
}

class _PopularTestScreenState extends State<PopularTestScreen> {
  PopularTestScreenController popularTestScreenController =
      Get.put(PopularTestScreenController());
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    popularTestScreenController.callGetLabTestListApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('search_test'.tr, style: semiBoldBlack_18),
        actions: [
          CartButtonCommon(
              callBack: () => popularTestScreenController.testList.refresh())
        ],
      ),
      body: PaddingHorizontal15(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              suffixMode: OverlayVisibilityMode.always,
              minLines: 1,
              placeholder: 'search_test'.tr,
              style: semiBoldBlack_14,
              readOnly: true,
              cursorColor: primaryColor,
              textAlign: TextAlign.start,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              prefixMode: OverlayVisibilityMode.always,
              prefix: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: SvgPicture.asset(searchDotsIcon)),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  border: Border.all(color: borderColor, width: 1.w)),
              onTap: () {
                AppConstants().loadWithCanBack(
                    const SearchTestScreen(isSelectedItem: false));
              },
            ),
            SizedBox(height: 20.h),
            RichText(
                text: TextSpan(children: [
              TextSpan(text: 'Popular', style: boldPrimary_20),
              TextSpan(text: ' Tests', style: boldPrimary2_20)
            ])),
            SizedBox(height: 10.h),
            Obx(
              () => Expanded(
                child: popularTestScreenController.isLoading.value
                    ? const CustomLoadingIndicator()
                    : popularTestScreenController.testList.isEmpty
                        ? NoDataFoundWidget(
                            title: 'no_test_found'.tr, description: '')
                        : GridView.builder(
                            // padding: EdgeInsets.only(bottom: 10.h),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 0.55.h,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 15.w,
                                    mainAxisSpacing: 12.h),
                            itemCount:
                                popularTestScreenController.testList.length,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              CustomCartModel labTestModel =
                                  popularTestScreenController.testList[index];
                              return FutureBuilder<bool>(
                                  future: dbHelper.checkRecordExist(
                                      id: labTestModel.id.toString(),
                                      type: AppConstants.test),
                                  builder: (context, snapshot) {
                                    return CustomContainer(
                                      onTap: () {
                                        Get.to(() => ItemDetailScreen(
                                            customCartModel: labTestModel));
                                      },
                                      color: Colors.white,
                                      radius: 20.r,
                                      boxShadow: [
                                        BoxShadow(
                                          color: borderColor.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 5),
                                        )
                                      ],
                                      child: Stack(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 15.w,
                                                    top: 15.h,
                                                    bottom: 7.h),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 50.h,
                                                      width: 55.w,
                                                      decoration: BoxDecoration(
                                                        color: cardBgColor,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.r)),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.r)),
                                                        child:
                                                            CachedNetworkImage(
                                                          height: 50.h,
                                                          width: 55.w,
                                                          fit: BoxFit.cover,
                                                          imageUrl: AppConstants
                                                                  .IMG_URL +
                                                              labTestModel
                                                                  .image!,
                                                          placeholder: (context,
                                                                  url) =>
                                                              const Center(
                                                                  child:
                                                                      CircularProgressIndicator()),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const ImageErrorWidget(),
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5.sp),
                                                      decoration: BoxDecoration(
                                                          color: cardBgColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10.r),
                                                                  bottomLeft: Radius
                                                                      .circular(10
                                                                          .r)),
                                                          border: Border.all(
                                                              color:
                                                                  borderColor)),
                                                      child: Text(
                                                        '${labTestModel.price} ₹',
                                                        style:
                                                            semiBoldPrimary_12,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 15.w),
                                                child: Text(
                                                  '${labTestModel.name}',
                                                  style: mediumBlack_11,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  CustomContainer(
                                                      top: 5.h,
                                                      color: cardBgColor,
                                                      borderWidth: 1.w,
                                                      left: 13.w,
                                                      radius: 20.r,
                                                      rightPadding: 6.w,
                                                      leftPadding: 6.w,
                                                      topPadding: 2.h,
                                                      bottomPadding: 2.h,
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SvgPicture.asset(
                                                              timeIcon),
                                                          SizedBox(
                                                            width: 3.w,
                                                          ),
                                                          Text(
                                                            '${labTestModel.testTime}',
                                                            style:
                                                                mediumBlack_9,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      )),
                                                  if (labTestModel
                                                              .parametersCount !=
                                                          null &&
                                                      labTestModel
                                                          .parametersCount!
                                                          .isNotEmpty &&
                                                      labTestModel
                                                              .parametersCount !=
                                                          "0")
                                                    Expanded(
                                                      child: CustomContainer(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            parametersDialog(
                                                                cartModel:
                                                                    labTestModel);
                                                          },
                                                          top: 5.h,
                                                          color: cardBgColor,
                                                          borderWidth: 1.w,
                                                          left: 13.w,
                                                          radius: 20.r,
                                                          rightPadding: 6.w,
                                                          leftPadding: 6.w,
                                                          topPadding: 2.h,
                                                          bottomPadding: 2.h,
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .info_outlined,
                                                                  color:
                                                                      primaryColor,
                                                                  size: 14.sp),
                                                              SizedBox(
                                                                  width: 3.w),
                                                              Expanded(
                                                                  child: Text(
                                                                '${labTestModel.parametersCount} ${'parameters'.tr}',
                                                                style:
                                                                    mediumBlack_9,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                            ],
                                                          )),
                                                    ),
                                                ],
                                              ),
                                              CustomContainer(
                                                  top: 5.h,
                                                  color: cardBgColor,
                                                  borderWidth: 1.w,
                                                  left: 13.w,
                                                  right: 15.w,
                                                  radius: 20.r,
                                                  rightPadding: 6.w,
                                                  leftPadding: 6.w,
                                                  topPadding: 2.h,
                                                  bottomPadding: 2.h,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.info_outlined,
                                                          color: primaryColor,
                                                          size: 14.sp),
                                                      SizedBox(width: 3.w),
                                                      Text(
                                                          labTestModel.isFastRequired ==
                                                                  "0"
                                                              ? 'fasting_not_required'
                                                                  .tr
                                                              : 'fasting_required'
                                                                  .tr,
                                                          style: mediumBlack_9,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (snapshot.data != null &&
                                                    snapshot.data!) {
                                                  await dbHelper
                                                      .deleteRecordFormCart(
                                                          id: labTestModel.id
                                                              .toString(),
                                                          type: AppConstants
                                                              .test);
                                                } else {
                                                  CustomCartModel cartModel =
                                                      CustomCartModel(
                                                    id: labTestModel.id,
                                                    name: labTestModel.name,
                                                    type: AppConstants.test,
                                                    price: labTestModel.price
                                                        .toString(),
                                                    image: labTestModel.image
                                                        .toString(),
                                                    isFastRequired: labTestModel
                                                        .isFastRequired
                                                        .toString(),
                                                    testTime: labTestModel
                                                        .testTime
                                                        .toString(),
                                                  );
                                                  await dbHelper
                                                      .insertRecordCart(
                                                          cartModel: cartModel);
                                                }
                                                popularTestScreenController
                                                    .testList
                                                    .refresh();
                                              },
                                              child: Container(
                                                margin: EdgeInsets.all(2.sp),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 6.h),
                                                width: Get.width,
                                                decoration: BoxDecoration(
                                                    color: primaryColor,
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    9.r),
                                                            topRight:
                                                                Radius.circular(
                                                                    9.r),
                                                            bottomLeft:
                                                                Radius
                                                                    .circular(
                                                                        20.r),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    20.r))),
                                                child: Center(
                                                    child: Text(
                                                        snapshot.data != null &&
                                                                snapshot.data!
                                                            ? 'remove_from_cart'
                                                                .tr
                                                            : 'add_to_cart'.tr,
                                                        style: boldWhite_12)),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  });
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
