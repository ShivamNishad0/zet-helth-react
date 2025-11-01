import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/PrescriptionModel.dart';
import '../../../CommonWidget/CustomAppbar.dart';
import '../../../CommonWidget/commonApis.dart';
import '../../../Helper/AssetHelper.dart';
import '../../../Helper/ColorHelper.dart';
import '../../../Helper/StyleHelper.dart';
import '../../../Helper/database_helper.dart';
import '../../AuthScreen/LoginScreen.dart';
import 'PrescriptionScreenController.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  PrescriptionScreenController prescriptionScreenController = Get.put(PrescriptionScreenController());
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    prescriptionScreenController.callGetPrescriptionApi(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        leading: Image.asset(backArrow),
        title: Text('view_prescriptions'.tr,style: semiBoldBlack_18),
      ),
      body: Obx( () => prescriptionScreenController.isLoading.value ?
          Container() :
          prescriptionScreenController.prescriptionList.isEmpty ?
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imgPrescription,height: 150.h),
                SizedBox(height: 5.h,),
                Text('no_prescription_found'.tr,style: semiBoldBlack_16,),
                Text('upload_prescription_description'.tr,style: semiBoldBlack_16,textAlign: TextAlign.center,),
              ],
            ),
          ) :
          ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 15.w,vertical: 15.h),
            physics: const BouncingScrollPhysics(),
            itemCount: prescriptionScreenController.prescriptionList.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              PrescriptionModel prescriptionModel = prescriptionScreenController.prescriptionList[index];
              return GestureDetector(
                onTap: () async {
                  if(prescriptionModel.labModel!= null){
                    if(checkLogin()){
                      getCartApi(labModel: prescriptionModel.labModel!);
                    }
                    else {
                      AppConstants().loadWithCanBack(LoginScreen(onLoginSuccess: (){
                        getCartApi(labModel: prescriptionModel.labModel!);
                      }));
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10.sp),
                  margin: EdgeInsets.only(bottom: 15.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: borderColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        child: CachedNetworkImage(
                          height: 55.w,
                          width: 55.w,
                          fit: BoxFit.cover,
                          imageUrl: AppConstants.IMG_URL + prescriptionModel.document.toString(),
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const ImageErrorWidget(),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(prescriptionModel.type.toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: boldBlack_12),
                            SizedBox(height: 5.h),
                            Text(formatDateString('dd-MM-yyyy hh:mm a', 'yyyy-MM-dd HH:mm:ss','${prescriptionModel.createdDate}'), style: semiBoldGray_10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      )
    );
  }

  // filterList(String query) {
  //   query = query.trim().toLowerCase();
  //   prescriptionScreenController.prescriptionList.clear();
  //   if(query.isEmpty) {
  //     setState(() {
  //       prescriptionScreenController.prescriptionList.addAll(prescriptionScreenController.filterList);
  //     });
  //   }
  //   else {
  //     for(int i=0; i < prescriptionScreenController.filterList.length; i++) {
  //       if(prescriptionScreenController.filterList[i]..toString().toLowerCase().contains(query)) {
  //         prescriptionScreenController.prescriptionList.add(prescriptionScreenController.filterList[i]);
  //       }
  //
  //     }
  //   }
  //   setState(() {
  //
  //   });
  // }

}
