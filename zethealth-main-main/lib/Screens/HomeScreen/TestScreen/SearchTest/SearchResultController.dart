import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:zet_health/Screens/HomeScreen/HomeScreenController.dart';
import '../../../../CommonWidget/commonApis.dart';
import '../../../../Helper/database_helper.dart';
import '../../../../Models/StatusModel.dart';
import '../../../../Models/custom_cart_model.dart';

class SearchResultController extends GetxController {

  TextEditingController searchController = TextEditingController();
  final searchFocusNode = FocusNode();
  var isFocused = false.obs;
  RxInt selectedFilter = 0.obs;
  RxString queryText = ''.obs;
  final _uniqueSuggestions = <String>{};
  Timer? _debounceTimer;
  RxBool hasPincodeError = false.obs;
  RxString errorMessage = ''.obs;
  

  CustomCartModel? customCartModel;

  RxList<CustomCartModel> testList = <CustomCartModel>[].obs;
  RxList<CustomCartModel> packageList = <CustomCartModel>[].obs;
  RxList<CustomCartModel> profileList = <CustomCartModel>[].obs;
  final DBHelper dbHelper = DBHelper();
  List<CustomCartModel> cartList = [];
  RxList<int> cartIds = <int>[].obs; // only for packages to make ui updates faster

  var cartCount = 0.obs;
  RxBool isLoading = true.obs;
  RxBool isSuggestionLoading = true.obs;

  RxList<CustomSuggestion> suggestionList = <CustomSuggestion>[].obs;
  RxBool isSearching = false.obs;
  RxBool showResults = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchFocusNode.addListener(() {
      isFocused.value = searchFocusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void updateCartCount() {
    cartCount.value = AppConstants().getStorage.read(AppConstants.cartCounter) ?? 0;
  }

  // In SearchResultController
void clearAllSelections() {
  // Clear selections in testList
  for (var test in testList) {
    test.isSelected = false;
  }
  
  // Clear selections in packageList
  for (var pkg in packageList) {
    pkg.isSelected = false;
  }
  
  // Clear selections in profileList
  for (var profile in profileList) {
    profile.isSelected = false;
  }
  
  // Refresh the lists to trigger UI update
  testList.refresh();
  packageList.refresh();
  profileList.refresh();
  
  // Also clear cartIds for packages
  cartIds.clear();
}

void updateSuggestions(String query, String pincode) {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // 👇 Reset state so UI goes back to default
    isSearching.value = true;
    showResults.value = false;

    // 👇 If query has less than 3 chars, clear suggestions and skip API call
    if (query.trim().length < 3) {
      suggestionList.clear();
      isSuggestionLoading.value = false;
      hasPincodeError.value = false;
      errorMessage.value = '';
      return;
    }
    
    // Set new debounce timer (300ms delay to prevent rapid API calls)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSuggestionSearch(query, pincode);
    });
  }

  void _performSuggestionSearch(String query, String pincode) async {
    print('🔄 updateSuggestions called with query: "$query", pincode: "$pincode"');

    isSearching.value = query.isNotEmpty;
    isSuggestionLoading.value = true;
    showResults.value = false;
    hasPincodeError.value = false;
    errorMessage.value = '';

    // Reset suggestions and uniqueness tracking
    suggestionList.clear();
    _uniqueSuggestions.clear();

    if (query.isEmpty) {
      isSuggestionLoading.value = false;
      return;
    }

    final params = {"q": query, "pincode": pincode};

    try {
      final response = await WebApiHelper().callNewNodeApi(null, "search", params, false);
      if (response == null) {
        isSuggestionLoading.value = false;
        return;
      }

      if (response is Map && response['error'] == 'PINCODE_NOT_SERVICEABLE') {
        hasPincodeError.value = true;
        errorMessage.value = response['message'] ?? 'Pincode not serviceable';
        isSuggestionLoading.value = false;
        return;
      }

      final result = SearchResponse.fromJson(response);

      int addedCount = 0;

      for (var test in result.labTests ?? []) {
        suggestionList.add(CustomSuggestion(id: int.parse(test.id.toString()), name: test.name, type: "labTests"));
        addedCount++;
      }

      for (var pkg in result.packages ?? []) {
        suggestionList.add(CustomSuggestion(id: int.parse(pkg.id.toString()), name: pkg.name, type: "packages"));
        addedCount++;
      }

      for (var prof in result.profileTests ?? []) {
        suggestionList.add(CustomSuggestion(id: int.parse(prof.id.toString()), name: prof.name, type: "profileTests"));
        addedCount++;
      }

      print('🎯 Total suggestions added: $addedCount');
    } catch (e) {
      print('❌ API error: $e');
    } finally {
      isSuggestionLoading.value = false;
      suggestionList.refresh();
    }
  }

