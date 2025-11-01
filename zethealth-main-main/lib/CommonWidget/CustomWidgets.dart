import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zet_health/Screens/HomeScreen/TestScreen/SearchTest/SearchResultController.dart';
import 'package:zet_health/Screens/MyCartScreen/MyCartScreenController.dart';
import '../Helper/AppConstants.dart';
import '../Helper/AssetHelper.dart';
import '../Helper/ColorHelper.dart';
import '../Helper/StyleHelper.dart';
import '../Models/custom_cart_model.dart';
import '../Screens/AuthScreen/LoginScreen.dart';
import '../Screens/DrawerView/NavigationDrawerController.dart';
import '../Screens/HomeScreen/AvailableLabsScreen/AvailableLabsScreen.dart';
import '../Screens/HomeScreen/NotificationScreen/NotificationScreen.dart';
import '../Screens/MyCartScreen/MyCartScreen.dart';
import 'CustomButton.dart';
import 'CustomContainer.dart';
import 'dart:ui' as ui;

import 'custom_expansion_tile.dart';

class PaddingHorizontal20 extends StatelessWidget {
  const PaddingHorizontal20(
      {super.key, required this.child, this.top, this.bottom});

  final Widget child;
  final double? top;
  final double? bottom;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            left: 20.w, right: 20.w, top: top ?? 0, bottom: bottom ?? 0),
        child: child);
  }
}

class PaddingHorizontal15 extends StatelessWidget {
  const PaddingHorizontal15(
      {super.key, required this.child, this.top, this.bottom});

  final Widget child;
  final double? top;
  final double? bottom;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
            left: 15.w, right: 15.w, top: top ?? 0, bottom: bottom ?? 0),
        child: child);
  }
}

String removeHtmlTags(String htmlText) {
  RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

  return htmlText.replaceAll(exp, '');
}

ddMMYYYYDateFormat(String date) {
  try {
    return DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
  } catch (e) {
    return '';
  }
}

yyyyMMddDateFormat(String date) {
  try {
    final parsedDate = DateFormat('dd-MM-yyyy').parse(date);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  } catch (e) {
    return '';
  }
}

String formatDateString(
    String formatWant, String apiFormat, String dateString) {
  try {
    final parsedDate = DateFormat(apiFormat).parse(dateString);
    return DateFormat(formatWant).format(parsedDate);
  } catch (e) {
    return '';
  }
}

class CustomDateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = _format(newValue.text, '/', oldValue);
    return newValue.copyWith(
        text: text, selection: _updateCursorPosition(text, oldValue));
  }
}

