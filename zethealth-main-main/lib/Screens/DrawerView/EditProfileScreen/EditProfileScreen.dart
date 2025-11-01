import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zet_health/Models/UserDetailModel.dart';
import 'package:zet_health/Screens/DrawerView/EditProfileScreen/EditProfileScreenController.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomButton.dart';
import '../../../CommonWidget/CustomContainer.dart';
import '../../../CommonWidget/CustomTextField2.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/AppConstants.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';

class EditProfileScreen extends StatefulWidget {
  final bool fromDialog;
  const EditProfileScreen({Key? key, this.fromDialog = false}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  EditProfileScreenController editProfileScreenController =
      Get.put(EditProfileScreenController());
  FocusNode mobileFocus = FocusNode();
  FocusNode dobFocus = FocusNode();
  UserDetailModel userDetailModel = UserDetailModel();

  @override
  void initState() {
    super.initState();
    userDetailModel = AppConstants().getUserDetails();
    editProfileScreenController.setValue(userDetailModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('edit_my_profile'.tr, style: semiBoldBlack_18),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
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
                ]),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (editProfileScreenController.profileImage == null &&
                      userDetailModel.userProfile == null)
                    Center(
                      child: Column(
                        children: [
                          DottedBorder(
                            borderType: BorderType.RRect,
                            radius: Radius.circular(15.r),
                            strokeWidth: 1.w,
                            color: primaryColor,
                            dashPattern: const [3],
                            child: CustomContainer(
                              topPadding: 13.h,
                              bottomPadding: 13.h,
                              onTap: () {
                                Get.dialog(UploadImageDialog(
                                  onTap1: () {
                                    getImagesFromCamera(
                                        source: ImageSource.camera);
                                  },
                                  onTap2: () {
                                    getImagesFromCamera(
                                        source: ImageSource.gallery);
                                  },
                                ));
                              },
                              leftPadding: 15.w,
                              rightPadding: 15.w,
                              color: cardBgColor,
                              radius: 15.r,
                              child: const Icon(Icons.file_upload_outlined,
                                  color: primaryColor),
                            ),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Center(
                              child: Text('upload_profile_photo'.tr,
                                  style: regularBlack_12)),
                        ],
                      ),
                    )
                  else
                    Center(
                      child: Column(
                        children: [
                          CustomContainer(
                            height: 70.h,
                            width: 70.h,
                            borderColor: whiteColor,
                            onTap: () {
                              Get.dialog(UploadImageDialog(
                                title: 'change_profile_photo'.tr,
                                onTap1: () {
                                  getImagesFromCamera(
                                      source: ImageSource.camera);
                                },
                                onTap2: () {
                                  getImagesFromCamera(
                                      source: ImageSource.gallery);
                                },
                              ));
                            },
                            borderWidth: 5.w,
                            radius: 100.r,
                            boxShadow: const [
                              BoxShadow(
                                color: borderColor,
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: Offset(0, 5),
                              ),
                            ],
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: editProfileScreenController
                                            .profileImage !=
                                        null
                                    ? Image.file(File(
                                        editProfileScreenController
                                            .profileImage!.path))
                                    : CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: AppConstants.IMG_URL +
                                            userDetailModel.userProfile
                                                .toString(),
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const ImageErrorWidget(),
                                      )),
                          ),
                          SizedBox(height: 5.h),
                          Center(
                              child: Text(
                            'change_profile_photo'.tr,
                            style: regularBlack_12,
                          )),
                        ],
                      ),
                    ),
                  SizedBox(height: 20.h),
                  CustomTextField2(
                    controller: editProfileScreenController.nameController,
                    title: 'name'.tr,
                    hintText: 'enter_name'.tr,
                    topMargin: 5.h,
                    filled: true,
                    bottomMargin: 15.h,
                    textInputAction: TextInputAction.next,
                  ),
                  CustomTextField2(
                    controller: editProfileScreenController.emailController,
                    title: 'email'.tr,
                    hintText: 'enter_email'.tr,
                    topMargin: 5.h,
                    filled: true,
                    bottomMargin: 15.h,
                    textInputAction: TextInputAction.done,
                  ),
                  CustomTextField2(
                    focusNode: mobileFocus,
                    controller: editProfileScreenController.mobileController,
                    readOnly: true,
                    title: 'number'.tr,
                    hintText: 'enter_number'.tr,
                    topMargin: 5.h,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    filled: true,
                    keyboardType: Platform.isIOS
                        ? TextInputType.phone
                        : TextInputType.number,
                    bottomMargin: 15.h,
                    textInputAction: TextInputAction.next,
                  ),
                  CustomTextField2(
                    focusNode: dobFocus,
                    controller: editProfileScreenController.dobController,
                    title: 'dob'.tr,
                    hintText: "dd/MM/yyyy",
                    topMargin: 5.h,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
                      LengthLimitingTextInputFormatter(10),
                      CustomDateTextFormatter()
                    ],
                    filled: true,
                    keyboardType: Platform.isIOS
                        ? TextInputType.phone
                        : TextInputType.number,
                    bottomMargin: 15.h,
                    textInputAction: TextInputAction.next,
                    suffixIcon: GestureDetector(
                      onTap: () async {
                        String? selectedDate = await AppConstants()
                            .openCalender(
                                context, DateTime(1900), DateTime.now(), true);
                        if (selectedDate != null) {
                          editProfileScreenController.dobController.text =
                              selectedDate;
                        }
                      },
                      child: PaddingHorizontal15(
                          child: Icon(FontAwesomeIcons.calendarDay,
                              size: 20.sp, color: primaryColor)),
                    ),
                  ),
                  Text('gender'.tr, style: semiBoldBlack_14),
                  SizedBox(height: 5.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomContainer(
                            topPadding: 6.h,
                            bottomPadding: 6.h,
                            leftPadding: 6.w,
                            rightPadding: 6.w,
                            color: editProfileScreenController
                                        .selectedGender.value ==
                                    0
                                ? borderColor
                                : cardBgColor,
                            radius: 16.r,
                            onTap: () {
                              setState(() {
                                editProfileScreenController
                                    .selectedGender.value = 0;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(38.r),
                                      border: Border.all(
                                          color: borderColor, width: 1.w),
                                    ),
                                    child: Container(
                                      width: 18.w,
                                      height: 16.h,
                                      decoration: BoxDecoration(
                                        color: editProfileScreenController
                                                    .selectedGender.value ==
                                                0
                                            ? primaryColor
                                            : cardBgColor,
                                        borderRadius:
                                            BorderRadius.circular(38.r),
                                      ),
                                    )),
                                SizedBox(
                                  width: 8.w,
                                ),
                                Text(
                                  'male'.tr,
                                  style: mediumBlack_14,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        width: 6.w,
                      ),
                      Expanded(
                        child: CustomContainer(
                            topPadding: 6.h,
                            onTap: () {
                              setState(() {
                                editProfileScreenController
                                    .selectedGender.value = 1;
                              });
                            },
                            bottomPadding: 6.h,
                            leftPadding: 6.w,
                            rightPadding: 6.w,
                            color: editProfileScreenController
                                        .selectedGender.value ==
                                    1
                                ? borderColor
                                : cardBgColor,
                            radius: 16.r,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(38.r),
                                      border: Border.all(
                                          color: borderColor, width: 1.w),
                                    ),
                                    child: Container(
                                      width: 18.w,
                                      height: 16.h,
                                      decoration: BoxDecoration(
                                        color: editProfileScreenController
                                                    .selectedGender.value ==
                                                1
                                            ? primaryColor
                                            : cardBgColor,
                                        borderRadius:
                                            BorderRadius.circular(38.r),
                                      ),
                                    )),
                                SizedBox(
                                  width: 8.w,
                                ),
                                Text(
                                  'female'.tr,
                                  style: mediumBlack_14,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        width: 6.w,
                      ),
                      Expanded(
                        child: CustomContainer(
                            topPadding: 6.h,
                            onTap: () {
                              setState(() {
                                editProfileScreenController
                                    .selectedGender.value = 2;
                              });
                            },
                            bottomPadding: 6.h,
                            leftPadding: 6.w,
                            rightPadding: 6.w,
                            color: editProfileScreenController
                                        .selectedGender.value ==
                                    2
                                ? borderColor
                                : cardBgColor,
                            radius: 16.r,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(38.r),
                                      border: Border.all(
                                          color: borderColor, width: 1.w),
                                    ),
                                    child: Container(
                                      width: 18.w,
                                      height: 16.h,
                                      decoration: BoxDecoration(
                                        color: editProfileScreenController
                                                    .selectedGender.value ==
                                                2
                                            ? primaryColor
                                            : cardBgColor,
                                        borderRadius:
                                            BorderRadius.circular(38.r),
                                      ),
                                    )),
                                SizedBox(
                                  width: 8.w,
                                ),
                                Text(
                                  'other'.tr,
                                  style: mediumBlack_14,
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                  CustomButton(
                      topMargin: 20.h,
                      borderRadius: 20.r,
                      height: 39.h,
                      text: 'save_changes'.tr,
                      onTap: () {
                        if (editProfileScreenController.isValidate()) {
                          editProfileScreenController
                              .callUpdateProfileApi(context);
                        }
                      }),
                  CustomButton(
                      topMargin: 15.h,
                      borderRadius: 20.r,
                      height: 39.h,
                      color: redColor,
                      text: 'delete_account'.tr,
                      onTap: () {
                        Get.dialog(CommonDialog(
                          title: 'please_confirm_account_deletion',
                          onTapNo: () => Get.back(),
                          onTapYes: () async {
                            Get.back();
                            editProfileScreenController.deleteAccountApi();
                          },
                        ));
                      }),
                ],
              ),
            )),
      ),
    );
  }

  getImagesFromCamera({required ImageSource source}) async {
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
        errorMessage = 'Camera permission denied. Please enable camera access in settings.';
        _showPermissionDeniedDialog('Camera');
      } else if (e.toString().contains('photo_access_denied')) {
        errorMessage = 'Photo library permission denied. Please enable photo access in settings.';
        _showPermissionDeniedDialog('Gallery');
      } else {
        AppConstants().showToast(errorMessage);
      }
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    Get.dialog(
      AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text('$permissionType permission is required for this feature. Please enable it in your device settings and try again.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
          IOSUiSettings(title: 'Crop Image'),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          editProfileScreenController.profileImage = croppedFile;
        });
      }
    } catch (e) {
      print("Error cropping image: $e");
    }
  }
}
