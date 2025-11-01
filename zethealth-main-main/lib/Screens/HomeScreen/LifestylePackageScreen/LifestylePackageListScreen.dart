import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomLoadingIndicator.dart';
import 'package:zet_health/Models/PackageModel.dart';

import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomContainer.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../CommonWidget/login_prompt_snackbar.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../../Models/custom_cart_model.dart';
import '../../../Screens/AuthScreen/LoginScreen.dart';
import '../../../Screens/HomeScreen/HomeScreenController.dart';
import '../ItemDetailScreen/ItemDetailScreen.dart';
import '../TestScreen/SearchTest/SearchResultController.dart';

class LifestylePackageListScreen extends StatefulWidget {
  final RxList<NewPackageModel> lifeStylePackageList;
  final RxList<NewPackageModel> filterList;
  const LifestylePackageListScreen(this.lifeStylePackageList, this.filterList,
      {super.key});

  @override
  State<LifestylePackageListScreen> createState() =>
      _LifestylePackageListScreenState();
}

class _LifestylePackageListScreenState
    extends State<LifestylePackageListScreen> {
  SearchResultController searchResultsController = Get.isRegistered<SearchResultController>() ? Get.find<SearchResultController>() : Get.put(SearchResultController());
  HomeScreenController homeScreenController = Get.find<HomeScreenController>();
  
  // Create local copies of the lists to prevent data loss
  late RxList<NewPackageModel> _displayList;
  late RxList<NewPackageModel> _originalFilterList;

  @override
  void initState() {
    super.initState();
    // Initialize local lists with the passed data
    _displayList = RxList<NewPackageModel>.from(widget.lifeStylePackageList);
    _originalFilterList = RxList<NewPackageModel>.from(widget.filterList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('Lifestyle Packages', style: semiBoldBlack_18),
        actions: [CartButtonCommon(callBack: () => setState(() {}))],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 15.w, right: 15.w, top: 16.h, bottom: 20.h),
            child: CupertinoTextField(
              suffixMode: OverlayVisibilityMode.always,
              minLines: 1,
              onChanged: filterList,
              placeholder: 'search_lifestyle_packages'.tr,
              style: semiBoldBlack_14,
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
              onTap: () {},
            ),
          ),
          Expanded(
            child: Obx(() => _displayList.isEmpty
                ? Center(
                    child: NoDataFoundWidget(
                        title: 'no_package_found'.tr, description: ''))
                : ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: _displayList.length,
              itemBuilder: (context, index) {
                NewPackageModel packageModel = _displayList[index];
                CustomCartModel cartModel = CustomCartModel(
                    id: packageModel.id,
                    name: packageModel.name,
                    type: AppConstants.package,
                    price: packageModel.price.toString(),
                    image: packageModel.image.toString(),
                    isFastRequired: packageModel.isFastRequired.toString(),
                    testTime: packageModel.testTime.toString(),
                    itemDetail: packageModel.itemDetail,
                    cityId: packageModel.cityId,
                    labId: packageModel.labId,
                    labName: packageModel.labName,
                    labAddress: packageModel.labAddress
                );
                return FutureBuilder<bool>(
                    future: searchResultsController.dbHelper.checkRecordExist(
                        id: packageModel.id.toString(),
                        type: AppConstants.package),
                    builder: (context, snapshot) {
                      return CustomContainer(
                        onTap: () {
                          Get.to(() => ItemDetailScreen(
                            customCartModel: cartModel, description: packageModel.description,));
                        },
                        height: 200.h,
                        bottom: 15.h,
                        left: 15.w,
                        right: 15.w,
                        radius: 24.r,
                        color: Colors.white,
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
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${packageModel.name}',
                                          maxLines: 2,
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: boldBlack_16,
                                        ),
                                        CustomContainer(
                                          borderColor: borderColor,
                                          radius: 18.r,
                                          leftPadding: 6.w,
                                          rightPadding: 6.w,
                                          top: 5.h,
                                          topPadding: 2.h,
                                          bottomPadding: 2.h,
                                          color: cardBgColor,
                                          child: Row(
                                            mainAxisSize:
                                            MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                  timeIcon),
                                              SizedBox(
                                                width: 2.w,
                                              ),
                                              Text(
                                                '2-4 Hours'
                                              ),
                                            ],
                                          ),
                                        ),
                                        CustomContainer(
                                          radius: 18.r,
                                          leftPadding: 6.w,
                                          rightPadding: 6.w,
                                          top: 5.h,
                                          topPadding: 2.h,
                                          bottom: 10.h,
                                          bottomPadding: 2.h,
                                          color: primaryColor,
                                          child: Text(
                                            'At ${packageModel.price} ₹ only',
                                            style: boldWhite_12,
                                          ),
                                        ),
                                        if (packageModel
                                            .itemDetail!.isNotEmpty)
                                          Expanded(
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount:
                                              packageModel
                                                  .itemDetail!
                                                  .length,
                                              physics:
                                              const BouncingScrollPhysics(),
                                              itemBuilder:
                                                  (context, index) {
                                                ItemDetail
                                                labTestModel =
                                                packageModel
                                                    .itemDetail![
                                                index];
                                                return Padding(
                                                  padding: EdgeInsets
                                                      .only(
                                                      bottom:
                                                      3.h),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                            horizontal:
                                                            5.w),
                                                        decoration: BoxDecoration(
                                                            color:
                                                            cardBgColor,
                                                            borderRadius:
                                                            BorderRadius.all(Radius.circular(9.r))),
                                                        child: Text(
                                                          '◈',
                                                          style:
                                                          regularPrimary_12,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5.w,
                                                      ),
                                                      Expanded(
                                                          child:
                                                          Text(
                                                            '${labTestModel.name}',
                                                            style:
                                                            regularBlack_12,
                                                            maxLines: 2,
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                          )),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(
                                              17.r)),
                                      child: CachedNetworkImage(
                                        height: 150.h,
                                        fit: BoxFit.cover,
                                        imageUrl:
                                        packageModel.image!,
                                        placeholder: (context,
                                            url) =>
                                        const Center(
                                            child:
                                            CircularProgressIndicator()),
                                        errorWidget: (context, url,
                                            error) =>
                                        const ImageErrorWidget(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Obx(() {
                                final isInCart = searchResultsController.cartIds.contains(packageModel.id);
                                return GestureDetector(
                                  onTap: () async {
                                    if (isInCart) {
                                      // Remove from cart logic
                                      await searchResultsController
                                          .dbHelper
                                          .deleteFromCart(
                                          id: packageModel
                                              .id
                                              .toString(),
                                          type: AppConstants
                                              .package);
                                      searchResultsController.cartList.removeWhere(
                                            (item) => item.id == packageModel.id && item.type == AppConstants.package,
                                      );
                                      searchResultsController.cartIds.remove(packageModel.id);
                                      if(searchResultsController.cartList.length <= 1) {
                                        searchResultsController.customCartModel = null;
                                        AppConstants().clearCartPincode();
                                      }
                                    } else {
                                      // ADD TO CART - Check login first
                                      if (!checkLogin()) {
                                        LoginPromptSnackbar.show(
                                          message: 'Please login to add items to cart',
                                          onLoginTap: () {
                                            AppConstants().loadWithCanBack(
                                              LoginScreen(
                                                onLoginSuccess: () {
                                                  homeScreenController.callHomeApi();
                                                  // After login, add the item to cart
                                                  _addPackageToCartAfterLogin(packageModel, cartModel);
                                                },
                                              ),
                                            );
                                          },
                                        );
                                        return;
                                      }
                                      
                                      // User is logged in, proceed with adding to cart
                                      AppConstants().setCartPincode(AppConstants().getSelectedAddress()?.pincode ?? AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE));
                                      if (searchResultsController.cartList.isEmpty || cartModel.labId == searchResultsController.cartList[0].labId) {
                                        // Same lab or empty list → allow adding
                                        setState(() {});
                                        searchResultsController.dbHelper.addToCart(cartModel: cartModel);
                                        searchResultsController.cartList.add(cartModel);
                                        searchResultsController.cartIds.add(packageModel.id!);
                                      } else {
                                        // Different lab → show warning
                                        Get.dialog(CommonDialog(
                                          title: 'warning'.tr,
                                          description: 'msg_add_this_item_previously_added_test_will_removed'.tr,
                                          tapNoText: 'cancel'.tr,
                                          tapYesText: 'confirm'.tr,
                                          onTapNo: () {
                                            Get.back();
                                          },
                                          onTapYes: () {
                                            setState(() {});
                                            searchResultsController.cartList = [];
                                            searchResultsController.cartIds.clear();
                                            searchResultsController.dbHelper.clearAllRecord();
                                            searchResultsController.dbHelper.addToCart(cartModel: cartModel);
                                            searchResultsController.cartList.add(cartModel);
                                            searchResultsController.cartIds.add(packageModel.id!);
                                            searchResultsController.cartCount.value = searchResultsController.cartList.length;
                                            Get.back();
                                          },
                                        ));
                                      }
                                    }
                                    searchResultsController.cartCount.value = searchResultsController.cartList.length;
                                  },
                                  child: Container(
                                    padding:
                                    EdgeInsets.symmetric(
                                        horizontal: 26.w,
                                        vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius:
                                      BorderRadius.only(
                                          bottomRight: Radius
                                              .circular(
                                              24.r),
                                          topLeft: Radius
                                              .circular(
                                              24.r),
                                          bottomLeft: Radius
                                              .circular(
                                              10.r),
                                          topRight: Radius
                                              .circular(
                                              10.r)),
                                    ),
                                    child: Text(
                                        isInCart ? 'remove_from_cart'.tr : 'add_to_cart'.tr,
                                        style: semiBoldWhite_12),
                                  ),
                                );}),
                            )
                          ],
                        ),
                      );
                    });
              },
            ),
          )
      )],
      ),
    );
  }

  // Helper method for adding package to cart after login
  void _addPackageToCartAfterLogin(NewPackageModel packageModel, CustomCartModel cartModel) {
    AppConstants().setCartPincode(
        AppConstants().getSelectedAddress()?.pincode ??
            AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE));

    if (cartModel.itemDetail == null || cartModel.itemDetail!.isEmpty) {
    // If itemDetail is missing, create it from the package model
    if (packageModel.itemDetail != null && packageModel.itemDetail!.isNotEmpty) {
      cartModel.itemDetail = packageModel.itemDetail;
      debugPrint("🛒 Added itemDetail to cartModel from packageModel");
    }
  }
    
    if (searchResultsController.cartList.isEmpty ||
        cartModel.labId == searchResultsController.cartList[0].labId) {
      searchResultsController.dbHelper.addToCart(cartModel: cartModel);
      searchResultsController.cartList.add(cartModel);
      searchResultsController.cartIds.add(packageModel.id!);
    } else {
      Get.dialog(CommonDialog(
        title: 'warning'.tr,
        description: 'msg_add_this_item_previously_added_test_will_removed'.tr,
        tapNoText: 'cancel'.tr,
        tapYesText: 'confirm'.tr,
        onTapNo: () => Get.back(),
        onTapYes: () {
          searchResultsController.cartList = [];
          searchResultsController.cartIds.clear();
          searchResultsController.dbHelper.clearAllRecord();
          searchResultsController.dbHelper.addToCart(cartModel: cartModel);
          searchResultsController.cartList.add(cartModel);
          searchResultsController.cartIds.add(packageModel.id!);
          searchResultsController.cartCount.value =
              searchResultsController.cartList.length;
          Get.back();
        },
      ));
    }
    
    searchResultsController.cartCount.value =
        searchResultsController.cartList.length;
    setState(() {});
  }

  filterList(String query) {
    query = query.trim().toLowerCase();
    _displayList.clear();
    if (query.isEmpty) {
      setState(() {
        _displayList.addAll(_originalFilterList);
      });
    } else {
      for (int i = 0; i < _originalFilterList.length; i++) {
        if (_originalFilterList[i].name
            .toString()
            .toLowerCase()
            .contains(query)) {
          _displayList.add(_originalFilterList[i]);
        }
      }
    }
    setState(() {});
  }
}