  void submitSearch(String query, String pincode) {
    if (query.isEmpty) {
      isSearching.value = false;
      showResults.value = false;
      showResults.value = false;
      return;
    }

    _debounceTimer?.cancel();

    isSearching.value = false;
    showResults.value = true;
    isSuggestionLoading.value = false;

    getSearchResults(query, pincode);
  }

 void selectSuggestion(CustomSuggestion item, String pincode) {
    print('🎯 Suggestion selected: ${item.name} (Type: ${item.type})');
    print('📍 Using pincode: $pincode');
    searchController.text = item.name ?? "";
    isSearching.value = false;
    isSuggestionLoading.value = false;
    showResults.value = true;
    queryText.value = item.name ?? "";
    FocusManager.instance.primaryFocus?.unfocus();
    
    // Cancel any pending debounce timer
    _debounceTimer?.cancel();
    
    getSearchResults(searchController.text, pincode);
    selectedFilter.value = CustomSuggestion().decode(item.type)!;
  }

  void clearSearch() {
    searchController.clear();
    suggestionList.clear();
    isSearching.value = false;
    isSuggestionLoading.value = false;
    showResults.value = false;
    isLoading.value = true;
    FocusManager.instance.primaryFocus?.unfocus();
    queryText.value = '';
    selectedFilter.value = 0;

    clearErrors();

    _debounceTimer?.cancel();

    // Reset to full list (so blurred home contents can reappear)
    testList.clear();
    packageList.clear();
    profileList.clear();
  }

getSearchResults(String query, String pincode) {
  if (query.isEmpty) {
    isSearching.value = false;
    showResults.value = false;
    return;
  }

  hasPincodeError.value = false;
  errorMessage.value = '';

  testList.value = <CustomCartModel>[];
  packageList.value = <CustomCartModel>[];
  profileList.value = <CustomCartModel>[];

  Map<String, dynamic> params = {
    "q": query,
    "pincode": pincode,
  };

  WebApiHelper().callNewNodeApi(null, "search", params, false).then((response) async {
    if(response != null) {
      if (response is Map && response['error'] == 'PINCODE_NOT_SERVICEABLE') {
        print('❌ Pincode not serviceable for search: $query');
        hasPincodeError.value = true;
        errorMessage.value = response['message'] ?? 'Pincode not serviceable';
        isLoading.value = false;
        return;
      }

      SearchResponse result = SearchResponse.fromJson(response);

      // Process Lab Tests
      if(result.labTests != null) {
        for(int i=0; i< result.labTests!.length; i++) {
          print("Lab Tests: ${result.labTests![i].toJson()}");
          
          if(result.labTests![i].labs != null) {
            for(int j=0; j<result.labTests![i].labs!.length; j++) {
              var labData = result.labTests![i].labs![j];
              int id = double.parse(result.labTests![i].id.toString()).toInt();
              
              testList.add(
                CustomCartModel(
                  id: id,
                  name: result.labTests![i].name,
                  type: AppConstants.test,
                  price: labData.price.toString(),
                  isSelected: cartList.any((item) => item.id == id),
                  cityId: labData.cityId ?? 0,
                  labId: labData.id ?? labData.id ?? 0,
                  labName: labData.labName ?? "Lab Name Not Available",
                  labAddress: labData.labAddress ?? "Address Not Available",
                )
              );
            }
          }
        }
      }

      // Process Packages (UPDATED - with proper itemDetail parsing)
      if(result.packages != null) {
        for(int i=0; i< result.packages!.length; i++) {
          print("Packages: ${result.packages![i].toJson()}");
          
          if(result.packages![i].labs != null) {
            for(int j=0; j<result.packages![i].labs!.length; j++) {
              var labData = result.packages![i].labs![j];
              int id = double.parse(result.packages![i].id.toString()).toInt();
              
              packageList.add(
                CustomCartModel(
                  id: id,
                  name: result.packages![i].name,
                  type: AppConstants.package,
                  price: labData.price.toString(),
                  isSelected: cartList.any((item) => item.id == id),
                  cityId: labData.cityId ?? 0,
                  labId: labData.id ?? labData.id ?? 0,
                  labName: labData.labName ?? "Lab Name Not Available",
                  labAddress: labData.labAddress ?? "Address Not Available",
                  // ✅ Parse itemDetail string into List<ItemDetail>
                  itemDetail: _parseItemDetailFromString(result.packages![i].itemDetail),
                )
              );
            }
          }
        }
      }

      // Process Profile Tests (UPDATED - with proper itemDetail parsing)
      if(result.profileTests != null) {
        for(int i=0; i< result.profileTests!.length; i++) {
          print("Profile Tests: ${result.profileTests![i].toJson()}");
          
          if(result.profileTests![i].labs != null) {
            for(int j=0; j<result.profileTests![i].labs!.length; j++) {
              var labData = result.profileTests![i].labs![j];
              int id = double.parse(result.profileTests![i].id.toString()).toInt();
              
              profileList.add(
                CustomCartModel(
                  id: id,
                  name: result.profileTests![i].name,
                  type: AppConstants.profile,
                  price: labData.price.toString(),
                  isSelected: cartList.any((item) => item.id == id),
                  cityId: labData.cityId ?? 0,
                  labId: labData.id ?? labData.id ?? 0,
                  labName: labData.labName ?? "Lab Name Not Available",
                  labAddress: labData.labAddress ?? "Address Not Available",
                  // ✅ Parse itemDetail string into List<ItemDetail>
                  itemDetail: _parseItemDetailFromString(result.profileTests![i].itemDetail),
                )
              );
            }
          }
        }
      }

      isLoading.value = false;
    }
  });
}

// Helper method to parse itemDetail string into List<ItemDetail> (keeping your existing structure)
List<ItemDetail>? _parseItemDetailFromString(String? itemDetailString) {
  if (itemDetailString == null || itemDetailString.isEmpty) {
    return null;
  }
  
  List<ItemDetail> itemDetails = [];
  
  // Split by semicolon and create ItemDetail objects
  List<String> testNames = itemDetailString.split(';');
  
  for (String testName in testNames) {
    String trimmedName = testName.trim();
    if (trimmedName.isNotEmpty) {
      itemDetails.add(ItemDetail(
        name: trimmedName,
        detail: null,
        testTime: null,
        sampleCollection: null,
      ));
    }
  }
  
  return itemDetails.isNotEmpty ? itemDetails : null;
}

