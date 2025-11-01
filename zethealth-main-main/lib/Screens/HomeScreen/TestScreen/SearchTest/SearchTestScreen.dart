import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomContainer.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/CartModel.dart';
import '../../../../CommonWidget/CustomAppbar.dart';
import '../../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../../Helper/AssetHelper.dart';
import '../../../../Helper/ColorHelper.dart';
import '../../../../Helper/StyleHelper.dart';
import '../../../../Models/custom_cart_model.dart';
import '../../../AuthScreen/LoginScreen.dart';
import 'SearchTestScreenController.dart';

class SearchTestScreen extends StatefulWidget {
  const SearchTestScreen(
      {super.key, this.cartItem, this.callBack, required this.isSelectedItem});
  final CartModel? cartItem;
  final Function(List<CustomCartModel>)? callBack;
  final bool isSelectedItem;
  @override
  State<SearchTestScreen> createState() => _SearchTestScreenState();
}

class _SearchTestScreenState extends State<SearchTestScreen> {
  SearchTestScreenController searchTestScreenController =
      Get.put(SearchTestScreenController());

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    searchTestScreenController.customCartModel = null;
    searchTestScreenController.cartList =
        await searchTestScreenController.dbHelper.getCartList();

    searchTestScreenController.cartCount.value =
        searchTestScreenController.cartList.length;

    if (searchTestScreenController.cartList.isNotEmpty) {
      // keep the lab info visible
      searchTestScreenController.customCartModel =
          searchTestScreenController.cartList.first;
    }