String _format(String value, String seperator, TextEditingValue old) {
  var finalString = '';
  var dd = '';
  var mm = '';
  var yyy = '';
  var oldVal = old.text;
  var tempOldval = oldVal;
  var tempValue = value;
  if (!oldVal.contains(seperator) ||
      oldVal.isEmpty ||
      seperator.allMatches(oldVal).length < 2) {
    oldVal += '///';
  }
  if (!value.contains(seperator) || _backSlashCount(value) < 2) {
    value += '///';
  }
  var splitArrOLD = oldVal.split(seperator);
  var splitArrNEW = value.split(seperator);
  for (var i = 0; i < 3; i++) {
    splitArrOLD[i] = splitArrOLD[i].toString().trim();
    splitArrNEW[i] = splitArrNEW[i].toString().trim();
  }
  // block erasing
  if ((splitArrOLD[0].isNotEmpty &&
          splitArrOLD[2].isNotEmpty &&
          splitArrOLD[1].isEmpty &&
          tempValue.length < tempOldval.length &&
          splitArrOLD[0] == splitArrNEW[0] &&
          splitArrOLD[2].toString().trim() ==
              splitArrNEW[1].toString().trim()) ||
      (_backSlashCount(tempOldval) > _backSlashCount(tempValue) &&
          splitArrNEW[1].length > 2) ||
      (splitArrNEW[0].length > 2 && _backSlashCount(tempOldval) == 1) ||
      (_backSlashCount(tempOldval) == 2 &&
          _backSlashCount(tempValue) == 1 &&
          splitArrNEW[0].length > splitArrOLD[0].length)) {
    finalString = tempOldval; // making the old date as it is
  } else {
    if (splitArrNEW[0].length > splitArrOLD[0].length) {
      if (splitArrNEW[0].length < 3) {
        dd = splitArrNEW[0];
      } else {
        for (var i = 0; i < 2; i++) {
          dd += splitArrNEW[0][i];
        }
      }
      if (dd.length == 2 && !dd.contains(seperator)) {
        dd += seperator;
      }
    } else if (splitArrNEW[0].length == splitArrOLD[0].length) {
      if (oldVal.length > value.length && splitArrNEW[1].isEmpty) {
        dd = splitArrNEW[0];
      } else {
        dd = splitArrNEW[0] + seperator;
      }
    } else if (splitArrNEW[0].length < splitArrOLD[0].length) {
      if (oldVal.length > value.length &&
          splitArrNEW[1].isEmpty &&
          splitArrNEW[0].isNotEmpty) {
        dd = splitArrNEW[0];
      } else if (tempOldval.length > tempValue.length &&
          splitArrNEW[0].isEmpty &&
          _backSlashCount(tempValue) == 2) {
        dd += seperator;
      } else {
        if (splitArrNEW[0].isNotEmpty) {
          dd = splitArrNEW[0] + seperator;
        }
      }
    }

    if (dd.isNotEmpty) {
      finalString = dd;
      if (dd.length == 2 &&
          !dd.contains(seperator) &&
          oldVal.length < value.length &&
          splitArrNEW[1].isNotEmpty) {
        if (seperator.allMatches(dd).isEmpty) {
          finalString += seperator;
        }
      } else if (splitArrNEW[2].isNotEmpty &&
          splitArrNEW[1].isEmpty &&
          tempOldval.length > tempValue.length) {
        if (seperator.allMatches(dd).isEmpty) {
          finalString += seperator;
        }
      } else if (oldVal.length < value.length &&
          (splitArrNEW[1].isNotEmpty || splitArrNEW[2].isNotEmpty)) {
        if (seperator.allMatches(dd).isEmpty) {
          finalString += seperator;
        }
      }
    } else if (_backSlashCount(tempOldval) == 2 && splitArrNEW[1].isNotEmpty) {
      dd += seperator;
    }
    if (splitArrNEW[0].length == 3 && splitArrOLD[1].isEmpty) {
      mm = splitArrNEW[0][2];
    }

    if (splitArrNEW[1].length > splitArrOLD[1].length) {
      if (splitArrNEW[1].length < 3) {
        mm = splitArrNEW[1];
      } else {
        for (var i = 0; i < 2; i++) {
          mm += splitArrNEW[1][i];
        }
      }
      if (mm.length == 2 && !mm.contains(seperator)) {
        mm += seperator;
      }
    } else if (splitArrNEW[1].length == splitArrOLD[1].length) {
      if (splitArrNEW[1].isNotEmpty) {
        mm = splitArrNEW[1];
      }
    } else if (splitArrNEW[1].length < splitArrOLD[1].length) {
      if (splitArrNEW[1].isNotEmpty) {
        mm = splitArrNEW[1] + seperator;
      }
    }

    if (mm.isNotEmpty) {
      finalString += mm;
      if (mm.length == 2 && !mm.contains(seperator)) {
        if (tempOldval.length < tempValue.length) {
          finalString += seperator;
        }
      }
    }
    if (splitArrNEW[1].length == 3 && splitArrOLD[2].isEmpty) {
      yyy = splitArrNEW[1][2];
    }

    if (splitArrNEW[2].length > splitArrOLD[2].length) {
      if (splitArrNEW[2].length < 5) {
        yyy = splitArrNEW[2];
      } else {
        for (var i = 0; i < 4; i++) {
          yyy += splitArrNEW[2][i];
        }
      }
    } else if (splitArrNEW[2].length == splitArrOLD[2].length) {
      if (splitArrNEW[2].isNotEmpty) {
        yyy = splitArrNEW[2];
      }
    } else if (splitArrNEW[2].length < splitArrOLD[2].length) {
      yyy = splitArrNEW[2];
    }

    if (yyy.isNotEmpty) {
      if (_backSlashCount(finalString) < 2) {
        if (splitArrNEW[0].isEmpty && splitArrNEW[1].isEmpty) {
          finalString = seperator + seperator + yyy;
        } else {
          finalString = finalString + seperator + yyy;
        }
      } else {
        finalString += yyy;
      }
    } else {
      if (_backSlashCount(finalString) > 1 && oldVal.length > value.length) {
        var valueUpdate = finalString.split(seperator);
        finalString = valueUpdate[0] + seperator + valueUpdate[1];
      }
    }
  }
  return finalString;
}

TextSelection _updateCursorPosition(String text, TextEditingValue oldValue) {
  var endOffset = max(
    oldValue.text.length - oldValue.selection.end,
    0,
  );
  var selectionEnd = text.length - endOffset;
  return TextSelection.fromPosition(TextPosition(offset: selectionEnd));
}

int _backSlashCount(String value) {
  return '/'.allMatches(value).length;
}

String? dateValidate(String value) {
  if (value.isEmpty) return "Please enter dob";

  final dateParts = value.split('/');
  if (dateParts.length != 3) return "Invalid date format";

  int day = int.tryParse(dateParts[0]) ?? 0;
  int month = int.tryParse(dateParts[1]) ?? 0;
  int year = int.tryParse(dateParts[2]) ?? 0;

  // Validate day, month, and year ranges
  if (day < 1 || day > 31) return "Day must be between 1 and 31";
  if (month < 1 || month > 12) return "Month must be between 1 and 12";
  if (dateParts[2].length != 4 || year < 1900) {
    return "Year must have 4 digits and be valid";
  }

  // Check if the entered date is valid
  DateTime? enteredDate;
  try {
    enteredDate = DateTime(year, month, day);
  } catch (e) {
    return "Invalid date";
  }

  // Ensure the date is not in the future
  final now = DateTime.now();
  if (enteredDate.isAfter(now)) {
    return "Date cannot be in the future";
  }

  return null; // No errors
}