  void clearErrors() {
    hasPincodeError.value = false;
    errorMessage.value = '';
  }

  callTestWiseLabApi({bool toViewCart = false}) {
    if (cartList.isEmpty) {
      debugPrint("❌ Cart is empty, nothing to pass to API");
      return;
    }

    EasyLoading.show(status: 'Please Wait...');

    // ✅ Directly use cartList
    List<CustomCartModel> selectedTests =
    cartList.where((c) => c.type == AppConstants.test).toList();
    List<CustomCartModel> selectedPackages =
    cartList.where((c) => c.type == AppConstants.package).toList();
    List<CustomCartModel> selectedProfiles =
    cartList.where((c) => c.type == AppConstants.profile).toList();

    // ✅ Use first item for lab info
    customCartModel = cartList.first;

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

    WebApiHelper().callFormDataPostApi(null, AppConstants.getLabListV2, params, false,).then((response) {
      if (response != null) {
        print("✅ Lab API Response: $response");
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if (statusModel.status!) {
          print("StatusModel: ${statusModel.toJson()}\n");
          if (statusModel.labList != null && statusModel.labList!.isNotEmpty) {
            getCartApi(
              labModel: statusModel.labList![0],
              toViewCart: toViewCart,
            );
          }
          else {
            EasyLoading.dismiss();
          }
        }
        else {
          EasyLoading.dismiss();
        }
      }
      else {
        EasyLoading.dismiss();
      }
    });
  }
}

class SearchResponse {
  List<CustomTest>? labTests;
  List<CustomTest>? packages;
  List<CustomTest>? profileTests;

