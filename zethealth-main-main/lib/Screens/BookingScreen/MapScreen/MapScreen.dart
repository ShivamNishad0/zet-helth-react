// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:zet_health/Helper/AssetHelper.dart';
import 'package:zet_health/Helper/StyleHelper.dart';
import 'package:location/location.dart';
import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomContainer.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Models/BookingModel.dart';
import 'Repo.dart';
import 'Stages.dart';

class MapScreen extends StatefulWidget {
  const MapScreen(
      {super.key, required this.bookingModel, required this.showCongrats});
  final BookingModel bookingModel;
  final bool showCongrats;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  Rx<MapType> currentMapType = MapType.normal.obs;
  GoogleMapController? googleMapController;
  Location location = Location();
  Marker? _marker;
  RxString selectAddress = ''.obs;
  RxDouble lat = 0.0.obs;
  RxDouble long = 0.0.obs;
  Rx<LatLng> currentLatLong = const LatLng(22.2871, 70.7925).obs;
  Rx<LatLng> endLatLng = const LatLng(22.2871, 70.7925).obs;
  late final DateTime _orderTime;
  final RxList<Stages> stages = <Stages>[].obs;
  final RxInt currentStage = 0.obs;
  late Timer ticker;
  final RxInt secondsLeft = 0.obs;
  // final RxBool revealMap = false.obs;
  late AnimationController animationController;
  late Animation<double> animation;
  RxDouble reveal = 0.0.obs; // instead of RxBool

  @override
  void initState() {
    super.initState();
    _orderTime = orderTime();
    buildStages();
    startTicker();

    if (widget.showCongrats) {
      animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );

      animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      )..addListener(() {
          reveal.value = animation.value;
        });

