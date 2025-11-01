import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../Helper/AssetHelper.dart';
import '../Helper/ColorHelper.dart';
import 'CustomWidgets.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final double? toolBarHeight;
  final Widget? title;
  final Color? backgroundColor;
  final double? titleSpacing;
  final List<Widget>? actions;
  final bool? isLeading;
  final Widget? leading;
  final bool? centerTitle;
  final Widget? flexibleChild;
  final Function()? onTap;

  const CustomAppbar({
    super.key,
    this.titleSpacing,
    this.onTap,
    this.toolBarHeight,
    this.title,
    this.flexibleChild,
    this.actions,
    this.leading,
    this.isLeading = false,
    this.centerTitle = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      backgroundColor: backgroundColor ?? Colors.white,
      toolbarHeight: toolBarHeight ?? 55.h,
      shadowColor: Colors.white,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: isLeading != null && isLeading!
          ? CustomSquareButton(
              backgroundColor: Colors.white,
              leftMargin: 15.w,
              icon: backArrow,
              iconColor: Colors.black,
              onTap: onTap ?? () => _safeNavigateBack(context),
              shadow: const [
                BoxShadow(
                    color: borderColor,
                    blurRadius: 8,
                    spreadRadius: -1,
                    offset: Offset(1, 3))
              ],
            )
          : leading,
      title: title,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolBarHeight ?? 55.h);

  static void _safeNavigateBack(BuildContext context) {
    // Use Flutter's native navigation only
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