String calculateAge(String birthDateString) {
  try {
    DateTime birthDate = DateTime.parse(birthDateString);
    DateTime currentDate = DateTime.now();
    int ageInYears = currentDate.year - birthDate.year;
    int ageInMonths = currentDate.month - birthDate.month;

    if (currentDate.day < birthDate.day) {
      ageInMonths--;
    }

    if (ageInYears < 1) {
      if (ageInMonths < 1) {
        return '$ageInMonths month${ageInMonths == 1 ? '' : 's'}';
      } else {
        return '$ageInMonths month${ageInMonths == 1 ? '' : 's'}';
      }
    } else {
      return '$ageInYears year${ageInYears == 1 ? '' : 's'}';
    }
  } catch (e) {
    e.toString();
  }
  return '';
}

customDateFormat(String inputDateString) {
  try {
    DateTime dateTime = DateTime.parse(inputDateString);
    String formattedDate = DateFormat("dd-MM-yyyy").format(dateTime);
    String formattedTime = DateFormat("hh:mm a").format(dateTime);
    return "$formattedDate at $formattedTime";
  } catch (e) {
    return '';
  }
}

showToast({required String message, int? seconds, Color? color}) {
  Get.closeAllSnackbars();
  Get.showSnackbar(GetSnackBar(
    backgroundColor: color ?? primaryColor,
    message: message,
    borderRadius: 16,
    duration: Duration(seconds: seconds ?? 2),
    isDismissible: true,
  ));
}

String getFileExtension(String fileName) {
  return ".${fileName.split('.').last}";
}

class CartButtonCommon extends GetView {
  CartButtonCommon(
      {super.key, this.callBack, this.marginLeft, this.marginRight});
  final Function()? callBack;
  final double? marginLeft;
  final double? marginRight;
  final NavigationDrawerController navigationDrawerController =
      Get.find<NavigationDrawerController>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (AppConstants().getStorage.read(AppConstants.isCartExist)) {
          AppConstants().loadWithCanBack(const MyCartScreen());
        } else {
          // AppConstants().loadWithCanBack(AvailableLabsScreen(callBack: callBack));
          SearchResultController searchResultController = Get.find<SearchResultController>();
          if (!checkLogin() || searchResultController.cartList.isEmpty) {
            AppConstants().loadWithCanBack(MyCartScreen());
          }
          else {
            searchResultController.callTestWiseLabApi(toViewCart: true);
          }
        }
      },
      child: Container(
          alignment: Alignment.center,
          height: 35.w,
          width: 35.w,
          margin: EdgeInsets.only(
              right: marginRight ?? 15.w, left: marginLeft ?? 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Obx(
            () => Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(cart, height: 20.w, width: 20.w),
                if (navigationDrawerController.cartCounter.value != 0)
                  Positioned(
                    top: -10.h,
                    right: -5.w,
                    child: Container(
                      padding: EdgeInsets.all(4.sp),
                      decoration: const BoxDecoration(
                          color: redColor, shape: BoxShape.circle),
                      child: Text(
                          '${navigationDrawerController.cartCounter.value}',
                          style: semiBoldWhite_8),
                    ),
                  )
              ],
            ),
          )),
    );
  }
}

class NotificationButtonCommon extends GetView {
  NotificationButtonCommon({super.key});
  final NavigationDrawerController navigationDrawerController =
      Get.find<NavigationDrawerController>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (checkLogin()) {
          navigationDrawerController.notificationCounter.value = 0;
          AppConstants().loadWithCanBack(() => const NotificationScreen());
        } else {
          AppConstants().loadWithCanBack(LoginScreen(onLoginSuccess: () {
            navigationDrawerController.notificationCounter.value = 0;
            AppConstants().loadWithCanBack(() => const NotificationScreen());
          }));
        }
      },
      child: Container(
          alignment: Alignment.center,
          height: 35.w,
          width: 35.w,
          margin: EdgeInsets.only(right: 5.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Obx(
            () => Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(notificationIcon, height: 20.w, width: 20.w),
                if (navigationDrawerController.notificationCounter.value != 0)
                  Positioned(
                    top: -10.h,
                    right: -5.w,
                    child: Container(
                      padding: EdgeInsets.all(4.sp),
                      decoration: const BoxDecoration(
                          color: redColor, shape: BoxShape.circle),
                      child: Text(
                          '${navigationDrawerController.notificationCounter.value}',
                          style: semiBoldWhite_8),
                    ),
                  )
              ],
            ),
          )),
    );
  }
}

