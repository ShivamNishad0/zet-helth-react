import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zet_health/Models/UserDetailModel.dart';
import 'package:zet_health/Models/CityModel.dart';
import 'package:zet_health/Models/AddressListModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import 'package:zet_health/Screens/HomeScreen/HomeScreenController.dart';

import 'ColorHelper.dart';
import 'StyleHelper.dart';

bool checkLogin() {
  return AppConstants().getStorage.read(AppConstants.USER_MOBILE) != null &&
      AppConstants()
          .getStorage
          .read(AppConstants.USER_MOBILE)
          .toString()
          .isNotEmpty;
}

class AppConstants {
  final GetStorage getStorage = GetStorage();
  static const int isPaymentLive = 1; // 0 means test and 1 means live

  // static var BASE_URL = "http://127.0.0.1:8000/api/v1/Authenticate/";
  // static var IMG_URL = "http://127.0.0.1:8000/images/";

  static var ADMIN_PANNEL = "https://admin.zethealth.com/admin-login";
  static var BASE_URL = "https://apihealth.zethealth.com/api/v1/Authenticate/";
  static var IMG_URL = "http://apihealth.zethealth.com/images/";

  // healjour API integration
  static var HEALJOUR_LOGIN_API = "https://apitesting.healjour.com/v1/";

  static const String playStoreURL =
      "https://play.google.com/store/apps/details?id=com.healthexpress";
  static const String appStoreURL =
      "https://apps.apple.com/in/app/zet-health/id6749360221";

  static const String googleMapApiKey =
      'AIzaSyBqG8oCDY59Pwe68Y0AUiUeis-jWlsmtN8';
  static const String googleMapApiKey2 =
      'AIzaSyCILYd8F2M7g95NQErBTZsXLmTD7baDBIw';

  // apis
  static var LOGIN_API = "login-user";
  static var REGISTER_API = "register-user";
  static var HOME_API = "get-home";
  static var GET_PACKAGE_API = "get-package-list";
  static var GET_LAB_TEST_API = "get-lab-test-list";
  static var GET_TEST_PROFILE_API = "get-test-profile";
  // static var GET_STATE_API = "get-state-city";
  static var ADD_PATIENT_API = "add-patient";
  static var GET_LAB_LIST_API = "get-lab-list";
  static var getLabListV2 = "get-lab-list-v2";
  static var ADD_TO_CART_API = "cart-create-or-update";
  static var GET_CART_API = "get-cart";
  static var ADMIN_BOOK_NOW_API = "admin/book-now";
  static var BOOK_NOW_API = "book-now-v2";
  static var GET_PATIENT_LIST_API = "get-patient-list";
  static var GET_SLOT_API = "get-slot";
  static var GET_BOOKING_LIST_API = "get-booking-list";
  static var GET_CLEAR_CART_API = "clear-cart-list";
  static var GET_LAB_WISE_TEST_API = "lab-wise-test";
  static var GET_OFFER_COUPON_API = "get-coupon";
  static var GET_REPORT_API = "get-report";
  static var UPDATE_PROFILE_API = "update-profile";
  static var UPLOAD_PRESCRIPTION_API = "upload-prescription";
  static var BOOKING_AFTER_PAYMENT_API = "booking-after-payment-v2";
  static var CMS_API = "cms";
  static var GET_PRESCRIPTION_API = "get-prescription";
  static var GET_NOTIFICATION_API = "common/get-notification";
  static var CONTACT_US_API = "contact-us";
  static var getAddressList = "get-address-list";
  static var addAddress = "add-address";
  static var addressDelete = "address-delete";
  static var getPatientList = "get-patient-list";
  static var adminGetCustomer = "admin/get-customer";
  static var deletePatient = "delete-patient";
  static var applyCoupon = "apply-coupon";
  static var logoutUser = "common/logout-user";
  static var getBookingDetails = "get-booking-details";
  static var ratingReview = "rating-review";
  static var rating = "rating";
  static var searchByCity = "search-by-city";
  static const String deleteAccount = 'delete-account';

  static var getOrderKey = "razorpay/get-order-key";
  static var getWalletTransaction = "razorpay/get-wallet-transaction";
  static var rechargeWallet = "razorpay/recharge-wallet";
  static var checkBalanceWithPayment = "check-balance-with-payment";

