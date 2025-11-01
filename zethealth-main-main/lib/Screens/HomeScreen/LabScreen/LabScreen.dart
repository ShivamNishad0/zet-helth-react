import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/LabModel.dart';
import 'package:zet_health/Models/CityModel.dart';
// import 'package:zet_health/Screens/HomeScreen/LabScreen/LabDetailScreen.dart';
import 'package:zet_health/Screens/HomeScreen/LabScreen/LabScreenController.dart';

import 'package:zet_health/Screens/BranchScreen/branchListWidget.dart';

import '../../../CommonWidget/CallBackDialogWithSearch.dart';
import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomContainer.dart';
import '../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../DrawerView/OrderHistoryScreen/ReviewRatingScreen/review_rating_screen.dart';
import 'package:flutter/material.dart';

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen>
    with SingleTickerProviderStateMixin {
  LabScreenController labScreenController = Get.put(LabScreenController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // String? cityId = AppConstants().getStorage.read(AppConstants.CITY_ID);
    // String? cityName =
    // AppConstants().getStorage.read(AppConstants.CURRENT_LOCATION);

      // Log city details
    // debugPrint("Selected City ID: $cityId");
    // debugPrint("Selected City Name: $cityName");
  
    // if (cityId != null) {
    //   labScreenController.selectedCity =
    //       CityModel(id: cityId, cityName: cityName);
    // }
    labScreenController.callGetLabListApi();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        leading: Image.asset(backArrow),
        title: Text('find_lab'.tr, style: semiBoldBlack_18),
        actions: [CartButtonCommon()],
      ),
      body: PaddingHorizontal15(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoTextField(
              suffixMode: OverlayVisibilityMode.always,
              minLines: 1,
              placeholder: 'search_lab'.tr,
              style: semiBoldBlack_14,
              cursorColor: primaryColor,
              textAlign: TextAlign.start,
              onChanged: filterList,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              prefixMode: OverlayVisibilityMode.always,
              prefix: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: SvgPicture.asset(searchDotsIcon)),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  border: Border.all(color: borderColor, width: 1.w)),
              onTap: () {},
            ),
            
            SizedBox(height: 10.h),
            TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: blackColor,
              indicatorColor: primaryColor,
              tabs: [
                Tab(text: 'Labs'),
              ],
            ),
            SizedBox(height: 11.h),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Obx(
                        () => labScreenController.isLoading.value
                        ? const SizedBox()
                        : labScreenController.labList.isEmpty
                        ? NoDataFoundWidget(
                      title: 'no_lab_found'.tr,
                      description: '',
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: labScreenController.labList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        LabModel labModel =
                        labScreenController.labList[index];
                        return CustomContainer(
                          bottom: 15.h,
                          // onTap: () {
                          //   AppConstants().loadWithCanBack(
                          //       LabDetailScreen(labModel));
                          // },
                          radius: 16.r,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: borderColor.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 5),
                            )
                          ],
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.h,
                              horizontal: 8.w,
                            ),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10.r)),
                                  child: CachedNetworkImage(
                                    imageUrl: AppConstants.IMG_URL +
                                        labModel.labProfile!,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                    errorWidget:
                                        (context, url, error) =>
                                    const ImageErrorWidget(),
                                    width: 74.w,
                                    height: 69.h,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${labModel.labName}',
                                        maxLines: 2,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: semiBoldBlack_13,
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      if (labModel.address != null)
                                        Text('${labModel.address}',
                                            style: regularBlack_11),
                                      CustomContainer(
                                        onTap: () {
                                          Get.to(() =>
                                              ReviewRatingScreen(
                                                  labId: labModel
                                                      .labId
                                                      .toString()));
                                        },
                                        top: 5.h,
                                        radius: 18.r,
                                        leftPadding: 6.w,
                                        rightPadding: 6.w,
                                        topPadding: 2.h,
                                        bottomPadding: 2.h,
                                        color: cardBgColor,
                                        child: Row(
                                          mainAxisSize:
                                          MainAxisSize.min,
                                          children: [
                                            Center(
                                                child: FaIcon(
                                                  FontAwesomeIcons
                                                      .solidStar,
                                                  size: 11.sp,
                                                  color: primaryColor,
                                                )),
                                            SizedBox(width: 1.w),
                                            Center(
                                                child: Text(
                                                    '${labModel.rating}',
                                                    style:
                                                    semiBoldBlack_10)),
                                            SizedBox(width: 5.w),
                                            Center(
                                                child: Text(
                                                    '${labModel.reviews} User',
                                                    style:
                                                    semiBoldBlack_10)),
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
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  filterList(String query) {
    labScreenController.labList.clear();
    if (query.isEmpty) {
      setState(() {
        labScreenController.labList.addAll(labScreenController.filterList);
      });
    } else {
      for (int i = 0; i < labScreenController.filterList.length; i++) {
        if (labScreenController.filterList[i].labName
            .toString()
            .toLowerCase()
            .contains(query.trim().toLowerCase()) ||
            labScreenController.filterList[i].address
                .toString()
                .toLowerCase()
                .contains(query.trim().toLowerCase())) {
          labScreenController.labList.add(labScreenController.filterList[i]);
        }
      }
    }
    setState(() {});
  }
}