class CommonDialog extends StatelessWidget {
  const CommonDialog({
    super.key,
    this.onTapNo,
    required this.onTapYes,
    required this.title,
    this.description,
    this.tapNoText,
    this.tapYesText,
  });
  final Function()? onTapNo;
  final Function() onTapYes;
  final String title;
  final String? description;
  final String? tapNoText;
  final String? tapYesText;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25.r)),
            boxShadow: const [
              BoxShadow(
                  color: primaryColor, spreadRadius: -1, offset: Offset(-5, 0)),
              BoxShadow(
                color: primaryColor,
                spreadRadius: -1,
                offset: Offset(5, 0),
              ),
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title.tr, style: boldPrimary2_16),
            SizedBox(height: 2.h),
            if (description != null)
              Text(description!.tr,
                  style: regularBlack_13, textAlign: TextAlign.center),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: CustomContainer(
                    borderColor: primaryColor,
                    borderWidth: 1.w,
                    topPadding: 10.h,
                    bottomPadding: 10.h,
                    onTap: onTapYes,
                    radius: 20.r,
                    child: Center(
                        child: Text(tapYesText ?? "yes".tr,
                            style: semiBoldPrimary_14)),
                  ),
                ),
                if (onTapNo != null)
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          child: CustomContainer(
                            borderColor: primaryColor,
                            borderWidth: 1.w,
                            topPadding: 10.h,
                            bottomPadding: 10.h,
                            onTap: onTapNo,
                            radius: 20.r,
                            child: Center(
                                child: Text(
                              tapNoText ?? "no".tr,
                              style: semiBoldPrimary_14,
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Expanded(
                //     child: ElevatedButton(
                //       onPressed: onTapNo,
                //       style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                //       child: Text(tapNoText ?? "no".tr, style: semiBoldBlack_14),
                //     )
                // ),
                // SizedBox(width: 15.w),
                // child: ElevatedButton(
                //   onPressed: onTapYes,
                //   style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                //   child: Text(tapYesText ?? "yes".tr, style: semiBoldWhite_14),
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CustomBorderDialog extends StatelessWidget {
  const CustomBorderDialog({super.key, required this.childWidget});
  final Widget childWidget;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25.r)),
            boxShadow: const [
              BoxShadow(
                  color: primaryColor, spreadRadius: -1, offset: Offset(-5, 0)),
              BoxShadow(
                color: primaryColor,
                spreadRadius: -1,
                offset: Offset(5, 0),
              ),
            ]),
        child: childWidget,
      ),
    );
  }
}

class UploadImageDialog extends StatelessWidget {
  final Function? onTap1;
  final Function? onTap2;
  final String? title;
  final String? description;
  final String? cameraImage;
  final String? galleryImage;

