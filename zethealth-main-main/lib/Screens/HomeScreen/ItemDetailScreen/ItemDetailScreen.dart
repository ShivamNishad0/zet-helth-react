import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/CommonWidget/login_prompt_snackbar.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/AssetHelper.dart';
import 'package:zet_health/Models/custom_cart_model.dart';
import 'package:zet_health/Screens/HomeScreen/TestScreen/SearchTest/SearchResultController.dart';
import 'package:zet_health/Screens/MyCartScreen/MyCartScreen.dart';
import '../../../CommonWidget/CallBackDialogWithSearch.dart';
import '../../../CommonWidget/CustomContainer.dart';
import '../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../CommonWidget/custom_expansion_tile.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../../Models/CityModel.dart';
import '../../../Models/LabModel.dart';
import '../../AuthScreen/LoginScreen.dart';
import '../../DrawerView/OrderHistoryScreen/ReviewRatingScreen/review_rating_screen.dart';
import 'ItemDetailScreenController.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.customCartModel, this.description});
  final CustomCartModel customCartModel;
  final String? description;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  ItemDetailScreenController itemDetailScreenController =
      Get.put(ItemDetailScreenController());
  
  // Get the SearchResultController to manage cart
  SearchResultController searchResultController = Get.find<SearchResultController>();

  @override
  void initState() {
    super.initState();
    String? cityId = AppConstants().getStorage.read(AppConstants.CITY_ID);
    String? cityName =
        AppConstants().getStorage.read(AppConstants.CURRENT_LOCATION);
    if (cityId != null) {
      itemDetailScreenController.selectedCity =
          CityModel(id: cityId, cityName: cityName);
    }
    itemDetailScreenController.customCartModel = widget.customCartModel;
    itemDetailScreenController.type = widget.customCartModel.type.toString();
    itemDetailScreenController.callTestWiseLabApi();
  }

  // Check if current item is in cart
  bool get isItemInCart {
    return searchResultController.cartIds.contains(widget.customCartModel.id);
  }

  // Add to cart function
  void _addToCart() async {
    if (!checkLogin()) {
      LoginPromptSnackbar.show(
        message: 'Please login to add items to cart',
        onLoginTap: () {
          AppConstants().loadWithCanBack(
            LoginScreen(
              onLoginSuccess: () {
                // After login, add the item to cart
                _performAddToCart();
              },
            ),
          );
        },
      );
      return;
    }
    
    _performAddToCart();
  }

  void _performAddToCart() {
    AppConstants().setCartPincode(
      AppConstants().getSelectedAddress()?.pincode ??
          AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE),
    );

    if (searchResultController.cartList.isEmpty ||
        widget.customCartModel.labId == searchResultController.cartList[0].labId) {
      // Same lab or empty list → allow adding
      searchResultController.dbHelper.addToCart(cartModel: widget.customCartModel);
      searchResultController.cartList.add(widget.customCartModel);
      searchResultController.cartIds.add(widget.customCartModel.id!);
    } else {
      // Different lab → show warning
      Get.dialog(CommonDialog(
        title: 'warning'.tr,
        description: 'msg_add_this_item_previously_added_test_will_removed'.tr,
        tapNoText: 'cancel'.tr,
        tapYesText: 'confirm'.tr,
        onTapNo: () => Get.back(),
        onTapYes: () {
          searchResultController.cartList = [];
          searchResultController.cartIds.clear();
          searchResultController.dbHelper.clearAllRecord();
          searchResultController.dbHelper.addToCart(cartModel: widget.customCartModel);
          searchResultController.cartList.add(widget.customCartModel);
          searchResultController.cartIds.add(widget.customCartModel.id!);
          searchResultController.cartCount.value = searchResultController.cartList.length;
          Get.back();
        },
      ));
    }
    
    searchResultController.cartCount.value = searchResultController.cartList.length;
    setState(() {});
  }

  // Remove from cart function
  void _removeFromCart() async {
    await searchResultController.dbHelper.deleteFromCart(
      id: widget.customCartModel.id.toString(),
      type: widget.customCartModel.type!,
    );
    searchResultController.cartList.removeWhere(
      (item) => item.id == widget.customCartModel.id && item.type == widget.customCartModel.type,
    );
    searchResultController.cartIds.remove(widget.customCartModel.id);
    
    if (searchResultController.cartList.length <= 1) {
      searchResultController.customCartModel = null;
      AppConstants().clearCartPincode();
    }
    
    searchResultController.cartCount.value = searchResultController.cartList.length;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 80.h), // Add padding for the fixed button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: Stack(children: [
                    Center(child: Image.asset(
                      testScreenHeaderImg,
                      fit: BoxFit.contain,
                    ),),
                    Positioned(
                      left: 0,
                      top: 15.h,
                      child: CustomSquareButton(
                        backgroundColor: Colors.white,
                        leftMargin: 15.w,
                        icon: backArrow,
                        iconColor: Colors.black,
                        onTap: () => Get.back(),
                        shadow: const [
                          BoxShadow(
                              color: borderColor,
                              blurRadius: 8,
                              spreadRadius: -1,
                              offset: Offset(1, 3))
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      Text('${itemDetailScreenController.customCartModel.name}',
                          style: boldPrimary2_16, textAlign: TextAlign.center),
                      Text(
                        'Instructions : ${itemDetailScreenController.customCartModel.isFastRequired == '0' ? 'fasting_not_required'.tr : 'fasting_required'.tr} ',
                        style: regularBlack_12,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (itemDetailScreenController.type ==
                                  AppConstants.test &&
                              itemDetailScreenController
                                      .customCartModel.itemDetail !=
                                  null &&
                              itemDetailScreenController
                                  .customCartModel.itemDetail!.isNotEmpty)
                            CustomContainer(
                              borderColor: borderColor,
                              radius: 8.r,
                              right: 10.w,
                              leftPadding: 6.w,
                              rightPadding: 6.w,
                              topPadding: 2.h,
                              bottomPadding: 2.h,
                              color: primaryColor,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(bloodIcon,
                                      color: whiteColor,
                                      height: 13.h,
                                      width: 15.w),
                                  SizedBox(width: 3.w),
                                  Text(
                                      itemDetailScreenController.customCartModel
                                          .itemDetail![0].sampleCollection
                                          .toString(),
                                      style: mediumWhite_12)
                                ],
                              ),
                            ),
                          CustomContainer(
                            borderColor: borderColor,
                            borderWidth: 1.w,
                            color: whiteColor,
                            radius: 8.r,
                            leftPadding: 6.w,
                            rightPadding: 6.w,
                            topPadding: 2.h,
                            bottomPadding: 2.h,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                    itemDetailScreenController.type ==
                                            AppConstants.test
                                        ? test
                                        : itemDetailScreenController.type ==
                                                AppConstants.package
                                            ? package
                                            : profile,
                                    height: 12.h,
                                    width: 12.h),
                                SizedBox(width: 3.w),
                                Text(
                                    itemDetailScreenController.type ==
                                            AppConstants.test
                                        ? 'test'.tr
                                        : itemDetailScreenController.type ==
                                                AppConstants.package
                                            ? 'package'.tr
                                            : 'profile'.tr,
                                    style: TextStyle(
                                        fontFamily: semiBold,
                                        fontSize: 12.sp,
                                        color: greyColor2))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ]),
            ),
            // About Section — only show if description is not null or empty
            if (itemDetailScreenController.type != AppConstants.test)
              if (widget.description != null && widget.description!.trim().isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(1, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: TextStyle(
                            fontFamily: semiBold,
                            fontSize: 14.sp,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: Text(
                            widget.description!,
                            textAlign: TextAlign.justify,
                            style: regularBlack_12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            CustomContainer(
                borderColor: borderColor,
                borderWidth: 1.w,
                color: whiteColor,
                radius: 10.r,
                leftPadding: 10.w,
                rightPadding: 10.w,
                topPadding: 8.h,
                bottomPadding: 8.h,
                left: 15.w,
                right: 15.w,
                top: 10.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        itemDetailScreenController.type == AppConstants.package
                            ? 'included_test_profile'.tr
                            : 'included_test'.tr,
                        style: TextStyle(
                            fontFamily: semiBold,
                            fontSize: 13.sp,
                            color: primaryColor2)),
                    if (itemDetailScreenController
                            .customCartModel.profilesDetail !=
                        null)
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: itemDetailScreenController
                            .customCartModel.profilesDetail?.length,
                        itemBuilder: (context, index) {
                          final cartItem = itemDetailScreenController
                              .customCartModel.profilesDetail![index];
                          return CustomContainer(
                            color: borderColor,
                            radius: 15.r,
                            top: 5.h,
                            child: CustomExpansionTile(
                              collapsedIconColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.r))),
                              iconColor: Colors.black,
                              childrenPadding: EdgeInsets.zero,
                              tilePadding:
                                  EdgeInsets.symmetric(horizontal: 10.w),
                              expandedAlignment: Alignment.centerLeft,
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(profile),
                                  SizedBox(width: 5.w),
                                  Expanded(
                                      child: Text(cartItem.name ?? '',
                                          maxLines: 1,
                                          style: mediumBlack_12,
                                          overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: <Widget>[
                                if (cartItem.itemDetail != null)
                                  ListView.separated(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: cartItem.itemDetail!.length,
                                    separatorBuilder: (context, secondIndex) {
                                      return Divider(
                                          color: borderColor,
                                          thickness: 1.w,
                                          height: 0);
                                    },
                                    itemBuilder: (context, secondIndex) {
                                      final tests =
                                          cartItem.itemDetail![secondIndex];
                                      return CustomContainer(
                                        color: cardBgColor,
                                        radius: 0,
                                        topPadding: 8.h,
                                        leftPadding: 10.w,
                                        rightPadding: 10.w,
                                        bottomPadding: 8.h,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(test),
                                            SizedBox(width: 5.w),
                                            Expanded(
                                                child: Text(tests.name ?? '',
                                                    maxLines: 1,
                                                    style: mediumBlack_12,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                            CustomContainer(
                                                color: cardBgColor,
                                                borderColor: borderColor,
                                                borderWidth: 1.w,
                                                left: 5.w,
                                                radius: 5.r,
                                                rightPadding: 6.w,
                                                leftPadding: 6.w,
                                                topPadding: 2.h,
                                                bottomPadding: 2.h,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SvgPicture.asset(bloodIcon),
                                                    SizedBox(
                                                      width: 3.w,
                                                    ),
                                                    Text(
                                                      '${tests.sampleCollection}',
                                                      style: regularPrimary_10,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    if (itemDetailScreenController.customCartModel.itemDetail !=
                        null)
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: itemDetailScreenController
                            .customCartModel.itemDetail?.length,
                        itemBuilder: (context, index) {
                          final cartItem = itemDetailScreenController
                              .customCartModel.itemDetail![index];
                          return CustomContainer(
                            color: cardBgColor,
                            radius: 15.r,
                            top: 5.h,
                            topPadding: 8.h,
                            leftPadding: 10.w,
                            rightPadding: 10.w,
                            bottomPadding: 8.h,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(test),
                                SizedBox(width: 5.w),
                                Expanded(
                                    child: Text(cartItem.name ?? '',
                                        maxLines: 1,
                                        style: mediumBlack_12,
                                        overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
          
          // Fixed Add to Cart Button at the bottom
          Positioned(
            bottom: 20.h,
            left: 15.w,
            right: 15.w,
            child: Obx(() {
              final cartCount = searchResultController.cartCount.value;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                child: Row(
                  children: [
                    // Cart info
                    if (cartCount > 0)
                      GestureDetector(
                        onTap: () {
                          // Navigate to cart screen
                          if (AppConstants().getStorage.read(AppConstants.isCartExist)) {
                            AppConstants().loadWithCanBack(const MyCartScreen());
                          } else {
                            searchResultController.callTestWiseLabApi(toViewCart: true);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: greenColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$cartCount items",
                                style: boldWhite_12,
                              ),
                              Text(
                                "View cart",
                                style: regularWhite_10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    SizedBox(width: 10.w),
                    
                    // Add/Remove to Cart button
                    Expanded(
                      child: GestureDetector(
                        onTap: isItemInCart ? _removeFromCart : _addToCart,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isItemInCart ? Colors.red : primaryColor,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: (isItemInCart ? Colors.red : primaryColor).withOpacity(0.3),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              isItemInCart ? 'Remove from Cart' : 'Add to Cart',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}