import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/BranchListModel.dart';
import 'package:zet_health/Models/TestModel.dart';
import 'package:zet_health/Models/PackageModel.dart';
import 'package:zet_health/Models/ProfileModel.dart';
import 'package:zet_health/Models/SliderModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Models/UserDetailModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:zet_health/Screens/DrawerView/EditProfileScreen/EditProfileScreen.dart';
import 'package:zet_health/Screens/DrawerView/NavigationDrawerController.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';
import '../../CommonWidget/CustomButton.dart';
import '../../CommonWidget/CustomWidgets.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';
import '../../Helper/database_helper.dart';
import '../../Models/CartModel.dart';
import '../../Models/PrescriptionModel.dart';

class HomeScreenController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<SliderModel> sliderList = <SliderModel>[].obs;
  RxString displayAddress = ''.obs;
  RxList<NewPackageModel> popularPackageList = <NewPackageModel>[].obs;
  RxList<NewPackageModel> lifeStylePackageList = <NewPackageModel>[].obs;
  RxList<NewPackageModel> filterList = <NewPackageModel>[].obs;
  RxList<TestModel> popularLabTestList = <TestModel>[].obs;
  RxList<NewPackageModel> popularProfileList = <NewPackageModel>[].obs;
  RxList<BranchListModel> branchList = <BranchListModel>[].obs;
  RxList<PrescriptionModel> prescriptionList = <PrescriptionModel>[].obs;
  final DBHelper dbHelper = DBHelper();
  LocationPermission locationPermission = LocationPermission.denied;

  CroppedFile? prescriptionImg;

  void _trackAppOpen() {
  final storage = AppConstants().getStorage;

  final token = storage.read(AppConstants.TOKEN);
  if (token != null) {
    int count = storage.read(AppConstants.LOGIN_COUNT) ?? 0;
    count++;
    storage.write(AppConstants.LOGIN_COUNT, count);

    debugPrint("📱 App opened count: $count");

    // Check every 3rd opening
    if (count % 3 == 0) {
      bool isProfileUpdated = _checkProfileUpdated();
      if (!isProfileUpdated) {
        Future.delayed(Duration.zero, () {
          Get.dialog(CommonDialog(
            title: "Update Profile",
            description: "Please update your profile for personalized experience.",
            tapNoText: "Later",
            tapYesText: "Update",
            onTapNo: () => Get.back(),
            onTapYes: () {
              Get.back();
              Get.to(() => const EditProfileScreen(fromDialog: true));
            },
          ));
        });
      }
    }
  }
}