    for (var item in searchTestScreenController.cartList) {
      debugPrint("🛒 Cart Item: ${item.toJson()}");
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchTestScreenController.searchByCityApi(
          cartItem: widget.cartItem, isSelectedItem: widget.isSelectedItem);
    });

    syncCartWithUI();
  }

  void syncCartWithUI() {
  for (var cartItem in searchTestScreenController.cartList) {
    if (cartItem.type == "LabTest") {
      for (var test in searchTestScreenController.testList) {
        if (test.id == cartItem.id) test.isSelected = true;
      }
    } else if (cartItem.type == "Package") {
      for (var pkg in searchTestScreenController.packageList) {
        if (pkg.id == cartItem.id) pkg.isSelected = true;
      }
    } else if (cartItem.type == "Profile") {
      for (var profile in searchTestScreenController.profileList) {
        if (profile.id == cartItem.id) profile.isSelected = true;
      }
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        backClickHandle(isViewCart: false);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppbar(
          centerTitle: true,
          isLeading: false,
          leading: CustomSquareButton(
            backgroundColor: Colors.white,
            leftMargin: 15.w,
            icon: backArrow,
            iconColor: Colors.black,
            onTap: () {
              backClickHandle(isViewCart: false);
            },
            shadow: const [
              BoxShadow(
                  color: borderColor,
                  blurRadius: 8,
                  spreadRadius: -1,
                  offset: Offset(1, 3))
            ],
          ),
          title: Text('search_test'.tr, style: semiBoldBlack_18),
        ),
        body: PaddingHorizontal15(
          child: Obx(
            () => searchTestScreenController.searchTestModel.value.status ==
                    null
                ? const CustomLoadingIndicator()
                : Column(children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(15.r),
                          boxShadow: [
                            BoxShadow(
                                color: borderColor.withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1)
                          ]),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (searchTestScreenController.customCartModel !=
                              null)
                            RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: '${'lab_name'.tr} : ',
                                      style: boldPrimary2_13),
                                  TextSpan(
                                      text:
                                          '${searchTestScreenController.customCartModel!.labName}',
                                      style: boldPrimary_15)
                                ])),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('you_can_select_multiple_test'.tr,
                                        style: mediumBlack_12),
                                    Text('we_assist_you_in_lab_test_booking'.tr,
                                        style: mediumGray_10),
                                  ],
                                ),
                              ),
                              CustomContainer(
                                topPadding: 6.h,
                                bottomPadding: 6.h,
                                rightPadding: 15.w,
                                leftPadding: 15.w,
                                borderColor: primaryColor,
                                borderWidth: 1.w,
                                radius: 20.r,
                                onTap: () => backClickHandle(isViewCart: true),
                                child: Obx(() => Text(
                                      searchTestScreenController
                                                  .cartCount.value >
                                              0

                                          ? "${"view_cart".tr} (${searchTestScreenController.cartCount.value})"

                                          : "view_cart".tr,
                                      style: semiBoldPrimary_12,
                                    )),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    CupertinoTextField(
                      controller: searchTestScreenController.searchController,
                      suffixMode: OverlayVisibilityMode.always,
                      minLines: 1,
                      placeholder: 'health'.tr,
                      style: semiBoldBlack_14,
                      cursorColor: primaryColor,
                      textAlign: TextAlign.start,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      prefixMode: OverlayVisibilityMode.always,
                      onChanged: searchTestScreenController.filterList,
                      prefix: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: SvgPicture.asset(searchDotsIcon)),
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          border: Border.all(color: borderColor, width: 1.w)),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            searchTestScreenController.selectedFilter.value = 0;
                            searchTestScreenController.filterList(
                                searchTestScreenController
                                    .searchController.text);
                          },
                          child: Container(
                            height: 30.h,
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(right: 8.w, left: 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: searchTestScreenController
                                                .selectedFilter.value ==
                                            0
                                        ? primaryColor
                                        : borderColor),
                                color: searchTestScreenController
                                            .selectedFilter.value ==
                                        0
                                    ? borderColor
                                    : whiteColor),
                            child: Text('Tests',
                                style: TextStyle(
                                    fontFamily: semiBold,
                                    fontSize: 12.sp,
                                    color: searchTestScreenController
                                                .selectedFilter.value ==
                                            0
                                        ? black
                                        : primaryColor)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            searchTestScreenController.selectedFilter.value = 1;
                            searchTestScreenController.filterList(
                                searchTestScreenController
                                    .searchController.text);
                          },
                          child: Container(
                            height: 30.h,
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(right: 8.w, left: 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: searchTestScreenController
                                                .selectedFilter.value ==
                                            1
                                        ? primaryColor
                                        : borderColor),
                                color: searchTestScreenController
                                            .selectedFilter.value ==
                                        1
                                    ? borderColor
                                    : whiteColor),
                            child: Text('Packages',
                                style: TextStyle(
                                    fontFamily: semiBold,
                                    fontSize: 12.sp,
                                    color: searchTestScreenController
                                                .selectedFilter.value ==
                                            1
                                        ? black
                                        : primaryColor)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            searchTestScreenController.selectedFilter.value = 2;
                            searchTestScreenController.filterList(
                                searchTestScreenController
                                    .searchController.text);
                          },
                          child: Container(
                            height: 30.h,
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(right: 8.w, left: 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: searchTestScreenController
                                                .selectedFilter.value ==
                                            2
                                        ? primaryColor
                                        : borderColor),
                                color: searchTestScreenController
                                            .selectedFilter.value ==
                                        2
                                    ? borderColor
                                    : whiteColor),
                            child: Text('Profile',
                                style: TextStyle(
                                    fontFamily: semiBold,
                                    fontSize: 12.sp,
                                    color: searchTestScreenController
                                                .selectedFilter.value ==
                                            2
                                        ? black
                                        : primaryColor)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Expanded(
                      child:
                      // !AppConstants().getDisplayAddress().toLowerCase().contains("bengaluru")
                      // ? NoDataFoundWidget(title: 'We are coming soon. Stay Updated.', description: '',)
                      //     :
                      ListView.builder(
                        itemCount: searchTestScreenController
                                    .selectedFilter.value ==
                                0
                            ? searchTestScreenController.testList.length
                            : searchTestScreenController.selectedFilter.value ==
                                    1
                                ? searchTestScreenController.packageList.length
                                : searchTestScreenController.profileList.length,
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          CustomCartModel labTestModel =
                              searchTestScreenController.selectedFilter.value ==
                                      0
                                  ? searchTestScreenController.testList[index]
                                  : searchTestScreenController
                                              .selectedFilter.value ==
                                          1
                                      ? searchTestScreenController
                                          .packageList[index]
                                      : searchTestScreenController
                                          .profileList[index];
                          return GestureDetector(
                            onTap: () {
                              CustomCartModel custom = CustomCartModel(
                                id: labTestModel.id,
                                name: labTestModel.name,
                                type: labTestModel.type,
                                price: labTestModel.price.toString(),
                                image: labTestModel.image.toString(),
                                isFastRequired:
                                    labTestModel.isFastRequired.toString(),
                                testTime: labTestModel.testTime.toString(),
                                itemDetail: labTestModel.itemDetail,
                                profilesDetail: labTestModel.profilesDetail,
                                parametersCount: labTestModel.parametersCount,
                                parameters: labTestModel.parameters,
                                cityId: labTestModel.cityId,
                                labId: labTestModel.labId,
                                labName: labTestModel.labName,
                              );
                              if (searchTestScreenController
                                      .cartList.isNotEmpty &&
                                  searchTestScreenController
                                          .cartList.first.labId !=
                                      labTestModel.labId) {
                                Get.dialog(CommonDialog(
                                  title: 'warning'.tr,
                                  description:
                                      'selected_item_is_from_different_lab'.tr,
                                  tapNoText: 'cancel'.tr,
                                  tapYesText: 'confirm'.tr,
                                  onTapNo: () {
                                    labTestModel.isSelected =
                                        !labTestModel.isSelected;
                                    Get.back();
                                  },
                                  onTapYes: () {
                                    // Clear DB and in-memory cart
                                    searchTestScreenController.dbHelper
                                        .clearAllRecord();
                                    searchTestScreenController.cartList.clear();

                                    // Reset selection in UI lists
                                    for (var test in searchTestScreenController
                                        .testList) {
                                      test.isSelected = false;
                                    }
                                    for (var pkg in searchTestScreenController
                                        .packageList) {
                                      pkg.isSelected = false;
                                    }
                                    for (var profile
                                        in searchTestScreenController
                                            .profileList) {
                                      profile.isSelected = false;
                                    }

                                    // Now add the new item
                                    labTestModel.isSelected = true;
                                    searchTestScreenController.cartList
                                        .add(labTestModel);
                                    searchTestScreenController.dbHelper
                                        .addToCartCart(cartModel: labTestModel);
                                    searchTestScreenController.cartCount.value =
                                        1;
                                    searchTestScreenController.customCartModel = labTestModel;

                                    Get.back();
                                  },
                                ));
                              } else {
                                // Same lab or empty cart, just add/remove normally
                                commonSelectionProcess(
                                    labTestModel: labTestModel);
                              }
                              setState(() {});
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.h, horizontal: 10.w),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16.r)),
                                color: labTestModel.isSelected
                                    ? borderColor
                                    : cardBgColor,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${labTestModel.name}',
                                          style: semiBoldBlack_13,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      if (labTestModel.parametersCount !=
                                              null &&
                                          labTestModel
                                              .parametersCount!.isNotEmpty &&
                                          labTestModel.parametersCount != "0")
                                        GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            parametersDialog(
                                                cartModel: labTestModel);
                                          },
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 3.h),
                                            child: Text(
                                                '${labTestModel.parametersCount} ${'parameter_included'.tr}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: semiBold,
                                                    color: primaryColor,
                                                    fontSize: 10.sp,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        primaryColor)),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.r)),
                                            child: CachedNetworkImage(
                                              imageUrl: AppConstants.IMG_URL +
                                                  labTestModel.labProfile
                                                      .toString(),
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter,
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const ImageErrorWidget(),
                                              width: 40.w,
                                              height: 40.w,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('${labTestModel.labName}',
                                                    style: semiBoldBlack_12,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                Text(
                                                    '${labTestModel.labAddress}',
                                                    style: mediumBlack_10,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )),
                                  SizedBox(width: 10.w),
                                  IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                            child: Text(
                                                '₹ ${labTestModel.price}',
                                                style: semiBoldBlack_14)),
                                        const Spacer(),
                                        AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          width: 25.w,
                                          height: 25.w,
                                          decoration: BoxDecoration(
                                            color: labTestModel.isSelected
                                                ? greenColor
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            border: Border.all(
                                                color: borderColor, width: 1.w),
                                          ),
                                          child: Center(
                                            child: AnimatedScale(
                                              scale: labTestModel.isSelected
                                                  ? 1.0
                                                  : 0.0,
                                              duration:
                                                  Duration(milliseconds: 200),
                                              child: Icon(Icons.check,
                                                  size: 14.sp,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
          ),
        ),
      ),
    );
  }

  commonSelectionProcess({required CustomCartModel labTestModel}) {
  labTestModel.isSelected = !labTestModel.isSelected;

  if (labTestModel.isSelected) {
    // ADD TO CART
    final exists = searchTestScreenController.cartList.any(
      (c) => c.id == labTestModel.id && c.type == labTestModel.type,
    );
    if (!exists) {
      searchTestScreenController.cartList.add(labTestModel);
      searchTestScreenController.dbHelper
          .addToCartCart(cartModel: labTestModel);
      searchTestScreenController.cartCount.value++;

      // **Update displayed lab info immediately**
      searchTestScreenController.customCartModel = labTestModel;
    }
  } else {
    // REMOVE FROM CART
    searchTestScreenController.cartList.removeWhere(
      (c) => c.id == labTestModel.id && c.type == labTestModel.type,
    );
    searchTestScreenController.dbHelper.deleteRecordFormCart(
      id: labTestModel.id.toString(),
      type: labTestModel.type!,
    );
    searchTestScreenController.cartCount.value--;

    // **Update lab info if cart is now empty**
    if (searchTestScreenController.cartList.isEmpty) {
      searchTestScreenController.customCartModel = null;
    } else {
      searchTestScreenController.customCartModel =
          searchTestScreenController.cartList.first;
    }
  }
}


  bool isAnySelected() {
    bool isTest =
        searchTestScreenController.testList.any((test) => test.isSelected);
    bool isPackage = searchTestScreenController.packageList
        .any((package) => package.isSelected);
    bool isProfile = searchTestScreenController.profileList
        .any((profile) => profile.isSelected);
    return isTest || isPackage || isProfile;
  }

  backClickHandle({required bool isViewCart}) async {
    // Check if any item is selected in UI
    bool anySelectedInUI =
        searchTestScreenController.testList.any((test) => test.isSelected) ||
            searchTestScreenController.packageList
                .any((package) => package.isSelected) ||
            searchTestScreenController.profileList
                .any((profile) => profile.isSelected);

    // Check if cart already has items
    bool anySelectedInCart = searchTestScreenController.cartList.isNotEmpty;

    debugPrint("anySelectedInCart, $anySelectedInCart");

    bool anySelected = anySelectedInUI || anySelectedInCart;
    debugPrint("anySelected, $anySelected");

    if (isViewCart) {
      // Viewing cart
      if (anySelected) {
        // Either user selected items just now or cart already has items
        if (checkLogin()) {
          searchTestScreenController.callTestWiseLabApi(toViewCart: true);
        } else {
          AppConstants().loadWithCanBack(LoginScreen(onLoginSuccess: () {
            searchTestScreenController.callTestWiseLabApi(toViewCart: true);
          }));
        }
      } else {
        // Nothing selected and cart empty
        showToast(message: 'please_select_tests'.tr);
      }

      // Do NOT pop the screen
      return;
    }

    // Normal back press
    if (widget.callBack != null) {
      List<CustomCartModel> tempList = [];

      // Add selected items from UI
      tempList.addAll(
          searchTestScreenController.testList.where((test) => test.isSelected));
      tempList.addAll(searchTestScreenController.packageList
          .where((package) => package.isSelected));
      tempList.addAll(searchTestScreenController.profileList
          .where((profile) => profile.isSelected));

      // Also include existing cart items if not already in the list
      for (var cartItem in searchTestScreenController.cartList) {
        if (!tempList.any(
            (item) => item.id == cartItem.id && item.type == cartItem.type)) {
          tempList.add(cartItem);
        }
      }

      widget.callBack?.call(tempList);
    }

    Get.back(); // Only pop screen on real back
     if (checkLogin()) {
          searchTestScreenController.callTestWiseLabApi(toViewCart: false);
          debugPrint("Printing while going back");
        }
  }
}
