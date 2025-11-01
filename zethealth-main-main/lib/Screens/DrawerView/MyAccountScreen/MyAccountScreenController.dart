import 'package:get/get.dart';
import 'package:zet_health/Models/DrawerModel.dart';
import 'package:zet_health/Screens/DrawerView/AddressScreen/AddressScreen.dart';
import 'package:zet_health/Screens/DrawerView/FamilyMemberScreen/FamilyMemberScreen.dart';
import 'package:zet_health/Screens/DrawerView/OrderHistoryScreen/OrderHistoryScreen.dart';
import 'package:zet_health/Screens/DrawerView/PrescriptionScreen/PrescriptionScreen.dart';
import 'package:zet_health/Screens/WalletScreen/wallet_screen.dart';

import '../../../Helper/AppConstants.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Models/UserDetailModel.dart';
import '../NavigationDrawerController.dart';

class AccountScreenController extends GetxController {
  RxList<DrawerModel> accountItemList = <DrawerModel>[].obs;
  Rx<UserDetailModel> userModel = AppConstants().getUserDetails().obs;

  @override
  void onInit() {
    super.onInit();
    loadAccountItems();
  }


  void loadAccountItems() {
    NavigationDrawerController navigationDrawerController =
    Get.put(NavigationDrawerController());
    accountItemList.value = [
      // DrawerModel(
      //     label: 'Edit Profile',
      //     image: editProfileIcon,
      //     onclick: () {
      //       AppConstants().loadWithCanBack(const EditProfileScreen());
      //     }),
      DrawerModel(
          label: 'Family Members',
          image: familyMembersIcon,
          onclick: () {
            AppConstants().loadWithCanBack(const FamilyMemberScreen());
          }),
      DrawerModel(
          label: 'Address',
          image: locationPinIcon,
          onclick: () {
            AppConstants().loadWithCanBack(const AddressScreen());
          }),
      DrawerModel(
          label: 'Order History',
          image: orderHistoryIcon,
          onclick: () {
            AppConstants().loadWithCanBack(const OrderHistoryScreen());
          }),
      DrawerModel(
          label: 'View Prescriptions',
          image: reportIcon,
          onclick: () {
            AppConstants().loadWithCanBack(const PrescriptionScreen());
            // if(homeScreenController.prescriptionList[0].type! == "Package") {
            //   AppConstants().loadWithCanBack(AvailableLabsScreen(packageModel: homeScreenController.prescriptionList[0].packageModel, type: AppConstants.PACKAGE));
            // }
            // else if(homeScreenController.prescriptionList[0].type! == "LabTestProfile") {
            //   AppConstants().loadWithCanBack(AvailableLabsScreen(profileModel: homeScreenController.prescriptionList[0].profileModel, type: AppConstants.PROFILE));
            // }
            // else if(homeScreenController.prescriptionList[0].type! == "LabTest") {
            //   AppConstants().loadWithCanBack(AvailableLabsScreen(listLabTest: homeScreenController.prescriptionList[0].labTestList, type: AppConstants.MULTIPLE_TEST));
            // }
          }),
      DrawerModel(
          label: 'Wallet',
          image: orderHistoryIcon,
          onclick: () {
            AppConstants().loadWithCanBack(const WalletScreen());
          }),
      DrawerModel(
          label: 'My Reports',
          image: reportIcon,
          onclick: () {
            Get.back();
            navigationDrawerController.pageIndex.value = 3;
          }),
    ];
  }
}