  const UploadImageDialog({
    super.key,
    this.onTap1,
    this.onTap2,
    this.title,
    this.description,
    this.cameraImage,
    this.galleryImage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(25.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title ?? 'Upload Profile Photo', style: boldPrimary2_16),
            SizedBox(height: 3.h),
            Text(
              description ??
                  'Tap to upload your profile photo and personalize your profile.',
              style: mediumGray_14,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 22.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomContainer(
                  borderColor: primaryColor,
                  borderWidth: 1.w,
                  leftPadding: 20.w,
                  rightPadding: 20.w,
                  topPadding: 18.h,
                  bottomPadding: 18.h,
                  onTap: () async {
                    if (onTap1 != null) {
                      onTap1!.call();
                    }
                  },
                  radius: 29.r,
                  child: Center(
                    child: SvgPicture.asset(
                      cameraImage ?? icCamera,
                      height: 30.h,
                    ),
                  ),
                ),
                CustomContainer(
                  borderColor: primaryColor,
                  borderWidth: 1.w,
                  leftPadding: 20.w,
                  rightPadding: 20.w,
                  topPadding: 18.h,
                  bottomPadding: 18.h,
                  onTap: () async {
                    if (onTap2 != null) {
                      onTap2!.call();
                    }
                  },
                  radius: 29.r,
                  child: Center(
                    child: SvgPicture.asset(
                      galleryImage ?? icGallery,
                      color: Colors.black,
                      height: 30.h,
                    ),
                  ),
                ),
              ],
            ),
            CustomContainer(
              borderColor: primaryColor,
              top: 20.h,
              borderWidth: 1.w,
              topPadding: 10.h,
              bottomPadding: 10.h,
              onTap: () {
                Navigator.of(context).pop();
              },
              radius: 20.r,
              child: Center(
                child: Text(
                  "Close",
                  style: semiBoldPrimary_14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

openDatePicker(
    {required context,
    required Function(String) pickDate,
    DateTime? firstDate,
    DateTime? lastDate}) async {
  DateTime? temp = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: firstDate ?? DateTime(2023, 01, 01),
    lastDate: lastDate ?? DateTime.now(),
    // initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      );
    },
  );

  if (temp != null) {
    pickDate.call(ddMMYYYYDateFormat(temp.toString()));
  }
}

openDatePicker2(
    {required context, required Function(DateTime) pickDate}) async {
  DateTime? temp = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(1950, 01, 01),
    lastDate: DateTime.now(),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: (context, child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: primaryColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      );
    },
  );

  if (temp != null) {
    pickDate.call(temp);
  }
}

class FromDateToDateDialog extends StatelessWidget {
  FromDateToDateDialog(
      {super.key, required this.onTapNo, required this.onTapYes});
  final Function() onTapNo;
  final Function(String fromDate, String toDate) onTapYes;
  final RxString fromDate = ''.obs;
  final RxString toDate = ''.obs;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('select_from_and_to_date'.tr, style: semiBoldBlack_16),
          SizedBox(height: 20.h),
          Obx(
            () => Row(
              children: [
                Expanded(
                    child: CustomContainer(
                  topPadding: 8.h,
                  bottomPadding: 8.h,
                  borderWidth: 1,
                  onTap: () {
                    openDatePicker(
                        context: context,
                        pickDate: (selectedDate) {
                          fromDate.value = selectedDate;
                        });
                  },
                  child: Text(
                      fromDate.value.isEmpty ? "from_date".tr : fromDate.value,
                      style: semiBoldBlack_11),
                )),
                SizedBox(width: 15.w),
                Text("To".tr, style: semiBoldBlack_12),
                SizedBox(width: 15.w),
                Expanded(
                  child: CustomContainer(
                      topPadding: 8.h,
                      bottomPadding: 8.h,
                      borderWidth: 1,
                      onTap: () {
                        openDatePicker(
                            context: context,
                            pickDate: (selectedDate) {
                              toDate.value = selectedDate;
                            });
                      },
                      child: Text(
                          toDate.value.isEmpty ? "to_date".tr : toDate.value,
                          style: semiBoldBlack_11)),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                onPressed: onTapNo,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text("no".tr, style: semiBoldBlack_14),
              )),
              SizedBox(width: 15.w),
              Expanded(
                child: Obx(
                  () => ElevatedButton(
                    onPressed: () {
                      if (fromDate.value.isNotEmpty && toDate.isNotEmpty) {
                        onTapYes.call(fromDate.value, toDate.value);
                        Navigator.pop(context);
                      } else {
                        showToast(message: 'select_from_and_to_date'.tr);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            fromDate.value.isNotEmpty && toDate.isNotEmpty
                                ? primaryColor
                                : greyColor.withAlpha(500)),
                    child: Text("yes".tr, style: semiBoldWhite_14),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CustomBottomSheetContainer {
  static Widget bottomSheetContainer(
      {required Widget child,
      double? height,
      double? horizontal,
      double? topMargin,
      Color? color}) {
    return SafeArea(
      child: Container(
        height: height,
        padding:
            EdgeInsets.symmetric(horizontal: horizontal ?? 20.w, vertical: 5.h),
        margin: EdgeInsets.only(top: topMargin ?? 0),
        width: Get.width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18.r))),
        child: child,
      ),
    );
  }
}

String formatPriceToIndianNumbering(int price) {
  String formattedPrice;
  if (price < 1000) {
    formattedPrice = price.toString();
  } else {
    NumberFormat numberFormat = NumberFormat.compactCurrency(
      symbol: '₹ ',
      locale: "HI",
      decimalDigits: 3,
    );
    formattedPrice = numberFormat.format(price);
  }
  return formattedPrice;
}

class CommonBackButton extends StatelessWidget {
  const CommonBackButton({
    super.key,
    this.leftMargin,
    this.rightMargin,
    this.topMargin,
    this.bottomMargin,
    this.backgroundColor,
    this.border,
    this.onTap,
  });
  final double? leftMargin;
  final double? rightMargin;
  final double? topMargin;
  final double? bottomMargin;
  final Color? backgroundColor;
  final BoxBorder? border;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap ?? Get.back(),
      child: Container(
          alignment: Alignment.center,
          height: 38.w,
          width: 38.w,
          margin: EdgeInsets.only(
              left: leftMargin ?? 0,
              right: rightMargin ?? 0,
              top: topMargin ?? 0,
              bottom: bottomMargin ?? 0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              color: backgroundColor ?? primaryColor,
              border: border ?? const Border()),
          child: SvgPicture.asset(backArrow)),
    );
  }
}

class GenderWidget {
  String name;
  IconData icon;
  bool isSelected;

  GenderWidget({
    required this.name,
    required this.icon,
    required this.isSelected,
  });
}

class LocationWidget {
  String name;
  bool isSelected;
  LocationWidget({
    required this.name,
    required this.isSelected,
  });
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class TextToBitmapPainter extends CustomPainter {
  final String text;

  TextToBitmapPainter({required this.text});

  @override
  void paint(Canvas canvas, Size size) async {
    final recorder = ui.PictureRecorder();
    final textPainter = TextPainter(
        text: TextSpan(text: text, style: const TextStyle(fontSize: 20)));

    textPainter.layout();
    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    final pictureCanvas = Canvas(recorder,
        Rect.fromPoints(const Offset(0, 0), Offset(textWidth, textHeight)));
    textPainter.paint(pictureCanvas, const Offset(0, 0));

    final picture = recorder.endRecording();
    final img = await picture.toImage(textWidth.toInt(), textHeight.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    final pngBytes = byteData!.buffer.asUint8List();
    // ignore: unused_local_variable
    final widgetImage = Image.memory(Uint8List.fromList(pngBytes));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.inputFormatters,
    this.onFieldSubmitted,
    this.onChanged,
    this.focusNode,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
  });
  final TextEditingController controller;
  final String hintText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.h,
      child: TextFormField(
        controller: controller,
        cursorColor: primaryColor,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        style: mediumBlack_14,
        inputFormatters: inputFormatters,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        maxLength: maxLength,
        focusNode: focusNode,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintStyle: semiBoldGray_12,
          border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.r)),
          hintText: hintText,
          counterText: '',
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }
}

class ImagePickBottomSheet extends StatelessWidget {
  const ImagePickBottomSheet(
      {super.key, required this.onTapCamera, required this.onTapGallery});
  final VoidCallback onTapCamera;
  final VoidCallback onTapGallery;
  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          onPressed: onTapCamera,
          child: Row(
            children: [
              Image.asset(icCamera, height: 30.h),
              SizedBox(width: 10.w),
              Text('camera'.tr, style: semiBoldBlack_14)
            ],
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: onTapGallery,
          child: Row(
            children: [
              Image.asset(icGallery, height: 30.h),
              SizedBox(width: 10.w),
              Text('gallery'.tr, style: semiBoldBlack_14)
            ],
          ),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('cancel'.tr, style: semiBoldBlack_14),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class CustomEmptyListView extends StatelessWidget {
  const CustomEmptyListView(
      {super.key, this.height, this.title, this.imagePath, this.subTitle});
  final double? height;
  final String? imagePath;
  final String? title;
  final String? subTitle;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: PaddingHorizontal15(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(imagePath.toString(),
                  height: height ?? Get.height / 5),
            SizedBox(height: 5.h),
            if (title != null)
              Text(title!.tr.toString(),
                  style: semiBoldBlack_14, textAlign: TextAlign.center),
            if (subTitle != null)
              Text(subTitle!.tr.toString(),
                  style: regularBlack_12, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ImageErrorWidget extends StatelessWidget {
  const ImageErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: shadowColor),
        child: Image.asset(appLogo, fit: BoxFit.fitWidth));
  }
}

class CustomListTile extends StatelessWidget {
  final double? horizontalPadding;
  final double? trailingIconSize;
  final IconData? icon;
  final IconData? trailingIcon;
  final String? listTitle;
  final Function? trailingOnTap;
  final Function? onTap;
  final Color? trailingIconColor;
  final FontWeight? fontWeight;
  final double? fontSize;

  const CustomListTile(
      {super.key,
      this.horizontalPadding,
      this.icon,
      this.trailingIcon,
      this.trailingIconSize,
      this.listTitle,
      this.onTap,
      this.fontWeight,
      this.fontSize,
      this.trailingOnTap,
      this.trailingIconColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 15),
      onTap: () {
        if (onTap != null) {
          onTap!.call();
        } else {
          Navigator.pop(context);
        }
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
                height: 25.h,
                width: 32.w,
                alignment: Alignment.centerLeft,
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 18.sp,
                )),
          Flexible(
            child: Text(
              listTitle!,
              maxLines: 2,
              style: TextStyle(
                  fontFamily: semiBold,
                  color: blackColor,
                  fontWeight: fontWeight ?? FontWeight.w500,
                  fontSize: fontSize ?? 11.sp),
            ),
          ),
        ],
      ),
      trailing: Icon(
        trailingIcon,
        size: trailingIconSize ?? 18.sp,
        color: trailingIconColor,
      ),
    );
  }
}

