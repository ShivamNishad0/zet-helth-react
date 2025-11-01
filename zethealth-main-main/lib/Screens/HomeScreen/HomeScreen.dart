import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomContainer.dart';
import 'package:zet_health/CommonWidget/CustomLoadingIndicator.dart';
import 'package:zet_health/CommonWidget/login_prompt_snackbar.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/StyleHelper.dart';
import 'package:zet_health/Models/PackageModel.dart';
import 'package:zet_health/Screens/HomeScreen/AvailableLabsScreen/AvailableLabsScreen.dart';
import 'package:zet_health/Screens/HomeScreen/HomeScreenController.dart';
// import 'package:zet_health/Screens/HomeScreen/LabScreen/LabScreen.dart';
import 'package:zet_health/Screens/HomeScreen/LifestylePackageScreen/LifestylePackageListScreen.dart';
import 'package:zet_health/Screens/HomeScreen/ProfileScreen/ProfileListScreen.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:zet_health/services/job_status_service.dart';

import 'dart:io';
import '../../CommonWidget/CustomWidgets.dart';
import '../../CommonWidget/swiper_slider.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/ColorHelper.dart';
import '../../Models/AddressListModel.dart';
import '../../Models/CartModel.dart';
import '../../Models/TestModel.dart';
import '../../Models/custom_cart_model.dart';
import '../../Network/PdfApiHelper.dart';
import '../../main.dart';
import '../AuthScreen/LoginScreen.dart';
import '../DrawerView/AddressScreen/AddressScreen.dart';
import '../DrawerView/NavigationDrawerController.dart';
import '../MyCartScreen/MyCartScreen.dart';
import '../MyReportScreen/MyReportScreen.dart';
import '../MyReportScreen/MyReportScreenController.dart';
import 'ItemDetailScreen/ItemDetailScreen.dart';
import 'PackageScreen/PackageListScreen.dart';
import 'TestScreen/SearchTest/SearchResultController.dart';
import 'TestScreen/SearchTest/SearchTestScreen.dart';
import 'TestScreen/PopularTest/PopularTestScreen.dart';
import 'TestScreen/SearchTest/SearchTestScreenController.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeScreenController homeScreenController = Get.put(HomeScreenController());
  SearchResultController searchTestScreenController =
      Get.put(SearchResultController());
   final JobStatusService jobStatusService = Get.put(JobStatusService());
  RxInt sliderPage = 0.obs;
  Function? listListen;
  bool isSelectedItem = false;
  CartModel? cartItem;
  RxString suggestValue = ''.obs;
  RxString searchValue = ''.obs;
  RxBool scrollablePhysics = true.obs;
  RxBool showBottomSnackbar = false.obs;
  final ScrollController outerScrollController = ScrollController();

  final RefreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.requestPermission();
    homeScreenController.callHomeApi();

    // Log current location details
    _logCurrentLocation();

    init();

     Future.delayed(Duration(milliseconds: 1000), () {
    _checkExistingJobs();
  });
  }

 void _checkExistingJobs() {
  if (checkLogin()) {
    String? userMobile = AppConstants()
        .getStorage
        .read(AppConstants.USER_MOBILE)
        ?.toString();
    if (userMobile != null && !jobStatusService.isProcessing) {
      // Check if there might be an existing processing job silently (without showing toasts)
      // jobStatusService.checkExistingJobsSilently(userMobile);

      // Only show processing snackbar if job is still processing and it's a new job
      if (jobStatusService.currentStatus == 'processing' && jobStatusService.isNewJob) {
        _showProcessingSnackbar();
      }
    }
  }
}


  init() async {
    searchTestScreenController.customCartModel = null;
    searchTestScreenController.cartList =
        await searchTestScreenController.dbHelper.getCartList();

    searchTestScreenController.cartCount.value =
        searchTestScreenController.cartList.length;
    searchTestScreenController.cartIds.value =
        searchTestScreenController.cartList.map((e) => e.id!).toList();
    if (searchTestScreenController.cartList.isNotEmpty) {
      // keep the lab info visible
      searchTestScreenController.customCartModel =
          searchTestScreenController.cartList.first;
    }

    for (var item in searchTestScreenController.cartList) {
      debugPrint("🛒 Cart Item: ${item.toJson()}");
    }
  }

  void _logCurrentLocation() {
    String currentLocation =
        AppConstants().getStorage.read(AppConstants.CURRENT_LOCATION) ??
            'Not Available';
    String fullAddress =
        AppConstants().getStorage.read(AppConstants.FULL_ADDRESS) ??
            'Not Available';
    String currentPincode =
        AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE) ??
            'Not Available';
    bool isLoggedIn = checkLogin();
    bool isAddressSelected = AppConstants().isAddressSelected();
    AddressList? selectedAddress = AppConstants().getSelectedAddress();

    print('=== HOME SCREEN LOCATION LOG ===');
    print('Current City: $currentLocation');
    print('Full Address: $fullAddress');
    print('Pincode: $currentPincode');
    print('Is Logged In: $isLoggedIn');
    print('Is Address Selected: $isAddressSelected');
    print('Display Address: ${AppConstants().getDisplayAddress()}');

    if (selectedAddress != null) {
      print('=== SELECTED ADDRESS DETAILS ===');
      print('Selected Address ID: ${selectedAddress.id}');
      print('Selected Address: ${selectedAddress.address}');
      print('Selected City: ${selectedAddress.city}');
      print('Selected Pincode: ${selectedAddress.pincode}');
      print('Selected House No: ${selectedAddress.houseNo}');
      print('Selected Landmark: ${selectedAddress.landmark}');
      print('Selected Location: ${selectedAddress.location}');
      print('Selected Address Type: ${selectedAddress.addressType}');
      print('================================');
    } else {
      print('No address selected');
    }
    print('================================');
  }

  void _onAddressTap() {
    if (checkLogin()) {
      // User is logged in, open address screen
      AppConstants().loadWithCanBack(
        AddressScreen(
          pickupAddress: (selectedAddress) {
            // Handle address selection
            AppConstants().setSelectedAddress(selectedAddress);
            homeScreenController
                .updateDisplayAddress(); // Update reactive address
            setState(() {}); // Refresh the UI
          },
        ),
      );
    } else {
       LoginPromptSnackbar.show(
      message: 'Please login to manage addresses',
      onLoginTap: () {
        AppConstants().loadWithCanBack(
          LoginScreen(
            onLoginSuccess: () {
              homeScreenController.callHomeApi();
            },
          ),
        );
      },
    );
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    Get.dialog(
      AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
            '$permissionType permission is required for this feature. Please enable it in your device settings and try again.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPdfUploadDialog() {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: FaIcon(
                FontAwesomeIcons.filePdf,
                color: primaryColor,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Upload Medical Report',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please upload your medical report in PDF format for AI analysis.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleInfo,
                    color: Colors.blue[600],
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Supported format: PDF only\nMax file size: 10MB',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _pickPdfFile();
            },
            icon: FaIcon(
              FontAwesomeIcons.upload,
              size: 14.sp,
              color: Colors.white,
            ),
            label: Text(
              'Choose PDF',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

 void _showProcessingSnackbar() {
  // Close any existing snackbars safely
  _hideUploadProgress();

  showBottomSnackbar.value = true;

  // Small delay to ensure previous snackbar is closed
  Future.delayed(Duration(milliseconds: 200), () {
    Get.snackbar(
      '',
      '',
      titleText: Obx(() => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Small processing indicator
            Container(
              width: 16.w,
              height: 16.w,
              margin: EdgeInsets.only(right: 8.w),
              child: CircularProgressIndicator(
                color: jobStatusService.currentStatus == 'failed'
                  ? Colors.red
                  : Colors.white,
                strokeWidth: 2,
                value: jobStatusService.currentStatus == 'processing'
                  ? null
                  : 1.0,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Text(
                    _getProcessingTitle(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                  SizedBox(height: 2.h),
                  Obx(() => Text(
                    jobStatusService.statusDescription.isNotEmpty
                      ? jobStatusService.statusDescription
                      : 'Processing your medical report...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            FaIcon(
              FontAwesomeIcons.fileMedical,
              color: Colors.white.withOpacity(0.8),
              size: 14.sp,
            ),
          ],
        ),
      )),
      messageText: SizedBox.shrink(),
      backgroundColor: _getProcessingColor(),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 70.h),
      borderRadius: 10.r,
      duration: Duration(days: 1),
      isDismissible: true,
      showProgressIndicator: false,
      boxShadows: [
        BoxShadow(
          color: _getProcessingColor().withOpacity(0.3),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      padding: EdgeInsets.zero,
    );
  });
}


  Color _getProcessingColor() {
    switch (jobStatusService.currentStatus) {
      case 'completed':
        return Colors.green.withOpacity(0.95);
      case 'failed':
        return Colors.red.withOpacity(0.95);
      case 'processing':
      default:
        return Colors.orange.withOpacity(0.95);
    }
  }

  String _getProcessingTitle() {
    switch (jobStatusService.currentStatus) {
      case 'completed':
        return 'Processing Complete!';
      case 'failed':
        return 'Processing Failed';
      case 'processing':
      default:
        return 'Processing PDF...';
    }
  }

Future<void> _pickPdfFile() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      File file = File(filePath);

      // Check file size (10MB limit)
      int fileSizeInBytes = await file.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 10) {
        AppConstants().showToast('File size should be less than 10MB');
        return;
      }

      // Get user mobile number (user ID)
      String? userMobile = AppConstants()
          .getStorage
          .read(AppConstants.USER_MOBILE)
          ?.toString();
      if (userMobile == null) {
        AppConstants().showToast('User not found. Please login again.');
        return;
      }

       AppConstants().showToast('Uploading PDF, Will notify once insights are ready', seconds: 5);

      // Upload PDF in background
      PdfApiHelper pdfApiHelper = PdfApiHelper();
      await pdfApiHelper.uploadPdfInBackground(filePath, userMobile,
          (success, message) async {
        if (success) {
         jobStatusService.startPolling(userMobile, isNewUpload: true);
        } else {
          AppConstants().showToast(message ?? 'Upload failed');
        }
      });
    }
  } catch (e) {
    AppConstants().showToast('Error picking file: ${e.toString()}');
  }
}

  void _hideUploadProgress() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  @override
  void dispose() {
    super.dispose();
    listListen?.call();
  }

  Future<void> _refreshData() async {
    await homeScreenController.callHomeApi();
    // Also refresh cart data
    await init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBgColor,
      resizeToAvoidBottomInset: false,
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // This ensures the refresh indicator works with CustomScrollView
          return false;
        },
        child: RefreshIndicator(
          key: RefreshIndicatorKey,
          backgroundColor: whiteColor,
          color: primaryColor,
          onRefresh: _refreshData,
          child: CustomScrollView(
            controller: outerScrollController,
            physics: const AlwaysScrollableScrollPhysics(), // Changed this line
            slivers: [
              // Main AppBar (scrolls normally)
              SliverAppBar(
                scrolledUnderElevation: 0,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: primaryColor,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
                backgroundColor: whiteColor,
                toolbarHeight: 55.h,
                shadowColor: Colors.white,
                centerTitle: false,
                automaticallyImplyLeading: false,
                pinned: false,
                floating: false,
                title: Padding(
                  padding: EdgeInsets.only(left: 2.w),
                  child: Row(
                    children: [
                      CustomSquareButton(
                        backgroundColor: whiteColor,
                        leftMargin: 0,
                        icon: drawerIcon,
                        shadow: [
                          BoxShadow(
                            color: borderColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
                          )
                        ],
                        onTap: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _onAddressTap();
                          },
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: Get.width * 0.6,
                              minWidth: 100.w,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: const [
                                BoxShadow(
                                  color: borderColor,
                                  blurRadius: 1,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Obx(() => Text(
                                        homeScreenController
                                                .displayAddress.value.isNotEmpty
                                            ? homeScreenController
                                                .displayAddress.value
                                            : AppConstants()
                                                .getDisplayAddress(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: mediumGray_14,
                                        textAlign: TextAlign.left,
                                      )),
                                ),
                                SizedBox(width: 5.w),
                                FaIcon(FontAwesomeIcons.locationDot,
                                    size: 16.sp, color: primaryColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [NotificationButtonCommon(), CartButtonCommon()],
              ),

              // Fixed Search Bar using SliverAppBar
              SliverAppBar(
                toolbarHeight: 60.h,
                automaticallyImplyLeading: false,
                pinned: true,
                floating: false,
                primary: false,
                elevation: 0,
                forceMaterialTransparency: true,
                titleSpacing: 0,
                title: Container(
                  color: pageBgColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  child: CustomContainer(
                    borderColor: borderColor,
                    borderWidth: 2.w,
                    radius: 20.r,
                    rightPadding: 8.w,
                    leftPadding: 8.w,
                    topPadding: 5.h,
                    bottomPadding: 5.h,
                    child: Row(
                      children: [
                        Obx(
                          () => searchTestScreenController.isFocused.value ||
                                  searchTestScreenController
                                      .queryText.value.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    searchTestScreenController.clearSearch();
                                  },
                                  child: SvgPicture.asset(backArrow,
                                      colorFilter: ColorFilter.mode(
                                          primaryColor, BlendMode.srcIn)),
                                )
                              : Container(
                                  padding: EdgeInsets.all(4.sp),
                                  child: SvgPicture.asset(labTestIcon,
                                      colorFilter: ColorFilter.mode(
                                          primaryColor, BlendMode.srcIn)),
                                ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            controller:
                                searchTestScreenController.searchController,
                            focusNode:
                                searchTestScreenController.searchFocusNode,
                            cursorColor: primaryColor,
                            style: boldGray2_12,
                            decoration: InputDecoration(
                              hintText: "search_for_tests_and_packages".tr,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              searchTestScreenController.queryText.value =
                                  value;
                              searchTestScreenController.isLoading.value =
                                  false;
                              String selectedPinCode = AppConstants()
                                      .getSelectedAddress()
                                      ?.pincode ??
                                  AppConstants()
                                      .getStorage
                                      .read(AppConstants.CURRENT_PINCODE);
                              searchTestScreenController.updateSuggestions(
                                  value, selectedPinCode);
                            },
                            onSubmitted: (value) {
                              String selectedPinCode = AppConstants()
                                      .getSelectedAddress()
                                      ?.pincode ??
                                  AppConstants()
                                      .getStorage
                                      .read(AppConstants.CURRENT_PINCODE);
                              searchTestScreenController.submitSearch(
                                  value, selectedPinCode);
                            },
                          ),
                        ),
                        Obx(
                          () => searchTestScreenController
                                  .queryText.value.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    searchTestScreenController.searchController
                                        .clear();
                                    searchTestScreenController.queryText.value =
                                        '';

                                    if (!searchTestScreenController
                                        .searchFocusNode.hasFocus) {
                                      searchTestScreenController.searchFocusNode
                                          .requestFocus();
                                    }
                                  },
                                  child: Icon(Icons.close, color: greyColor),
                                )
                              : SizedBox.shrink(),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () {
                            if (checkLogin()) {
                              Get.dialog(UploadImageDialog(
                                title: 'upload_prescription'.tr,
                                description:
                                    'msg_please_upload_prescription'.tr,
                                onTap1: () {
                                  getImagesFromCamera(
                                      source: ImageSource.camera);
                                },
                                onTap2: () {
                                  getImagesFromCamera(
                                      source: ImageSource.gallery);
                                },
                              ));
                            } else {
                              AppConstants().loadWithCanBack(
                                  LoginScreen(onLoginSuccess: () {
                                Get.dialog(UploadImageDialog(
                                  title: 'upload_prescription'.tr,
                                  description:
                                      'msg_please_upload_prescription'.tr,
                                  onTap1: () {
                                    getImagesFromCamera(
                                        source: ImageSource.camera);
                                  },
                                  onTap2: () {
                                    getImagesFromCamera(
                                        source: ImageSource.gallery);
                                  },
                                ));
                              }));
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.sp),
                            decoration: BoxDecoration(
                                color: primaryColor,
                                border: Border.all(color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(13.r)),
                                boxShadow: const [
                                  BoxShadow(
                                      color: borderColor,
                                      blurRadius: 3,
                                      offset: Offset(0, 5))
                                ]),
                            child: SvgPicture.asset(uploadPrescriptionIcon),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content based on search state
              Obx(() {
                if (homeScreenController.isLoading.value &&
                    searchTestScreenController.queryText.value.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CustomLoadingIndicator(),
                    ),
                  );
                } else if (searchTestScreenController.queryText.value.isEmpty) {
                  return _buildDefaultSliverContent();
                } else if (searchTestScreenController.isSearching.value) {
                  return _buildSuggestionsSliver();
                } else {
                  return _buildResultsSliver();
                }
              }),
            ],
          ),
        ),
      ),
      // ✅ Cart button
      floatingActionButton: Obx(() {
        if (searchTestScreenController.cartCount.value > 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: GestureDetector(
              onTap: () {
                goToCart();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${searchTestScreenController.cartCount.value} items in cart",
                      style: boldWhite_14,
                    ),
                    Text(
                      "view",
                      style: regularWhite_12,
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  SliverList _buildSuggestionsSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (searchTestScreenController.hasPincodeError.value) {
            return _buildPincodeError();
          }

          if (searchTestScreenController.isSuggestionLoading.value) {
            return Container(
              height: 200.h,
              child: Center(child: CustomLoadingIndicator()),
            );
          }

        final item = searchTestScreenController.suggestionList[index];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: ListTile(
            // dense: true,
            title: Text(item.name ?? "", style: mediumBlack_14),
            onTap: () {
              String currentPincode = AppConstants().getSelectedAddress()?.pincode ?? AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE);
              searchTestScreenController.selectSuggestion(item, currentPincode);
            },
          ),
        );
      },
      childCount: searchTestScreenController.hasPincodeError.value
          ? 1
          : (searchTestScreenController.isSuggestionLoading.value
              ? 1
              : searchTestScreenController.suggestionList.length),
    ),
  );
}

  SliverList _buildResultsSliver() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (searchTestScreenController.hasPincodeError.value) {
            return _buildPincodeError();
          }

          if (searchTestScreenController.isLoading.value) {
            return Container(
              height: 200.h,
              child: Center(child: CustomLoadingIndicator()),
            );
          }

          // Use your existing _buildResults method
          return _buildResults();
        },
        childCount: 1, // Since _buildResults returns a complete column
      ),
    );
  }

  SliverList _buildDefaultSliverContent() {
    if (homeScreenController.isLoading.value) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Container(
            height: 200.h,
            child: Center(child: CustomLoadingIndicator()),
          ),
        ]),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        // Carousel Slider
        Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: CarouselSlider(
            options: CarouselOptions(
              height: (Get.width / 1.1) / 2,
              aspectRatio: 16 / 6,
              viewportFraction: 0.95,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                sliderPage.value = index;
              },
              scrollDirection: Axis.horizontal,
            ),
            items: homeScreenController.sliderList.map((item) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: Get.width / 1.02,
                    margin: EdgeInsets.symmetric(horizontal: 2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: AppConstants.IMG_URL + item.image!,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const ImageErrorWidget(),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 10.h),

        // AI Medical Report Analysis Section
        PaddingHorizontal15(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 5.w, // Reduced left padding to allow logo to move left
              right: 20.w,
              top: 20.w,
              bottom: 20.w,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                  primaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: -5,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150.sp, // Set height to match logo height
                  child: Stack(
                    children: [
                      // Logo positioned at the far left
                      Positioned(
                        left: -21.w, // Move logo further left
                        top: -10.w,
                        child: Image.asset(
                          'assets/images/zetGenie.png',
                          height: 150.sp,
                          width: 150.sp,
                        ),
                      ),
                      // Text container positioned to the right with more width
                      Container(
                        margin: EdgeInsets.only(
                            left: 125.w), // Start text after logo
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'AI Medical ',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Analysis',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Container(
                              width: double.infinity,
                              child: Text(
                                'Upload your medical reports for instant AI-powered insights',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                              ),
                            ),
                            SizedBox(height: 15.h),
                            AnimatedButton(
                              onTap: () {
                                if (checkLogin()) {
                                  _showPdfUploadDialog();
                                } else {
                                  AppConstants().loadWithCanBack(
                                      LoginScreen(onLoginSuccess: () {
                                    _showPdfUploadDialog();
                                  }));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // GestureDetector(
                //   onTap: () {
                //     if (checkLogin()) {
                //       _showPdfUploadDialog();
                //     } else {
                //       AppConstants().loadWithCanBack(
                //         LoginScreen(onLoginSuccess: () {
                //           _showPdfUploadDialog();
                //         })
                //       );
                //     }
                //   },
                //   child: Container(
                //     width: double.infinity,
                //     padding: EdgeInsets.symmetric(vertical: 16.h),
                //     decoration: BoxDecoration(
                //       gradient: LinearGradient(
                //         colors: [
                //           Colors.white.withOpacity(0.8),
                //           Colors.white.withOpacity(0.6),
                //         ],
                //       ),
                //       borderRadius: BorderRadius.circular(15.r),
                //       border: Border.all(
                //         color: primaryColor.withOpacity(0.2),
                //         width: 1,
                //       ),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.white.withOpacity(0.5),
                //           blurRadius: 10,
                //           offset: const Offset(0, -2),
                //         ),
                //         BoxShadow(
                //           color: primaryColor.withOpacity(0.1),
                //           blurRadius: 10,
                //           offset: const Offset(0, 5),
                //         ),
                //       ],
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Container(
                //           padding: EdgeInsets.all(8.w),
                //           decoration: BoxDecoration(
                //             color: primaryColor.withOpacity(0.1),
                //             borderRadius: BorderRadius.circular(10.r),
                //           ),
                //           child: FaIcon(
                //             FontAwesomeIcons.fileArrowUp,
                //             color: primaryColor,
                //             size: 18.sp,
                //           ),
                //         ),
                //         SizedBox(width: 12.w),
                //         Text(
                //           'Upload Report for Analysis',
                //           style: TextStyle(
                //             fontSize: 14.sp,
                //             fontWeight: FontWeight.w600,
                //             color: primaryColor,
                //           ),
                //         ),
                //         SizedBox(width: 8.w),
                //         FaIcon(
                //           FontAwesomeIcons.chevronRight,
                //           color: primaryColor,
                //           size: 12.sp,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.shieldHalved,
                              color: Colors.green[600],
                              size: 12.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Secure & Private',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.bolt,
                              color: Colors.blue[600],
                              size: 12.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Instant Results',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // Popular Packages Section
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                        text: TextSpan(children: [
                      TextSpan(text: 'Popular', style: boldPrimary2_20),
                      TextSpan(text: ' Packages', style: boldPrimary_20)
                    ])),
                  ),
                  GestureDetector(
                      onTap: () {
                        AppConstants().loadWithCanBack(PackageListScreen(
                            // callBack: () {
                            //   homeScreenController.popularPackageList.refresh();
                            // },
                            ));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.all(Radius.circular(9.r)),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 9.w, vertical: 4.h),
                        child: Text('View all »', style: regularPrimary_12),
                      )),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            if (homeScreenController.popularPackageList.isEmpty)
              NoDataFoundWidget(title: 'no_package_found'.tr, description: '')
            else
              SizedBox(
                height: 210.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: homeScreenController.popularPackageList.length,
                  itemBuilder: (context, index) {
                    NewPackageModel packageModel =
                        homeScreenController.popularPackageList[index];
                    CustomCartModel cartModel = CustomCartModel(
                        id: packageModel.id,
                        name: packageModel.name,
                        type: AppConstants.package,
                        price: packageModel.price.toString(),
                        image: packageModel.image.toString(),
                        isFastRequired: packageModel.isFastRequired.toString(),
                        testTime: packageModel.testTime.toString(),
                        itemDetail: packageModel.itemDetail,
                        // profilesDetail:
                        // packageModel.profilesDetail,
                        cityId: packageModel.cityId,
                        labId: packageModel.labId,
                        labName: packageModel.labName,
                        labAddress: packageModel.labAddress);
                    return FutureBuilder<bool>(
                        future: homeScreenController.dbHelper.checkRecordExist(
                            id: packageModel.id.toString(),
                            type: AppConstants.package),
                        builder: (context, snapshot) {
                          return CustomContainer(
                            onTap: () {
                              Get.to(() => ItemDetailScreen(
                                    customCartModel: cartModel,
                                    description: packageModel.description,
                                  ));
                            },
                            width: Get.width / 1.2,
                            left: 15.w,
                            top: 2.h,
                            bottom: 10.h,
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.w, vertical: 12.h),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${packageModel.name}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgPicture.asset(timeIcon),
                                                  SizedBox(
                                                    width: 2.w,
                                                  ),
                                                  Text(
                                                      // '${packageModel.testTime} Hours',
                                                      '2-4 Hours',
                                                      style: regularBlack_11),
                                                ],
                                              ),
                                            ),
                                            CustomContainer(
                                              radius: 18.r,
                                              leftPadding: 6.w,
                                              rightPadding: 6.w,
                                              top: 5.h,
                                              topPadding: 2.h,
                                              bottomPadding: 2.h,
                                              bottom: 10.h,
                                              color: primaryColor,
                                              child: Text(
                                                'At ${packageModel.price} ₹ only',
                                                style: boldWhite_12,
                                              ),
                                            ),
                                            if (packageModel.itemDetail !=
                                                    null &&
                                                packageModel
                                                    .itemDetail!.isNotEmpty)
                                              Expanded(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: packageModel
                                                              .itemDetail!
                                                              .length >
                                                          5
                                                      ? 5
                                                      : packageModel
                                                          .itemDetail!.length,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemBuilder:
                                                      (context, index) {
                                                    ItemDetail labTestModel =
                                                        packageModel
                                                            .itemDetail![index];
                                                    return Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 5.h),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        5.w),
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    cardBgColor,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            9.r))),
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
                                                              child: Text(
                                                                  '${labTestModel.name}',
                                                                  style:
                                                                      regularBlack_12,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis)),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 15.w),
                                      Expanded(
                                        flex: 4,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(17.r)),
                                          child: CachedNetworkImage(
                                            height: 150.h,
                                            fit: BoxFit.cover,
                                            imageUrl:
                                                // AppConstants
                                                //     .IMG_URL +
                                                packageModel.image!,
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
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
                                    final isInCart = searchTestScreenController
                                        .cartIds
                                        .contains(packageModel.id);
                                    return GestureDetector(
                              onTap: () async {
                                if (isInCart) {
                                  // Remove from cart logic
                                  await searchTestScreenController
                                      .dbHelper
                                      .deleteFromCart(
                                          id: packageModel.id
                                              .toString(),
                                          type: AppConstants.package);
                                  searchTestScreenController.cartList
                                      .removeWhere(
                                    (item) =>
                                        item.id == packageModel.id &&
                                        item.type ==
                                            AppConstants.package,
                                  );
                                  searchTestScreenController.cartIds
                                      .remove(packageModel.id);
                                  if (searchTestScreenController
                                          .cartList.length <=
                                      1) {
                                    searchTestScreenController
                                        .customCartModel = null;
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
                                  AppConstants().setCartPincode(
                                      AppConstants()
                                              .getSelectedAddress()
                                              ?.pincode ??
                                          AppConstants()
                                              .getStorage
                                              .read(AppConstants
                                                  .CURRENT_PINCODE));
                                  if (searchTestScreenController
                                          .cartList.isEmpty ||
                                      cartModel.labId ==
                                          searchTestScreenController
                                              .cartList[0].labId) {
                                    // Same lab or empty list → allow adding
                                    setState(() {});
                                    searchTestScreenController.dbHelper
                                        .addToCart(
                                            cartModel: cartModel);
                                    searchTestScreenController.cartList
                                        .add(cartModel);
                                    searchTestScreenController.cartIds
                                        .add(packageModel.id!);
                                  } else {
                                    // Different lab → show warning
                                    Get.dialog(CommonDialog(
                                      title: 'warning'.tr,
                                      description:
                                          'msg_add_this_item_previously_added_test_will_removed'
                                              .tr,
                                      tapNoText: 'cancel'.tr,
                                      tapYesText: 'confirm'.tr,
                                      onTapNo: () {
                                        Get.back();
                                      },
                                      onTapYes: () {
                                        setState(() {});
                                        searchTestScreenController
                                            .cartList = [];
                                        searchTestScreenController
                                            .cartIds
                                            .clear();
                                        searchTestScreenController
                                            .dbHelper
                                            .clearAllRecord();
                                        searchTestScreenController
                                            .dbHelper
                                            .addToCart(
                                                cartModel: cartModel);
                                        searchTestScreenController
                                            .cartList
                                            .add(cartModel);
                                        searchTestScreenController
                                            .cartIds
                                            .add(packageModel.id!);
                                        searchTestScreenController
                                                .cartCount.value =
                                            searchTestScreenController
                                                .cartList.length;
                                        Get.back();
                                      },
                                    ));
                                  }
                                }
                                searchTestScreenController
                                        .cartCount.value =
                                    searchTestScreenController
                                        .cartList.length;
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 26.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.only(
                                      bottomRight:
                                          Radius.circular(24.r),
                                      topLeft: Radius.circular(24.r),
                                      bottomLeft: Radius.circular(10.r),
                                      topRight: Radius.circular(10.r)),
                                ),
                                child: Text(
                                    isInCart
                                        ? 'remove_from_cart'.tr
                                        : 'add_to_cart'.tr,
                                    style: semiBoldWhite_12),
                              ),
                            );
                          }),
                        )
                      ],
                    ),
                  );
                });
          },
        ),
      )
  ],
),
        // // Popular Profiles Section
        // Padding(
        //     padding: EdgeInsets.only(top: 30.h),
        //     child: Column(
        //       children: [
        //         Padding(
        //           padding: EdgeInsets.symmetric(horizontal: 15.w),
        //           child: Row(
        //             children: [
        //               Expanded(
        //                 child: RichText(
        //                     text: TextSpan(children: [
        //                       TextSpan(
        //                           text: 'Popular',
        //                           style: boldPrimary_20),
        //                       TextSpan(
        //                           text: ' Profiles',
        //                           style: boldPrimary2_20)
        //                     ])),
        //               ),
        //               GestureDetector(
        //                 onTap: () {
        //                   AppConstants().loadWithCanBack(
        //                       ProfileListScreen());
        //                 },
        //                 child: Container(
        //                     decoration: BoxDecoration(
        //                         color: cardBgColor,
        //                         borderRadius: BorderRadius.all(
        //                             Radius.circular(9.r))),
        //                     padding: EdgeInsets.symmetric(
        //                         horizontal: 9.w, vertical: 4.h),
        //                     child: Text('View all »',
        //                         style: regularPrimary_12)),
        //               ),
        //             ],
        //           ),
        //         ),
        //         SizedBox(height: 10.h),
        //         if (homeScreenController
        //             .popularProfileList.isEmpty)
        //           NoDataFoundWidget(
        //               title: 'no_profile_found'.tr,
        //               description: '')
        //         else
        //           SizedBox(
        //             height: 230.h,
        //             child: ListView.builder(
        //               scrollDirection: Axis.horizontal,
        //               physics: const BouncingScrollPhysics(),
        //               itemCount: homeScreenController
        //                   .popularProfileList.length,
        //               itemBuilder: (context, index) {
        //                 NewPackageModel packageModel =
        //                 homeScreenController
        //                     .popularProfileList[index];
        //                 CustomCartModel cartModel =
        //                 CustomCartModel(
        //                   id: packageModel.id,
        //                   name: packageModel.name,
        //                   type: AppConstants.profile,
        //                   price: packageModel.price.toString(),
        //                   image: packageModel.image.toString(),
        //                   isFastRequired: packageModel
        //                       .isFastRequired
        //                       .toString(),
        //                   testTime:
        //                   packageModel.testTime.toString(),
        //                   itemDetail: packageModel.itemDetail,
        //                   // profilesDetail:
        //                   // packageModel.profilesDetail,
        //                   cityId: packageModel.cityId,
        //                   labId: packageModel.labId,
        //                   labName: packageModel.labName,
        //                   labAddress: packageModel.labAddress
        //                 );
        //                 return FutureBuilder<bool>(
        //                     future: homeScreenController
        //                         .dbHelper
        //                         .checkRecordExist(
        //                         id: packageModel.id
        //                             .toString(),
        //                         type: AppConstants.profile),
        //                     builder: (context, snapshot) {
        //                       return CustomContainer(
        //                         onTap: () {
        //                           Get.to(() => ItemDetailScreen(
        //                               customCartModel:
        //                               cartModel));
        //                         },
        //                         width: Get.width / 1.2,
        //                         left: 15.w,
        //                         right: index ==
        //                             homeScreenController
        //                                 .popularProfileList
        //                                 .length -
        //                                 1
        //                             ? 15.w
        //                             : 0,
        //                         top: 2.h,
        //                         bottom: 10.h,
        //                         radius: 24.r,
        //                         leftPadding: 15.w,
        //                         topPadding: 8.h,
        //                         color: Colors.white,
        //                         boxShadow: [
        //                           BoxShadow(
        //                             color: borderColor
        //                                 .withOpacity(0.5),
        //                             blurRadius: 10,
        //                             spreadRadius: 1,
        //                             offset: const Offset(0, 5),
        //                           )
        //                         ],
        //                         child: Column(
        //                           children: [
        //                             Expanded(
        //                               child: Column(
        //                                 children: [
        //                                   Row(
        //                                     children: [
        //                                       Expanded(
        //                                         flex: 4,
        //                                         child:
        //                                         ClipRRect(
        //                                           borderRadius:
        //                                           BorderRadius.all(
        //                                               Radius.circular(
        //                                                   17.r)),
        //                                           child:
        //                                           CachedNetworkImage(
        //                                             // height: 150.h,
        //                                             fit: BoxFit
        //                                                 .cover,
        //                                             imageUrl: AppConstants
        //                                                 .IMG_URL +
        //                                                 packageModel
        //                                                     .image!,
        //                                             placeholder: (context,
        //                                                 url) =>
        //                                             const Center(
        //                                                 child:
        //                                                 CircularProgressIndicator()),
        //                                             errorWidget: (context,
        //                                                 url,
        //                                                 error) =>
        //                                             const ImageErrorWidget(),
        //                                           ),
        //                                         ),
        //                                       ),
        //                                       Expanded(
        //                                         flex: 6,
        //                                         child:
        //                                         Padding(
        //                                           padding: EdgeInsets.symmetric(horizontal: 15.w),
        //                                           child: Column(
        //                                             mainAxisSize:
        //                                             MainAxisSize
        //                                                 .min,
        //                                             crossAxisAlignment:
        //                                             CrossAxisAlignment
        //                                                 .end,
        //                                             children: [
        //                                               Text(
        //                                                 '${packageModel.name}',
        //                                                 maxLines:
        //                                                 2,
        //                                                 overflow:
        //                                                 TextOverflow.ellipsis,
        //                                                 style:
        //                                                 boldBlack_16,
        //                                                 textAlign:
        //                                                 TextAlign.end,
        //                                               ),
        //                                               CustomContainer(
        //                                                 borderColor:
        //                                                 borderColor,
        //                                                 radius:
        //                                                 18.r,
        //                                                 leftPadding:
        //                                                 6.w,
        //                                                 rightPadding:
        //                                                 6.w,
        //                                                 top:
        //                                                 5.h,
        //                                                 topPadding:
        //                                                 2.h,
        //                                                 bottomPadding:
        //                                                 2.h,
        //                                                 color:
        //                                                 cardBgColor,
        //                                                 child:
        //                                                 Row(
        //                                                   mainAxisSize:
        //                                                   MainAxisSize.min,
        //                                                   children: [
        //                                                     SvgPicture.asset(timeIcon),
        //                                                     SizedBox(
        //                                                       width: 2.w,
        //                                                     ),
        //                                                     Text('${packageModel.testTime}',
        //                                                         style: regularBlack_11),
        //                                                   ],
        //                                                 ),
        //                                               ),
        //                                               CustomContainer(
        //                                                 radius:
        //                                                 18.r,
        //                                                 leftPadding:
        //                                                 6.w,
        //                                                 rightPadding:
        //                                                 6.w,
        //                                                 top:
        //                                                 5.h,
        //                                                 topPadding:
        //                                                 2.h,
        //                                                 bottomPadding:
        //                                                 2.h,
        //                                                 bottom:
        //                                                 10.h,
        //                                                 color:
        //                                                 primaryColor,
        //                                                 child:
        //                                                 Text(
        //                                                   'At ${packageModel.price} ₹ only',
        //                                                   style:
        //                                                   boldWhite_12,
        //                                                 ),
        //                                               ),
        //                                             ],
        //                                           ),
        //                                         ),
        //                                       ),
        //                                     ],
        //                                   ),
        //                                   if (packageModel
        //                                       .itemDetail !=
        //                                       null &&
        //                                       packageModel
        //                                           .itemDetail!
        //                                           .isNotEmpty)
        //                                     ListView.builder(
        //                                       shrinkWrap: true,
        //                                       padding:
        //                                       EdgeInsets
        //                                           .zero,
        //                                       itemCount: packageModel
        //                                           .itemDetail!
        //                                           .length >
        //                                           4
        //                                           ? 4
        //                                           : packageModel
        //                                           .itemDetail!
        //                                           .length,
        //                                       physics:
        //                                       const NeverScrollableScrollPhysics(),
        //                                       itemBuilder:
        //                                           (context,
        //                                           index) {
        //                                         ItemDetail
        //                                         labTestModel =
        //                                         packageModel
        //                                             .itemDetail![
        //                                         index];
        //                                         return Padding(
        //                                           padding: EdgeInsets
        //                                               .only(
        //                                               bottom:
        //                                               5.h),
        //                                           child: Row(
        //                                             crossAxisAlignment:
        //                                             CrossAxisAlignment
        //                                                 .start,
        //                                             children: [
        //                                               Container(
        //                                                 padding:
        //                                                 EdgeInsets.symmetric(horizontal: 5.w),
        //                                                 decoration: BoxDecoration(
        //                                                     color:
        //                                                     cardBgColor,
        //                                                     borderRadius:
        //                                                     BorderRadius.all(Radius.circular(9.r))),
        //                                                 child:
        //                                                 Text(
        //                                                   '◈',
        //                                                   style:
        //                                                   regularPrimary_12,
        //                                                 ),
        //                                               ),
        //                                               SizedBox(
        //                                                   width:
        //                                                   5.w),
        //                                               Expanded(
        //                                                   child: Text(
        //                                                       '${labTestModel.name}',
        //                                                       style: regularBlack_12,
        //                                                       maxLines: 1,
        //                                                       overflow: TextOverflow.ellipsis)),
        //                                             ],
        //                                           ),
        //                                         );
        //                                       },
        //                                     ),
        //                                 ],
        //                               ),
        //                             ),
        //                             GestureDetector(
        //                               onTap: () async {
        //                                 if (snapshot.data !=
        //                                     null &&
        //                                     snapshot.data!) {
        //                                   await searchTestScreenController
        //                                       .dbHelper
        //                                       .deleteRecordFormCart(
        //                                       id: packageModel
        //                                           .id
        //                                           .toString(),
        //                                       type: AppConstants
        //                                           .profile);
        //                                   searchTestScreenController.cartList.removeWhere(
        //                                         (item) => item.id == packageModel.id && item.type == AppConstants.profile,
        //                                   );
        //                                   if(searchTestScreenController.cartList.length <= 1) {
        //                                     searchTestScreenController.customCartModel = null;
        //                                     AppConstants().clearCartPincode();
        //                                   }
        //                                 } else {
        //                                   if (searchTestScreenController.cartList.isEmpty || cartModel.labId == searchTestScreenController.cartList[0].labId) {
        //                                     // Same lab or empty list → allow adding
        //                                     setState(() {});
        //                                     searchTestScreenController.dbHelper.addToCart(cartModel: cartModel);
        //                                     searchTestScreenController.cartList.add(cartModel);
        //                                   } else {
        //                                     // Different lab → show warning
        //                                     Get.dialog(CommonDialog(
        //                                       title: 'warning'.tr,
        //                                       description: 'msg_add_this_item_previously_added_test_will_removed'.tr,
        //                                       tapNoText: 'cancel'.tr,
        //                                       tapYesText: 'confirm'.tr,
        //                                       onTapNo: () {
        //                                         // snapshot.data = !snapshot.data;
        //                                         Get.back();
        //                                       },
        //                                       onTapYes: () {
        //                                         searchTestScreenController.cartList = [];
        //                                         searchTestScreenController.dbHelper.clearAllRecord();
        //                                         searchTestScreenController.dbHelper.addToCart(cartModel: cartModel);
        //                                         searchTestScreenController.cartList.add(cartModel);
        //                                         setState(() {});
        //                                         searchTestScreenController.cartCount.value = searchTestScreenController.cartList.length;
        //                                         Get.back();
        //                                       },
        //                                     ));
        //                                   }
        //                                   AppConstants().setCartPincode(AppConstants().getSelectedAddress()?.pincode ?? AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE));
        //                                 }
        //                                 searchTestScreenController.cartCount.value = searchTestScreenController.cartList.length;
        //                                 homeScreenController
        //                                     .popularProfileList
        //                                     .refresh();
        //                               },
        //                               child: Align(
        //                                 alignment: Alignment
        //                                     .centerRight,
        //                                 child: Container(
        //                                   padding: EdgeInsets
        //                                       .symmetric(
        //                                       horizontal:
        //                                       26.w,
        //                                       vertical:
        //                                       6.h),
        //                                   decoration:
        //                                   BoxDecoration(
        //                                     color: primaryColor,
        //                                     borderRadius: BorderRadius.only(
        //                                         bottomRight: Radius
        //                                             .circular(
        //                                             24.r),
        //                                         topLeft: Radius
        //                                             .circular(
        //                                             24.r),
        //                                         bottomLeft: Radius
        //                                             .circular(
        //                                             10.r),
        //                                         topRight: Radius
        //                                             .circular(
        //                                             10.r)),
        //                                   ),
        //                                   child: Text(
        //                                       snapshot.data !=
        //                                           null &&
        //                                           snapshot
        //                                               .data!
        //                                           ? 'remove_from_cart'
        //                                           .tr
        //                                           : 'add_to_cart'
        //                                           .tr,
        //                                       style:
        //                                       semiBoldWhite_12),
        //                                 ),
        //                               ),
        //                             )
        //                           ],
        //                         ),
        //                       );
        //                     });
        //               },
        //             ),
        //           )
        //       ],
        //     )
        // ),

        // Lifestyle Packages Section
        Padding(
            padding: EdgeInsets.only(top: 30.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                            text: TextSpan(children: [
                          TextSpan(text: 'Lifestyle', style: boldPrimary_20),
                          TextSpan(text: ' Packages', style: boldPrimary2_20)
                        ])),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppConstants()
                              .loadWithCanBack(LifestylePackageListScreen(
                            homeScreenController.lifeStylePackageList,
                            homeScreenController.filterList,
                            // callBack: () {
                            //   homeScreenController.lifeStylePackageList.refresh();
                            // },
                          ));
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.r))),
                            padding: EdgeInsets.symmetric(
                                horizontal: 9.w, vertical: 4.h),
                            child:
                                Text('View all »', style: regularPrimary_12)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                if (homeScreenController.lifeStylePackageList.isEmpty)
                  NoDataFoundWidget(
                      title: 'no_package_found'.tr, description: '')
                else
                  SizedBox(
                    height: 230.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount:
                          homeScreenController.lifeStylePackageList.length,
                      itemBuilder: (context, index) {
                        NewPackageModel packageModel =
                            homeScreenController.lifeStylePackageList[index];
                        CustomCartModel cartModel = CustomCartModel(
                          id: packageModel.id,
                          name: packageModel.name,
                          type: AppConstants.package,
                          price: packageModel.price.toString(),
                          image: packageModel.image.toString(),
                          isFastRequired:
                              packageModel.isFastRequired.toString(),
                          testTime: packageModel.testTime.toString(),
                          itemDetail: packageModel.itemDetail,
                          // profilesDetail:
                          // packageModel.profilesDetail,
                          cityId: packageModel.cityId,
                          labId: packageModel.labId,
                          labName: packageModel.labName,
                          labAddress: packageModel.labAddress,
                        );
                        return FutureBuilder<bool>(
                            future: homeScreenController.dbHelper
                                .checkRecordExist(
                                    id: packageModel.id.toString(),
                                    type: AppConstants.package),
                            builder: (context, snapshot) {
                              return CustomContainer(
                                onTap: () {
                                  Get.to(() => ItemDetailScreen(
                                        customCartModel: cartModel,
                                        description: packageModel.description,
                                      ));
                                },
                                width: Get.width / 1.2,
                                left: 15.w,
                                top: 2.h,
                                bottom: 10.h,
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.w, vertical: 12.h),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
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
                                                          // '${packageModel.testTime} Hours',
                                                          '2-4 Hours',
                                                          style:
                                                              regularBlack_11),
                                                    ],
                                                  ),
                                                ),
                                                CustomContainer(
                                                  radius: 18.r,
                                                  leftPadding: 6.w,
                                                  rightPadding: 6.w,
                                                  top: 5.h,
                                                  topPadding: 2.h,
                                                  bottomPadding: 2.h,
                                                  bottom: 10.h,
                                                  color: primaryColor,
                                                  child: Text(
                                                    'At ${packageModel.price} ₹ only',
                                                    style: boldWhite_12,
                                                  ),
                                                ),
                                                if (packageModel.itemDetail !=
                                                        null &&
                                                    packageModel
                                                        .itemDetail!.isNotEmpty)
                                                  Expanded(
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      itemCount: packageModel
                                                                  .itemDetail!
                                                                  .length >
                                                              5
                                                          ? 5
                                                          : packageModel
                                                              .itemDetail!
                                                              .length,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        ItemDetail
                                                            labTestModel =
                                                            packageModel
                                                                    .itemDetail![
                                                                index];
                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 5.h),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5.w),
                                                                decoration: BoxDecoration(
                                                                    color:
                                                                        cardBgColor,
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(9.r))),
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
                                                                  child: Text(
                                                                      '${labTestModel.name}',
                                                                      style:
                                                                          regularBlack_12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis)),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 15.w),
                                          Expanded(
                                            flex: 4,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(17.r)),
                                              child: CachedNetworkImage(
                                                height: 150.h,
                                                fit: BoxFit.cover,
                                                imageUrl:
                                                    // AppConstants
                                                    //     .IMG_URL +
                                                    packageModel.image!,
                                                placeholder: (context, url) =>
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
                                        final isInCart =
                                            searchTestScreenController.cartIds
                                                .contains(packageModel.id);
                                        return GestureDetector(
                                          onTap: () async {
                                  if (isInCart) {
                                    await searchTestScreenController
                                        .dbHelper
                                        .deleteFromCart(
                                            id: packageModel.id
                                                .toString(),
                                            type:
                                                AppConstants.package);
                                    searchTestScreenController
                                        .cartList
                                        .removeWhere(
                                      (item) =>
                                          item.id ==
                                              packageModel.id &&
                                          item.type ==
                                              AppConstants.package,
                                    );
                                    searchTestScreenController.cartIds
                                        .remove(packageModel.id);
                                    if (searchTestScreenController
                                            .cartList.length <=
                                        1) {
                                      searchTestScreenController
                                          .customCartModel = null;
                                      AppConstants()
                                          .clearCartPincode();
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
                                    AppConstants().setCartPincode(
                                        AppConstants()
                                                .getSelectedAddress()
                                                ?.pincode ??
                                            AppConstants()
                                                .getStorage
                                                .read(AppConstants
                                                    .CURRENT_PINCODE));
                                    if (searchTestScreenController
                                            .cartList.isEmpty ||
                                        cartModel.labId ==
                                            searchTestScreenController
                                                .cartList[0].labId) {
                                      // Same lab or empty list → allow adding
                                      setState(() {});
                                      searchTestScreenController
                                          .dbHelper
                                          .addToCart(
                                              cartModel: cartModel);
                                      searchTestScreenController
                                          .cartList
                                          .add(cartModel);
                                      searchTestScreenController
                                          .cartIds
                                          .add(packageModel.id!);
                                    } else {
                                      // Different lab → show warning
                                      Get.dialog(CommonDialog(
                                        title: 'warning'.tr,
                                        description:
                                            'msg_add_this_item_previously_added_test_will_removed'
                                                .tr,
                                        tapNoText: 'cancel'.tr,
                                        tapYesText: 'confirm'.tr,
                                        onTapNo: () {
                                          Get.back();
                                        },
                                        onTapYes: () {
                                          setState(() {});
                                          searchTestScreenController
                                              .cartList = [];
                                          searchTestScreenController
                                              .cartIds
                                              .clear();
                                          searchTestScreenController
                                              .dbHelper
                                              .clearAllRecord();
                                          searchTestScreenController
                                              .dbHelper
                                              .addToCart(
                                                  cartModel: cartModel);
                                          searchTestScreenController
                                              .cartList
                                              .add(cartModel);
                                          searchTestScreenController
                                              .cartIds
                                              .add(packageModel.id!);
                                          searchTestScreenController
                                                  .cartCount.value =
                                              searchTestScreenController
                                                  .cartList.length;
                                          Get.back();
                                        },
                                      ));
                                    }
                                  }
                                  searchTestScreenController
                                          .cartCount.value =
                                      searchTestScreenController
                                          .cartList.length;
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 26.w,
                                      vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.only(
                                        bottomRight:
                                            Radius.circular(24.r),
                                        topLeft:
                                            Radius.circular(24.r),
                                        bottomLeft:
                                            Radius.circular(10.r),
                                        topRight:
                                            Radius.circular(10.r)),
                                  ),
                                  child: Text(
                                      isInCart
                                          ? 'remove_from_cart'.tr
                                          : 'add_to_cart'.tr,
                                      style: semiBoldWhite_12),
                                ),
                              );
                            }),
                          )
                        ],
                      ),
                    );
                  });
            },
          ),
        )
    ],
  ),
),

        // Popular Tests Section
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 30.h),
        //   child: Row(
        //     children: [
        //       RichText(
        //           text: TextSpan(children: [
        //             TextSpan(
        //                 text: 'Popular', style: boldPrimary_20),
        //             TextSpan(text: ' Tests', style: boldPrimary2_20)
        //           ])),
        //       const Spacer(),
        //       GestureDetector(
        //         onTap: () {
        //           AppConstants().loadWithCanBack(
        //               const PopularTestScreen());
        //         },
        //         child: Container(
        //             decoration: BoxDecoration(
        //                 color: cardBgColor,
        //                 borderRadius: BorderRadius.all(
        //                     Radius.circular(9.r))),
        //             padding: EdgeInsets.symmetric(
        //                 horizontal: 9.w, vertical: 4.h),
        //             child: Text('View all »',
        //                 style: regularPrimary_12)),
        //       ),
        //     ],
        //   ),
        // ),
        // SizedBox(height: 10.h),
        // homeScreenController.popularLabTestList.isEmpty
        //     ? NoDataFoundWidget(
        //     title: 'no_test_found'.tr, description: '')
        //     : SizedBox(
        //   height: 159.h,
        //   child: ListView.builder(
        //     scrollDirection: Axis.horizontal,
        //     physics: const BouncingScrollPhysics(),
        //     itemCount: homeScreenController
        //         .popularLabTestList.length,
        //     itemBuilder: (context, index) {
        //       TestModel labTestModel =
        //       homeScreenController
        //           .popularLabTestList[index];
        //       CustomCartModel cartModel = CustomCartModel(
        //         id: labTestModel.id,
        //         name: labTestModel.name,
        //         type: AppConstants.test,
        //         price: labTestModel.price.toString(),
        //         image: labTestModel.image.toString(),
        //         isFastRequired: labTestModel
        //             .isFastRequired
        //             .toString(),
        //         testTime:
        //         labTestModel.testTime.toString(),
        //         itemDetail: labTestModel.itemDetail,
        //         profilesDetail:
        //         labTestModel.profilesDetail,
        //       );
        //       return FutureBuilder<bool>(
        //           future: homeScreenController.dbHelper
        //               .checkRecordExist(
        //               id: labTestModel.id.toString(),
        //               type: AppConstants.test),
        //           builder: (context, snapshot) {
        //             return CustomContainer(
        //               onTap: () {
        //                 Get.to(() => ItemDetailScreen(
        //                     customCartModel: cartModel));
        //               },
        //               width: 131.w,
        //               left: 15.w,
        //               top: 2.h,
        //               bottom: 10.h,
        //               color: Colors.white,
        //               radius: 20.r,
        //               boxShadow: [
        //                 BoxShadow(
        //                   color: borderColor
        //                       .withOpacity(0.5),
        //                   blurRadius: 10,
        //                   spreadRadius: 1,
        //                   offset: const Offset(0, 5),
        //                 )
        //               ],
        //               child: Column(
        //                 crossAxisAlignment:
        //                 CrossAxisAlignment.start,
        //                 children: [
        //                   Padding(
        //                     padding: EdgeInsets.only(
        //                         left: 15.w,
        //                         top: 15.h,
        //                         bottom: 7.h),
        //                     child: Row(
        //                       children: [
        //                         Container(
        //                           height: 50.h,
        //                           width: 55.w,
        //                           decoration:
        //                           BoxDecoration(
        //                             color: cardBgColor,
        //                             borderRadius:
        //                             BorderRadius.all(
        //                                 Radius
        //                                     .circular(
        //                                     10.r)),
        //                           ),
        //                           child:
        //                           CachedNetworkImage(
        //                             height: 50.h,
        //                             width: 55.w,
        //                             fit: BoxFit.cover,
        //                             imageUrl: AppConstants
        //                                 .IMG_URL +
        //                                 labTestModel
        //                                     .image!,
        //                             placeholder: (context,
        //                                 url) =>
        //                             const Center(
        //                                 child:
        //                                 CircularProgressIndicator()),
        //                             errorWidget: (context,
        //                                 url, error) =>
        //                             const ImageErrorWidget(),
        //                           ),
        //                         ),
        //                         const Spacer(),
        //                         Container(
        //                           padding:
        //                           const EdgeInsets
        //                               .all(5),
        //                           decoration: BoxDecoration(
        //                               color: cardBgColor,
        //                               borderRadius: BorderRadius.only(
        //                                   topLeft: Radius
        //                                       .circular(
        //                                       10.r),
        //                                   bottomLeft: Radius
        //                                       .circular(
        //                                       10.r)),
        //                               border: Border.all(
        //                                   color:
        //                                   borderColor)),
        //                           child: Text(
        //                             '${labTestModel.price} ₹',
        //                             style:
        //                             semiBoldPrimary_12,
        //                           ),
        //                         )
        //                       ],
        //                     ),
        //                   ),
        //                   Padding(
        //                     padding: EdgeInsets.symmetric(
        //                         horizontal: 15.w),
        //                     child: Text(
        //                         '${labTestModel.name}',
        //                         style: mediumBlack_12,
        //                         maxLines: 2,
        //                         overflow: TextOverflow
        //                             .ellipsis),
        //                   ),
        //                   const Spacer(),
        //                   GestureDetector(
        //                     onTap: () async {
        //                       if (snapshot.data != null &&
        //                           snapshot.data!) {
        //                         await homeScreenController
        //                             .dbHelper
        //                             .deleteRecordFormCart(
        //                             id: labTestModel
        //                                 .id
        //                                 .toString(),
        //                             type: AppConstants
        //                                 .test);
        //                       } else {
        //                         await homeScreenController
        //                             .dbHelper
        //                             .insertRecordCart(
        //                             cartModel:
        //                             cartModel);
        //                       }
        //                       homeScreenController
        //                           .popularLabTestList
        //                           .refresh();
        //                     },
        //                     child: Container(
        //                       margin:
        //                       const EdgeInsets.all(2),
        //                       padding:
        //                       EdgeInsets.symmetric(
        //                           vertical: 6.h),
        //                       width: Get.width,
        //                       decoration: BoxDecoration(
        //                           color: primaryColor,
        //                           borderRadius:
        //                           BorderRadius.only(
        //                               topLeft: Radius
        //                                   .circular(
        //                                   9.r),
        //                               topRight: Radius
        //                                   .circular(
        //                                   9.r),
        //                               bottomLeft: Radius
        //                                   .circular(
        //                                   20.r),
        //                               bottomRight:
        //                               Radius.circular(
        //                                   20.r))),
        //                       child: Center(
        //                           child: Text(
        //                               snapshot.data !=
        //                                   null &&
        //                                   snapshot
        //                                       .data!
        //                                   ? 'remove_from_cart'
        //                                   .tr
        //                                   : 'add_to_cart'
        //                                   .tr,
        //                               style:
        //                               boldWhite_12)),
        //                     ),
        //                   )
        //                 ],
        //               ),
        //             );
        //           });
        //     },
        //   ),
        // ),

        // Popular Profile Section
        // if (homeScreenController.popularProfileList.isNotEmpty)
        //   Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 30.h),
        //     child: Row(
        //       children: [
        //         RichText(
        //             text: TextSpan(children: [
        //               TextSpan(
        //                   text: 'Popular',
        //                   style: boldPrimary_20),
        //               TextSpan(
        //                   text: ' Profile',
        //                   style: boldPrimary2_20)
        //             ])),
        //         const Spacer(),
        //         GestureDetector(
        //           onTap: () {
        //             AppConstants().loadWithCanBack(
        //                 const ProfileListScreen());
        //           },
        //           child: Container(
        //             decoration: BoxDecoration(
        //               color: cardBgColor,
        //               borderRadius: BorderRadius.all(
        //                   Radius.circular(9.r)),
        //             ),
        //             padding: EdgeInsets.symmetric(
        //                 horizontal: 9.w, vertical: 4.h),
        //             child: Text(
        //               'View all »',
        //               style: regularPrimary_12,
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // if (homeScreenController.popularProfileList.isNotEmpty)
        //   SizedBox(
        //       height: 10.h),
        // if (homeScreenController.popularProfileList.isNotEmpty)
        //   SizedBox(
        //     height: 165.h,
        //     child: ListView.builder(
        //       scrollDirection: Axis.horizontal,
        //       physics: const BouncingScrollPhysics(),
        //       itemCount: homeScreenController
        //           .popularProfileList.length,
        //       itemBuilder: (context, index) {
        //         // Add your profile list builder code here
        //         return SizedBox.shrink(); // Placeholder
        //       },
        //     ),
        //   ),
      ]),
    );
  }

