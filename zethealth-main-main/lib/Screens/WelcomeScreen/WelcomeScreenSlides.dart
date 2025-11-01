import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zet_health/Helper/AssetHelper.dart';

class Slide {
  final String title;
  final String description;
  final String imageAsset;

  Slide({required this.title, required this.description, required this.imageAsset});
}

List<Slide> slideList = [
  Slide(
    title: "Zet Health",
    description: "Get instant access to diagnostic tests with lightning-fast home collection and same-day reports.",
    imageAsset: first,
  ),
  Slide(
    title: "Lightning Speed",
    description: "Experience the fastest healthcare service in India with our revolutionary 10-minute home sample collection.",
    imageAsset: second,
  ),
  Slide(
    title: "24/7 Availability",
    description: "Round-the-clock healthcare services whenever you need them. No more waiting for clinic.",
    imageAsset: third,
  ),
  Slide(
    title: "Trusted Labs",
    description: "NABL accredited labs and certified trained phlebotomists ensure accurate results you can trust.",
    imageAsset: fourth,
  ),
  Slide(
    title: "Same Day Reports",
    description: "Get your diagnostic test reports delivered the same day. No more anxious waiting periods.",
    imageAsset: fifth,
  ),
  Slide(
    title: "Vast Coverage",
    description: "Comprehensive test library spanning pathology and radiology from multiple accredited labs.",
    imageAsset: sixth,
  ),
  Slide(
    title: "Transparent Pricing",
    description: "Affordable healthcare with transparent pricing across all diagnostic tests from nearby labs.",
    imageAsset: seventh,
  ),
];