class CustomSquareButton extends StatelessWidget {
  const CustomSquareButton(
      {super.key,
      required this.icon,
      required this.onTap,
      this.leftMargin,
      this.rightMargin,
      this.topMargin,
      this.bottomMargin,
      this.backgroundColor,
      this.border,
      this.iconColor,
      this.shadow,
      this.alignment});
  final String icon;
  final Color? iconColor;
  final Function() onTap;
  final double? leftMargin;
  final double? rightMargin;
  final double? topMargin;
  final double? bottomMargin;
  final Color? backgroundColor;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            alignment: alignment ?? Alignment.center,
            height: 35.w,
            width: 35.w,
            margin: EdgeInsets.only(
                left: leftMargin ?? 0,
                right: rightMargin ?? 0,
                top: topMargin ?? 0,
                bottom: bottomMargin ?? 0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: backgroundColor ?? primaryColor,
                border: border,
                boxShadow: shadow),
            child: SvgPicture.asset(icon,
                color: iconColor, height: 20.w, width: 20.w)),
      ),
    );
  }
}

class AppBarView extends StatelessWidget {
  const AppBarView(
      {super.key,
      required this.title,
      this.left,
      this.right,
      this.top,
      this.bottom});
  final String title;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          left: left ?? 15.w,
          right: right ?? 15.w,
          top: top ?? 15.h,
          bottom: bottom ?? 15.h,
        ),
        child: SizedBox(
          height: 38.w,
          child: Stack(
            children: [
              const CommonBackButton(),
              Center(child: Text(title.tr, style: semiBoldBlack_18))
            ],
          ),
        ));
  }
}

// List<CustomCalendarModel> getAllMonthsDateList() {
//   List<DateTime> dates = [];
//   DateTime currentDate = DateTime.now();
//   DateTime firstDate = DateTime(currentDate.year, currentDate.month, 1);
//   DateTime lastDate = DateTime(currentDate.year, currentDate.month + 1, 0);
//
//   while (!firstDate.isAfter(lastDate)) {
//     dates.add(firstDate);
//     firstDate = firstDate.add(const Duration(days: 1));
//   }
//
//   List<CustomCalendarModel> dateStringList = [];
//   for (DateTime date in dates) {
//     dateStringList.add(CustomCalendarModel(
//       dateName: DateFormat('dd').format(date),
//       dayName: DateFormat('EEE').format(date),
//       monthName: DateFormat('MMM').format(date),
//       fullDate: DateFormat('yyyy-MM-dd').format(date),
//     ));
//   }
//   return dateStringList;
// }
//
// List<CustomCalendarModel> getDateList(DateTime date1, DateTime date2) {
//   List<DateTime> dates = [];
//
//   while (!date1.isAfter(date2)) {
//     if(date1.isAfter(DateTime.now()) || ddMMYYYYDateFormat(date1.toString())==ddMMYYYYDateFormat(DateTime.now().toString())) {
//       dates.add(date1);
//     }
//     date1 = date1.add(const Duration(days: 1));
//   }
//
//   List<CustomCalendarModel> dateStringList = [];
//   for (DateTime date in dates) {
//     dateStringList.add(CustomCalendarModel(
//       dateName: DateFormat('dd').format(date),
//       dayName: DateFormat('EEE').format(date),
//       monthName: DateFormat('MMM').format(date),
//       fullDate: DateFormat('yyyy-MM-dd').format(date),
//     ));
//   }
//   return dateStringList;
// }