/*  getImagesFromCamera({required ImageSource source} ) async {
    try{
      Get.back();
      XFile? pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 40);
      if (pickedFile != null) {
        cropImage(pickedFile);
        // setState(() {
        //   editProfileScreenController.profileImage = pickedFile;
        // });
      }
    }
    catch (e) {
      print("Error picking image: $e");
    }
  }*/

  Future<void> getImagesFromCamera({required ImageSource source}) async {
    try {
      Get.back(); // Close the dialog first

      // Let image_picker handle permissions internally
      XFile? pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 40,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        cropImage(pickedFile);
      }
      // If pickedFile is null, user simply cancelled - no need to show any message
    } catch (e) {
      print("Error picking image: $e");
      // Handle specific error cases
      String errorMessage = 'Failed to pick image';
      if (e.toString().contains('camera_access_denied')) {
        errorMessage =
            'Camera permission denied. Please enable camera access in settings.';
        _showPermissionDeniedDialog('Camera');
      } else if (e.toString().contains('photo_access_denied')) {
        errorMessage =
            'Photo library permission denied. Please enable photo access in settings.';
        _showPermissionDeniedDialog('Gallery');
      } else {
        AppConstants().showToast(errorMessage);
      }
    }
  }

  Future<void> cropImage(XFile pickedFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.png,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 40,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            hidesNavigationBar: false,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          homeScreenController.prescriptionImg = croppedFile;
          homeScreenController.callUploadPrescriptionApi(context);
        });
      }
    } catch (e) {
      print("Error cropping image: $e");
    }
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 150.h,
      child: Obx(() {
        if (searchTestScreenController.hasPincodeError.value) {
          return _buildPincodeError();
        }

        return searchTestScreenController.isSuggestionLoading.value
            ? const CustomLoadingIndicator()
            : ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: searchTestScreenController.suggestionList.length,
                itemBuilder: (ctx, i) {
                  final item = searchTestScreenController.suggestionList[i];
                  return ListTile(
                    title: Text(item.name ?? ""),
                    onTap: () {
                      String currentPincode = AppConstants()
                          .getStorage
                          .read(AppConstants.CURRENT_PINCODE);
                      searchTestScreenController.selectSuggestion(
                          item, currentPincode);
                    },
                  );
                },
              );
      }),
    );
  }

  Widget _buildPincodeError() {
    return PaddingHorizontal15(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'Service Not Available',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'We are currently not serviceable in your locality. We will be expanding our operations soon in your location',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () {
                searchTestScreenController.clearSearch();
              },
              child: Text(
                'Back to Home',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return PaddingHorizontal15(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 150.h,
        child: Obx(() {
          if (searchTestScreenController.isLoading.value) {
            return const CustomLoadingIndicator();
          }

          if (searchTestScreenController.hasPincodeError.value) {
            return _buildPincodeError();
          }

          if (!searchTestScreenController.isLoading.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _ensureValidTab(); // function placed inside the widget class
            });

            // bool allEmpty =
            //     searchTestScreenController.testList.isEmpty &&
            //         searchTestScreenController.packageList.isEmpty &&
            //         searchTestScreenController.profileList.isEmpty;
            //
            // if (allEmpty) {
            //   return NoDataFoundWidget(
            //     title: 'No results found',
            //     description: 'Please try a different search or location.',
            //   );
            // }
          }

         return Column(
             children: [
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
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
               Row(
                 children: [
                   if (searchTestScreenController.testList.isNotEmpty)
                     GestureDetector(
                       onTap: () {
                         FocusScope.of(context).unfocus();
                         searchTestScreenController.selectedFilter.value = 0;
                       },
                       child: Container(
                         height: 30.h,
                         padding: EdgeInsets.symmetric(horizontal: 15.w),
                         alignment: Alignment.center,
                         margin: EdgeInsets.only(right: 8.w),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(100),
                           border: Border.all(
                             color: searchTestScreenController.selectedFilter.value == 0
                                 ? primaryColor
                                 : borderColor,
                           ),
                           color: searchTestScreenController.selectedFilter.value == 0
                               ? borderColor
                               : whiteColor,
                         ),
                         child: Text(
                           'Tests',
                           style: TextStyle(
                             fontFamily: semiBold,
                             fontSize: 12.sp,
                             color: searchTestScreenController.selectedFilter.value == 0
                                 ? black
                                 : primaryColor,
                           ),
                         ),
                       ),
                     ),

                   if (searchTestScreenController.packageList.isNotEmpty)
                     GestureDetector(
                       onTap: () {
                         FocusScope.of(context).unfocus();
                         searchTestScreenController.selectedFilter.value = 1;
                       },
                       child: Container(
                         height: 30.h,
                         padding: EdgeInsets.symmetric(horizontal: 15.w),
                         alignment: Alignment.center,
                         margin: EdgeInsets.only(right: 8.w),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(100),
                           border: Border.all(
                             color: searchTestScreenController.selectedFilter.value == 1
                                 ? primaryColor
                                 : borderColor,
                           ),
                           color: searchTestScreenController.selectedFilter.value == 1
                               ? borderColor
                               : whiteColor,
                         ),
                         child: Text(
                           'Packages',
                           style: TextStyle(
                             fontFamily: semiBold,
                             fontSize: 12.sp,
                             color: searchTestScreenController.selectedFilter.value == 1
                                 ? black
                                 : primaryColor,
                           ),
                         ),
                       ),
                     ),

                   if (searchTestScreenController.profileList.isNotEmpty)
                     GestureDetector(
                       onTap: () {
                         FocusScope.of(context).unfocus();
                         searchTestScreenController.selectedFilter.value = 2;
                       },
                       child: Container(
                         height: 30.h,
                         padding: EdgeInsets.symmetric(horizontal: 15.w),
                         alignment: Alignment.center,
                         margin: EdgeInsets.only(right: 8.w),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(100),
                           border: Border.all(
                             color: searchTestScreenController.selectedFilter.value == 2
                                 ? primaryColor
                                 : borderColor,
                           ),
                           color: searchTestScreenController.selectedFilter.value == 2
                               ? borderColor
                               : whiteColor,
                         ),
                         child: Text(
                           'Profile',
                           style: TextStyle(
                             fontFamily: semiBold,
                             fontSize: 12.sp,
                             color: searchTestScreenController.selectedFilter.value == 2
                                 ? black
                                 : primaryColor,
                           ),
                         ),
                       ),
                     ),
                 ],
               ),
               SizedBox(height: 15.h),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is UserScrollNotification ||
                    notification is ScrollUpdateNotification) {
                  final metrics = notification.metrics;

                  // If user is scrolling down and inner list is at the end
                  if (metrics.pixels >= metrics.maxScrollExtent &&
                      notification is ScrollUpdateNotification &&
                      notification.scrollDelta != null &&
                      notification.scrollDelta! > 0) {
                    if (outerScrollController.hasClients) {
                      // instantly move outer scroll by same delta
                      outerScrollController.jumpTo(
                        outerScrollController.offset + notification.scrollDelta!,
                      );
                    }
                  }

                  // If user is scrolling up and inner list is at the top
                  if (metrics.pixels <= metrics.minScrollExtent &&
                      notification is ScrollUpdateNotification &&
                      notification.scrollDelta != null &&
                      notification.scrollDelta! < 0) {
                    if (outerScrollController.hasClients) {
                      outerScrollController.jumpTo(
                        outerScrollController.offset + notification.scrollDelta!,
                      );
                    }
                  }
                }
                return false;
              },
            child: ListView.builder(
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

                     debugPrint("🛒 BEFORE Creating CustomCartModel:");
                    debugPrint("🛒 Original item - ID: ${labTestModel.id}, Name: ${labTestModel.name}");
                    debugPrint("🛒 Original itemDetail: ${labTestModel.itemDetail?.length ?? 0} items");
                    if (labTestModel.itemDetail != null && labTestModel.itemDetail!.isNotEmpty) {
                      for (var i = 0; i < labTestModel.itemDetail!.length; i++) {
                        debugPrint("🛒   ItemDetail[$i]: ${labTestModel.itemDetail![i].name}");
                      }
                    }
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
                     debugPrint("🛒 AFTER Creating CustomCartModel:");
                        debugPrint("🛒 Custom item - ID: ${custom.id}, Name: ${custom.name}");
                        debugPrint("🛒 Custom itemDetail: ${custom.itemDetail?.length ?? 0} items");
                        if (custom.itemDetail != null && custom.itemDetail!.isNotEmpty) {
                          for (var i = 0; i < custom.itemDetail!.length; i++) {
                            debugPrint("🛒   Custom ItemDetail[$i]: ${custom.itemDetail![i].name}");
                          }
                        }

                    if (searchTestScreenController.customCartModel ==
                        null) {
                      searchTestScreenController.customCartModel =
                          custom;
                      commonSelectionProcess(
                          labTestModel: labTestModel);
                    } else if (searchTestScreenController
                        .customCartModel!.labId ==
                        labTestModel.labId) {
                      commonSelectionProcess(
                          labTestModel: labTestModel);
                    } else {
                      Get.dialog(CommonDialog(
                        title: 'warning'.tr,
                        description:
                        'selected_item_is_from_different_lab'.tr,
                        tapNoText: 'cancel'.tr,
                        tapYesText: 'confirm'.tr,
                        onTapNo: () => Get.back(),
                        onTapYes: () {
                          Get.back();
                          for (var test in searchTestScreenController
                              .testList) {
                            if (test.isSelected) {
                              searchTestScreenController.dbHelper
                                  .deleteRecordFormCart(
                                  id: labTestModel.id.toString(),
                                  type: labTestModel.type!);
                              test.isSelected = false;
                            }
                          }
                          for (var package
                          in searchTestScreenController
                              .packageList) {
                            if (package.isSelected) {
                              searchTestScreenController.dbHelper
                                  .deleteRecordFormCart(
                                  id: labTestModel.id.toString(),
                                  type: labTestModel.type!);
                              package.isSelected = false;
                            }
                          }
                          for (var profile
                          in searchTestScreenController
                              .profileList) {
                            if (profile.isSelected) {
                              searchTestScreenController.dbHelper
                                  .deleteRecordFormCart(
                                  id: labTestModel.id.toString(),
                                  type: labTestModel.type!);
                              profile.isSelected = false;
                            }
                          }
                          searchTestScreenController.customCartModel =
                              custom;
                          commonSelectionProcess(
                              labTestModel: labTestModel);
                        },
                      ));
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
                      border: Border.all(color: borderColor),
                      color: labTestModel.isSelected
                          ? borderColor
                          : cardBgColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Expanded(
                        //     child:
                        Column(
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
                          ],
                        ),
                        // ),
                        SizedBox(height: 10.h),
                        // IntrinsicHeight(
                        //   child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Expanded(
                            //     child:
                            Text(
                                '₹ ${labTestModel.price}',
                                style: semiBoldBlack_14),
                            // ),
                            // const Spacer(),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: 80.w,
                              height: 25.w,
                              decoration: BoxDecoration(
                                color: labTestModel.isSelected ? greenColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: borderColor, width: 1.w),
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(opacity: animation, child: child),
                                  child: labTestModel.isSelected
                                      ? Text(
                                    'In cart',
                                    // key: const ValueKey('inCart'),
                                    style: regularWhite_10,
                                  )
                                      : Text(
                                    'Add to cart',
                                    // key: const ValueKey('addToCart'),
                                    style: regularBlack_10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // )
                      ],
                    ),
                  ),
                );
              },
            ),
            ),
          ),
        ]);
  }
      ),),
    );
  }

  goToCart() {
    searchTestScreenController.clearSearch();
    // AppConstants().loadWithCanBack(AvailableLabsScreen(callBack: callBack));
    if (AppConstants().getStorage.read(AppConstants.isCartExist)) {
      AppConstants().loadWithCanBack(const MyCartScreen());
    } else {
      // AppConstants().loadWithCanBack(AvailableLabsScreen(callBack: callBack));
      SearchResultController searchResultController =
          Get.find<SearchResultController>();
      if (!checkLogin() || searchResultController.cartList.isEmpty) {
        AppConstants().loadWithCanBack(const MyCartScreen());
      } else {
        searchResultController.callTestWiseLabApi(toViewCart: true);
      }
    }
  }

  Future<void> callBack() async {
    // Refresh cart or update UI when coming back
    searchTestScreenController.cartList =
        await searchTestScreenController.dbHelper.getCartList();
    searchTestScreenController.cartCount.value =
        searchTestScreenController.cartList.length;
    debugPrint("✅ Cart callback triggered");
  }

