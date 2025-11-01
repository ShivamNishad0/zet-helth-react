import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/AssetHelper.dart';
import 'package:zet_health/Models/CityModel.dart';
import 'package:zet_health/Models/custom_cart_model.dart';
import '../../../CommonWidget/CallBackDialogWithSearch.dart';
import '../../../CommonWidget/ChipsChoice.dart';
import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/CustomContainer.dart';
import '../../../CommonWidget/CustomLoadingIndicator.dart';
import '../../../CommonWidget/commonApis.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../../Models/LabModel.dart';
import '../../AuthScreen/LoginScreen.dart';
import '../../DrawerView/OrderHistoryScreen/ReviewRatingScreen/review_rating_screen.dart';
import '../TestScreen/SearchTest/SearchTestScreen.dart';
import 'AvailableLabsScreenController.dart';

class AvailableLabsScreen extends StatefulWidget {
  const AvailableLabsScreen({super.key, required this.callBack});
  final Function()? callBack;

  @override
  State<AvailableLabsScreen> createState() => _AvailableLabsScreenState();
}

class _AvailableLabsScreenState extends State<AvailableLabsScreen> {
  AvailableLabsScreenController availableLabsScreenController = Get.put(AvailableLabsScreenController());

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    availableLabsScreenController.cartList.value = await availableLabsScreenController.dbHelper.getCartList();