bool _checkProfileUpdated() {
  final userDetailJson = AppConstants().getStorage.read(AppConstants.USER_DETAIL);
  if (userDetailJson == null) return false;

  final Map<String, dynamic> data = jsonDecode(userDetailJson);
  final userDetail = UserDetailModel.fromJson(data);

  // Otherwise check manually (dob, email, name, gender etc.)
  bool hasDob = userDetail.userDob != null && userDetail.userDob!.trim().isNotEmpty;
  bool hasEmail = (userDetail.userEmail != null && userDetail.userEmail!.trim().isNotEmpty) ||
                  (userDetail.email != null && userDetail.email!.trim().isNotEmpty);
  bool hasName = userDetail.userName != null && userDetail.userName!.trim().isNotEmpty;
  bool hasGender = userDetail.userGender != null && userDetail.userGender!.trim().isNotEmpty;

  return hasDob && hasEmail && hasName && hasGender;
}

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      return iosInfo.identifierForVendor!;
    }
    return "unknown";
  }

  callHomeApi() async {
    NavigationDrawerController navigationDrawerController =
        Get.put(NavigationDrawerController());
    isLoading.value = true;
    sliderList.value = [];
    popularPackageList.value = [];
    lifeStylePackageList.value = [];
    branchList.value = [];
    filterList.value = [];

    popularLabTestList.value = [];
    popularProfileList.value = [];
    AppConstants().getStorage.write(AppConstants.isCartExist, false);
    locationPermission = await Geolocator.checkPermission();

    String deviceId = await _getDeviceId();
    final versionInfo = await PackageInfo.fromPlatform();
    String? fcmToken = '';
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      e.toString();
    }
    Map<String, dynamic> params = {
      'token': fcmToken,
      "device_id": deviceId,
      "plateform": Platform.isAndroid ? 'Android' : 'IOS',
      'app_version': versionInfo.version,
      // "mobile_number" : AppConstants().getStorage.read(AppConstants.USER_MOBILE)??''
    };

    Map<String, dynamic> nodeParams = {
      'pincode': AppConstants().getSelectedAddress()?.pincode ?? AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE),
    };

    WebApiHelper().callNewNodeApi(null, "tests/popular-package", nodeParams, false).then((response) {
      if (response != null) {
        print('Popular Package API Response: $response');
        PopularResponseNode popularResponse = PopularResponseNode.fromJson(response);
        if (popularResponse.status == true && popularResponse.packages != null) {
          for(var pkg in popularResponse.packages!) {
            if(pkg.type == "Lifestyle") {
              lifeStylePackageList.add(pkg);
              filterList.add(pkg);
            }
            else {
              popularPackageList.add(pkg);
            }
          }
          // popularPackageList.addAll(popularResponse.packages!);
          print('Popular & Lifestyle packages loaded: ${popularPackageList.length}');
        } else {
          print('No popular packages found or status false');
        }
      } else {
        print('Popular Package API returned null response');
      }
    }).catchError((error) {
      print('Error fetching popular packages: $error');
    });

    WebApiHelper().callNewNodeApi(null, "tests/popular-profile", nodeParams, false).then((response) {
      if (response != null) {
        print('Popular Package API Response: $response');
        PopularResponseNode popularResponse = PopularResponseNode.fromJson(response);
        if (popularResponse.status == true && popularResponse.packages != null) {
          popularProfileList.addAll(popularResponse.packages!);
          print('Popular packages loaded: ${popularProfileList.length}');
        } else {
          print('No popular packages found or status false');
        }
      } else {
        print('Popular Package API returned null response');
      }
    }).catchError((error) {
      print('Error fetching popular packages: $error');
    });

    WebApiHelper()
        .callFormDataPostApi(null, AppConstants.HOME_API, params, true)
        .then((response) async {
      if (response != null) {
        print('=== HOME API RESPONSE ===');
        print('Response length: ${response.length}');
        
        Map<String, dynamic> jsonResponse = jsonDecode(response);
        print('JSON contains city key: ${jsonResponse.containsKey('city')}');
        if (jsonResponse.containsKey('city')) {
          print('City data type: ${jsonResponse['city'].runtimeType}');
          if (jsonResponse['city'] is List) {
            print('City array length: ${jsonResponse['city'].length}');
            if (jsonResponse['city'].isNotEmpty) {
              print('First city sample: ${jsonResponse['city'][0]}');
            }
          }
        }
        
        StatusModel statusModel = StatusModel.fromJson(jsonResponse);
        print('Status: ${statusModel.status}');
        print('About to check if status is true...');
        
        if (statusModel.status!) {
          print('Status is true - proceeding with data processing...');
          try {
            isLoading.value = false;
          forceUpdateDialog(
            versionInfo: versionInfo,
            currentPlatformVersion: Platform.isAndroid
                ? statusModel.userAndroidAppVersion
                : statusModel.userIosAppVersion,
            message: Platform.isAndroid
                ? statusModel.userAndroidUpdateMessage
                : statusModel.userIosAppVersion,
          );
          if (statusModel.unreadNotification != null) {
            navigationDrawerController.notificationCounter.value =
                statusModel.unreadNotification!;
          }
          AppConstants()
              .getStorage
              .write(AppConstants.SUPPORT_MOBILE, statusModel.supportMobile);
          AppConstants()
              .getStorage
              .write(AppConstants.SUPPORT_EMAIL, statusModel.supportEmail);
          AppConstants()
              .getStorage
              .write(AppConstants.serviceCharge, statusModel.serviceCharge);
          AppConstants().getStorage.write(AppConstants.serviceChargeDisplay,
              statusModel.serviceChargeDisplay);

          if (statusModel.cartList != null &&
              statusModel.cartList!.isNotEmpty) {
            AppConstants().getStorage.write(AppConstants.isCartExist, true);
            final cc = CartModel.fromJson(
                json.decode(statusModel.cartList![0].cartJson!));
            AppConstants()
                .getStorage
                .write(AppConstants.cartCounter, cc.itemList!.length);
          } else {
            AppConstants().getStorage.write(AppConstants.isCartExist, false);
            dbHelper.getCartCounter();
          }

          if (statusModel.sliderList != null && statusModel.sliderList!.isNotEmpty) {
            sliderList.addAll(statusModel.sliderList!);
          }

          // if (statusModel.popularPackageList != null && statusModel.popularPackageList!.isNotEmpty) {
          //   popularPackageList.addAll(statusModel.popularPackageList!);
          // }

          // if (statusModel.lifestylePackageList != null && statusModel.lifestylePackageList!.isNotEmpty) {
          //   lifeStylePackageList.addAll(statusModel.lifestylePackageList!);
          //   filterList.addAll(statusModel.lifestylePackageList!);
          // }
          if (statusModel.branchList != null && statusModel.branchList!.isNotEmpty) {
            branchList.addAll(statusModel.branchList!);
          }

          if (statusModel.testList != null && statusModel.testList!.isNotEmpty) {
            popularLabTestList.addAll(statusModel.testList!);
          }

          // if (statusModel.popularProfilesList != null && statusModel.popularProfilesList!.isNotEmpty) {
          //   popularProfileList.addAll(statusModel.popularProfilesList!);
          // }

          print('=== REACHED CITY PROCESSING SECTION ===');
          print('=== CITY LIST PROCESSING ===');
          print('statusModel.cityList is null: ${statusModel.cityList == null}');
          if (statusModel.cityList != null) {
            print('statusModel.cityList length: ${statusModel.cityList!.length}');
            print('First few cities: ${statusModel.cityList!.take(3).map((c) => c.cityName).toList()}');
          } else {
            print('statusModel.cityList is null - checking why...');
          }
          
          if (statusModel.cityList != null &&
              statusModel.cityList!.isNotEmpty) {
            print('Converting ${statusModel.cityList!.length} cities to JSON format');
            // Convert city list to JSON format for proper storage
            List<Map<String, dynamic>> cityJsonList = statusModel.cityList!
                .map((city) => city.toJson())
                .toList();
            
            print('JSON conversion completed. Sample JSON: ${cityJsonList.isNotEmpty ? cityJsonList[0] : 'empty'}');
            
            AppConstants()
                .getStorage
                .write(AppConstants.CITY_LIST, cityJsonList);
                
            print('City list saved to storage with key: ${AppConstants.CITY_LIST}');
            
            // Verify what was actually stored
            var verifyStored = AppConstants().getStorage.read(AppConstants.CITY_LIST);
            print('Verification - stored data type: ${verifyStored.runtimeType}');
            print('Verification - stored data is List: ${verifyStored is List}');
            if (verifyStored is List) {
              print('Verification - stored list length: ${verifyStored.length}');
            }
            for (int i = 0; i < statusModel.cityList!.length; i++) {
              if (statusModel.cityList![i].cityName.toString().toLowerCase() ==
                  AppConstants()
                      .getStorage
                      .read(AppConstants.CURRENT_LOCATION)
                      .toString()
                      .toLowerCase()) {
                AppConstants().getStorage.write(AppConstants.CITY_ID,
                    statusModel.cityList![i].id.toString());
              }
            }
          } else {
            print('City list is null or empty - no cities to save');
          }
          } catch (e) {
            print('Error during status processing: $e');
            isLoading.value = false;
          }
        } else {
          print('Status is false - not processing data');
          isLoading.value = false;
        }
      } else {
        print('Response is null');
        isLoading.value = false;
      }
    });
  }

  callUploadPrescriptionApi(BuildContext context) async {
    Map<String, dynamic> params = {"document": prescriptionImg};

    WebApiHelper()
        .callFormDataPostApi(
            context, AppConstants.UPLOAD_PRESCRIPTION_API, params, true,
            imageKey: 'document', file: prescriptionImg?.path)
        .then((response) {
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if (statusModel.status!) {
          showToast(message: 'Uploaded Successfully!');
          Get.dialog(CustomBorderDialog(
            childWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Thanks for submitting Rx creating an order for you in a moment'
                      .tr,
                  textAlign: TextAlign.center,
                  style: mediumBlack_18,
                ),
                CustomButton(
                    topMargin: 10.h,
                    height: 35.h,
                    borderColor: primaryColor,
                    color: whiteColor,
                    borderRadius: 100,
                    text: 'Close',
                    textStyle: semiBoldPrimary_16,
                    onTap: () {
                      Get.back();
                    })
              ],
            ),
          ));
        } else {
          showToast(message: 'Please try again!');
        }
      }
    });
  }

  forceUpdateDialog(
      {required versionInfo,
      String? currentPlatformVersion,
      String? message}) async {
    if (double.parse(versionInfo.version) <
        double.parse(currentPlatformVersion ?? "1.0")) {
      // if(true){
      Get.dialog(
          barrierDismissible: false,
          WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: CupertinoAlertDialog(
              title: Text("update".tr,
                  style: TextStyle(
                      color: primaryColor,
                      fontFamily: semiBold,
                      fontSize: 16.sp)),
              content: Text(message ?? "",
                  style: TextStyle(
                      color: black, fontFamily: medium, fontSize: 12.sp)),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    try {
                      StoreRedirect.redirect(
                          androidAppId: "com.healthexpress",
                          iOSAppId: "798555007");
                    } catch (e) {
                      // showToast(e.toString());
                    }
                  },
                  child: Text('update'.tr,
                      style: TextStyle(
                          color: black, fontFamily: semiBold, fontSize: 16.sp)),
                ),
              ],
            ),
          ));
    }
  }

  // Method to update display address reactively
  void updateDisplayAddress() {
    String newAddress = AppConstants().getDisplayAddress();
    print('🏠 HomeScreenController: Getting display address from AppConstants: $newAddress');
    displayAddress.value = newAddress;
    print('🏠 HomeScreenController: Display address updated to: ${displayAddress.value}');
    print('🏠 HomeScreenController: Reactive variable updated successfully');
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize display address
    updateDisplayAddress();
    print('HomeScreenController onInit - Display address initialized: ${displayAddress.value}');
  }

  @override
  void onReady() {
    super.onReady();
    // Update address again when controller is ready
    updateDisplayAddress();
    print('HomeScreenController onReady - Display address updated: ${displayAddress.value}');

    _trackAppOpen();
  }
}

class PopularResponseNode {
  bool? status;
  List<NewPackageModel>? packages;
  String? message;

  PopularResponseNode({this.status, this.packages, this.message});

  PopularResponseNode.fromJson(Map<String, dynamic> json) {
    status = json['success'];
    if (json['data'] != null) {
      packages = <NewPackageModel>[];
      json['data'].forEach((v) {
        packages!.add(NewPackageModel.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = status;
    if (packages != null) {
      data['data'] = packages!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}