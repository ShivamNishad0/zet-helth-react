import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import '../Helper/ColorHelper.dart';
import '../Helper/StyleHelper.dart';

// ignore: must_be_immutable
class CustomTextField2 extends StatelessWidget {
  final double? height;
  final double? width;
  final String? title;
  final String? hintText;
  final String? labelText;
  final Color? borderClr;
  final Color? errorBorderColor;
  final Color? fillColor;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextStyle? titleStyle;
  final TextStyle? textStyle;
  final double? horizontalMargin;
  final double? topMargin;
  final double? bottomMargin;
  final double? horizontalPadding;
  final double? topPadding;
  final double? bottomPadding;
  final double? borderRadius;
  final bool? obscureText;
  final bool? filled;
  final bool? enabled;
  final int? maxLength;
  final bool? readOnly;
  final Widget? suffixIcon;
  final double? suffixIconMinWidth;
  final double? suffixIconMaxWidth;
  final bool? alignLabelWithHint;
  final Widget? prefix;
  final Function? onChanged;
  final EdgeInsets? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? hintStyle;
  final InputBorder? inputBorder;
  Function? onTap;
  final int? maxLines;
  final FocusNode? focusNode;
  final TextAlign? textAlign;
  final Widget? titleSuffixIcon;

  CustomTextField2({
    super.key,
    this.height,
    this.width,
    this.title,
    this.hintText,
    this.labelText,
    this.borderClr,
    this.errorBorderColor,
    this.fillColor,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.titleStyle,
    this.textStyle,
    this.horizontalMargin,
    this.topMargin,
    this.bottomMargin,
    this.borderRadius,
    this.horizontalPadding,
    this.topPadding,
    this.bottomPadding,
    this.obscureText,
    this.filled,
    this.enabled,
    this.maxLength,
    this.readOnly,
    this.suffixIcon,
    this.suffixIconMinWidth,
    this.suffixIconMaxWidth,
    this.prefix,
    this.hintStyle,
    this.maxLines,
    this.onTap,
    this.contentPadding,
    this.alignLabelWithHint,
    this.inputFormatters,
    this.onChanged,
    this.inputBorder,
    this.focusNode,
    this.textAlign,
    this.titleSuffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (title != null)
              Text(title!.tr, style: titleStyle ?? semiBoldBlack_14),
            if (titleSuffixIcon != null) ...[
              SizedBox(width: 5.w),
              titleSuffixIcon!,
            ]
          ],
        ),
        Container(
          height: height,
          width: width ?? Get.width,
          decoration: BoxDecoration(
            color: filled ?? false ? cardBgColor : fillColor,
            borderRadius:
                BorderRadius.all(Radius.circular(borderRadius ?? 15.r)),
          ),
          margin: EdgeInsets.only(
              left: horizontalMargin ?? 0,
              right: horizontalMargin ?? 0,
              top: topMargin ?? 0,
              bottom: bottomMargin ?? 0),
          child: KeyboardActions(
            config: buildKeyboardActionsConfig(context, focusNode),
            disableScroll: true,
            child: TextFormField(
                focusNode: focusNode,
                onTap: () {
                  if (onTap != null) {
                    onTap!.call();
                  }
                },
                controller: controller,
                textAlign: textAlign ?? TextAlign.start,
                obscureText: obscureText ?? false,
                keyboardType: keyboardType ?? TextInputType.text,
                inputFormatters: inputFormatters ?? [],
                textInputAction: textInputAction ?? TextInputAction.next,
                style: textStyle ?? mediumBlack_14,
                maxLength: maxLength,
                maxLines: maxLines ?? 1,
                cursorColor: borderClr ?? primaryColor,
                readOnly: readOnly ?? false,
                onChanged: (value) {
                  if (onChanged != null) {
                    onChanged!.call(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: hintStyle ??
                      TextStyle(
                          fontFamily: regular,
                          color: greyColor2,
                          fontSize: 13.sp),
                  prefixIcon: prefix,
                  counterText: "",
                  suffixIcon: suffixIcon,
                  suffixIconConstraints: BoxConstraints(
                      maxWidth: suffixIconMaxWidth ?? 40.w,
                      minWidth: suffixIconMinWidth ?? 30.w),
                  border: inputBorder ?? InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 15.r),
                      borderSide: BorderSide(width: 1.5.w, color: borderClr ?? borderColor)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 15.r),
                      borderSide: BorderSide(width: 1.5.w, color: errorBorderColor ?? borderColor)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      borderSide: BorderSide(width: 1.5.w, color: errorBorderColor ?? borderColor)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 15.r),
                      borderSide: BorderSide(width: 1.5.w, color: borderClr ?? black10)),
                  disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(borderRadius ?? 15.r),
                      borderSide: BorderSide(width: 1.5.w, color: borderClr ?? borderColor)),
                  labelText: labelText,
                  alignLabelWithHint: alignLabelWithHint ?? false,
                  contentPadding: contentPadding ?? EdgeInsets.all(10.sp),
                  // fillColor: fillColor ?? cardBgColor,
                  // filled: filled ?? false,
                )),
          ),
        ),
      ],
    );
  }
}

KeyboardActionsConfig buildKeyboardActionsConfig(
    BuildContext context, FocusNode? focusNode) {
  return KeyboardActionsConfig(
    keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
    keyboardBarColor: borderColor2,
    actions: [
      KeyboardActionsItem(focusNode: focusNode ?? FocusNode(), toolbarButtons: [
        (node) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => node.nextFocus(),
                child: Text("Next", style: semiBoldPrimary_14),
              ),
              GestureDetector(
                onTap: () => node.unfocus(),
                child: PaddingHorizontal15(
                    child: Text("Done", style: semiBoldPrimary_14)),
              )
            ],
          );
        },
      ]),
    ],
  );
}
