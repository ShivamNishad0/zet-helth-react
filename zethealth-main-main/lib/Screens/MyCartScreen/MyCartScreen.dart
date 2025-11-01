import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/custom_cart_model.dart';
import 'package:zet_health/Screens/DrawerView/AddressScreen/AddressScreen.dart';
import 'package:zet_health/Screens/AuthScreen/LoginScreen.dart';
import 'package:zet_health/Screens/MyCartScreen/MyCartScreenController.dart';
import 'package:zet_health/Screens/MyCartScreen/UserSelectionScreen/user_selection_screen.dart';
import 'package:zet_health/Screens/OfferScreen/OfferScreen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../CommonWidget/CustomAppbar.dart';
import '../../CommonWidget/CustomButton.dart';
import '../../CommonWidget/CustomContainer.dart';
import '../../CommonWidget/CustomLoadingIndicator.dart';
import '../../CommonWidget/CustomTextField2.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../Models/AddressListModel.dart';
import '../../Models/CartModel.dart';
import '../DrawerView/AddressScreen/AddAdressScreen/get_address_map_screen.dart';
import '../DrawerView/FamilyMemberScreen/FamilyMemberScreen.dart';
import '../DrawerView/FamilyMemberScreen/FamilyMemberScreenController.dart';
import '../DrawerView/OrderHistoryScreen/ReviewRatingScreen/review_rating_screen.dart';
import '../HomeScreen/TestScreen/SearchTest/SearchTestScreen.dart';

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({super.key});

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  MyCartScreenController myCartScreenController =
      Get.put(MyCartScreenController());
  FamilyMemberScreenController familyMemberScreenController = Get.put(FamilyMemberScreenController());
  bool isLoggedIn = AppConstants().getStorage.read(AppConstants.USER_MOBILE) != null &&
      AppConstants().getStorage.read(AppConstants.USER_MOBILE) != "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(!isLoggedIn) {
        myCartScreenController.loadLocalCart();
      }
      else {
        myCartScreenController.razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
            myCartScreenController.handlePaymentSuccess);
        myCartScreenController.razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
            myCartScreenController.handlePaymentError);
        myCartScreenController.razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
            myCartScreenController.handleExternalWallet);
        myCartScreenController.callGetCartApi();
        myCartScreenController.selectedAddress = AppConstants().getSelectedAddress();
        await familyMemberScreenController.getPatientListApi(onUpdated: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {});
          });
        });
      }
    });
  }

