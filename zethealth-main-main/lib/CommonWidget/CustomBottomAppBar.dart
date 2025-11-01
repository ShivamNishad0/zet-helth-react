import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zet_health/Helper/ColorHelper.dart';

import 'CustomContainer.dart';
import 'CustomWidgets.dart';

class CustomBottomAppBar extends StatefulWidget {
  final Color? backgroundColor;
  final List<PandaBarButtonData> buttonData;
  final Widget? fabIcon;

  final Color? buttonColor;
  final Color? buttonSelectedColor;
  final List<Color>? fabColors;

  final Function(dynamic selectedPage) onChange;
  final VoidCallback? onFabButtonPressed;

  const CustomBottomAppBar({
    super.key,
    required this.buttonData,
    required this.onChange,
    this.backgroundColor,
    this.fabIcon,
    this.fabColors,
    this.onFabButtonPressed,
    this.buttonColor,
    this.buttonSelectedColor,
  });

  @override
  _CustomBottomAppBarState createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  final double fabSize = 55;
  final Color unSelectedColor = Colors.grey;

  dynamic selectedId;

  @override
  void initState() {
    selectedId =
        widget.buttonData.isNotEmpty ? widget.buttonData.first.id : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final clipper = _PandaBarClipper(fabSize: fabSize);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CustomPaint(
          painter: _ClipShadowPainter(
            shadow: Shadow(
                color: Colors.white.withOpacity(.1),
                blurRadius: 10,
                offset: const Offset(0, -3)),
            clipper: clipper,
          ),
          child: ClipPath(
            clipper: clipper,
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? const Color(0xFF222427),
                border: Border(
                  top: BorderSide(
                    color: primaryColor,
                    width: 2.w,
                  ),
                ),
              ),
              child: Builder(builder: (context) {
                List<Widget> leadingChildren = [];
                List<Widget> trailingChildren = [];

                widget.buttonData.asMap().forEach((i, data) {
                  Widget btn = PandaBarButton(
                    icon: data.icon,
                    title: data.title,
                    isSelected: data.id != null && selectedId == data.id,
                    unselectedColor: widget.buttonColor,
                    selectedColor: widget.buttonSelectedColor,
                    onTap: () {
                      setState(() {
                        selectedId = data.id;
                      });
                      widget.onChange(data.id);
                    },
                  );

                  if (i < 2) {
                    leadingChildren.add(btn);
                  } else {
                    trailingChildren.add(btn);
                  }
                });

                return Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: leadingChildren,
                      ),
                    ),
                    Container(
                      width: fabSize.w,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: trailingChildren,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        Positioned(
          bottom: fabSize.h / 1.4.h,
          child: CustomContainer(
            width: fabSize.w,
            height: fabSize.h,
            onTap: widget.onFabButtonPressed,
            color: primaryColor,
            borderColor: Colors.white,
            borderWidth: 1.w,
            radius: 25.r,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 3,
                offset: const Offset(0, 5),
              )
            ],
            child: widget.fabIcon,
          ),
        ),

        // PandaBarFabButton(
        //   size: fabSize,
        //   icon: widget.fabIcon,
        //   onTap: widget.onFabButtonPressed,
        //   colors: widget.fabColors,
        // ),
      ],
    );
  }
}

class _PandaBarClipper extends CustomClipper<Path> {
  final double fabSize;
  final double padding = 50;
  final double centerRadius = 25;
  final double cornerRadius = 5;

  _PandaBarClipper({this.fabSize = 100});

  @override
  Path getClip(Size size) {
    final xCenter = (size.width / 2);

    final fabSizeWithPadding = fabSize + padding;

    final path = Path();
    path.lineTo((xCenter - (fabSizeWithPadding / 2) - cornerRadius), 0);
    path.quadraticBezierTo(xCenter - (fabSizeWithPadding / 2), 0,
        (xCenter - (fabSizeWithPadding / 2)) + cornerRadius, cornerRadius);
    path.lineTo(
        xCenter - centerRadius, (fabSizeWithPadding / 2) - centerRadius);
    path.quadraticBezierTo(xCenter, (fabSizeWithPadding / 2),
        xCenter + centerRadius, (fabSizeWithPadding / 2) - centerRadius);
    path.lineTo(
        (xCenter + (fabSizeWithPadding / 2) - cornerRadius), cornerRadius);
    path.quadraticBezierTo(xCenter + (fabSizeWithPadding / 2), 0,
        (xCenter + (fabSizeWithPadding / 2) + cornerRadius), 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}

class _ClipShadowPainter extends CustomPainter {
  final Shadow shadow;
  final CustomClipper<Path> clipper;

  _ClipShadowPainter({required this.shadow, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = shadow.toPaint();
    var clipPath = clipper.getClip(size).shift(shadow.offset);
    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class PandaBarButtonData {
  final dynamic id;
  final Widget icon;
  final String title;

  PandaBarButtonData({
    this.id,
    required this.icon,
    this.title = '',
  });
}