List<DateTime> getCurrentMonthDates(String dateString) {
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  DateTime givenDate = DateTime.now();

  try {
    givenDate = dateFormat.parse(dateString);
  } catch (e) {
    print(e.toString());
  }

  // Get the month from the given date
  DateTime currentDate = DateTime(givenDate.year, givenDate.month, 1);
  // ignore: unused_local_variable
  int month = currentDate.month;

  // Get the first and last dates of the month
  DateTime firstDate = DateTime(currentDate.year, currentDate.month, 1);
  DateTime lastDate = DateTime(currentDate.year, currentDate.month + 1, 0);

  // Format month name
  DateFormat monthFormat = DateFormat('MMMM');
  String monthName = monthFormat.format(currentDate);
  int year = currentDate.year;

  print('$monthName - $year'); // You may print this for debugging or remove it

  return [firstDate, lastDate];
}

class SliderIndicator extends StatelessWidget {
  const SliderIndicator({
    super.key,
    required this.index,
    required this.currentBannerImageIndex,
  });

  final int index, currentBannerImageIndex;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linearToEaseOut,
      margin: EdgeInsets.only(right: 5.w),
      height: 4.h,
      width: 20.w,
      decoration: BoxDecoration(
        color: index == currentBannerImageIndex ? primaryColor : black10,
        borderRadius: BorderRadius.circular(30.r),
      ),
    );
  }
}

class PandaBarButton extends StatefulWidget {
  final Widget icon;
  final String title;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;

  const PandaBarButton({
    super.key,
    this.isSelected = false,
    required this.icon,
    this.selectedColor,
    this.unselectedColor,
    this.title = '',
    this.onTap,
  });

  @override
  _PandaBarButtonState createState() => _PandaBarButtonState();
}

class _PandaBarButtonState extends State<PandaBarButton>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    animation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0, end: 10), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 10, end: 0), weight: 50),
    ]).chain(CurveTween(curve: Curves.bounceOut)).animate(animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkResponse(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: widget.onTap,
        onHighlightChanged: (touched) {
          if (!touched) {
            animationController.forward().whenCompleteOrCancel(() {
              animationController.reset();
            });
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: widget.isSelected
                  ? ColorFilter.mode(
                      widget.selectedColor ?? const Color(0xFFC47FFF),
                      BlendMode.srcIn)
                  : ColorFilter.mode(
                      widget.unselectedColor ?? const Color(0xFF9DB2CE),
                      BlendMode.srcIn),
              child: widget.icon,
            ),
            // Container(
            //   height: animation.value,
            // ),
            Text(
              widget.title,
              style: TextStyle(
                color: widget.isSelected
                    ? (widget.selectedColor ?? const Color(0xFFC47FFF))
                    : (widget.unselectedColor ?? const Color(0xFF9DB2CE)),
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}

class DoubleBorderContainer extends StatelessWidget {
  const DoubleBorderContainer({
    super.key,
    required this.svgImage,
    this.width,
    this.height,
    this.radius,
    this.svgHeight,
    this.svgWidth,
    this.leftMargin,
    this.rightMargin,
    this.topMargin,
    this.bottomMargin,
    this.color,
    this.onTap,
  });
  final double? height;
  final double? width;
  final double? radius;
  final double? svgHeight;
  final double? svgWidth;
  final String svgImage;
  final double? leftMargin;
  final double? rightMargin;
  final double? topMargin;
  final double? bottomMargin;
  final Color? color;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 40.h,
        width: width ?? 40.h,
        padding: EdgeInsets.all(2.sp),
        margin: EdgeInsets.only(
            left: leftMargin ?? 0,
            right: rightMargin ?? 0,
            top: topMargin ?? 0,
            bottom: bottomMargin ?? 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius ?? 10.r),
            border: Border.all(color: primaryColor, width: 1.w)),
        child: Container(
          decoration: BoxDecoration(
              color: color ?? whiteColor,
              borderRadius: BorderRadius.circular(radius ?? 10.r),
              border: Border.all(color: primaryColor, width: 1.w)),
          child: Center(
              child: SvgPicture.asset(
            svgImage,
            height: svgHeight ?? 20.h,
            width: svgWidth ?? 20.h,
          )),
        ),
      ),
    );
  }
}