void _updateSearchResultItemSelection(int itemId, String itemType, bool isSelected) {
  final searchController = myCartScreenController.searchResultController;
  
  for (var item in searchController.testList) {
    if (item.id == itemId && item.type == itemType) {
      item.isSelected = isSelected;
      break;
    }
  }
  
  // Update in packageList
  for (var item in searchController.packageList) {
    if (item.id == itemId && item.type == itemType) {
      item.isSelected = isSelected;
      break;
    }
  }
  
  for (var item in searchController.profileList) {
    if (item.id == itemId && item.type == itemType) {
      item.isSelected = isSelected;
      break;
    }
  }
  
  searchController.testList.refresh();
  searchController.packageList.refresh();
  searchController.profileList.refresh();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('my_cart'.tr, style: semiBoldBlack_18),
        actions: [
          Obx(() => myCartScreenController.showClearCart.value
            ? GestureDetector(
              onTap: () {
                Get.dialog(CommonDialog(
                  title: 'Warning',
                  description: 'Are you sure you want to clear your Cart?',
                  tapNoText: 'cancel'.tr,
                  tapYesText: 'confirm'.tr,
                  onTapNo: () => Get.back(),
                  onTapYes: () {
                    Get.back();
                    myCartScreenController.callClearCartApi();
                    myCartScreenController.dbHelper.clearAllRecord();
                  },
                ));
              },
              child: Container(
                  margin: EdgeInsets.only(right: 15.w),
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.all(Radius.circular(9.r))),
                  child: Text(
                    'clear_cart'.tr,
                    style: regularPrimary_12,
                  )
              ),
            )
            : SizedBox()
          ),
        ],
      ),
      body: Obx(
        () => myCartScreenController.cartModel.value.itemList == null
            ? const CustomLoadingIndicator()
            : myCartScreenController.cartModel.value.itemList!.isEmpty
                ? const NoDataFoundWidget(
                    title: 'Empty Cart!',
                    description: 'Your cart is empty! Please Add items')
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(text: 'Cart', style: boldPrimary_20),
                                TextSpan(text: ' Items', style: boldPrimary2_20)
                              ])),
                            ),
                            // GestureDetector(
                            //   onTap: () {
                            //     AppConstants().loadWithCanBack(SearchTestScreen(
                            //       isSelectedItem: true,
                            //       cartItem:
                            //           myCartScreenController.cartModel.value,
                            //       callBack: (newListLabTest) {
                            //         myCartScreenController.clearCoupon();
                            //         if (newListLabTest.isEmpty) {
                            //           myCartScreenController.callClearCartApi();
                            //         } else {
                            //           myCartScreenController.cartModel.value
                            //               .itemList = newListLabTest;
                            //           myCartScreenController.callAddToCartApi();
                            //         }
                            //       },
                            //     ));
                            //   },
                            //   child: Align(
                            //     alignment: Alignment.centerRight,
                            //     child: Container(
                            //         margin: EdgeInsets.only(bottom: 10.h),
                            //         decoration: BoxDecoration(
                            //             color: white,
                            //             borderRadius: BorderRadius.all(
                            //                 Radius.circular(20.r)),
                            //             border:
                            //                 Border.all(color: primaryColor)),
                            //         padding: EdgeInsets.symmetric(
                            //             horizontal: 9.w, vertical: 4.h),
                            //         child: Text(
                            //           'add_more_test'.tr,
                            //           style: semiBoldPrimary_12,
                            //         )),
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.r)),
                              boxShadow: [
                                BoxShadow(
                                    color: borderColor.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 5))
                              ]),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(bottom: 10.h),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: myCartScreenController
                                    .cartModel.value.itemList!.length,
                                itemBuilder: (context, index) {
                                  final cartItem = myCartScreenController
                                      .cartModel.value.itemList![index];
                                  return Padding(
                                    padding: EdgeInsets.only(top: 5.h),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              CustomContainer(
                                                color: cardBgColor,
                                                right: 20.w,
                                                radius: 15.r,
                                                topPadding: 8.h,
                                                leftPadding: 10.w,
                                                bottomPadding: 8.h,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SvgPicture.asset(cartItem
                                                                .type ==
                                                            AppConstants.test
                                                        ? test
                                                        : cartItem.type ==
                                                                AppConstants
                                                                    .package
                                                            ? package
                                                            : profile),
                                                    SizedBox(width: 5.w),
                                                    Expanded(
                                                        child: Text(
                                                            cartItem.name ?? '',
                                                            maxLines: 2,
                                                            style:
                                                                mediumBlack_12,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis)),
                                                    SizedBox(width: 5.w),
                                                    CustomContainer(
                                                      color: whiteColor,
                                                      borderColor: borderColor,
                                                      borderWidth: 2.w,
                                                      radius: 10.r,
                                                     onTap: () async {
                                                        if (cartItem.type == AppConstants.test) {
                                                          testDialog(cartModel: cartItem);
                                                        } else if (cartItem.type == AppConstants.package || cartItem.type == AppConstants.profile) {
                                                          // 🔥 FIX: Get the complete package data from local storage
                                                          final localCartItems = await myCartScreenController.dbHelper.getCartList();
                                                          CustomCartModel? localPackage = localCartItems.firstWhere(
                                                            (item) => item.id == cartItem.id && item.type == cartItem.type,
                                                            orElse: () => cartItem, // Fallback to server data if not found
                                                          );
                                                          
                                                          packageProfileDialog(cartModel: localPackage);
                                                        }
                                                      },
                                                      topPadding: 2.h,
                                                      bottomPadding: 2.h,
                                                      leftPadding: 2.w,
                                                      rightPadding: 2.w,
                                                      child: const Icon(
                                                          Icons
                                                              .remove_red_eye_rounded,
                                                          color: primaryColor,
                                                          size: 18),
                                                    ),
                                                    SizedBox(width: 55.w),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                top: 2.h,
                                                right: 0,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4.h,
                                                      horizontal: 12.w),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  11.r)),
                                                      color: cardBgColor,
                                                      border: Border.all(
                                                          color: borderColor,
                                                          width: 1.w),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: borderColor
                                                                .withOpacity(
                                                                    0.5),
                                                            blurRadius: 10,
                                                            spreadRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 4))
                                                      ]),
                                                  child: Text(
                                                      '${cartItem.price ?? ''} ₹',
                                                      style: boldBlack_14),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        CustomContainer(
                                          borderColor: redColor,
                                          borderWidth: 2.w,
                                          radius: 8.r,
                                          onTap: () {
                                            Get.dialog(CommonDialog(
                                              title: 'Delete Test',
                                              description:
                                                  'Are you sure you want to delete test ?',
                                              tapNoText: 'cancel'.tr,
                                              tapYesText: 'Yes'.tr,
                                              onTapNo: () => Get.back(),
                                              onTapYes: () async {
                                                if (myCartScreenController
                                                        .cartModel
                                                        .value
                                                        .itemList!
                                                        .length >
                                                    1) {
                                                  myCartScreenController.cartModel.value.itemList!.remove(cartItem);
                                                  _updateSearchResultItemSelection(cartItem.id!, cartItem.type!, false);
                                                  // await myCartScreenController.dbHelper.deleteRecordFormCart(id: cartItem.id.toString(), type: cartItem.type.toString());
                                                  myCartScreenController.searchResultController.cartList.removeWhere((item) => item.id == cartItem.id && item.type == cartItem.type);
                                                  myCartScreenController.searchResultController.cartIds.removeWhere((item) => item == cartItem.id);
                                                  myCartScreenController.searchResultController.cartCount.value = myCartScreenController.searchResultController.cartList.length;
                                                  myCartScreenController.callAddToCartApi();
                                                } else {
                                                  myCartScreenController.callClearCartApi();
                                                }
                                                await myCartScreenController.dbHelper.deleteRecordFormCart(id: cartItem.id.toString(), type: cartItem.type.toString());
                                                myCartScreenController.clearCoupon();
                                                Get.back();
                                              },
                                            ));
                                          },
                                          topPadding: 2.h,
                                          bottomPadding: 2.h,
                                          leftPadding: 2.h,
                                          rightPadding: 2.h,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                                color: redColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            child: SvgPicture.asset(deleteIcon),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 57.w),
                                    width: Get.width,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 5.h),
                                    decoration: BoxDecoration(
                                        color: borderColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(14.r))),
                                    child: Text(
                                      'total_amount'.tr,
                                      style: mediumBlack_14,
                                    ),
                                  ),
                                  Positioned(
                                    right: 37.w,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.h, horizontal: 12.w),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(11.r)),
                                          color: primaryColor,
                                          border: Border.all(
                                              color: whiteColor, width: 1.w),
                                          boxShadow: [
                                            BoxShadow(
                                                color: borderColor
                                                    .withOpacity(0.5),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                                offset: const Offset(0, 4))
                                          ]),
                                      child: Text(
                                        '${myCartScreenController.cartList[0].subTotal} ₹',
                                        style: boldWhite_14,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        if (false)
                          // ignore: dead_code
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                  text: TextSpan(children: [
                                TextSpan(text: 'Upload', style: boldPrimary_20),
                                TextSpan(
                                    text: ' Prescription',
                                    style: boldPrimary2_20),
                                TextSpan(
                                    text: ' (optional)', style: regularBlack_14)
                              ])),
                              CustomContainer(
                                top: 10.h,
                                bottom: 15.h,
                                radius: 16.r,
                                color: Colors.white,
                                onTap: () {
                                  Get.dialog(UploadImageDialog(
                                    title: 'upload_prescription'.tr,
                                    description:
                                        'msg_please_upload_prescription'.tr,
                                    onTap1: () {
                                      getImagesFromCamera(
                                          source: ImageSource.camera);
                                    },
                                    onTap2: () {
                                      getImagesFromCamera(
                                          source: ImageSource.gallery);
                                    },
                                  ));
                                },
                                boxShadow: [
                                  BoxShadow(
                                    color: borderColor.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 9.h,
                                    horizontal: 8.w,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          DottedBorder(
                                            borderType: BorderType.RRect,
                                            radius: Radius.circular(15.r),
                                            strokeWidth: 1.w,
                                            color: primaryColor,
                                            dashPattern: const [3],
                                            child: CustomContainer(
                                              topPadding: 18.h,
                                              bottomPadding: 18.h,
                                              leftPadding: 15.w,
                                              rightPadding: 15.w,
                                              color: cardBgColor,
                                              radius: 15.r,
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.file_upload_outlined,
                                                    color: primaryColor,
                                                  ),
                                                  SizedBox(
                                                    width: 5.w,
                                                  ),
                                                  Text('brows_file'.tr,
                                                      style: mediumBlack_12),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10.w,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(children: [
                                                    TextSpan(
                                                        text: 'Upload Only',
                                                        style: mediumBlack_12),
                                                    TextSpan(
                                                        text: '\njpg, png',
                                                        style: boldBlack_12),
                                                    TextSpan(
                                                        text: ' or ',
                                                        style: mediumBlack_12),
                                                    TextSpan(
                                                        text: 'pdf',
                                                        style: boldBlack_12),
                                                    TextSpan(
                                                        text:
                                                            ' file\nSize limit is ',
                                                        style: mediumBlack_12),
                                                    TextSpan(
                                                        text: '20MB',
                                                        style: boldBlack_12),
                                                  ]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        noLoginOrPatient(),
                        SizedBox(height: 30.h),
                        Obx(
                          () => myCartScreenController.isCouponApplied.value
                              ? Container(
                                  margin: EdgeInsets.only(bottom: 15.h),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(24.r)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: borderColor.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 5,
                                            offset: const Offset(10, 0))
                                      ]),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        verifiedIcon,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${myCartScreenController.couponDiscountAmount.value} ₹',
                                              style: boldPrimary_14,
                                            ),
                                            Text(
                                              'discount_applied'.tr,
                                              style: mediumGray_12,
                                            ),
                                          ],
                                        ),
                                      ),
                                      CustomContainer(
                                        onTap: () {
                                          myCartScreenController.clearCoupon();
                                        },
                                        topPadding: 6.h,
                                        bottomPadding: 6.h,
                                        rightPadding: 15.w,
                                        leftPadding: 15.w,
                                        borderColor: redColor,
                                        borderWidth: 1.w,
                                        radius: 20.r,
                                        child: Text(
                                          'remove'.tr,
                                          style: semiBoldRed_12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : !isLoggedIn ? SizedBox.shrink() :  Container(
                                  margin: EdgeInsets.only(bottom: 15.h),
                                  padding: EdgeInsets.only(
                                      left: 15.w, top: 12.h, bottom: 12.h),
                                  decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(24.r)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: borderColor.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 5,
                                            offset: const Offset(10, 0))
                                      ]),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Apply Coupon'.tr,
                                                    style: semiBoldBlack_14),
                                                Text(
                                                    'Get discounts on order booking'
                                                        .tr,
                                                    style: regularBlack_11),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(() => OfferScreen(
                                                  labId: myCartScreenController
                                                      .cartList[0].labId
                                                      .toString(),
                                                  onSelectOffer: (offer) {
                                                    myCartScreenController
                                                            .couponCodeController
                                                            .text =
                                                        offer.couponCode
                                                            .toString();
                                                    myCartScreenController
                                                        .applyCouponApi();
                                                  }));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.w,
                                                  vertical: 5.h),
                                              decoration: BoxDecoration(
                                                  color: primaryColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15.r),
                                                          topLeft:
                                                              Radius.circular(
                                                                  5.r))),
                                              child: Text('Find Discount',
                                                  style: semiBoldWhite_12),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 5.h),
                                      Padding(
                                        padding: EdgeInsets.only(right: 15.w),
                                        child: CustomTextField2(
                                          controller: myCartScreenController
                                              .couponCodeController,
                                          hintText: 'Enter your code here'.tr,
                                          topMargin: 5.h,
                                          filled: true,
                                          textInputAction: TextInputAction.next,
                                          suffixIconMaxWidth: 90.w,
                                          suffixIconMinWidth: 70.w,
                                          suffixIcon: GestureDetector(
                                            onTap: () {
                                              if (myCartScreenController
                                                  .couponCodeController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                myCartScreenController
                                                    .applyCouponApi();
                                              }
                                            },
                                            child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5.h),
                                                margin: EdgeInsets.only(
                                                    right: 10.w),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: whiteColor,
                                                    border: Border.all(
                                                        color: primaryColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.r)),
                                                child: Text('Apply Now'.tr,
                                                    style: TextStyle(
                                                        fontFamily: semiBold,
                                                        fontSize: 11.sp,
                                                        color: primaryColor))),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 15.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 12.h),
                          decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24.r)),
                              boxShadow: [
                                BoxShadow(
                                    color: borderColor.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 5,
                                    offset: const Offset(10, 0))
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: 'total_amount'.tr,
                                            style: semiBoldBlack_12),
                                        // TextSpan(
                                        //   text: ' 70000 ₹',
                                        //   style: boldBlack_12.copyWith(
                                        //       decoration: TextDecoration.lineThrough,
                                        //       decorationThickness: 2.0
                                        //   ),
                                        // )
                                      ]),
                                    ),
                                  ),
                                  Text(
                                    '₹ ${myCartScreenController.cartList[0].subTotal}',
                                    style: semiBoldBlack_14,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: 'collection_charges'.tr,
                                            style: semiBoldBlack_12),
                                        if (myCartScreenController
                                            .serviceChargeDisplay.isNotEmpty)
                                          TextSpan(
                                            text:
                                                ' (₹ ${myCartScreenController.serviceChargeDisplay})',
                                            style: mediumBlack_12.copyWith(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationThickness: 1.sp),
                                          )
                                      ]),
                                    ),
                                  ),
                                  Text(
                                    '₹ ${myCartScreenController.serviceCharge}',
                                    style: semiBoldBlack_14,
                                  )
                                ],
                              ),
                              if (myCartScreenController.isCouponApplied.value)
                                Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(children: [
                                          TextSpan(
                                              text: 'coupon_discount'.tr,
                                              style: semiBoldBlack_12),
                                          // TextSpan(
                                          //     text: ' 70 ₹',
                                          //     style: boldBlack_12.copyWith(
                                          //         decoration: TextDecoration.lineThrough,
                                          //       decorationThickness: 2.0
                                          //     ),
                                          // )
                                        ]),
                                      ),
                                    ),
                                    Text(
                                      '₹ ${myCartScreenController.couponDiscountAmount.value}',
                                      style: semiBoldBlack_14,
                                    )
                                  ],
                                ),
                              Divider(
                                color: borderColor,
                                thickness: 1.w,
                              ),
                              Row(
                                children: [
                                  Text('payable_amount'.tr,
                                      style: semiBoldBlack_14),
                                  const Spacer(),
                                  Text(
                                    '₹ ${myCartScreenController.payableAmount.value}',
                                    style: semiBoldBlack_14,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: Obx(
        () => myCartScreenController.cartList.isEmpty
            ? const SizedBox()
            : CustomButton(
                height: 40.h,
                borderRadius: 100,
                bottomMargin: MediaQuery.of(context).viewPadding.bottom > 15 ? 50.h : 20.h,
                horizontalMargin: 15.w,
                text: isLoggedIn ? 'checkout_now'.tr : 'Login Now'.tr,
                onTap: () {
                  if (!isLoggedIn) {
                    AppConstants().loadWithCanBack(
                      LoginScreen(onLoginSuccess: () {
                        myCartScreenController.cartList.clear();
                        myCartScreenController.cartModel.value = CartModel();
                        myCartScreenController.searchResultController.callTestWiseLabApi(); // from searchResultController
                        myCartScreenController.callGetCartApi();
                        setState(() {});
                      }),
                    );
                  } else {
                    if (myCartScreenController.isValidate()) {
                      // Get.dialog(CommonDialog(
                      //   title: 'Book Tests',
                      //   description: 'Are you sure you want to book ?',
                      //   tapNoText: 'cancel'.tr,
                      //   tapYesText: 'confirm'.tr,
                      //   onTapNo: () => Get.back(),
                      //   onTapYes: () {
                      //     myCartScreenController.callBookNowApi();
                      myCartScreenController.startPaymentThenBook();
                      //     Get.back();
                      //   },
                      // ));
                    }
                  }
                },
              ),
      ),
    );
  }

  Widget noLoginOrPatient() {
    if(!isLoggedIn) {
      return NoLoginWidget(
        onLoginSuccess: () {
          myCartScreenController.cartList.clear();
          myCartScreenController.cartModel.value = CartModel();
          myCartScreenController.searchResultController.callTestWiseLabApi(); // from searchResultController
          myCartScreenController.callGetCartApi();
          setState(() {});
        },
      );
    }
    else {
      return Container(
        width: Get.width,
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius:
            BorderRadius.all(Radius.circular(16.r)),
            boxShadow: [
              BoxShadow(
                  color: borderColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 5))
            ]),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'booking_at'.tr,
              style: semiBoldBlack_14,
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        myCartScreenController
                            .selectedBookingType = 0;
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                            color: myCartScreenController
                                .selectedBookingType ==
                                0
                                ? borderColor
                                : cardBgColor,
                            borderRadius: BorderRadius.all(
                                Radius.circular(16.r))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                padding:
                                const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.all(
                                        Radius.circular(
                                            38.r)),
                                    border: Border.all(
                                        color: borderColor,
                                        width: 1.w)),
                                child: Container(
                                  width: 18.w,
                                  height: 16.h,
                                  decoration: BoxDecoration(
                                      color: myCartScreenController
                                          .selectedBookingType ==
                                          0
                                          ? primaryColor
                                          : cardBgColor,
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(
                                              38.r))),
                                )),
                            SizedBox(width: 8.w),
                            Text('book_now'.tr,
                                style: mediumBlack_14),
                          ],
                        )),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        myCartScreenController
                            .selectedBookingType = 1;
                      });
                    },
                    child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                            color: myCartScreenController
                                .selectedBookingType ==
                                1
                                ? borderColor
                                : cardBgColor,
                            borderRadius: BorderRadius.all(
                                Radius.circular(16.r))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                padding:
                                const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.all(
                                        Radius.circular(
                                            38.r)),
                                    border: Border.all(
                                        color: borderColor,
                                        width: 1.w)),
                                child: Container(
                                  width: 18.w,
                                  height: 16.h,
                                  decoration: BoxDecoration(
                                      color: myCartScreenController
                                          .selectedBookingType ==
                                          1
                                          ? primaryColor
                                          : cardBgColor,
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(
                                              38.r))),
                                )),
                            SizedBox(width: 8.w),
                            Text('choose_slot'.tr,
                                style: mediumBlack_14),
                          ],
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            if (myCartScreenController.selectedBookingType ==
                1)
              Row(
                children: [
                  Expanded(
                    child: CustomTextField2(
                      title: 'date'.tr,
                      topMargin: 5.h,
                      filled: true,
                      hintText: myCartScreenController
                          .selectedDate.value.isEmpty
                          ? 'select_date'.tr
                          : myCartScreenController
                          .selectedDate.value,
                      readOnly: true,
                      bottomMargin: 15.h,
                      textInputAction: TextInputAction.next,
                      onTap: () async {
                        String? newDate = await AppConstants()
                            .openCalender(
                            context,
                            DateTime.now(),
                            DateTime.now().add(
                                const Duration(days: 7)),
                            false);
                        if (newDate != null) {
                          myCartScreenController
                              .selectedDate.value = newDate;
                        }
                      },
                      suffixIcon: FaIcon(
                          FontAwesomeIcons.calendarDay,
                          size: 18.sp),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CustomTextField2(
                      title: 'time'.tr,
                      topMargin: 5.h,
                      filled: true,
                      hintText: myCartScreenController
                          .selectedTime.value.isEmpty
                          ? 'select_time'.tr
                          : myCartScreenController
                          .selectedTime.value,
                      readOnly: true,
                      bottomMargin: 15.h,
                      textInputAction: TextInputAction.next,
                      onTap: () async {
                        if (myCartScreenController
                            .selectedDate.isNotEmpty) {
                          TimeOfDay? pickedTime =
                          await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            final now = DateTime.now();
                            final selectedDateTime = DateTime(
                                now.year,
                                now.month,
                                now.day,
                                pickedTime.hour,
                                pickedTime.minute);
                            if (myCartScreenController
                                .selectedDate.value ==
                                ddMMYYYYDateFormat(
                                    now.toString())) {
                              if (selectedDateTime.isBefore(
                                  now.add(const Duration(
                                      hours: 1)))) {
                                showToast(
                                    message:
                                    "Please select a time minimum after 1 Hour");
                                myCartScreenController
                                    .selectedTime.value = '';
                              } else {
                                myCartScreenController
                                    .selectedTime.value =
                                    DateFormat('hh:mm a')
                                        .format(
                                        selectedDateTime);
                              }
                            } else {
                              myCartScreenController
                                  .selectedTime.value =
                                  DateFormat('hh:mm a')
                                      .format(
                                      selectedDateTime);
                            }
                          }
                        } else {
                          showToast(
                              message: "please_select_date");
                        }
                      },
                      suffixIcon: FaIcon(
                          FontAwesomeIcons.solidClock,
                          size: 18.sp),
                    ),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('patient'.tr, style: semiBoldBlack_14),
                SizedBox(width: 5.w),
                GestureDetector(
                  onTap: () async {
                    if (myCartScreenController
                        .userModel.value.userType ==
                        "Admin") {
                      Get.to(() => UserSelectionScreen(
                          selectedPatient: (selectedPatient) {
                            setState(() {
                              myCartScreenController
                                  .selectedUser = selectedPatient;
                              if (selectedPatient.familyMember !=
                                  null) {
                                myCartScreenController
                                    .selectedPatient =
                                selectedPatient
                                    .familyMember![0];
                              }
                            });
                          }));
                    } else {
                      Get.to(() => FamilyMemberScreen(
                          selectedPatient: (selectedPatient) {
                            setState(() {
                              myCartScreenController
                                  .selectedPatient =
                                  selectedPatient;
                              myCartScreenController.saveSelectedPatient(selectedPatient);
                            });
                          }));
                    }
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 6.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(20.r)
                      ),
                      child: Text(myCartScreenController.selectedPatient == null ? 'add_patient'.tr : 'change_patient'.tr,style: TextStyle(fontFamily: semiBold,fontSize: 11.sp,color: primaryColor))
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                if (myCartScreenController
                    .userModel.value.userType ==
                    "Admin") {
                  Get.to(() => UserSelectionScreen(
                      selectedPatient: (selectedPatient) {
                        setState(() {
                          myCartScreenController
                              .selectedUser = selectedPatient;
                          if (selectedPatient.familyMember !=
                              null) {
                            myCartScreenController
                                .selectedPatient =
                            selectedPatient
                                .familyMember![0];
                          }
                        });
                      }));
                } else {
                  Get.to(() => FamilyMemberScreen(
                      selectedPatient: (selectedPatient) {
                        setState(() {
                          myCartScreenController
                              .selectedPatient =
                              selectedPatient;
                          myCartScreenController.saveSelectedPatient(selectedPatient);
                        });
                      }));
                }
              },
              child: Container(
                height: 40.h,
                width: Get.width,
                alignment: Alignment.centerLeft,
                margin:
                EdgeInsets.only(top: 5.h, bottom: 10.h),
                padding:
                EdgeInsets.symmetric(horizontal: 15.w),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.all(
                      Radius.circular(15.r)
                  ),
                  border: Border.all(color: borderColor2, width: 1.5.w),
                ),
                child: Text(
                  myCartScreenController.selectedPatient ==
                      null
                      ? 'select_add_patient'.tr
                      : myCartScreenController.userModel
                      .value.userType ==
                      "Admin"
                      ? "${myCartScreenController.selectedUser!.userName}"
                      : "${myCartScreenController.selectedPatient!.firstName!} ${myCartScreenController.selectedPatient!.lastName!}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: mediumBlack_13
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('address'.tr, style: semiBoldBlack_14),
                SizedBox(width: 5.w),
                GestureDetector(
                  onTap: () async {
                    if (myCartScreenController
                        .userModel.value.userType ==
                        "Admin") {
                      Get.to(() => GetAddressMapScreen(
                        callBack: (address) {
                          setState(() {
                            myCartScreenController
                                .selectedAddress =
                                AddressList(
                                    landmark: '',
                                    latitude:
                                    address['latitude'],
                                    longitude:
                                    address['longitude'],
                                    address:
                                    address['address']);
                          });
                        },
                      ));
                    } else {
                      Get.to(() => AddressScreen(
                          isFromCart: true,
                          pickupAddress: (addressList) {
                            setState(() {
                              myCartScreenController
                                  .selectedAddress = addressList;
                            });
                          },
                          callback: () {
                            myCartScreenController.update();
                          }
                          ));
                    }
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 6.w),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: primaryColor),
                          borderRadius: BorderRadius.circular(20.r)
                      ),
                      child: Text(myCartScreenController.selectedAddress == null ? 'add_address'.tr : 'change_address'.tr,style: TextStyle(fontFamily: semiBold,fontSize: 11.sp,color: primaryColor))
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                if (myCartScreenController
                    .userModel.value.userType ==
                    "Admin") {
                  Get.to(() => GetAddressMapScreen(
                    callBack: (address) {
                      setState(() {
                        myCartScreenController
                            .selectedAddress =
                            AddressList(
                                landmark: '',
                                latitude:
                                address['latitude'],
                                longitude:
                                address['longitude'],
                                address:
                                address['address']);
                      });
                    },
                  ));
                } else {
                  Get.to(() => AddressScreen(
                      isFromCart: true,
                      pickupAddress: (addressList) {
                        setState(() {
                          myCartScreenController
                              .selectedAddress = addressList;
                        });
                      },
                      callback: () {
                        myCartScreenController.update();
                      }
                      ));
                }
              },
              child: Container(
                height: 40.h,
                width: Get.width,
                alignment: Alignment.centerLeft,
                margin:
                EdgeInsets.only(top: 5.h, bottom: 15.h),
                padding:
                EdgeInsets.symmetric(horizontal: 15.w),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15.r)
                  ),
                  border: Border.all(color: borderColor2, width: 1.5.w),
                ),
                child: Text(
                  myCartScreenController.selectedAddress == null
                      ? AppConstants().getSelectedAddress()?.address.toString() ?? 'Pickup Address'.tr
                      : myCartScreenController.selectedAddress!.address.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: mediumBlack_13,
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //     myCartScreenController.isWomenPhlebo.value =
            //     !myCartScreenController
            //         .isWomenPhlebo.value;
            //   },
            //   child: Container(
            //     width: Get.width,
            //     padding: EdgeInsets.symmetric(
            //         vertical: 8.h, horizontal: 12.w),
            //     decoration: BoxDecoration(
            //         color: cardBgColor,
            //         borderRadius: BorderRadius.all(
            //             Radius.circular(15.r))),
            //     child: Row(
            //       children: [
            //         Obx(() => Container(
            //             padding: const EdgeInsets.all(4),
            //             decoration: BoxDecoration(
            //               color: Colors.white,
            //               border: Border.all(
            //                 color: borderColor,
            //                 width: 2.w,
            //               ),
            //               borderRadius:
            //               BorderRadius.circular(8.r),
            //             ),
            //             child: Container(
            //               width: 15.w,
            //               height: 13.h,
            //               decoration: BoxDecoration(
            //                 color: myCartScreenController
            //                     .isWomenPhlebo.value
            //                     ? primaryColor
            //                     : cardBgColor,
            //                 borderRadius:
            //                 BorderRadius.circular(5.r),
            //               ),
            //             ))),
            //         SizedBox(
            //           width: 8.w,
            //         ),
            //         Text(
            //           'need_only_women_phlebo'.tr,
            //           style: semiBoldBlack_14,
            //         ),
            //       ],
            //     ),
            //   ),
            // )
          ],
        ),
      );
    }
  }

  // Widget slotBottomSheet(StateSetter setState) {
  //   return CustomBottomSheetContainer.bottomSheetContainer(
  //       child: Obx(() => SingleChildScrollView(
  //           child: Container(
  //             color: whiteColor,
  //             child: Column(
  //               children: [
  //                 Container(
  //                   margin: EdgeInsets.symmetric(horizontal: 10.w),
  //                   child: CustomListTile(
  //                       listTitle: 'select_time_slot'.tr,
  //                       horizontalPadding: 0,
  //                       fontSize: 18.sp,
  //                       // icon: FontAwesomeIcons.solidCalendar,
  //                       trailingIcon: FontAwesomeIcons.xmark,
  //                       trailingIconColor: greyColor),
  //                 ),
  //                 myCartScreenController.slotTimeList.isEmpty
  //                     ? Center(
  //                       child: NoDataFoundWidget(
  //                         title: 'no_time_slot_found'.tr,
  //                         description: '',
  //                       ),
  //                     )
  //                     :
  //                 Column(
  //                   children: [
  //                     GridView.builder(
  //                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //                           crossAxisCount: 3, crossAxisSpacing: 10.w, mainAxisSpacing: 10.w, mainAxisExtent: 32.h
  //                       ),
  //                       itemCount: myCartScreenController.slotTimeList.length,
  //                       physics: const BouncingScrollPhysics(),
  //                       padding: EdgeInsets.only(top: 15.h, bottom: 12.h, left: 15.w,right: 15.w),
  //                       shrinkWrap: true,
  //                       itemBuilder: (context, index) {
  //                         SlotDetailsModel slotDetailModel = myCartScreenController.slotTimeList[index];
  //                         return CustomContainer(
  //                           height: 32.h,
  //                           borderWidth: 1.w,
  //                           borderColor: borderColor,
  //                           onTap: () {
  //                             if(!myCartScreenController.slotTimeList[index].isBooked!) {
  //                               myCartScreenController.selectedSlot.clear();
  //                               myCartScreenController.selectedSlot.add(
  //                                 SlotDetailsModel(
  //                                   isAvailable: myCartScreenController.slotTimeList[index].isAvailable,
  //                                   isBooked: true,
  //                                   time: myCartScreenController.slotTimeList[index].time
  //                                 )
  //                               );
  //                             }
  //
  //                             myCartScreenController.selectedIndex.value = index;
  //                             setState(() {});
  //
  //                           },
  //                           color: slotDetailModel.isBooked! ? gray : myCartScreenController.selectedSlot.isNotEmpty && myCartScreenController.selectedIndex.value == index
  //                               ? primaryColor : whiteColor,
  //                           child: Center(
  //                             child: Text('${slotDetailModel.time.toString().split('-')[0]} - ${slotDetailModel.time.toString().split('-')[1]}',
  //                                 style: myCartScreenController.slotTimeList.isNotEmpty && myCartScreenController.selectedIndex.value == index ? semiBoldWhite_11 : semiBoldGray_11),
  //                           ),
  //                         );},
  //                     ),
  //                     CustomButton(
  //                       height: 38.h,
  //                         topMargin: 10.h,
  //                         horizontalMargin: 15.w,
  //                         text: 'confirm_time'.tr,
  //                         onTap: () {
  //                           if(myCartScreenController.selectedSlot.isEmpty){
  //                             showToast(message: 'please_select_slot'.tr,seconds: 1);
  //                           } else {
  //                             Get.back();
  //                           }
  //                         }
  //                     )
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       )
  //   );
  //
  // }

  getImagesFromCamera({required ImageSource source}) async {
    try {
      Get.back(); // Close the dialog first
      
      // Let image_picker handle permissions internally
      XFile? pickedFile = await ImagePicker().pickImage(
        source: source, 
        imageQuality: 40,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedFile != null) {
        cropImage(pickedFile);
      }
      // If pickedFile is null, user simply cancelled - no need to show any message
    } catch (e) {
      print("Error picking image: $e");
      // Handle specific error cases
      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('camera_access_denied')) {
        errorMessage = 'Camera permission denied. Please enable camera access in settings.';
        _showPermissionDeniedDialog('Camera');
      } else if (e.toString().contains('photo_access_denied')) {
        errorMessage = 'Photo library permission denied. Please enable photo access in settings.';
        _showPermissionDeniedDialog('Gallery');
      } else {
        AppConstants().showToast(errorMessage);
      }
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    Get.dialog(
      AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text('$permissionType permission is required for this feature. Please enable it in your device settings and try again.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> cropImage(XFile pickedFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.png,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 40,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          myCartScreenController.prescriptionImg = croppedFile;
          myCartScreenController.callUploadPrescriptionApi();
        });
      }
    } catch (e) {
      print("Error cropping image: $e");
    }
  }
}
