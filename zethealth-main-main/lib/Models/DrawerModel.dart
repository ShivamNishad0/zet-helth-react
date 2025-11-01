import 'dart:ui';

class DrawerModel {
  final String label;
  final String image;
  final Function() onclick;
  final String? icon;
  final Color? color;

  DrawerModel({
    required this.label,
    required this.image,
    required this.onclick,
    this.icon,
    this.color
  });
}