commonSelectionProcess({required CustomCartModel labTestModel}) {
  // Check if user is logged in
  if (!checkLogin()) {
    // Show login snackbar instead of adding to cart
    LoginPromptSnackbar.show(
      message: 'Please login to add items to cart',
      onLoginTap: () {
        AppConstants().loadWithCanBack(
          LoginScreen(
            onLoginSuccess: () {
              homeScreenController.callHomeApi();
              // After login, user can add to cart
              labTestModel.isSelected = !labTestModel.isSelected;
              _performAddToCart(labTestModel);
            },
          ),
        );
      },
    );
    return;
  }

    debugPrint("🛒 ADD TO CART PROCESS STARTED:");
  debugPrint("🛒 Item ID: ${labTestModel.id}, Name: ${labTestModel.name}");
  debugPrint("🛒 Item Type: ${labTestModel.type}");
  debugPrint("🛒 ItemDetail count: ${labTestModel.itemDetail?.length ?? 0}");
  if (labTestModel.itemDetail != null && labTestModel.itemDetail!.isNotEmpty) {
    for (var i = 0; i < labTestModel.itemDetail!.length; i++) {
      debugPrint("🛒   Detail[$i]: ${labTestModel.itemDetail![i].name}");
    }
  }
  
  // User is logged in, proceed with cart operation
  labTestModel.isSelected = !labTestModel.isSelected;
  _performAddToCart(labTestModel);
}