  // variables
  static var TOKEN = "token";
  static var USER_TYPE = "user_type";
  static var USER_ID = "user_id";
  static var USER_NAME = "user_name";
  static var USER_DETAIL = "user_detail";
  static var USER_MOBILE = "user_mobile";
  static var IS_NOTIFICATION = "is_notification";
  static var SUPPORT_MOBILE = "support_mobile";
  static var SUPPORT_EMAIL = "support_email";
  static var serviceCharge = "serviceCharge";
  static var serviceChargeDisplay = "serviceChargeDisplay";
  static var isCartExist = "isCartExist";
  static var cartCounter = "cartCounter";

  static const String LOGIN_COUNT = "login_count";

  static var CITY_LIST = "city_list";
  static var CITY_ID = "city_id";
  static var CURRENT_LOCATION = "current_location";
  static var CURRENT_PINCODE = "current_pincode";
  static var FULL_ADDRESS = "full_address";
  static var SELECTED_ADDRESS = "selected_address";
  static var IS_ADDRESS_SELECTED = "is_address_selected";
  static var CURRENT_ADDRESS = "current_address";
  static var IS_CURRENT_ADDRESS = "is_current_address";
  static var CART_PINCODE = "cart_pincode";

  // booking types
  static const String test = "LabTest";
  static const String package = "Package";
  static const String profile = "Profile";

  // CMS
  static const String TERMS_CONDITION = "terms_and_conditions";
  static const String CONTACT_US = "contact_us";
  static const String PRIVACY_POLICY = "privacy_policy";
  static const String ABOUT_US = "about_us";
  static const String BANK_DETAIL = "bank_detail";

  // Routes
  static const SPLASH_SCREEN = '/splashScreen';
  static const HOME_SCREEN = '/homeScreen';
  static const LOGIN_SCREEN = '/loginScreen';
  static const WELCOME_SCREEN = '/welcomeScreen';
  static const REPORT_SCREEN = '/reportScreen';

  //healjour
  static const String healjour_admin = '/admin/login';
  static const String branch_list = '/branch_list';
  static const String departmant_list = '/department_list';

  // Welcome Shown Key
  static const String WELCOME_SHOWN = "welcome_shown";
  static String appVersion = "Could not get";

  showToast(String message, {Color? color, int? seconds, double? width}) {
    try {
      // Check if GetX context is available
      if (Get.context != null) {
        // Simple approach: just show the snackbar without trying to manage existing ones
        Get.showSnackbar(GetSnackBar(
          backgroundColor: color ?? primaryColor,
          message: message,
          borderRadius: 16,
          borderColor: Colors.transparent,
          duration: Duration(seconds: seconds ?? 2),
          isDismissible: true,
          dismissDirection: DismissDirection.horizontal,
          forwardAnimationCurve: Curves.easeOutBack,
          reverseAnimationCurve: Curves.easeInBack,
          margin: EdgeInsets.symmetric(
            horizontal: width != null ? (Get.width - width) / 2 : 20,
            vertical: 10,
          ),
          snackPosition: SnackPosition.BOTTOM,
          maxWidth: width ?? Get.width * 0.9,
          shouldIconPulse: false,
          leftBarIndicatorColor: Colors.transparent,
        ));
      }
    } catch (e) {
      // Fallback: print the message if snackbar fails
      print('Toast error: $e - Message: $message');
    }
  }

  // Welcome Screen Showing Logic
  bool isWelcomeScreenShown() {
    return getStorage.read(WELCOME_SHOWN) ?? false;
  }

  // Welcome Screen Shown Save
  Future<void> markWelcomeScreenAsShown() async {
    await getStorage.write(WELCOME_SHOWN, true);
  }