packageProfileDialog({required CustomCartModel cartModel}) {
  Get.dialog(
    CustomBorderDialog(
      childWidget: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              // max height for long content
              maxHeight: Get.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🟢 Scrollable only when needed
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              cartModel.type == AppConstants.package
                                  ? package
                                  : profile,
                              height: 20.h,
                            ),
                            Expanded(
                              child: Text(
                                cartModel.name.toString(),
                                style: boldPrimary2_16,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ).paddingSymmetric(horizontal: 10.w),
                            ),
                          ],
                        ),
                        if (cartModel.profilesDetail != null)
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 5.h),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartModel.profilesDetail?.length,
                            itemBuilder: (context, index) {
                              final cartItem =
                                  cartModel.profilesDetail![index];
                              return CustomContainer(
                                color: cardBgColor,
                                radius: 15.r,
                                top: 5.h,
                                child: CustomExpansionTile(
                                  collapsedIconColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(5.r)),
                                  ),
                                  iconColor: Colors.black,
                                  childrenPadding: EdgeInsets.zero,
                                  tilePadding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  expandedAlignment: Alignment.centerLeft,
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(profile),
                                      SizedBox(width: 5.w),
                                      Expanded(
                                        child: Text(
                                          cartItem.name ?? '',
                                          maxLines: 1,
                                          style: mediumBlack_12,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  expandedCrossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    if (cartItem.itemDetail != null)
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            cartItem.itemDetail!.length,
                                        separatorBuilder:
                                            (context, secondIndex) => Divider(
                                          color: borderColor,
                                          thickness: 1.w,
                                          height: 0,
                                        ),
                                        itemBuilder: (context, secondIndex) {
                                          final tests =
                                              cartItem.itemDetail![secondIndex];
                                          return CustomContainer(
                                            color: cardBgColor,
                                            radius: 15.r,
                                            topPadding: 8.h,
                                            leftPadding: 10.w,
                                            rightPadding: 10.w,
                                            bottomPadding: 8.h,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SvgPicture.asset(test),
                                                SizedBox(width: 5.w),
                                                Expanded(
                                                  child: Text(
                                                    tests.name ?? '',
                                                    maxLines: 1,
                                                    style: mediumBlack_12,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        if (cartModel.itemDetail != null)
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.only(bottom: 10.h),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartModel.itemDetail?.length,
                            itemBuilder: (context, index) {
                              final cartItem = cartModel.itemDetail![index];
                              return CustomContainer(
                                color: cardBgColor,
                                radius: 15.r,
                                top: 5.h,
                                topPadding: 8.h,
                                leftPadding: 10.w,
                                rightPadding: 10.w,
                                bottomPadding: 8.h,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(test),
                                    SizedBox(width: 5.w),
                                    Expanded(
                                      child: Text(
                                        cartItem.name ?? '',
                                        maxLines: 1,
                                        style: mediumBlack_12,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // 🔵 Fixed Close button (not part of scroll)
                Padding(
                  padding: EdgeInsets.only(top: 10.h, bottom: 5.h),
                  child: CustomButton(
                    height: 35.h,
                    borderColor: primaryColor,
                    color: whiteColor,
                    borderRadius: 100,
                    text: 'Close',
                    textStyle: semiBoldPrimary_16,
                    onTap: () {
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}


testDialog({required CustomCartModel cartModel}) {
  Get.dialog(CustomBorderDialog(
    childWidget: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(cartModel.name.toString(),
                style: boldPrimary2_16,
                maxLines: 1,
                overflow: TextOverflow.ellipsis)
            .paddingSymmetric(horizontal: 15.w),
        if (cartModel.itemDetail != null &&
            cartModel.itemDetail!.isNotEmpty &&
            cartModel.itemDetail![0].detail != null &&
            cartModel.itemDetail![0].detail!.isNotEmpty)
          Text("Instructions : ${cartModel.itemDetail![0].detail}",
                  style: regularGray_13,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis)
              .paddingSymmetric(horizontal: 15.w),
        if (cartModel.itemDetail != null && cartModel.itemDetail!.isNotEmpty)
          CustomContainer(
              top: 5.h,
              color: primaryColor,
              borderColor: borderColor,
              borderWidth: 1.w,
              left: 5.w,
              radius: 5.r,
              rightPadding: 6.w,
              leftPadding: 6.w,
              topPadding: 2.h,
              bottomPadding: 2.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(bloodIcon, color: whiteColor),
                  SizedBox(width: 3.w),
                  Text('${cartModel.itemDetail![0].sampleCollection}',
                      style: regularWhite_12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              )),
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
}

parametersDialog({required CustomCartModel cartModel}) {
  final paramList = cartModel.parameters.toString().split(',');
  Get.dialog(CustomBorderDialog(
    childWidget: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: paramList.length,
          itemBuilder: (_, int index) =>
              Text(paramList[index], style: mediumBlack_14),
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
}

double calculateDistance(LatLng start, LatLng end) {
  const double earthRadius = 6371.0; // Radius of Earth in kilometers
  double lat1 = start.latitude;
  double lon1 = start.longitude;
  double lat2 = end.latitude;
  double lon2 = end.longitude;

  double dLat = _degToRad(lat2 - lat1);
  double dLon = _degToRad(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) *
          cos(_degToRad(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = earthRadius * c;
  // print('Distance before rounding: $distance km');

  // Round to one decimal place
  distance = double.parse(distance.toStringAsFixed(1));

  // Adjust the distance if necessary
  if (distance - distance.floor() == 0.0 ||
      distance - distance.floor() == 0.5) {
    distance = distance.ceilToDouble();
  }

  return distance;
}

double _degToRad(double degree) {
  return degree * pi / 180.0;
}

launchUrlInOtherApp({required Uri url}) async {
  try {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
      webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
    );
  } catch (e) {
    e.toString();
  }
}