      // First show banner for 2.5 seconds, then start animation
      Future.delayed(const Duration(milliseconds: 2500), () {
        animationController.forward();
      });
    }
  }

  Timer? timer;
  // Polyline? routePolyline;
  // Rx<PolylineResult> polylineResult = PolylineResult().obs;
  bool isRouteCreating = false;
  Marker? currentMarker;
  Marker? endMarker;
  RxDouble distance = 0.0.obs;

  Future<void> onMapCreated(GoogleMapController controller) async {
    // final GoogleMapController myController = await _controller.future;

    googleMapController = controller;
    EasyLoading.show(
      status: 'Please Wait...',
      maskType: EasyLoadingMaskType.black,
    );
    startListen();
    timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      startListen();
    });
    EasyLoading.dismiss();
  }

  void startListen() {
    DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('location_master');

    // Assuming waitViewModel.requestModel.value is available in Flutter too
    String driverId = widget.bookingModel.boyId.toString();

    dbRef.orderByChild('user_id').equalTo(driverId).onValue.listen((event) {
      var values = event.snapshot.value;
      if (values != null) {
        String temp = json.encode(values);
        Map<String, dynamic> decoded = json.decode(temp);
        currentLatLong.value = LatLng(
            decoded[driverId]['latitude'], decoded[driverId]['longitude']);
        endLatLng.value = LatLng(
            double.parse(widget.bookingModel.fromLatitude.toString()),
            double.parse(widget.bookingModel.fromLongitude.toString()));
        getCurrentLocationSetPin();
      }
    }, onError: (error) {
      EasyLoading.dismiss();
    });
  }

  getCurrentLocationSetPin() async {
    distance.value = calculateDistance(currentLatLong.value, endLatLng.value);
    BitmapDescriptor? currentMarkerIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset(path: currentMarkerIc, width: 100));
    BitmapDescriptor? endMarkerIcon = BitmapDescriptor.fromBytes(
        await getBytesFromAsset(path: mapLocationIc, width: 100));

    // PolylineResult? pointLatLng = await Repo.getRouteBetweenTwoPoints(start: currentLatLong.value, end: endLatLng.value, color: primaryColor);
    // if(pointLatLng!=null) {
    //   routePolyline = Polyline(
    //       polylineId: const PolylineId("Routes"),
    //       color: const Color(0xff4a54cd),
    //       width: 4,
    //       points: pointLatLng.points.map((e) => LatLng(e.latitude, e.longitude)).toList()
    //   );
    //   polylineResult.value = pointLatLng;
    // }

    currentMarker = Marker(
        markerId: const MarkerId("currentMarker"),
        icon: currentMarkerIcon,
        position: currentLatLong.value);
    endMarker = Marker(
        markerId: const MarkerId("endMarker"),
        icon: endMarkerIcon,
        position: endLatLng.value);
    updateCameraLocationToZoomBetweenTwoMarkers(
        currentLatLong.value, endLatLng.value, googleMapController!);
    if (mounted) {
      setState(() {});
    }
  }

  DateTime orderTime() {
    try {
      return DateFormat("yyyy-MM-dd HH:mm:ss")
          .parse(widget.bookingModel.createdDate.toString().trim());
    } catch (_) {
      return DateTime.now();
    }
  }

  void buildStages() {
    final temp = <Stages>[
      Stages('Order Confirmed', _orderTime, true),
      Stages('Phlebotomist Assigned',
          _orderTime.add(const Duration(seconds: 1)), true),
      Stages('Phlebotomist is Reaching Your Location',
          _orderTime.add(const Duration(minutes: 10)), false),
      Stages('Phlebotomist Has Arrived',
          _orderTime.add(const Duration(minutes: 10)), false),
      Stages('Sample Collected by Phlebotomist',
          _orderTime.add(const Duration(minutes: 15)), false),
      Stages('Sample Deposited at Laboratory',
          _orderTime.add(const Duration(minutes: 30)), false),
      Stages('Sample in Process at Lab',
          _orderTime.add(const Duration(minutes: 40)), false),
      Stages('Sample Processed',
          _orderTime.add(const Duration(hours: 1, minutes: 30)), false),
      Stages('Report Delivered',
          _orderTime.add(const Duration(hours: 1, minutes: 40)), false),
    ];

    // mark stages that are already in the past
    final now = DateTime.now();
    stages.assignAll(
      temp
          .map((s) => s.time.isBefore(now) ? Stages(s.status, s.time, true) : s)
          .toList(),
    );

    // find current stage index
    currentStage.value = stages.lastIndexWhere((e) => e.isCompleted);
    if (currentStage.value < 0) currentStage.value = 0;
  }

  void startTicker() {
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();

      // update the countdown
      final arrival = stages.firstWhere((e) => e.status == 'Phlebotomist Has Arrived');
      secondsLeft.value = arrival.time.isAfter(now)
          ? arrival.time.difference(now).inSeconds
          : 0;

      // update completed stages
      for (var i = 0; i < stages.length; i++) {
        if (!stages[i].isCompleted && now.isAfter(stages[i].time)) {
          stages[i] = Stages(stages[i].status, stages[i].time, true);
          currentStage.value = i;
        }
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    ticker.cancel();
    googleMapController?.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('booking_details'.tr, style: semiBoldBlack_18),
      ),
      body: Stack(
        children: [
          // Map area with reveal
          SizedBox(
            height: 0.56.sh,
            child: Stack(
              children: [
                // Map clipped
                Obx(() {
                  return ClipPath(
                    child: GoogleMap(
                      padding: EdgeInsets.only(bottom: 45),
                      myLocationEnabled: false,
                      myLocationButtonEnabled: true,
                      tiltGesturesEnabled: true,
                      mapType: currentMapType.value,
                      initialCameraPosition: CameraPosition(
                          target: currentLatLong.value, zoom: 18),
                      onMapCreated: onMapCreated,
                      markers: {
                        currentMarker ??
                            const Marker(markerId: MarkerId("currentMarker")),
                        endMarker ??
                            const Marker(markerId: MarkerId("endMarker")),
                      },
                    ),
                  );
                }),

                // Banner also clipped with same reveal (so circle removes it)
                Obx(() {
                  return ClipPath(
                    clipper: CircleRevealClipper(reveal: 1.0 - reveal.value),
                    child: Container(
                      color: whatsappGreen,
                      alignment: Alignment.center,
                      child: Text(
                        'Congratulations,\nYour Order is Confirmed!',
                        textAlign: TextAlign.center,
                        style: semiBoldWhite_24,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Draggable Booking Details Card
          DraggableScrollableSheet(
            initialChildSize: 0.42, // default visible height
            minChildSize: 0.42, // collapsed height
            maxChildSize: 1, // fully expanded height
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30.r)),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40.w,
                            height: 4.h,
                            margin: EdgeInsets.only(bottom: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),

                        // Timer
                        Obx(() {
                          final left =
                              secondsLeft.value; // <- use the ticking Rx
                          if (left <= 0) return const SizedBox.shrink();

                          final min = (left ~/ 60).toString().padLeft(2, '0');
                          final sec = (left % 60).toString().padLeft(2, '0');

                          return Container(
                            width: Get.width,
                            margin: EdgeInsets.only(top: 10.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color: whatsappGreen,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: '$min:$sec',
                                        style: boldWhite_45),
                                    TextSpan(
                                        text: ' min',
                                        style: semiBoldWhite_20)
                                  ]),
                                ),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: 'estimated'.tr,
                                        style: semiBoldWhite_20),
                                    TextSpan(
                                        text: ' ${'pickup_time'.tr}',
                                        style: semiBoldWhite_20),
                                  ]),
                                ),
                              ],
                            ),
                          );
                        }),
                        SizedBox(height: 15.h),

                        // Booking name + more icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(widget.bookingModel.bookingName!,
                                    style: semiBoldBlack_13)),
                            // Container(
                            //   padding: EdgeInsets.symmetric(
                            //       vertical: 3.h, horizontal: 4.w),
                            //   decoration: BoxDecoration(
                            //       color: cardBgColor,
                            //       borderRadius:
                            //           BorderRadius.all(Radius.circular(10.r)),
                            //       border:
                            //           Border.all(color: borderColor, width: 1)),
                            //   child: const Icon(Icons.more_vert,
                            //       color: primaryColor),
                            // )
                          ],
                        ),
                        SizedBox(height: 7.h),

                        // Status + Booking No
                        Row(
                          children: [
                            if (widget.bookingModel.bookingStatus!.isNotEmpty)
                              CustomContainer(
                                right: 5.w,
                                borderColor:
                                    widget.bookingModel.bookingStatus ==
                                            "Pending"
                                        ? pendingBorderColor
                                        : completeBorderColor,
                                radius: 18.r,
                                leftPadding: 6.w,
                                rightPadding: 6.w,
                                topPadding: 2.h,
                                borderWidth: 1.w,
                                bottomPadding: 2.h,
                                color: widget.bookingModel.bookingStatus ==
                                        "Pending"
                                    ? pendingColor
                                    : completeColor,
                                child: Text(
                                    '${widget.bookingModel.bookingStatus}',
                                    style: mediumBlack_10),
                              ),
                            CustomContainer(
                              borderColor: borderColor,
                              radius: 18.r,
                              leftPadding: 6.w,
                              rightPadding: 6.w,
                              topPadding: 2.h,
                              bottomPadding: 2.h,
                              color: cardBgColor,
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: '#', style: semiBoldPrimary_12),
                                  TextSpan(
                                      text:
                                          ' ${widget.bookingModel.bookingNo?.substring(1)}',
                                      style: mediumBlack_10)
                                ]),
                              ),
                            ),
                          ],
                        ),

                        // Lab name
                        CustomContainer(
                          right: 5.w,
                          bottom: 5.h,
                          top: 5.h,
                          borderColor: borderColor,
                          radius: 18.r,
                          leftPadding: 6.w,
                          rightPadding: 6.w,
                          topPadding: 2.h,
                          bottomPadding: 2.h,
                          color: cardBgColor,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.business_outlined,
                                  color: primaryColor, size: 14.sp),
                              SizedBox(width: 2.w),
                              Text(widget.bookingModel.labName!,
                                  style: mediumBlack_10)
                            ],
                          ),
                        ),

                        // Date
                        Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                                customDateFormat(
                                    widget.bookingModel.createdDate.toString()),
                                style: mediumGray_10)),
                        // SizedBox(height: 5.h),

                        // Rider info + call/chat buttons
                        // Row(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Expanded(
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Text(
                        //             widget.bookingModel.boyName.toString(),
                        //             style: semiBoldBlack_14,
                        //             maxLines: 2,
                        //             overflow: TextOverflow.ellipsis,
                        //             textAlign: TextAlign.center,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     DoubleBorderContainer(
                        //       leftMargin: 10.w,
                        //       svgImage: chatting,
                        //       onTap: () async {
                        //         final Uri launchUri = Uri.parse(
                        //             'https://wa.me/${widget.bookingModel.boyNumber}');
                        //         launchUrlInOtherApp(url: launchUri);
                        //       },
                        //     ),
                        //     DoubleBorderContainer(
                        //       leftMargin: 10.w,
                        //       svgImage: callingIcon,
                        //       onTap: () async {
                        //         final Uri launchUri = Uri(
                        //             scheme: 'tel',
                        //             path: widget.bookingModel.boyNumber);
                        //         launchUrlInOtherApp(url: launchUri);
                        //       },
                        //     )
                        //   ],
                        // ),

                        SizedBox(height: 15.h),
                        Text('Order Progress', style: semiBoldBlack_14),
                        SizedBox(height: 10.h),
                        // buildVerticalTimeline(buildStages()),
                        Obx(() => buildVerticalTimeline(stages)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildVerticalTimeline(List<Stages> stages) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: stages.length,
      separatorBuilder: (_, __) => SizedBox(height: 0.h),
      itemBuilder: (_, index) {
        final stage = stages[index];
        final isLast = index == stages.length - 1;
        final done = stage.isCompleted;

        return IntrinsicHeight(
          child: Row(
            children: [
              // Dot & line
              SizedBox(
                width: 30.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: done ? 20.w : 14.w,
                      height: done ? 20.w : 14.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? primaryColor : greyColor,
                      ),
                      child: done
                          ? Icon(Icons.check, size: 12.sp, color: white)
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: VerticalDivider(
                          width: 2.w,
                          thickness: 2.w,
                          color: done ? primaryColor : greyColor,
                        ),
                      ),
                    if (isLast)
                      Expanded(
                        child: VerticalDivider(
                          width: 2.w,
                          thickness: 2.w,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),

              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.status,
                      style: done ? mediumBlack_12 : semiBoldBlack_12,
                    ),
                    SizedBox(height: 2.h),

                    // ETA for upcoming stages
                    if (!done)
                      Text(
                        'ETA ${DateFormat('hh:mm a').format(stage.time)}',
                        // DateFormat('hh:mm a').format(stage.time),
                        style: regularGray_10,
                      ),

                    // existing time
                    if (done)
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: slideCard,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            DateFormat('hh:mm a').format(stage.time),
                            style: mediumPrimary_10,
                          ),
                        ),
                      ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CircleRevealClipper extends CustomClipper<Path> {
  final double reveal; // 0 → fully covered, 1 → fully visible
  CircleRevealClipper({required this.reveal});

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.longestSide;
    final radius = maxRadius * reveal;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant CircleRevealClipper old) => old.reveal != reveal;
}
