import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zet_health/Models/CartModel.dart';
import 'package:zet_health/Screens/DrawerView/OrderHistoryScreen/ReviewRatingScreen/add_review_screen.dart';
import '../../../../CommonWidget/CustomAppbar.dart';
import '../../../../CommonWidget/CustomContainer.dart';
import '../../../../CommonWidget/CustomWidgets.dart';
import '../../../../Helper/AppConstants.dart';
import '../../../../Helper/AssetHelper.dart';
import '../../../../Helper/ColorHelper.dart';
import '../../../../Helper/StyleHelper.dart';
import '../../../../Models/BookingModel.dart';
import '../ReviewRatingScreen/review_rating_screen.dart';
import 'OrderHistoryDetailScreenController.dart';


class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key,required this.bookingModel});
  final BookingModel bookingModel;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {

  OrderHistoryDetailScreenController orderHistoryDetailScreenController = Get.put(OrderHistoryDetailScreenController());
  CartModel cartModel = CartModel();

  @override
  void initState() {
    super.initState();
    orderHistoryDetailScreenController.getBookingDetailsApi(bookingId: widget.bookingModel.id.toString());
    cartModel = CartModel.fromJson(json.decode(widget.bookingModel.bookingJson.toString()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        leading: Image.asset(backArrow),
        title: Text('order_history_detail'.tr,style: semiBoldBlack_18),
      ),
      body: Obx(() => orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails==null ?
          const SizedBox() :
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 10.h),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomContainer(
                bottom: 15.h,
                radius: 16.r,
                leftPadding: 8.w, rightPadding: 8.w,
                topPadding: 8.h, bottomPadding: 8.h,
                color: Colors.white,
                boxShadow: [BoxShadow(color: borderColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 5))],
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      child: CachedNetworkImage(
                        imageUrl: AppConstants.IMG_URL + orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.lab!.labProfile.toString(),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const ImageErrorWidget(),
                        width: 65.w,
                        height: 60.h,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.lab!.labName.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: semiBoldBlack_13,
                          ),
                          SizedBox(height: 2.h),
                          if(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.lab!.address != null)
                          Text(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.lab!.address.toString(), style: regularBlack_11),
                          SizedBox(height: 5.h),
                          Row(
                            children: [
                              if(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.lab!=null)
                                CustomContainer(
                                  onTap: (){
                                    Get.to(()=> ReviewRatingScreen(labId: orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.lab!.labId.toString()));
                                  },
                                  radius: 18.r,
                                  right: 5.w,
                                  left: 5.w,
                                  leftPadding: 6.w,
                                  rightPadding: 6.w,
                                  topPadding: 2.h,
                                  bottomPadding: 2.h,
                                  color: cardBgColor,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Center(child: FaIcon(FontAwesomeIcons.solidStar, size: 11.sp, color: primaryColor)),
                                      SizedBox(width: 1.w),
                                      Center(child: Text('${orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.lab!.rating}', style: semiBoldBlack_10)),
                                      SizedBox(width: 5.w),
                                      Center(child: Text('${orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.lab!.reviews} User', style: semiBoldBlack_10)),
                                    ],
                                  ),
                                ),
                              Expanded(child: GestureDetector(
                                onTap: () {
                                  Get.to(()=> AddReviewScreen(bookingDetails: orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!));
                                },
                                child: Text('add_review'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                    fontFamily: semiBold,
                                    color: primaryColor,
                                    fontSize: 10.sp,
                                    decoration: TextDecoration.underline,
                                    decorationColor: primaryColor)
                                ),
                              ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!=null &&
                  widget.bookingModel.isOriginal == 1 &&
                  orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.devliveryBoyMobile!=null &&
                  orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.devliveryBoyMobile!.isNotEmpty
              )
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: AppConstants.IMG_URL + orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.devliveryBoyProfile.toString(),
                      height: 40.h,width: 40.h,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>  const ImageErrorWidget(),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.devliveryBoyName.toString(),
                          style: semiBoldBlack_14,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        Text(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.devliveryBoyMobile.toString(),
                          style: semiBoldBlack_14,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  DoubleBorderContainer(
                    leftMargin: 10.w,
                    color: cardBgColor,
                    svgImage: chatting,
                    onTap: () async {
                      final Uri launchUri = Uri.parse('https://wa.me/${orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.devliveryBoyMobile}');
                      launchUrlInOtherApp(url: launchUri);
                    },
                  ),
                  DoubleBorderContainer(
                    leftMargin: 10.w,
                    color: cardBgColor,
                    svgImage: callingIcon,
                    onTap: () async {
                      final Uri launchUri = Uri(scheme: 'tel', path: '${orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.devliveryBoyMobile}');
                      launchUrlInOtherApp(url: launchUri);
                    },
                  )
                ],
              ),

              CustomContainer(
                borderColor: borderColor,
                borderWidth: 1.w,
                color: whiteColor,
                radius: 15.r,
                leftPadding: 10.w,
                rightPadding: 10.w,
                topPadding: 10.h,
                bottomPadding: 10.h,
                top: 15.h,
                bottom: 15.h,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartModel.itemList!.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartModel.itemList![index];
                    return CustomContainer(
                      color: cardBgColor,
                      radius: 15.r,
                      top: index == 0 ? 0 : 5.h,
                      topPadding: 8.h,
                      leftPadding: 10.w,
                      rightPadding: 10.w,
                      bottomPadding: 8.h,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(cartItem.type == AppConstants.test ? test:
                          cartItem.type == AppConstants.package ? package : profile),
                          SizedBox(width: 5.w),
                          Expanded(child: Text(cartItem.name ?? '', maxLines: 2, style: mediumBlack_12, overflow: TextOverflow.ellipsis)),

                          SizedBox(width: 5.w),
                          CustomContainer(
                            color: whiteColor,
                            borderColor: borderColor,
                            borderWidth: 2.w,
                            radius: 10.r,
                            onTap: () {
                              if(cartItem.type == AppConstants.test) {
                                testDialog(cartModel: cartItem);
                              }
                              else if(cartItem.type == AppConstants.package || cartItem.type == AppConstants.profile) {
                                packageProfileDialog(cartModel: cartItem);
                              }
                            },
                            topPadding: 2.h,
                            bottomPadding: 2.h,
                            leftPadding: 2.w,
                            rightPadding: 2.w,
                            child: const Icon(Icons.remove_red_eye_rounded, color: primaryColor, size: 18),
                          ),
                          SizedBox(width: 5.w),
                          Text('₹ ${cartItem.price ?? ''}', style: boldBlack_14),
                        ],
                      ),
                    );
                  },
                ),
              ),


              if(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!=null &&
                  orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.devliveryBoyMobile!=null &&
                  orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.devliveryBoyMobile!.isNotEmpty)
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: 'My', style: boldPrimary2_20),
                    TextSpan(text: ' Report', style: boldPrimary_20)
                  ]
                )
              ),

              if(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.reports!=null &&
                  orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.reports!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                itemCount: orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.reports!.length,
                itemBuilder: (context, index) {
                  final reports = orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.reports![index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: grayAlpha)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
                          margin: EdgeInsets.only(right: 10.w),
                          decoration: BoxDecoration(
                              color: lightOrange,
                              borderRadius: BorderRadius.all(Radius.circular(15.r)),
                          ),
                          child: SvgPicture.asset(pdf)
                        ),
                        Expanded(child: Text(reports.path.toString(),style: mediumBlack_15)),
                        GestureDetector(
                          onTap: (){
                            AppConstants().downloadAndOpenFile(link: "${reports.folderName}/${reports.path}", type: 0);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 5.w),
                            decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                border: Border.all(color: borderColor, width: 1)
                            ),
                            child: SvgPicture.asset(downloadPDF)
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),

              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: 'Booking', style: boldPrimary_20),
                    TextSpan(text: ' For', style: boldPrimary2_20)
                  ]
                )
              ),

              Container(
                margin: EdgeInsets.only(top: 10.h,bottom: 15.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16.r)),
                  boxShadow: [BoxShadow(color: borderColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('patient_name'.tr,style: semiBoldBlack_14),
                    Container(
                      width: Get.width,
                      margin: EdgeInsets.only(top: 5.h,bottom: 10.h),
                      padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Text(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.patientName.toString(),
                          style: mediumBlack_13),
                    ),
                    Text('patient_address'.tr,style: semiBoldBlack_14),
                    Container(
                      width: Get.width,
                      margin: EdgeInsets.only(top: 5.h),
                      padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Text(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.pickupAddress.toString(),
                          style: mediumBlack_13),
                    ),
                  ],
                ),
              ),

              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: 'Cart', style: boldPrimary_20),
                    TextSpan(text: ' Item', style: boldPrimary2_20)
                  ]
                )
              ),
              Container(
                margin: EdgeInsets.only(top: 10.h),
                padding: EdgeInsets.symmetric(vertical: 10.h,horizontal: 15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: const [
                    BoxShadow(
                      color: grayAlpha,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.serviceCharge!=null ||
                        orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.serviceCharge!="null")
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: 'total_amount'.tr,
                                      style: semiBoldBlack_12
                                  ),
                                  // TextSpan(
                                  //   text: ' 70000 ₹',
                                  //   style: boldBlack_12.copyWith(
                                  //       decoration: TextDecoration.lineThrough,
                                  //       decorationThickness: 2.0
                                  //   ),
                                  // )
                                ]
                            ),
                          ),
                        ),
                        Text('₹ ${double.parse(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.totalPayableAmount.toString()) - double.parse(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.serviceCharge.toString())}',
                            style: semiBoldBlack_14)
                      ],
                    ),
                    if(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.serviceCharge!=null ||
                        orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.serviceCharge!="null")
                    Row(
                      children: [
                        Expanded(child: Text('collection_charges'.tr, style: semiBoldBlack_12)),
                        Text('₹ ${orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.serviceCharge}', style: semiBoldBlack_14)
                      ],
                    ),
                    if(orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.couponPrice!='0')
                      Row(
                        children: [
                          Expanded(child: Text('coupon_discount'.tr, style: semiBoldBlack_12)),
                          Text('₹ ${orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.couponPrice}', style: semiBoldBlack_14)
                        ],
                      ),
                    Divider(color: borderColor, thickness: 0.8.w),
                    Row(
                      children: [
                        Expanded(child: Text('total_payable_amount'.tr, style: semiBoldBlack_12)),
                        Text('₹ ${orderHistoryDetailScreenController.orderDetailModel.value.bookingDetails!.totalPayableAmount}', style: semiBoldBlack_14)
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