  SearchResponse({this.labTests, this.packages, this.profileTests});

  SearchResponse.fromJson(Map<String, dynamic> json) {
    labTests = json['lab_tests'] != null
        ? (json['lab_tests'] as List)
        .map((v) => CustomTest.fromJson(v))
        .where((test) => test.labs != null && test.labs!.isNotEmpty)
        .toList()
        : null;

    packages = json['packages'] != null
        ? (json['packages'] as List)
        .map((v) => CustomTest.fromJson(v))
        .where((pkg) => pkg.labs != null && pkg.labs!.isNotEmpty)
        .toList()
        : null;

    profileTests = json['profile_tests'] != null
        ? (json['profile_tests'] as List)
        .map((v) => CustomTest.fromJson(v))
        .where((prof) => prof.labs != null && prof.labs!.isNotEmpty)
        .toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (labTests != null) {
      data['lab_tests'] = labTests!.map((v) => v.toJson()).toList();
    }
    if (packages != null) {
      data['packages'] = packages!.map((v) => v.toJson()).toList();
    }
    if (profileTests != null) {
      data['profile_tests'] = profileTests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomTest {
  String? id;
  String? name;
  List<Labs>? labs;
  String? itemDetail; // Add this field to capture the string from API

  CustomTest({this.id, this.name, this.labs, this.itemDetail});

  CustomTest.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name'];
    itemDetail = json['itemDetail']; // Parse itemDetail string from API

    if (json['labs'] != null) {
      labs = (json['labs'] as List)
          .map((v) => Labs.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['itemDetail'] = itemDetail;
    if (labs != null) {
      data['labs'] = labs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class Labs {
  int? id;
  int? price;
  String? createdDate;
  int? cityId;
  String? labName;
  String? labAddress;
  String? type;

  Labs({
    this.id,
    this.price,
    this.createdDate,
    this.cityId,
    this.labName,
    this.labAddress,
    this.type,
  });

  Labs.fromJson(Map<String, dynamic> json) {
    id = json['lab_id'];
    price = json['price'];
    createdDate = json['created_date'];
    cityId = json['cityId'];
    labName = json['labName'];
    labAddress = json['labAddress'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['lab_id'] = id;
    data['price'] = price;
    data['created_date'] = createdDate;
    data['cityId'] = cityId;
    data['labName'] = labName;
    data['labAddress'] = labAddress;
    data['type'] = type;
    return data;
  }
}

class SuggestionResponse {
  bool? status;
  SuggestionData? data;

  SuggestionResponse({this.status, this.data});

  SuggestionResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? SuggestionData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['status'] = status;
    if (data != null) {
      result['data'] = data!.toJson();
    }
    return result;
  }
}

class SuggestionData {
  List<Suggestion>? labTests;
  List<Suggestion>? packages;
  List<Suggestion>? profileTests;

  SuggestionData({this.labTests, this.packages, this.profileTests});

  SuggestionData.fromJson(Map<String, dynamic> json) {
    labTests = json['lab_tests'] != null
        ? (json['lab_tests'] as List)
        .map((v) => Suggestion.fromJson(v))
        .toList()
        : [];
    packages = json['packages'] != null
        ? (json['packages'] as List)
        .map((v) => Suggestion.fromJson(v))
        .toList()
        : [];
    profileTests = json['profile_tests'] != null
        ? (json['profile_tests'] as List)
        .map((v) => Suggestion.fromJson(v))
        .toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    if (labTests != null) {
      result['lab_tests'] = labTests!.map((v) => v.toJson()).toList();
    }
    if (packages != null) {
      result['packages'] = packages!.map((v) => v.toJson()).toList();
    }
    if (profileTests != null) {
      result['profile_tests'] = profileTests!.map((v) => v.toJson()).toList();
    }
    return result;
  }
}

class Suggestion {
  String? id;
  String? name;

  Suggestion({this.id, this.name});

  Suggestion.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString(); // safe even if int/double/string
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    result['id'] = id;
    result['name'] = name;
    return result;
  }
}

class CustomSuggestion {
  int? id;
  String? name;
  String? type;

  CustomSuggestion({this.id, this.name, this.type});

  int? decode(String? type) { if(type == "labTests") return 0; if(type == "packages") return 1; if(type == "profileTests") return 2; return null; }
}