import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomButton.dart';
import 'package:zet_health/CommonWidget/CustomContainer.dart';
import 'package:zet_health/Screens/MyCartScreen/MyCartScreenController.dart';
import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../../Models/AddressListModel.dart';
import '../../../Models/CityModel.dart';
import '../../HomeScreen/HomeScreen.dart';
import '../../HomeScreen/HomeScreenController.dart';
import 'AddAdressScreen/AddAddressScreen.dart';
import 'AddAdressScreen/get_address_map_screen.dart';
import 'AddressScreenController.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key, this.pickupAddress, this.isFromCart = false, this.callback});
  final Function(AddressList)? pickupAddress;
  final bool isFromCart;
  final Function? callback;
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  AddressScreenController addressScreenController =
      Get.put(AddressScreenController());

  void showMaterialToast(BuildContext context, String message,
      {Color? color, int? seconds, double? width}) {
    final duration = Duration(seconds: seconds ?? 2);

    // Show native snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: color ?? Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.symmetric(
          horizontal: width != null
              ? (MediaQuery.of(context).size.width - width) / 2
              : 20,
          vertical: 20,
        ),
      ),
    );
  }

  void showMaterialToastAndGoBack(BuildContext context, String message,
      {Color? color, int? seconds, double? width}) {
    showMaterialToast(context, message,
        color: color, seconds: seconds, width: width);
  }

  @override
  void initState() {
    addressScreenController.getAddressListApi();
    // Initialize the reactive selected address
    addressScreenController.selectedAddress.value =
        AppConstants().getSelectedAddress();
    super.initState();
    List<CityModel> cityList = AppConstants().getCityList();
    if (cityList.isNotEmpty) {
      addressScreenController.cityList.addAll(cityList);
    }
  }

  bool _isCurrentlySelected(AddressList address) {
    AddressList? selected = addressScreenController.selectedAddress.value;
    if (selected == null) return false;
    return selected.id == address.id;
  }

  Future<void> _setAsCurrentAddress(AddressList address, {showtoastandgoback = true}) async {
    print('🏠 Setting address ID ${address.id} as current address');
    String? cartPincode = AppConstants().getCartPincode();
    print('🛒 Current cart pincode: $cartPincode');
    if (cartPincode != null && cartPincode != address.pincode) {
      // Wait for user action
      final confirmed = await Get.dialog<bool>(
        CommonDialog(
          title: 'warning'.tr,
          description:
          'changing_address_warning'.tr,
          tapNoText: 'no'.tr,
          tapYesText: 'yes'.tr,
          onTapNo: () => Get.back(result: false),
          onTapYes: () => Get.back(result: true),
        ),
      );

      // If user pressed "No" or dismissed dialog, stop execution
      if (confirmed != true) return;
      // On "Yes" -> clear cart
      MyCartScreenController cartController =
      Get.isRegistered<MyCartScreenController>()
          ? Get.find<MyCartScreenController>()
          : Get.put(MyCartScreenController());
      await cartController.callClearCartApi(showLoading: false);
      cartController.dbHelper.clearAllRecord();

      if(widget.isFromCart && widget.callback != null){
        // widget.callback!();
        widget.callback?.call();
      }
    }

    // ✅ Only continues here if user confirmed or no cart conflict
    AppConstants().setSelectedAddress(address);
    AppConstants().setCurrentAddress(address);
    addressScreenController.selectedAddress.value =
        address; // Update reactive variable
    setState(() {}); // Refresh UI to show selection

    if(showtoastandgoback) {
      showMaterialToastAndGoBack(context, "Address Updated");
    }

    try {
      if (Get.isRegistered<HomeScreenController>()) {
        HomeScreenController homeScreenController =
            Get.find<HomeScreenController>();
        homeScreenController
            .updateDisplayAddress(); // Update the reactive address
        homeScreenController.callHomeApi();
        homeScreenController.update();
      }
    } catch (e) {
      print('HomeScreenController not found: $e');
    }

    if (widget.pickupAddress != null) {
      Get.back();
      widget.pickupAddress?.call(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('address_list'.tr, style: semiBoldBlack_18),
      ),
      body: Obx(
        () => addressScreenController.isLoading.value
            ? Container()
            : Column(
                children: [
                  // Conditionally show buttons based on isFromCart
                  if (false)    // Temporarily hide current location button (!widget.isFromCart)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              // addressScreenController.fetchCurrentLocationAsAddress();
                              Get.to(() => GetAddressMapScreen(
                                    callBack: (address) {
                                      setState(() {
                                        addressScreenController
                                            .currentAddress.value.id = 0;
                                        addressScreenController
                                                .currentAddress.value.address =
                                            address['address'].toString();
                                        addressScreenController
                                            .currentAddress
                                            .value
                                            .latitude = address['latitude'];
                                        addressScreenController
                                            .currentAddress
                                            .value
                                            .longitude = address['longitude'];
                                        addressScreenController.currentAddress
                                            .value.pincode = address['pincode'];

                                        // Set house number if available
                                        if (address['house_no'] != null &&
                                            address['house_no']
                                                .toString()
                                                .isNotEmpty) {
                                          addressScreenController.currentAddress
                                                  .value.houseNo =
                                              address['house_no'].toString();
                                        } else {
                                          addressScreenController.currentAddress
                                              .value.houseNo = "-";
                                        }

                                        // Set area if available
                                        if (address['area'] != null &&
                                            address['area']
                                                .toString()
                                                .isNotEmpty) {
                                          addressScreenController.currentAddress
                                                  .value.location =
                                              address['area'].toString();
                                        } else {
                                          addressScreenController.currentAddress
                                              .value.location = "-";
                                        }

                                        // Set landmark if available
                                        if (address['landmark'] != null &&
                                            address['landmark']
                                                .toString()
                                                .isNotEmpty) {
                                          addressScreenController.currentAddress
                                                  .value.landmark =
                                              address['landmark'].toString();
                                        } else {
                                          addressScreenController.currentAddress
                                              .value.landmark = "-";
                                        }

                                        // Set city - create temporary city model if not found in list
                                        String incomingCity =
                                            address['city'].toString().trim();
                                        debugPrint(
                                            '🏙️ Received city from map: "$incomingCity"');

                                        if (incomingCity.isNotEmpty) {
                                          // Try to find exact match first
                                          CityModel? matchedCity;
                                          for (var element
                                              in addressScreenController
                                                  .cityList) {
                                            if (element.cityName!
                                                    .toLowerCase() ==
                                                incomingCity.toLowerCase()) {
                                              matchedCity = element;
                                              debugPrint(
                                                  '✅ City matched from list: ${element.cityName}');
                                              break;
                                            }
                                          }

                                          if (matchedCity != null) {
                                            addressScreenController
                                                .currentAddress
                                                .value
                                                .city = matchedCity.cityName;
                                          } else {
                                            // Create a temporary city model with the map city name
                                            debugPrint(
                                                'ℹ️ Creating temporary city model for: "$incomingCity"');
                                            addressScreenController
                                                .currentAddress
                                                .value
                                                .city = incomingCity;
                                          }
                                        } else {
                                          addressScreenController
                                              .currentAddress.value.city = "-";
                                        }

                                        // Debug log to verify all fields are populated
                                        debugPrint(
                                            '📝 Address Form Fields Populated:');
                                        debugPrint(
                                            'Complete Address: ${addressScreenController.currentAddress.value.address}');
                                        debugPrint(
                                            'House No: ${addressScreenController.currentAddress.value.houseNo}');
                                        debugPrint(
                                            'Area: ${addressScreenController.currentAddress.value.location}');
                                        debugPrint(
                                            'Landmark: ${addressScreenController.currentAddress.value.landmark}');
                                        debugPrint(
                                            'Pin Code: ${addressScreenController.currentAddress.value.pincode}');
                                        debugPrint(
                                            'Selected City: ${addressScreenController.currentAddress.value.city ?? "None"}');

                                        AppConstants().setCurrentAddress(addressScreenController.currentAddress.value);
                                        addressScreenController.selectedAddress.value = addressScreenController.currentAddress.value;
                                        setState(() {});
                                        _setAsCurrentAddress(addressScreenController.currentAddress.value, showtoastandgoback: false);
                                        AppConstants().showToast("Current location set as active address");
                                      });
                                    },
                                  ));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.h, horizontal: 10.w),
                              margin: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.r)),
                                border: Border.all(color: borderColor),
                                color: cardBgColor,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.my_location, color: Colors.black),
                                  SizedBox(width: 3.w),
                                  Text("Use Current Location",
                                      style: semiBoldBlack_10),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final result =
                                  await Get.to(() => const AddAddressScreen());
                              // Refresh UI and selected address when returning from add new address
                              addressScreenController.selectedAddress.value =
                                  AppConstants().getSelectedAddress();
                              setState(() {});

                              // Show toast if address was successfully added
                              if (result != null && result['success'] == true) {
                                showMaterialToast(
                                  context,
                                  result['message'] ??
                                      'Address added successfully',
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5.h, horizontal: 10.w),
                              margin: EdgeInsets.symmetric(horizontal: 10.w),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.r)),
                                border: Border.all(color: borderColor),
                                color: primaryColor,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: Colors.white),
                                  SizedBox(width: 3.w),
                                  Text("Add new address",
                                      style: semiBoldWhite_10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // Only show Add new address button when coming from cart
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: GestureDetector(
                        onTap: () async {
                          final result =
                              await Get.to(() => const AddAddressScreen());
                          // Refresh UI and selected address when returning from add new address
                          addressScreenController.selectedAddress.value =
                              AppConstants().getSelectedAddress();
                          setState(() {});

                          // Show toast if address was successfully added
                          if (result != null && result['success'] == true) {
                            showMaterialToast(
                                context,
                                result['message'] ??
                                    'Address added successfully');
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              vertical: 8.h, horizontal: 15.w),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.r)),
                            border: Border.all(color: borderColor),
                            color: primaryColor,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 8.w),
                              Text("Add new address", style: semiBoldWhite_12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.w, vertical: 10.h),
                      children: [
                        // ✅ Current Address (only if set)
                        // if (AppConstants().isCurrentAddressSet()) ...[
                        //   Text("Current Address", style: semiBoldGray_10),
                        //   SizedBox(height: 8.h),
                        //   _buildAddressCard(AppConstants().getCurrentAddress()!, isCurrent: true),
                        //   SizedBox(height: 16.h),
                        // ],

                        // Saved address list
                        addressScreenController.addressList.isEmpty
                            ? Center(
                                child: PaddingHorizontal15(
                                  top: Get.height * 0.15,
                                  child: NoDataFoundWidget(
                                    title: 'no_address_added_yet'.tr,
                                    description:
                                        'no_address_added_yet_description',
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Saved Address", style: semiBoldGray_10),
                                  SizedBox(height: 8.h),
                                  ...addressScreenController.addressList
                                      .map((address) {
                                    return _buildAddressCard(address);
                                  }),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAddressCard(AddressList address, {bool isCurrent = false}) {
    return GestureDetector(
      onTap: () async {
        if (isCurrent) {
          _setAsCurrentAddress(address);
        } else {
          // if (widget.pickupAddress != null) {
          //   AppConstants().setSelectedAddress(address);
          //   addressScreenController.selectedAddress.value = address;
          //   setState(() {});
          //   Get.back();
          //   widget.pickupAddress?.call(address);
          // } else {
            _setAsCurrentAddress(address);
          // }
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          color: Colors.white,
          border: _isCurrentlySelected(address)
              ? Border.all(color: primaryColor, width: 2.w)
              : null,
          boxShadow: [
            BoxShadow(
              color: _isCurrentlySelected(address)
                  ? primaryColor.withOpacity(0.3)
                  : borderColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address type badge
            if (address.addressType != null && address.addressType!.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 5.h, horizontal: 15.w),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(16.r)),
                  ),
                  child: Text('${address.addressType}', style: mediumWhite_11),
                ),
              ),

            SizedBox(height: 10.h),

            // Address row
            Container(
              width: Get.width,
              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 6.w),
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(locationPinIcon, color: primaryColor),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      '${address.address}'
                      '${address.houseNo != null && address.houseNo!.isNotEmpty ? ', ${address.houseNo}' : ''}'
                      '${address.landmark != null && address.landmark!.isNotEmpty ? ', ${address.landmark}' : ''}'
                      '${address.location != null && address.location!.isNotEmpty ? ', ${address.location}' : ''}',
                      style: mediumBlack_11,
                    ),
                  ),
                ],
              ),
            ),

            // City + Pincode + Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 5.h, horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: 'City : ',
                                    style: TextStyle(
                                        fontFamily: semiBold,
                                        fontSize: 10.sp,
                                        color: greyColor2)),
                                TextSpan(
                                    text: address.city ?? "",
                                    style: TextStyle(
                                        fontFamily: semiBold,
                                        fontSize: 12.sp,
                                        color: greyColor2)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 5.h, horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Pincode : ',
                                    style: TextStyle(
                                        fontFamily: semiBold,
                                        fontSize: 10.sp,
                                        color: greyColor2)),
                                TextSpan(
                                    text: address.pincode ?? "",
                                    style: TextStyle(
                                        fontFamily: semiBold,
                                        fontSize: 12.sp,
                                        color: greyColor2)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit + Delete (only for saved addresses)
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () async {
                      final result = await Get.to(
                          () => AddAddressScreen(addressList: address));
                      addressScreenController.selectedAddress.value =
                          AppConstants().getSelectedAddress();
                      if (result != null && result['success'] == true) {
                        showMaterialToast(
                            context,
                            result['message'] ??
                                'Address updated successfully');
                        AppConstants().clearCurrentAddress();
                      }
                      setState(() {});
                    },
                    child: Container(
                      height: 25.h,
                      width: 25.h,
                      padding: EdgeInsets.all(3.h),
                      margin: EdgeInsets.symmetric(horizontal: 5.w),
                      decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(8.r)),
                      child: Center(
                          child: SvgPicture.asset(renameIcon,
                              height: 15.h, width: 15.h)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (isCurrent) {
                        // Clear current address
                        AppConstants().clearCurrentAddress();

                        // If the cleared one was also selected, reassign
                        final saved = addressScreenController.addressList;
                        if (_isCurrentlySelected(
                            AppConstants().getCurrentAddress() ??
                                AddressList())) {
                          if (saved.isNotEmpty) {
                            AppConstants().setSelectedAddress(saved.first);
                            addressScreenController.selectedAddress.value =
                                saved.first;
                          } else {
                            AppConstants().clearSelectedAddress();
                            addressScreenController.selectedAddress.value =
                                null;
                            try {
                              if (Get.isRegistered<HomeScreenController>()) {
                                HomeScreenController homeScreenController =
                                    Get.find<HomeScreenController>();
                                homeScreenController
                                    .updateDisplayAddress(); // Update the reactive address
                                homeScreenController.update();
                              }
                            } catch (e) {
                              print('HomeScreenController not found: $e');
                            }
                          }
                        }

                        setState(() {}); // refresh UI
                      } else {
                        Get.dialog(CommonDialog(
                          title: 'Delete'.tr,
                          description: 'delete_address'.tr,
                          tapNoText: 'cancel'.tr,
                          tapYesText: 'confirm'.tr,
                          onTapNo: () => Get.back(),
                          onTapYes: () {
                            Get.back();
                            addressScreenController.addressDeleteApi(
                                id: address.id.toString());
                          },
                        ));
                      }
                    },
                    child: Container(
                      height: 25.h,
                      width: 25.h,
                      decoration: BoxDecoration(
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(8.r)),
                      child: Center(
                        child:
                            SvgPicture.asset(delete, height: 15.h, width: 15.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
