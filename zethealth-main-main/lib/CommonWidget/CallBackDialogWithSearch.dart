import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:zet_health/CommonWidget/CountryCode.dart';

import '../Helper/AppConstants.dart';
import '../Helper/ColorHelper.dart';
import '../Helper/StyleHelper.dart';
import '../Models/CityModel.dart';
import 'CustomTextField2.dart';

class CallBackDialogWithSearch extends StatefulWidget {
  const CallBackDialogWithSearch(
      {super.key, required this.callBack, required this.type});

  final Function(dynamic) callBack;
  final int type;

  @override
  State<CallBackDialogWithSearch> createState() =>
      _CallBackDialogWithSearchState();
}

class _CallBackDialogWithSearchState extends State<CallBackDialogWithSearch> {
  final TextEditingController searchController = TextEditingController();

  List filterCountryIndex = [];
  List<CityModel> cityList = [];
  List<CityModel> tempCityList = [];
  GetStorage getStorage = GetStorage();

  @override
  void initState() {
    super.initState();
    if (widget.type == 0) {
      for (int i = 0; i < countryCodes.length; i++) {
        filterCountryIndex.add(i);
      }
    } else if (widget.type == 1) {
      print('=== LOADING CITIES FROM STORAGE ===');
      List<CityModel> list = AppConstants().getCityList();
      if (list.isNotEmpty) {
        cityList.addAll(list);
        tempCityList.addAll(list);
        print('Loaded ${list.length} cities from storage');
      } else {
        print('No cities found in storage');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  height: Get.height / 1.3,
                  margin: EdgeInsets.symmetric(horizontal: 15.w),
                  decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(15.r)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CustomTextField2(
                            width: Get.width / 1.2,
                            hintText: 'search_city'.tr,
                            filled: true,
                            bottomMargin: 5.h,
                            topMargin: 20.h,
                            onChanged: filterList,
                            horizontalMargin: 15.w,
                            fillColor: whiteColor,
                            textInputAction: TextInputAction.search,
                            controller: searchController,
                            prefix: Icon(
                              FontAwesomeIcons.magnifyingGlass,
                              size: 14.sp,
                              color: primaryColor,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                if (searchController.text.trim().isNotEmpty) {
                                  filterList('');
                                  searchController.clear();
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: Icon(
                                FontAwesomeIcons.xmark,
                                size: 18.sp,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.type == 0
                          ? filterCountryIndex.isEmpty
                          : cityList.isEmpty)
                        Text('no_data_found'.tr, style: semiBoldGray_14)
                      else
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            itemCount: widget.type == 0
                                ? filterCountryIndex.length
                                : cityList.length,
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () {
                                    if (widget.type == 0) {
                                      widget.callBack.call(
                                          '+${countryCodes[filterCountryIndex[index]]['e164_cc']}');
                                    } else if (widget.type == 1) {
                                      widget.callBack.call(cityList[index]);
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      child: widget.type == 0
                                          ? Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                SizedBox(
                                                    width: 65.w,
                                                    child: Text(
                                                      '+${countryCodes[filterCountryIndex[index]]['e164_cc']}',
                                                      style: mediumBlack_14,
                                                    )),
                                                Text(
                                                  '${countryCodes[filterCountryIndex[index]]['name']}',
                                                  style: regularBlack_14,
                                                  maxLines: 2,
                                                ),
                                              ],
                                            )
                                          : Text(
                                              cityList[index]
                                                  .cityName
                                                  .toString(),
                                              style: mediumBlack_14,
                                            )));
                            },
                          ),
                        ),
                    ],
                  )),
            ],
          )),
    );
  }

  filterList(String query) {
    if (widget.type == 0) {
      filterCountryIndex = [];
      if (query.isEmpty) {
        setState(() {
          for (int i = 0; i < countryCodes.length; i++) {
            filterCountryIndex.add(i);
          }
        });
      } else {
        for (int i = 0; i < countryCodes.length; i++) {
          if (countryCodes[i]['name']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              countryCodes[i]['e164_cc']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase())) {
            filterCountryIndex.add(i);
          }
        }
        setState(() {});
      }
    } else if (widget.type == 1) {
      cityList = [];
      if (query.isEmpty) {
        setState(() {
          for (int i = 0; i < tempCityList.length; i++) {
            cityList.add(tempCityList[i]);
          }
        });
      } else {
        for (int i = 0; i < tempCityList.length; i++) {
          if (tempCityList[i]
              .cityName
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())) {
            cityList.add(tempCityList[i]);
          }
        }
        setState(() {});
      }
    }
  }
}
