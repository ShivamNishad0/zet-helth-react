import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomButton.dart';
import 'package:zet_health/Models/AddressListModel.dart';
import '../../../../CommonWidget/CallBackDialogWithSearch.dart';
import '../../../../CommonWidget/CustomAppbar.dart';
import '../../../../CommonWidget/CustomTextField2.dart';
import '../../../../Helper/AppConstants.dart';
import '../../../../Helper/AssetHelper.dart';
import '../../../../Helper/ColorHelper.dart';
import '../../../../Helper/StyleHelper.dart';
import '../../../../Models/CityModel.dart';
import 'AddAddressScreenController.dart';
import 'get_address_map_screen.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key,this.addressList});
  final AddressList? addressList;
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {

  AddAddressScreenController addressScreenController = Get.put(AddAddressScreenController());

  bool isCityAutoSelected = false;

  @override
  void initState() {
    List<CityModel> cityList = AppConstants().getCityList();
    if(cityList.isNotEmpty) {
      addressScreenController.cityList.addAll(cityList);
    }
    addressScreenController.clearData();
    addressScreenController.setData(widget.addressList);

    addressScreenController.addressController.addListener(() {
    if (addressScreenController.addressController.text.trim().isEmpty && isCityAutoSelected) {
      setState(() {
        isCityAutoSelected = false;
        addressScreenController.selectedCity = null;
      });
    }
  });

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppbar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          isLeading: true,
          title: Text('add_address'.tr,style: semiBoldBlack_18),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15.w,vertical: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 12.h),
            width: Get.width,
            decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.all(Radius.circular(16.r)),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  )
                ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('address_type'.tr, style: semiBoldBlack_14),
                Container(
                  height: 40.h,
                  width: Get.width,
                  margin: EdgeInsets.only(top: 5.h, bottom: 15.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.all(Radius.circular(15.r)),
                    border: Border.all(color: borderColor.withOpacity(0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: addressScreenController.selectedAddressType.isEmpty ? null : addressScreenController.selectedAddressType,
                      hint: Text(
                        addressScreenController.selectedAddressType.isEmpty ? 'select_address_type'.tr : addressScreenController.selectedAddressType, 
                        style: mediumBlack_14,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      icon: Container(
                        margin: EdgeInsets.only(left: 8.w),
                        child: SvgPicture.asset(
                          dropDownIcon, 
                          height: 16.h, 
                          width: 16.w,
                          colorFilter: ColorFilter.mode(blackColor, BlendMode.srcIn),
                        ),
                      ),
                      items: addressScreenController.addressTypeList.map((String items) {
                        return DropdownMenuItem<String>(
                          value: items,
                          child: Text(
                            items, 
                            style: mediumBlack_12,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          addressScreenController.selectedAddressType = value!;
                        });
                      },
                    ),
                  ),
                ),
                CustomTextField2(
                  controller: addressScreenController.addressController,
                  title: 'complete_address'.tr,
                  hintText: 'enter_address'.tr,
                  topMargin: 5.h,
                  filled: true,
                  bottomMargin: 15.h,
                  textInputAction: TextInputAction.next,
                  suffixIconMaxWidth: 90.w,
                  suffixIconMinWidth: 70.w,
                   onChanged: (val) {
                      if (val.trim().isEmpty && isCityAutoSelected) {
                        setState(() {
                          isCityAutoSelected = false;
                          addressScreenController.selectedCity = null;
                        });
                      }
                    },
                    titleSuffixIcon: GestureDetector(
                    onTap: (){
                      Get.to(()=> GetAddressMapScreen(
                        callBack: (address){
                          setState(() {
                            isCityAutoSelected = true;
                            addressScreenController.addressController.text = address['address'].toString();
                            addressScreenController.lateController.text = address['latitude'];
                            addressScreenController.longController.text = address['longitude'];
                            addressScreenController.pinCodeController.text = address['pincode'];
                            
                            // Set house number if available
                            if (address['house_no'] != null && address['house_no'].toString().isNotEmpty) {
                              addressScreenController.houseNoController.text = address['house_no'].toString();
                            }
                            
                            // Set area if available
                            if (address['area'] != null && address['area'].toString().isNotEmpty) {
                              addressScreenController.areaController.text = address['area'].toString();
                            }
                            
                            // Set landmark if available
                            if (address['landmark'] != null && address['landmark'].toString().isNotEmpty) {
                              addressScreenController.landMarkController.text = address['landmark'].toString();
                            }
                            
                            // Set city - create temporary city model if not found in list
                            String incomingCity = address['city'].toString().trim();
                            debugPrint('🏙️ Received city from map: "$incomingCity"');
                            
                            if (incomingCity.isNotEmpty) {
                              // Try to find exact match first
                              CityModel? matchedCity;
                              for (var element in addressScreenController.cityList) {
                                if (element.cityName!.toLowerCase() == incomingCity.toLowerCase()) {
                                  matchedCity = element;
                                  debugPrint('✅ City matched from list: ${element.cityName}');
                                  break;
                                }
                              }
                              
                              if (matchedCity != null) {
                                addressScreenController.selectedCity = matchedCity;
                              } else {
                                // Create a temporary city model with the map city name
                                debugPrint('ℹ️ Creating temporary city model for: "$incomingCity"');
                                addressScreenController.selectedCity = CityModel(
                                  id: '0', // Temporary ID
                                  cityName: incomingCity,
                                  stateId: 0,
                                  pincodes: '',
                                  status: 1,
                                  createdDate: '',
                                );
                              }
                            }
                            
                            // Debug log to verify all fields are populated
                            debugPrint('📝 Address Form Fields Populated:');
                            debugPrint('Complete Address: ${addressScreenController.addressController.text}');
                            debugPrint('House No: ${addressScreenController.houseNoController.text}');
                            debugPrint('Area: ${addressScreenController.areaController.text}');
                            debugPrint('Landmark: ${addressScreenController.landMarkController.text}');
                            debugPrint('Pin Code: ${addressScreenController.pinCodeController.text}');
                            debugPrint('Selected City: ${addressScreenController.selectedCity?.cityName ?? "None"}');
                          });
                        },
                      ));
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 6.w),
                      alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: primaryColor),
                            borderRadius: BorderRadius.circular(20.r)
                        ),
                        child: Text('auto_fetch'.tr,style: TextStyle(fontFamily: semiBold,fontSize: 11.sp,color: primaryColor))
                    ),
                  ),
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: CustomTextField2(
                //         controller: addressScreenController.lateController,
                //         title: 'latitude'.tr,
                //         hintText: '',
                //         topMargin: 5.h,
                //         filled: true,
                //         readOnly: true,
                //         textInputAction: TextInputAction.next,
                //       ),
                //     ),
                //     SizedBox(width: 15.w),
                //     Expanded(
                //       child: CustomTextField2(
                //         controller: addressScreenController.longController,
                //         title: 'longitude'.tr,
                //         hintText: '',
                //         topMargin: 5.h,
                //         filled: true,
                //         readOnly: true,
                //         textInputAction: TextInputAction.next,
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(height: 15.h),
                CustomTextField2(
                  controller: addressScreenController.houseNoController,
                  title: 'house_flat_blockno'.tr,
                  hintText: 'enter_house_flat_blockno'.tr,
                  topMargin: 5.h,
                  filled: true,
                  bottomMargin: 15.h,
                  textInputAction: TextInputAction.next,
                ),
                CustomTextField2(
                  controller: addressScreenController.landMarkController,
                  title: 'nearby_landmark'.tr,
                  hintText: 'enter_landmark'.tr,
                  topMargin: 5.h,
                  filled: true,
                  bottomMargin: 15.h,
                  textInputAction: TextInputAction.next,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField2(
                        controller: addressScreenController.areaController,
                        title: 'area'.tr,
                        hintText: 'enter_area'.tr,
                        topMargin: 5.h,
                        filled: true,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: CustomTextField2(
                        controller: addressScreenController.pinCodeController,
                        title: 'pin_code'.tr,
                        hintText: 'enter_pincode'.tr,
                        topMargin: 5.h,
                        maxLength: 6,
                        filled: true,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Text('city'.tr, style: semiBoldBlack_14),
                GestureDetector(
                  onTap: isCityAutoSelected
                  ? null
                  : () {
                    Get.dialog(CallBackDialogWithSearch(
                      type: 1,
                      callBack: (city) {
                        setState(() {
                          addressScreenController.selectedCity = city;
                        });
                      },
                    ));
                  },
                child: AbsorbPointer(
                  absorbing: isCityAutoSelected,
                  child: Container(
                    height: 40.h,
                    width: Get.width,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                    margin: EdgeInsets.only(top: 5.h),
                    decoration: BoxDecoration(
                      color: isCityAutoSelected ? Colors.grey.shade300 : cardBgColor,
                      borderRadius: BorderRadius.all(Radius.circular(15.r)),
                      border: Border.all(color: borderColor.withOpacity(0.5)), // Added border here
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(addressScreenController.selectedCity==null?
                          'select_city'.tr : addressScreenController.selectedCity!.cityName.toString(),
                              style: isCityAutoSelected ? regularBlack_14.copyWith(color: Colors.grey) : mediumBlack_14,
                          ),
                        ),
                        SvgPicture.asset(dropDownIcon, color: blackColor, height: 18.h, width: 18.w),
                      ],
                    )
                  ),
                 ),
                ),
                CustomButton(
                  topMargin: 20.h,
                  borderRadius: 20.r,
                  height: 39.h,
                  text: 'save_changes'.tr,
                  onTap: () {
                    if(addressScreenController.isValidate()) {
                      addressScreenController.callAddAddressApi(widget.addressList);
                    }
                  }
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}