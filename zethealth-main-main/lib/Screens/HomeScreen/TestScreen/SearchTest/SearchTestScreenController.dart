import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/commonApis.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import '../../../../Helper/database_helper.dart';
import '../../../../Models/CartModel.dart';
import '../../../../Models/CityModel.dart';
import '../../../../Models/SearchTestModel.dart';
import '../../../../Models/StatusModel.dart';
import '../../../../Models/custom_cart_model.dart';

class SearchTestScreenController extends GetxController {

  TextEditingController searchController = TextEditingController();
  RxInt selectedFilter = 0.obs;
  RxString queryText = ''.obs;

  CustomCartModel? customCartModel;

  RxList<CustomCartModel> testList = <CustomCartModel>[].obs;
  RxList<CustomCartModel> tempTestList = <CustomCartModel>[].obs;

  RxList<CustomCartModel> packageList = <CustomCartModel>[].obs;
  RxList<CustomCartModel> tempPackageList = <CustomCartModel>[].obs;

  RxList<CustomCartModel> profileList = <CustomCartModel>[].obs;
  RxList<CustomCartModel> tempProfileList = <CustomCartModel>[].obs;
  final DBHelper dbHelper = DBHelper();
  CityModel? selectedCity;
  List<CustomCartModel> cartList = [];

  Rx<SearchTestModel> searchTestModel = SearchTestModel().obs;
  var cartCount = 0.obs;
  RxBool isLoading = true.obs;

// New additions:
  RxList<CustomCartModel> suggestionList = <CustomCartModel>[].obs;
  RxBool isSearching = false.obs;   // true while typing / showing suggestions
  RxBool showResults = false.obs;   // true after submit or suggestion tap

  void updateSuggestions(String query) {
    isSearching.value = query.isNotEmpty;
    showResults.value = false;
    suggestionList.clear();

    if (query.isEmpty) return;

    if (selectedFilter.value == 0) {
      suggestionList.addAll(tempTestList.where((e) =>
          e.name!.toLowerCase().contains(query.toLowerCase())));
    } else if (selectedFilter.value == 1) {
      suggestionList.addAll(tempPackageList.where((e) =>
          e.name!.toLowerCase().contains(query.toLowerCase())));
    } else {
      suggestionList.addAll(tempProfileList.where((e) =>
          e.name!.toLowerCase().contains(query.toLowerCase())));
    }
  }

  void submitSearch(String query) {
    if (query.isEmpty) {
      isSearching.value = false;
      showResults.value = false;
      return;
    }

    isSearching.value = false;
    showResults.value = true;

    // Use your existing filter logic
    filterList(query);
  }

  void selectSuggestion(CustomCartModel item) {
    searchController.text = item.name ?? "";
    isSearching.value = false;
    showResults.value = true;
    queryText.value = item.name ?? "";
    FocusManager.instance.primaryFocus?.unfocus();

    filterList(item.name ?? "");
  }

  void clearSearch() {
    searchController.clear();
    suggestionList.clear();
    isSearching.value = false;
    showResults.value = false;
    FocusManager.instance.primaryFocus?.unfocus();
    queryText.value = '';

    // Reset to full list (so blurred home contents can reappear)
    testList.clear();
    testList.addAll(tempTestList);

    packageList.clear();
    packageList.addAll(tempPackageList);

    profileList.clear();
    profileList.addAll(tempProfileList);
  }