void _performAddToCart(CustomCartModel labTestModel) {
  if (labTestModel.isSelected == true) {
    if (searchTestScreenController.cartList.isNotEmpty) {
      // Check if same lab
      final existingLabId = searchTestScreenController.cartList.first.labId;
      if (labTestModel.labId == existingLabId) {
        // Same lab → allow adding
        searchTestScreenController.dbHelper
            .addToCart(cartModel: labTestModel);
        searchTestScreenController.cartList.add(labTestModel);
      } else {
        // Different lab → show warning
        Get.dialog(CommonDialog(
          title: 'warning'.tr,
          description:
              'msg_add_this_item_previously_added_test_will_removed'.tr,
          tapNoText: 'cancel'.tr,
          tapYesText: 'confirm'.tr,
          onTapNo: () {
            labTestModel.isSelected = !labTestModel.isSelected;
            Get.back();
          },
          onTapYes: () {
            Get.back();
            searchTestScreenController.cartList = [];
            searchTestScreenController.dbHelper.clearAllRecord();
            searchTestScreenController.dbHelper
                .addToCart(cartModel: labTestModel);
            searchTestScreenController.cartList.add(labTestModel);
          },
        ));
      }
    } else {
      // First item
      searchTestScreenController.dbHelper
          .insertRecordCart(cartModel: labTestModel);
      searchTestScreenController.cartList.add(labTestModel);
    }

    // Set the pincode for cart
    AppConstants().setCartPincode(
        AppConstants().getSelectedAddress()?.pincode ??
            AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE));
  } else {
    // Remove
     searchTestScreenController.dbHelper.deleteFromCart(
      id: labTestModel.id.toString(),
      type: labTestModel.type!,
    );

    searchTestScreenController.dbHelper.deleteFromCart(
      id: labTestModel.id.toString(),
      type: labTestModel.type!,
    );
    searchTestScreenController.cartList.removeWhere(
      (item) => item.id == labTestModel.id && item.type == labTestModel.type,
    );

     _updateSearchResultItemSelection(labTestModel.id!, labTestModel.type!, false);
    if (isAnySelected() == false) {
      searchTestScreenController.customCartModel = null;
      AppConstants().clearCartPincode();
    }
  }

  searchTestScreenController.cartCount.value =
      searchTestScreenController.cartList.length;
  setState(() {});
}

