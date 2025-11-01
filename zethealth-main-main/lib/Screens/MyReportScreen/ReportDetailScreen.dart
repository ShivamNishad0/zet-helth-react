import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zet_health/CommonWidget/CustomLoadingIndicator.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/AssetHelper.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Models/ReportModel.dart';
import 'package:zet_health/Screens/MyReportScreen/PdfViewerScreen.dart';

import '../../CommonWidget/CustomAppbar.dart';
import '../../CommonWidget/CustomWidgets.dart';
import '../../Helper/StyleHelper.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen(this.reportModel, {super.key});
  final ReportModel reportModel;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  ReportModel reportModel = ReportModel();
  RxInt selectedIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    reportModel = widget.reportModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        onTap: () => Get.back(),
        title: Text(
            reportModel.folderName != null
                ? reportModel.folderName!.split('/')[1].tr
                : '',
            style: semiBoldBlack_18),
      ),
      body: reportModel.reportList!.isEmpty
          ? NoDataFoundWidget(title: 'no_file_found'.tr, description: '')
          : Container(
              margin: EdgeInsets.only(top: 18.h),
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 15.h),
                  itemCount: reportModel.reportList!.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Reports reports = reportModel.reportList![index];
                    return GestureDetector(
                      onTap: () {
                        String pdfUrl = "${AppConstants.IMG_URL}${reports.folder}/${reports.path}";
                        Get.to(() => PdfViewerScreen(
                          pdfUrl: pdfUrl,
                          title: reports.path ?? 'PDF Document',
                        ));
                        // setState(() {
                        //   selectedIndex.value = index;
                        // });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          // border: Border.all(color: selectedIndex.value == index ? redColor : Colors.transparent)
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.h, horizontal: 10.w),
                                margin: EdgeInsets.only(bottom: 4.h),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: lightOrange),
                                child: Image.asset(
                                  pdfIcon,
                                  height: 35.h,
                                  width: 40.w,
                                )),
                            Expanded(
                                child: Text('${reports.path}',
                                    style: mediumBlack_12,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis))
                          ],
                        ),
                      ),
                    );
                  }),
            ),
      // bottomNavigationBar: reportModel.reportList!=null || reportModel.reportList!.isNotEmpty ? Container(
      //     margin: EdgeInsets.only(left: 33.w, right: 33.w, bottom: 20.h),
      //     padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
      //     decoration: BoxDecoration(
      //         color: whiteColor,
      //         borderRadius: BorderRadius.circular(20.r),
      //         boxShadow: [
      //           BoxShadow(
      //             color: borderColor.withOpacity(0.5),
      //             blurRadius: 10,
      //             spreadRadius: 1,
      //             offset: const Offset(0, 5),
      //           )
      //         ]
      //     ),
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Expanded(
      //           child: GestureDetector(
      //             onTap: () {
      //               AppConstants().downloadAndOpenFile(
      //                 link: "${reportModel.reportList![selectedIndex.value].folder}/${reportModel.reportList![selectedIndex.value].path}",
      //                 type: 0
      //               );
      //             },
      //             child: Column(
      //               mainAxisSize: MainAxisSize.min,
      //               children: [
      //                 SvgPicture.asset(downloadIcon),
      //                 Text('Download', style: mediumBlack_10,)
      //               ],
      //             ),
      //           ),
      //         ),
      //         SizedBox(width: 5.w,),
      //         Expanded(
      //           child: GestureDetector(
      //             onTap: () {
      //               AppConstants().downloadAndOpenFile(
      //                 link: "${reportModel.reportList![selectedIndex.value].folder}/${reportModel.reportList![selectedIndex.value].path}",
      //                 type: 1
      //               );
      //             },
      //             child: Column(
      //               mainAxisSize: MainAxisSize.min,
      //               children: [
      //                 SvgPicture.asset(share2Icon),
      //                 Text('Share', style: mediumBlack_10,)
      //               ],
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ) : null
    );
  }
}