  searchByCityApi({CartModel? cartItem, required bool isSelectedItem}) {
    searchTestModel.value = SearchTestModel();
    testList.value = <CustomCartModel>[];
    tempTestList.value = <CustomCartModel>[];
    packageList.value = <CustomCartModel>[];
    tempPackageList.value = <CustomCartModel>[];
    profileList.value = <CustomCartModel>[];
    tempProfileList.value = <CustomCartModel>[];

    Map<String, dynamic> params = {
      "city_id": selectedCity != null ? selectedCity!.id : "0",
      "lab_id": cartItem == null ? "0" : cartItem.labId.toString(),
    };

    WebApiHelper().callFormDataPostApi(null, AppConstants.searchByCity, params, false).then((response) async {
      if(response != null) {
        isLoading.value = false;
        SearchTestModel result = SearchTestModel.fromJson(jsonDecode(response));
        print("Response: $response");
        if(result.status!) {
          testList.value = <CustomCartModel>[];
          tempTestList.value = <CustomCartModel>[];
          packageList.value = <CustomCartModel>[];
          tempPackageList.value = <CustomCartModel>[];
          profileList.value = <CustomCartModel>[];
          tempProfileList.value = <CustomCartModel>[];
          if(result.searchList != null){
            for(int i=0; i< result.searchList!.length; i++){
              print("searchList: ${result.searchList![i].toJson()}\n");
              print("Address: ${result.searchList![i].toJson()['address']}");

              if(result.searchList![i].test != null && result.searchList![i].test!.isNotEmpty){
                for(int j=0; j< result.searchList![i].test!.length; j++){
                  final test = result.searchList![i].test![j];
                  print("test: ${test.toJson()}");
                  testList.add(
                    CustomCartModel(
                      id: test.id,
                      name: test.name,
                      type: AppConstants.test,
                      price: test.price.toString(),
                      image: test.image.toString(),
                      isFastRequired: test.isFastRequired.toString(),
                      testTime: test.testTime.toString(),
                      isSelected: false,
                      itemDetail: test.itemDetail,
                      profilesDetail: test.profilesDetail,
                      parametersCount: test.parametersCount,
                      parameters: test.parameters,
                      cityId: result.searchList![i].cityId,
                      labId: result.searchList![i].userId,
                      labName: result.searchList![i].userName,
                      labProfile: result.searchList![i].userProfile,
                      labAddress: result.searchList![i].address,
                    )
                  );
                }
              }

              if(result.searchList![i].package != null && result.searchList![i].package!.isNotEmpty){
                for(int j=0; j< result.searchList![i].package!.length; j++){
                  final package = result.searchList![i].package![j];
                  packageList.add(
                    CustomCartModel(
                      id: package.id,
                      name: package.name,
                      type: AppConstants.package,
                      price: package.price.toString(),
                      image: package.image.toString(),
                      isFastRequired: package.isFastRequired.toString(),
                      testTime: package.testTime.toString(),
                      isSelected: false,
                      itemDetail: package.itemDetail,
                      profilesDetail: package.profilesDetail,
                      parametersCount: package.parametersCount,
                      parameters: package.parameters,
                      cityId: result.searchList![i].cityId,
                      labId: result.searchList![i].userId,
                      labName: result.searchList![i].userName,
                      labProfile: result.searchList![i].userProfile,
                      labAddress: result.searchList![i].address,
                    )
                  );
                }
              }

              if(result.searchList![i].profile != null && result.searchList![i].profile!.isNotEmpty){
                for(int j=0; j< result.searchList![i].profile!.length; j++){
                  final profile = result.searchList![i].profile![j];
                  profileList.add(
                    CustomCartModel(
                      id: profile.id,
                      name: profile.name,
                      type: AppConstants.profile,
                      price: profile.price.toString(),
                      image: profile.image.toString(),
                      isFastRequired: profile.isFastRequired.toString(),
                      testTime: profile.testTime.toString(),
                      isSelected: false,
                      itemDetail: profile.itemDetail,
                      profilesDetail: profile.profilesDetail,
                      parametersCount: profile.parametersCount,
                      parameters: profile.parameters,
                      cityId: result.searchList![i].cityId,
                      labId: result.searchList![i].userId,
                      labName: result.searchList![i].userName,
                      labProfile: result.searchList![i].userProfile,
                      labAddress: result.searchList![i].address,
                    )
                  );
                }
              }
            }
          }

          if(isSelectedItem){
            for(int i=0; i <cartList.length; i++){
              for(int k1=0; k1< testList.length; k1++){
                if(cartList[i].id== testList[k1].id && cartList[i].type == AppConstants.test){
                  testList[k1].isSelected = true;
                }
              }
              for(int k1=0; k1<packageList.length; k1++){
                if(cartList[i].id== packageList[k1].id && cartList[i].type == AppConstants.package){
                  packageList[k1].isSelected = true;
                }
              }
              for(int k1=0; k1<profileList.length; k1++){
                if(cartList[i].id== profileList[k1].id && cartList[i].type == AppConstants.profile){
                  profileList[k1].isSelected = true;
                }
              }
            }
          }

          tempTestList.addAll(testList);
          tempPackageList.addAll(packageList);
          tempProfileList.addAll(profileList);
          searchTestModel.value = result;

          for (var cart in cartList) {
  for (var test in testList) {
    if (cart.id == test.id && cart.type == AppConstants.test) {
      test.isSelected = true;
      debugPrint("✅ Synced LabTest from cart: ${test.name}");
    }
  }
  for (var pkg in packageList) {
    if (cart.id == pkg.id && cart.type == AppConstants.package) {
      pkg.isSelected = true;
      debugPrint("✅ Synced Package from cart: ${pkg.name}");
    }
  }
  for (var profile in profileList) {
    if (cart.id == profile.id && cart.type == AppConstants.profile) {
      profile.isSelected = true;
      debugPrint("✅ Synced Profile from cart: ${profile.name}");
    }
  }
}
        }
      }
    });
  }


