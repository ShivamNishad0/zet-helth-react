import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

import '../Helper/ColorHelper.dart';
import '../Helper/StyleHelper.dart';

class CustomButton extends StatelessWidget {
  final double? height;
  final double? width;
  final double? horizontalMargin;
  final double? topMargin;
  final double? bottomMargin;
  final double? borderRadius;
  final Color? color;
  final Color? borderColor;
  final String text;
  final TextStyle? textStyle;
  final Function onTap;

  const CustomButton(
      {super.key,
      this.height,
      this.width,
      this.horizontalMargin,
      this.borderRadius,
      this.color,
      this.borderColor,
      required this.text,
      this.textStyle,
      required this.onTap,
      this.topMargin,
      this.bottomMargin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap.call();
      },
      child: Container(
        height: height ?? 45.h,
        width: width ?? Get.width,
        margin: EdgeInsets.only(
            right: horizontalMargin ?? 0,
            left: horizontalMargin ?? 0,
            top: topMargin ?? 0,
            bottom: bottomMargin ?? 0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: color ?? primaryColor,
          border: Border.all(color: borderColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
        ),
        child: Center(child: Text(text, style: textStyle ?? semiBoldWhite_16)),
      ),
    );
  }
}