    availableLabsScreenController.selectedCity = getCity();
    if(availableLabsScreenController.cartList.isNotEmpty) {
      availableLabsScreenController.callTestWiseLabApi();
    }
  }

  CityModel? getCity() {
    List<CityModel> list = AppConstants().getCityList();
    for(CityModel c in list) {
      print(c.cityName);
      if(c.cityName == 'Bengaluru') {
        return c;
      }
    }

    String? cityId = AppConstants().getStorage.read(AppConstants.CITY_ID);
    String? cityName = AppConstants().getStorage.read(AppConstants.CURRENT_LOCATION);
    if(cityId!=null){
      return CityModel(id: cityId, cityName: cityName);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        title: Text('select_lab'.tr,style: semiBoldBlack_18),
      ),
      body: Obx(()=> availableLabsScreenController.cartList.isEmpty ?
      const NoDataFoundWidget(
          title: 'Empty Cart!',
          description: 'Your cart is empty! Please Add items') :
          SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PaddingHorizontal15(
                    top: 4.h,
                    bottom: 4.h,
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                              text: TextSpan(
                                  children: [
                                    TextSpan(text: 'Selected', style: boldPrimary_20),
                                    TextSpan(text: ' Tests', style: boldPrimary2_20)
                                  ]
                              )
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            List<CustomCartModel> tempList = <CustomCartModel>[];
                            tempList.addAll(availableLabsScreenController.cartList);
                            AppConstants().loadWithCanBack(
                              SearchTestScreen(
                                isSelectedItem: true,
                                callBack: (cartList) {
                                  availableLabsScreenController.cartList.value = [];
                                  availableLabsScreenController.cartList.addAll(cartList);
                                  availableLabsScreenController.callTestWiseLabApi();
                                },
                              )
                            );
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.all(Radius.circular(20.r)),
                                border: Border.all(color: primaryColor)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                              child: Text('add_more_test'.tr, style: semiBoldPrimary_12)
                          ),
                        ),
                      ],
                    ),
                  ),
                  ChipsChoice<CustomCartModel>.multiple(
                    value: availableLabsScreenController.cartList,
                    onChanged: (value) {},
                    choiceItems: C2Choice.listFrom(
                      source: availableLabsScreenController.cartList,
                      value: (i,v) => v,
                      label: (i,v) => v.name!,
                    ),
                    choiceActiveStyle: C2ChoiceStyle(
                        color: blackColor,
                        backgroundColor: borderColor,
                        labelStyle: mediumBlack_14,
                        borderColor: Colors.transparent,
                        showCheckmark: false
                    ),
                    choiceBuilder: (item) {
                      return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.symmetric(horizontal:8.w,vertical: 5.h),
                          decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.all(Radius.circular(16.r))
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // CustomContainer(
                              //   color: whiteColor,
                              //   borderWidth: 0,
                              //   radius: 8.r,
                              //   topPadding: 3.h,
                              //   bottomPadding: 3.h,
                              //   leftPadding: 3.h,
                              //   rightPadding: 3.h,
                              //   child: const Icon(Icons.remove_red_eye_rounded, color: primaryColor, size: 18),
                              // ),

                              SizedBox(width: 5.w),
                              SvgPicture.asset(item.value.type == AppConstants.test ? test:
                              item.value.type == AppConstants.package ? package : profile),
                              SizedBox(width: 5.w),

                              if(item.value.name!.length>30)
                                Expanded(child: Text(item.value.name!,style: mediumBlack_12))
                              else
                                Text(item.value.name!,style: mediumBlack_12),

                              GestureDetector(
                                onTap: () {
                                  availableLabsScreenController.cartList.remove(item.value);
                                  availableLabsScreenController.dbHelper.deleteRecordFormCart(id: item.value.id.toString(),type: item.value.type.toString());
                                  if(availableLabsScreenController.cartList.isEmpty){
                                    Get.back();
                                  }
                                  else {
                                    availableLabsScreenController.callTestWiseLabApi();
                                  }
                                  widget.callBack?.call();
                                },
                                child: Container(
                                    margin: EdgeInsets.only(left: 8.w),
                                    padding: EdgeInsets.all(5.sp),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(color: whiteColor, shape: BoxShape.circle),
                                    child: Icon(Icons.close, size: 10.sp, color: primaryColor)
                                ),
                              )
                            ],
                          )
                      );
                    },
                    choiceStyle: const C2ChoiceStyle(color: Colors.black),
                    wrapped: true,
                  ),

                  PaddingHorizontal15(
                    top: 10.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Available',
                                    style: boldPrimary_20
                                ),
                                TextSpan(
                                    text: ' Labs',
                                    style: boldPrimary2_20
                                )
                              ]
                            )
                          ),
                          SizedBox(height: 10.h,),
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
                                border: Border.all(color: borderColor, width: 1.w)
                            ),
                            onTap: () {
                            },
                          ),
                          SizedBox(height: 10.h,),
                          Row(
                            children: [
                              GestureDetector(
                                onTap:(){
                                  Get.dialog(CallBackDialogWithSearch(
                                    type: 1,
                                    callBack: (city) {
                                      setState(() {
                                        availableLabsScreenController.selectedCity = city;
                                        availableLabsScreenController.callTestWiseLabApi();
                                      });
                                    },
                                  ));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(3.sp),
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.all(Radius.circular(15.r)),
                                    border: Border.all(color: borderColor)
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 4.h),
                                    decoration: BoxDecoration(
                                        color: cardBgColor,
                                        borderRadius: BorderRadius.all(Radius.circular(15.r))
                                    ),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(locationPinIcon),
                                        SizedBox(width: 5.w),
                                        SizedBox(
                                          height: 18.h,
                                          child: Text(availableLabsScreenController.selectedCity == null ?
                                            'select_city'.tr : availableLabsScreenController.selectedCity!.cityName.toString(),
                                            style: mediumBlack_14)
                                        ),
                                        SizedBox(width: 3.w),
                                        SvgPicture.asset(dropDownIcon, color: blackColor, height: 15.h, width: 15.h),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.all(3.sp),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.all(Radius.circular(15.r)),
                                  border: Border.all(color: borderColor)
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 4.h),
                                      decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.all(Radius.circular(15.r))),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(filterIcon),
                                          SizedBox(width: 5.w,),
                                          SizedBox(
                                            height: 18.h,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton(
                                                style: mediumBlack_14,
                                                underline: null,
                                                value: availableLabsScreenController.selectedFilter,
                                                icon: Container(),
                                                items: availableLabsScreenController.filterOptions.map((String items) {
                                                  return DropdownMenuItem(
                                                    value: items,
                                                    child: Text(items, style: mediumBlack_12,)
                                                  );
                                                }).toList(),
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    availableLabsScreenController.selectedFilter = value!;
                                                    availableLabsScreenController.callTestWiseLabApi();
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                                      child: SvgPicture.asset(filterArrowIcon),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),

                          availableLabsScreenController.testWiseLabList.isEmpty ?
                          PaddingHorizontal15(
                            top: 20.h,
                            child: NoDataFoundWidget(title: 'no_lab_found'.tr, description: ''),
                          ) :
                          ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            physics: const BouncingScrollPhysics(),
                            itemCount: availableLabsScreenController.testWiseLabList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                LabModel labModel = availableLabsScreenController.testWiseLabList[index];
                                return CustomContainer(
                                  bottom: 15.h,
                                  radius: 24.r,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: borderColor.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.h, left: 10.w, bottom: 10.h),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                                                  child: CachedNetworkImage(
                                                    imageUrl: AppConstants.IMG_URL + labModel.labProfile!,
                                                    fit: BoxFit.cover,
                                                    alignment: Alignment.topCenter,
                                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                                    errorWidget: (context, url, error) => const ImageErrorWidget(),
                                                    width: 65.w,
                                                    height: 60.h,
                                                  ),
                                                ),
                                                SizedBox(width: 10.w,),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('${labModel.labName}', maxLines: 2, overflow: TextOverflow.ellipsis, style: semiBoldBlack_13,),
                                                      SizedBox(height: 2.h,),
                                                      if(labModel.address != null)
                                                        Text(labModel.address.toString(), style: regularBlack_11),
                                                      // Text(labModel.labDetailModel != null ? '${labModel.labDetailModel!.labDescription}' : '',
                                                      //   maxLines: 2, overflow: TextOverflow.ellipsis, style: regularBlack_11,),
                                                    ],
                                                  ),

                                                ),
                                                SizedBox(width: 10.w,),
                                                Align(
                                                  child: Container(
                                                    padding: const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), bottomLeft: Radius.circular(10.r)),
                                                      border: Border.all(color: borderColor, width: 1.w)
                                                    ),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        color: cardBgColor,
                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.r), bottomLeft: Radius.circular(10.r)),
                                                      ),
                                                      child: Text('${labModel.totalPrice} ₹', style: boldPrimary_12,),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 10.h),
                                            CustomContainer(
                                              onTap: (){
                                                Get.to(()=> ReviewRatingScreen(labId: labModel.labId.toString()));
                                              },
                                              radius: 18.r,
                                              leftPadding: 6.w,
                                              rightPadding: 6.w,
                                              topPadding: 2.h,
                                              bottomPadding: 2.h,
                                              color: cardBgColor,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Center(child: FaIcon(FontAwesomeIcons.solidStar, size: 11.sp, color: primaryColor,)),
                                                  SizedBox(width: 1.w),
                                                  Center(child: Text('${labModel.rating}', style: semiBoldBlack_10)),
                                                  SizedBox(width: 5.w),
                                                  Center(child: Text('${labModel.reviews} User', style: semiBoldBlack_10)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            if(checkLogin()){
                                              getCartApi(labModel: labModel);
                                            } else {
                                              AppConstants().loadWithCanBack(LoginScreen(onLoginSuccess: (){
                                                getCartApi(labModel: labModel);
                                              }));
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 2.w, bottom: 2.h),
                                            padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 6.h),
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(24.r), topLeft: Radius.circular(24.r),
                                                  bottomLeft: Radius.circular(6.r), topRight: Radius.circular(6.r)),
                                            ),
                                            child: Text('book_now'.tr, style: semiBoldWhite_12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                          )
                        ],
                      ),
                    )
                ],
              ),
          ),
      ),
    );
  }

  filterList(String query) {
    query = query.trim().toLowerCase();
    availableLabsScreenController.testWiseLabList.clear();
    if(query.isEmpty) {
      setState(() {
        availableLabsScreenController.testWiseLabList.addAll(availableLabsScreenController.filterList);
      });
    }
    else {
      for(int i=0; i < availableLabsScreenController.filterList.length; i++) {
        if(availableLabsScreenController.filterList[i].labName.toString().toLowerCase().contains(query)) {
          availableLabsScreenController.testWiseLabList.add(availableLabsScreenController.filterList[i]);
        }

      }
    }
    setState(() {});
  }
}