  clearCartAfterGoingBack({String? type}) {
    WebApiHelper().callGetApi(null, AppConstants.GET_CLEAR_CART_API, true).then((response) {
      if(response != null) {
        EasyLoading.dismiss();
        StatusModel statusModel = StatusModel.fromJson(response);
        if(statusModel.status!) {
          if(type != "Booking") {
            Get.until((route) => route.isFirst);
            // HomeScreenController homeScreenController = Get.put(HomeScreenController());
            // homeScreenController.callHomeApi();
          }
          AppConstants().getStorage.write(AppConstants.isCartExist,false);
        }
      }
    });
  }

callTestWiseLabApi({bool toViewCart = false}) {
  filterList('');
  searchController.text = "";

  // Use selected items if exist, otherwise fallback to cartList
  List<CustomCartModel> selectedTests = testList.where((t) => t.isSelected).toList();
  List<CustomCartModel> selectedPackages = packageList.where((p) => p.isSelected).toList();
  List<CustomCartModel> selectedProfiles = profileList.where((p) => p.isSelected).toList();

  if (selectedTests.isEmpty && selectedPackages.isEmpty && selectedProfiles.isEmpty) {
    selectedTests = cartList.where((c) => c.type == AppConstants.test).toList();
    selectedPackages = cartList.where((c) => c.type == AppConstants.package).toList();
    selectedProfiles = cartList.where((c) => c.type == AppConstants.profile).toList();
    if (selectedTests.isNotEmpty || selectedPackages.isNotEmpty || selectedProfiles.isNotEmpty) {
      customCartModel = cartList.first; // Restore lab info
      debugPrint("⚠️ Using cartList items because nothing is selected");
    } else {
      clearCartAfterGoingBack();
      debugPrint("❌ Cart is empty, using normal remove");

      return;
    }
  }

  String testIds = selectedTests.map((e) => e.id!).join(',');
  String packageNames = selectedPackages.map((e) => e.name!).join(',');
  String profileNames = selectedProfiles.map((e) => e.name!).join(',');

  Map<String, dynamic> params = {
    "test_ids": testIds,
    "city_name": customCartModel!.cityId,
    "package_names": packageNames,
    "profile_names": profileNames,
    "sort_by": "",
  };

  debugPrint("📤 callTestWiseLabApi params: $params");

  WebApiHelper().callFormDataPostApi(null, AppConstants.getLabListV2, params, true).then((response) {
    if(response != null) {
      StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
      if(statusModel.status!) {
        print("StatusModel: ${statusModel.toJson()}\n");
        if(statusModel.labList != null && statusModel.labList!.isNotEmpty) {
          getCartApi(
            labModel: statusModel.labList![0],
            toViewCart: toViewCart,
          );
        }
      }
    }
  });
}

  filterList(String query) {
    print("filterList: $query");
    if(selectedFilter.value == 0) {
      testList.clear();
      if(query.isEmpty) {
        testList.addAll(tempTestList);
      }
      else {
        for(int i=0; i<tempTestList.length; i++) {
          if(tempTestList[i].name.toString().toLowerCase().contains(query.trim().toLowerCase())) {
            testList.add(tempTestList[i]);
          }
        }
      }
      tempTestList.refresh();
    }
    else if(selectedFilter.value == 1) {
      packageList.clear();
      if(query.isEmpty) {
        packageList.addAll(tempPackageList);
      }
      else {
        for(int i=0; i<tempPackageList.length; i++) {
          if(tempPackageList[i].name.toString().toLowerCase().contains(query.trim().toLowerCase())) {
            packageList.add(tempPackageList[i]);
          }
        }
      }
      tempPackageList.refresh();
    }
    else if(selectedFilter.value == 2) {
      profileList.clear();
      if(query.isEmpty) {
        profileList.addAll(tempProfileList);
      }
      else {
        for(int i=0; i<tempProfileList.length; i++) {
          if(tempProfileList[i].name.toString().toLowerCase().contains(query.trim().toLowerCase())) {
            profileList.add(tempProfileList[i]);
          }
        }
      }
      profileList.refresh();
    }
  }
}