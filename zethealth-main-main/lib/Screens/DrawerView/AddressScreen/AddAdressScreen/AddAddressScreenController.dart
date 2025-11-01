import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Models/AddressListModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:zet_health/Screens/DrawerView/AddressScreen/AddressScreenController.dart';
import 'package:zet_health/Screens/HomeScreen/HomeScreenController.dart';
import '../../../../Models/CityModel.dart';

class AddAddressScreenController extends GetxController {
  RxList<CityModel> cityList = <CityModel>[].obs;
  CityModel? selectedCity;

  TextEditingController addressController = TextEditingController();
  TextEditingController lateController = TextEditingController();
  TextEditingController longController = TextEditingController();
  TextEditingController houseNoController = TextEditingController();
  TextEditingController landMarkController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  List<String> addressTypeList = ['Home','Office','Other'];
  String selectedAddressType = "Home";

  setData(AddressList? addressList){
    if(addressList!=null){
      addressController.text = addressList.address.toString();
      lateController.text = addressList.latitude.toString();
      longController.text = addressList.longitude.toString();
      houseNoController.text = addressList.houseNo.toString();
      landMarkController.text = addressList.landmark.toString();
      areaController.text = addressList.location.toString();
      pinCodeController.text = addressList.pincode.toString();
      if(addressList.addressType!=null && addressList.addressType!.isNotEmpty){
        selectedAddressType = addressList.addressType.toString();
      }
      for (var element in cityList) {
        if(element.cityName == addressList.city){
          selectedCity = element;
        }
      }
    }
  }

  clearData(){
    addressController = TextEditingController();
    lateController = TextEditingController();
    longController = TextEditingController();
    houseNoController = TextEditingController();
    landMarkController = TextEditingController();
    areaController = TextEditingController();
    pinCodeController = TextEditingController();
    selectedCity = null;
  }

  callAddAddressApi(AddressList? addressList) {
    Map<String, dynamic> params = {
      'id': addressList!=null ? addressList.id.toString() : '0',
      'address': addressController.text.trim(),
      'house_no': houseNoController.text.trim().isNotEmpty? houseNoController.text.trim():"-",
      'landmark': landMarkController.text.trim().isNotEmpty? landMarkController.text.trim():"-",
      'location': areaController.text.trim(),
      'pincode': pinCodeController.text.trim(),
      'city': selectedCity!.cityName.toString(),
      'state': '-',
      'longitude': longController.text.trim().isNotEmpty ? longController.text.trim() : '0',
      'latitude': lateController.text.trim().isNotEmpty ? lateController.text.trim() : '0',
      'address_type': selectedAddressType,
    };

    WebApiHelper().callFormDataPostApi(null, AppConstants.addAddress, params, true).then((response) {
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if (statusModel.status!) {
          // Create AddressList object from the form data
          AddressList updatedAddress = AddressList(
            id: addressList?.id ?? (statusModel.addressList != null && statusModel.addressList!.isNotEmpty 
                ? statusModel.addressList!.first.id 
                : null), // Use existing ID for edit, or new ID from API response
            address: addressController.text.trim(),
            houseNo: houseNoController.text.trim().isNotEmpty ? houseNoController.text.trim() : "-",
            landmark: landMarkController.text.trim().isNotEmpty ? landMarkController.text.trim() : "-",
            location: areaController.text.trim(),
            pincode: pinCodeController.text.trim(),
            city: selectedCity!.cityName.toString(),
            state: '-',
            longitude: longController.text.trim().isNotEmpty ? longController.text.trim() : '0',
            latitude: lateController.text.trim().isNotEmpty ? lateController.text.trim() : '0',
            addressType: selectedAddressType,
          );
          
          bool isEditMode = addressList != null;
          bool wasSelectedAddress = false;
          
          if (isEditMode) {
            // Check if the edited address was the currently selected one
            AddressList? currentSelected = AppConstants().getSelectedAddress();
            wasSelectedAddress = currentSelected?.id == addressList.id;
          }
          
          print('=== ADDRESS ${isEditMode ? 'UPDATED' : 'ADDED'} ===');
          print('Address: ${updatedAddress.address}');
          print('City: ${updatedAddress.city}');
          print('Pincode: ${updatedAddress.pincode}');
          print('Address Type: ${updatedAddress.addressType}');
          print('Is Edit Mode: $isEditMode');
          print('Was Selected Address: $wasSelectedAddress');
          print('Set as current selected: ${!isEditMode || wasSelectedAddress}');
          print('Updated Address ID: ${updatedAddress.id}');
          print('=====================================');
          
          AddressScreenController addressScreenController = Get.find<AddressScreenController>();
          
          // Refresh the address list first, then set the selected address
          addressScreenController.getAddressListApi(onComplete: () {
            // After the list is refreshed, set the address as selected if needed
            if (!isEditMode || wasSelectedAddress) {
              // Find the address in the refreshed list by matching key fields
              AddressList? addressToSelect;
              for (var addr in addressScreenController.addressList) {
                if (addr.address == updatedAddress.address &&
                    addr.pincode == updatedAddress.pincode &&
                    addr.city == updatedAddress.city &&
                    addr.addressType == updatedAddress.addressType) {
                  addressToSelect = addr;
                  break;
                }
              }
              
              if (addressToSelect != null) {
                AppConstants().setSelectedAddress(addressToSelect);
                addressScreenController.selectedAddress.value = addressToSelect; // Update reactive variable
                print('✅ Selected address set with correct ID: ${addressToSelect.id}');
                 try {
                  if (Get.isRegistered<HomeScreenController>()) {
                    HomeScreenController homeScreenController = Get.find<HomeScreenController>();
                    homeScreenController.updateDisplayAddress();
                    print('🏠 HomeScreen address updated after setting selected address');
                  }
                } catch (e) {
                  print('Error updating HomeScreen: $e');
                }
              } else {
                print('⚠️ Could not find address in refreshed list to select');
              }
            }
          });

          // Go back and pass the success message to be shown in AddressScreen
          Get.back(result: {'success': true, 'message': statusModel.message});
        } else {
          showToast(message: '${statusModel.message}');
        }
      }
    });
  }

  bool isValidate() {
    if (addressController.text.trim().isEmpty) {
      showToast(message: 'please_enter_address'.tr);
      return false;
    }
    // Note: Latitude and longitude are optional - they're only filled when using auto-fetch
    // else if (lateController.text.trim().isEmpty) {
    //   showToast(message: 'please_select_address'.tr);
    //   return false;
    // }
    // else if (longController.text.trim().isEmpty) {
    //   showToast(message: 'please_select_address'.tr);
    //   return false;
    // }
    // else if (houseNoController.text.trim().isEmpty) {
    //   showToast(message: 'please_enter_house_no'.tr);
    //   return false;
    // }
    // else if (landMarkController.text.trim().isEmpty) {
    //   showToast(message: 'please_enter_landmark'.tr);
    //   return false;
    // }
    else if (areaController.text.trim().isEmpty) {
      showToast(message: 'please_enter_area'.tr);
      return false;
    } else if (pinCodeController.text.trim().isEmpty) {
      showToast(message: 'please_enter_pin_code'.tr);
      return false;
    }
    else if (pinCodeController.text.trim().length<6) {
      showToast(message: 'please_enter_valid_pin_code'.tr);
      return false;
    }
    else if (selectedCity == null) {
      showToast(message: 'please_select_city'.tr);
      return false;
    }
    else {
      return true;
    }
  }
}