void _updateSearchResultItemSelection(int itemId, String itemType, bool isSelected) {
  // Update in testList
  for (var item in searchTestScreenController.testList) {
    if (item.id == itemId && item.type == itemType) {
      item.isSelected = isSelected;
      break;
    }
  }
  
  // Update in packageList
  for (var item in searchTestScreenController.packageList) {
    if (item.id == itemId && item.type == itemType) {
      item.isSelected = isSelected;
      break;
    }
  }
  
  // Update in profileList
  for (var item in searchTestScreenController.profileList) {
    if (item.id == itemId && item.type == itemType) {
      item.isSelected = isSelected;
      break;
    }
  }
  
  // Refresh the lists to trigger UI update
  searchTestScreenController.testList.refresh();
  searchTestScreenController.packageList.refresh();
  searchTestScreenController.profileList.refresh();
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

  void _ensureValidTab() {
    final c = searchTestScreenController;
    int selected = c.selectedFilter.value;

    if (selected == 0 && c.testList.isEmpty) {
      if (c.packageList.isNotEmpty) {
        c.selectedFilter.value = 1;
      } else if (c.profileList.isNotEmpty) {
        c.selectedFilter.value = 2;
      }
    } else if (selected == 1 && c.packageList.isEmpty) {
      if (c.testList.isNotEmpty) {
        c.selectedFilter.value = 0;
      } else if (c.profileList.isNotEmpty) {
        c.selectedFilter.value = 2;
      }
    } else if (selected == 2 && c.profileList.isEmpty) {
      if (c.testList.isNotEmpty) {
        c.selectedFilter.value = 0;
      } else if (c.packageList.isNotEmpty) {
        c.selectedFilter.value = 1;
      }
    }
  }
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
  
  if (searchTestScreenController.cartList.isEmpty ||
      cartModel.labId == searchTestScreenController.cartList[0].labId) {
    searchTestScreenController.dbHelper.addToCart(cartModel: cartModel);
    searchTestScreenController.cartList.add(cartModel);
    searchTestScreenController.cartIds.add(packageModel.id!);
  } else {
    Get.dialog(CommonDialog(
      title: 'warning'.tr,
      description: 'msg_add_this_item_previously_added_test_will_removed'.tr,
      tapNoText: 'cancel'.tr,
      tapYesText: 'confirm'.tr,
      onTapNo: () => Get.back(),
      onTapYes: () {
        searchTestScreenController.cartList = [];
        searchTestScreenController.cartIds.clear();
        searchTestScreenController.dbHelper.clearAllRecord();
        searchTestScreenController.dbHelper.addToCart(cartModel: cartModel);
        searchTestScreenController.cartList.add(cartModel);
        searchTestScreenController.cartIds.add(packageModel.id!);
        searchTestScreenController.cartCount.value =
            searchTestScreenController.cartList.length;
        Get.back();
      },
    ));
  }
  
  searchTestScreenController.cartCount.value =
      searchTestScreenController.cartList.length;
  setState(() {});
}
}