  static Future<void> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    // print(info.version);
    // return info.version; // or "${info.version} (${info.buildNumber})"
    appVersion = info.version;
  }

  UserDetailModel getUserDetails() {
    UserDetailModel userDetail = UserDetailModel();
    if (getStorage.read(USER_DETAIL) != null) {
      userDetail = UserDetailModel.fromJson(
          jsonDecode(getStorage.read(USER_DETAIL).toString()));
    }
    return userDetail;
  }

  List<CityModel> getCityList() {
    try {
      var storedData = getStorage.read(CITY_LIST);
      List<CityModel> cityList = [];
      
      if (storedData != null && storedData is List) {
        for (var item in storedData) {
          if (item is Map<String, dynamic>) {
            cityList.add(CityModel.fromJson(item));
          } else if (item is CityModel) {
            cityList.add(item);
          }
        }
      }
      return cityList;
    } catch (e) {
      print('Error loading city list: $e');
      return [];
    }
  }

  // Address Management Methods
  void setSelectedAddress(AddressList address) {
    String addressJson = jsonEncode(address.toJson());
    getStorage.write(SELECTED_ADDRESS, addressJson);
    getStorage.write(IS_ADDRESS_SELECTED, true);
    
    print('=== ADDRESS SELECTED ===');
    print('Address ID: ${address.id}');
    print('Address: ${address.address}');
    print('City: ${address.city}');
    print('Pincode: ${address.pincode}');
    print('JSON stored: $addressJson');
    print('IS_ADDRESS_SELECTED set to: true');
    
    // Verify storage immediately
    var storedData = getStorage.read(SELECTED_ADDRESS);
    var isSelected = getStorage.read(IS_ADDRESS_SELECTED);
    print('Verification - Stored data: $storedData');
    print('Verification - Is selected: $isSelected');
    print('========================');
  }

  AddressList? getSelectedAddress() {
    try {
      var storedData = getStorage.read(SELECTED_ADDRESS);
      if (storedData != null) {
        return AddressList.fromJson(jsonDecode(storedData));
      }
    } catch (e) {
      print('Error loading selected address: $e');
    }
    return null;
  }

  bool isAddressSelected() {
    return getStorage.read(IS_ADDRESS_SELECTED) ?? false;
  }

  void clearSelectedAddress() {
    getStorage.remove(SELECTED_ADDRESS);
    getStorage.write(IS_ADDRESS_SELECTED, false);
  }

  void setCurrentAddress(AddressList? address) {
    if (address == null) {
      clearCurrentAddress();
      showToast("Unexpected Error");
      return;
    }
    String addressJson = jsonEncode(address.toJson());
    getStorage.write(CURRENT_ADDRESS, addressJson);
    getStorage.write(IS_CURRENT_ADDRESS, true);

    print('=== CURRENT ADDRESS SET ===');
    print('Address ID: ${address.id}');
    print('Address: ${address.address}');
    print('City: ${address.city}');
    print('Pincode: ${address.pincode}');
    print('JSON stored: $addressJson');
    print('IS_CURRENT_ADDRESS set to: true');

    // Verify storage immediately
    var storedData = getStorage.read(CURRENT_ADDRESS);
    var isCurrent = getStorage.read(IS_CURRENT_ADDRESS);
    print('Verification - Stored data: $storedData');
    print('Verification - Is current: $isCurrent');
    print('===========================');
  }

  AddressList? getCurrentAddress() {
    try {
      var storedData = getStorage.read(CURRENT_ADDRESS);
      if (storedData != null) {
        return AddressList.fromJson(jsonDecode(storedData));
      }
    } catch (e) {
      print('Error loading current address: $e');
    }
    return null;
  }

  bool isCurrentAddressSet() {
    return getStorage.read(IS_CURRENT_ADDRESS) ?? false;
  }

  void clearCurrentAddress() {
    getStorage.remove(CURRENT_ADDRESS);
    getStorage.write(IS_CURRENT_ADDRESS, false);
  }

  String? getCartPincode() {
    try {
      return getStorage.read(CART_PINCODE);
    } catch (e) {
      print('Error loading cart pincode: $e');
    }
    return null;
  }

  void setCartPincode(String pincode) {
    print('Setting cart pincode: $pincode');
    getStorage.write(CART_PINCODE, pincode);
  }

  void clearCartPincode() {
    getStorage.remove(CART_PINCODE);
  }

  String getDisplayAddress() {
    print('=== GET DISPLAY ADDRESS ===');
    print('Is logged in: ${checkLogin()}');
    print('Is address selected: ${isAddressSelected()}');
    
    if (checkLogin() && isAddressSelected()) {
      AddressList? selectedAddress = getSelectedAddress();
      print('Selected address found: ${selectedAddress != null}');
      if (selectedAddress != null) {
        // Construct complete address from multiple fields
        List<String> addressParts = [];
        
        // Add house number if available
        if (selectedAddress.houseNo != null && selectedAddress.houseNo!.isNotEmpty && selectedAddress.houseNo != 'null') {
          addressParts.add(selectedAddress.houseNo!);
        }
        
        // Add main address if available
        if (selectedAddress.address != null && selectedAddress.address!.isNotEmpty && selectedAddress.address != 'null') {
          addressParts.add(selectedAddress.address!);
        }
        
        // Add landmark if available
        if (selectedAddress.landmark != null && selectedAddress.landmark!.isNotEmpty && selectedAddress.landmark != 'null') {
          addressParts.add(selectedAddress.landmark!);
        }
        
        // Add city if available
        if (selectedAddress.city != null && selectedAddress.city!.isNotEmpty && selectedAddress.city != 'null') {
          addressParts.add(selectedAddress.city!);
        }
        
        // Add pincode if available
        if (selectedAddress.pincode != null && selectedAddress.pincode!.isNotEmpty && selectedAddress.pincode != 'null') {
          addressParts.add(selectedAddress.pincode!);
        }
        
        // Join all parts with comma and space
        String displayAddr = addressParts.isNotEmpty ? addressParts.join(', ') : 'Unknown';
        print('Display address from selected: $displayAddr');
        return displayAddr;
      }
    }
    
    String fallbackAddr = getStorage.read(FULL_ADDRESS) ?? getStorage.read(CURRENT_LOCATION) ?? 'Unknown';
    print('Fallback address: $fallbackAddr');
    print('===========================');
    return fallbackAddr;
  }

  Future<void> handleAddressAfterLogin() async {
    // Fetch user's saved addresses from API
    await fetchUserAddressesAfterLogin();
    
    // Update HomeScreenController's display address after fetching addresses
    try {
      final homeController = Get.find<HomeScreenController>();
      homeController.updateDisplayAddress();
      print('HomeScreenController address updated after login');
    } catch (e) {
      print('HomeScreenController not found during address update: $e');
    }
  }

  Future<void> fetchUserAddressesAfterLogin() async {
    print('=== FETCHING USER ADDRESSES AFTER LOGIN ===');
    
    try {
      final response = await WebApiHelper()
          .callGetApi(null, getAddressList, true);
          
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if (statusModel.status! && statusModel.addressList != null) {
          List<AddressList> userAddresses = statusModel.addressList!;
          
          print('=== USER ADDRESSES FETCHED ===');
          print('Found ${userAddresses.length} saved addresses');
          
          if (userAddresses.isNotEmpty) {
            // Log all saved addresses
            for (int i = 0; i < userAddresses.length; i++) {
              print('Address ${i + 1}:');
              print('  ID: ${userAddresses[i].id}');
              print('  Address: ${userAddresses[i].address}');
              print('  City: ${userAddresses[i].city}');
              print('  Pincode: ${userAddresses[i].pincode}');
              print('  House No: ${userAddresses[i].houseNo}');
              print('  Landmark: ${userAddresses[i].landmark}');
              print('  Location: ${userAddresses[i].location}');
              print('  Address Type: ${userAddresses[i].addressType}');
              print('  ---');
            }
            
            // Check if there's already a selected address
            AddressList? currentSelectedAddress = getSelectedAddress();
            bool foundCurrentSelection = false;
            
            if (currentSelectedAddress != null) {
              // Check if the current selected address is still in the fetched list
              for (AddressList address in userAddresses) {
                if (address.id == currentSelectedAddress.id) {
                  foundCurrentSelection = true;
                  print('Current selected address (ID: ${currentSelectedAddress.id}) found in fetched addresses');
                  break;
                }
              }
            }
            
            if (!foundCurrentSelection) {
              // No current selection or current selection not found, set first address as default
              setSelectedAddress(userAddresses[0]);
              print('Set first address as default selected (ID: ${userAddresses[0].id})');
            } else {
              print('Keeping current selected address (ID: ${currentSelectedAddress!.id})');
            }
          } else {
            print('No saved addresses found, clearing selected address');
            clearSelectedAddress(); // Clear any previously selected address
          }
          print('==============================');
        } else {
          print('Failed to fetch addresses or no addresses found');
          clearSelectedAddress(); // Clear any previously selected address
        }
      } else {
        print('Failed to fetch addresses - API response null');
        _setCurrentLocationAsSelected();
      }
    } catch (error) {
      print('Error fetching addresses: $error');
      _setCurrentLocationAsSelected();
    }
  }

  void _setCurrentLocationAsSelected() {
    // Create address from current location and set as selected
    String currentLocation = getStorage.read(CURRENT_LOCATION) ?? 'Unknown';
    String fullAddress = getStorage.read(FULL_ADDRESS) ?? currentLocation;
    String currentPincode = getStorage.read(CURRENT_PINCODE) ?? '';
    
    AddressList currentLocationAddress = AddressList(
      address: fullAddress,
      city: currentLocation,
      pincode: currentPincode,
      location: currentLocation,
    );
    
    setSelectedAddress(currentLocationAddress);
    print('=== CURRENT LOCATION SET AS SELECTED ===');
    print('Address: $fullAddress');
    print('City: $currentLocation');
    print('Pincode: $currentPincode');
    print('========================================');
  }

  loadWithCanBack(dynamic pageName, {Transition? transition}) {
    Get.to(
      pageName,
      transition: transition ?? Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }

  loadWithCanNotBack(dynamic pageName, {Transition? transition}) {
    Get.off(
      pageName,
      transition: transition ?? Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }

  loadWithCanNotAllBack(dynamic pageName, {Transition? transition}) {
    Get.offAll(
      pageName,
      transition: transition ?? Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }

  hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static gradientText(String text, TextStyle style, List<Color> colors) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(colors: colors).createShader(bounds);
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }

  String getCurrentDayOfWeek() {
    DateTime now = DateTime.now();
    List<String> daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return daysOfWeek[now.weekday % 7];
  }

  String currentDateTime() {
    try {
      final DateFormat targetFormat = DateFormat('dd-MMM-yyyy h:mm a');
      final DateTime now = DateTime.now();
      final String formattedDateTime = targetFormat.format(now);
      return formattedDateTime;
    } catch (e) {
      print(e.toString());
    }
    return '-';
  }

  String currentDateTimeApi() {
    try {
      final DateFormat targetFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final DateTime now = DateTime.now();
      final String formattedDateTime = targetFormat.format(now);
      return formattedDateTime;
    } catch (e) {
      print(e.toString());
    }
    return '-';
  }

  String currentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  String apiDateFormat(String enterDate) {
    try {
      final DateFormat sourceFormat = DateFormat('dd-MM-yyyy');
      final DateFormat targetFormat = DateFormat('yyyy-MM-dd');
      final DateTime date = sourceFormat.parse(enterDate);
      final String newDate = sourceFormat.format(date);
      final DateTime finalDate = sourceFormat.parse(newDate);
      return targetFormat.format(finalDate);
    } catch (e) {
      print(e.toString());
    }
    return '-';
  }

  String apiDateFormatFromSlas(String enterDate) {
    try {
      final DateFormat sourceFormat = DateFormat('dd/MM/yyyy');
      final DateFormat targetFormat = DateFormat('yyyy-MM-dd');
      final DateTime date = sourceFormat.parse(enterDate);
      final String newDate = sourceFormat.format(date);
      final DateTime finalDate = sourceFormat.parse(newDate);
      return targetFormat.format(finalDate);
    } catch (e) {
      print(e.toString());
    }
    return '-';
  }

  ddMMYYYYSlasDateFormat(String date) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    } catch (e) {
      return '';
    }
  }

  String formatDateWithOrdinal(DateTime date) {
    String getDaySuffix(int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    String dayWithSuffix = '${date.day}${getDaySuffix(date.day)}';
    String formattedDate = DateFormat('MMMM yyyy').format(date);
    return '$dayWithSuffix $formattedDate';
  }

/*  Future<String> openCalender(BuildContext context, var firstDate, var lastDate) async
  {
    String date ="";
    DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: firstDate,
        lastDate: lastDate,
        builder: (context, picker)
        {
          return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: primaryColor,
                  onPrimary: white,
                  surface: borderColor,
                  onSurface: Colors.white,
                ),
                dialogBackgroundColor: white,
              ),
              child: picker!);
        }
    );
    if (newSelectedDate != null)
    {
      date = DateFormat('dd-MM-yyyy').format(newSelectedDate);
    }
    return date;
  }*/

  Future<String?> openCalender(BuildContext context, DateTime firstDate,
      DateTime lastDate, bool isReturnSlas) async {
    DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: firstDate,
        lastDate: lastDate,
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (context, picker) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              dialogTheme: const DialogThemeData(backgroundColor: white),
            ),
            child: picker!,
          );
        });

    if (newSelectedDate != null) {
      return isReturnSlas
          ? DateFormat('dd/MM/yyyy').format(newSelectedDate)
          : DateFormat('dd-MM-yyyy').format(newSelectedDate);
    }
    return null;
  }

  bool isEmailValid(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      caseSensitive: false,
      multiLine: false,
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> downloadAndOpenFile(
      {required String link, required int type}) async {
    try {
      EasyLoading.show(
        status: 'Please Wait...',
        maskType: EasyLoadingMaskType.black,
      );

      final name = ".${link.split('.').first}";
      final index = name.lastIndexOf('/');
      final lastString = name.substring(index + 1);

      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      final filePath = '${directory!.path}/$lastString.${link.split('.').last}';

      final response = await http.get(Uri.parse(AppConstants.IMG_URL + link));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (await file.exists()) {
          EasyLoading.dismiss();
          if (type == 0) {
            OpenFile.open(filePath);
          } else {
            Share.shareXFiles([XFile(filePath)]);
          }
        } else {
          EasyLoading.dismiss();
          showToast('Download Failed'.tr, seconds: 2);
        }
      } else {
        EasyLoading.dismiss();
        showToast('Download Failed: ${response.statusCode}', seconds: 2);
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }
}