class AnimatedButton extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedButton({Key? key, required this.onTap}) : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with TickerProviderStateMixin {
  late AnimationController _borderController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _borderAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Border rotation animation
    _borderController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _borderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _borderController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _borderController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_borderController, _pulseController, _shimmerController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated border container
                Container(
                  width: 170.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.r),
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: _borderAnimation.value * 2 * 3.14159,
                      endAngle:
                          (_borderAnimation.value * 2 * 3.14159) + 3.14159,
                      colors: [
                        primaryColor.withOpacity(0.8),
                        Colors.white.withOpacity(0.8),
                        primaryColor.withOpacity(0.8),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),
                // Inner button container
                Container(
                  width: 170.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(23.r),
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Shimmer effect
                      ClipRRect(
                        borderRadius: BorderRadius.circular(23.r),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(_shimmerAnimation.value - 1, 0),
                              end: Alignment(_shimmerAnimation.value, 0),
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Button content
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated AI icon
                            AnimatedBuilder(
                              animation: _borderController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _borderAnimation.value *
                                      2 *
                                      3.14159 *
                                      0.1,
                                  child: FaIcon(
                                    FontAwesomeIcons.brain,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Analyze Now!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Animated arrow
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                      (_pulseAnimation.value - 1) * 5, 0),
                                  child: FaIcon(
                                    FontAwesomeIcons.arrowRight,
                                    color: Colors.white,
                                    size: 12.sp,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
