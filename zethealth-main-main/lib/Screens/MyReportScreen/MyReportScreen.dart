import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/ReportModel.dart';
import 'package:zet_health/Models/UploadedPdfModel.dart';
import 'package:zet_health/Screens/MyReportScreen/MyReportScreenController.dart';
import 'package:zet_health/Screens/MyReportScreen/PdfViewerScreen.dart';
import 'package:zet_health/Screens/MyReportScreen/ReportDetailScreen.dart';
import 'package:zet_health/Screens/ChatScreen/ChatSessionsScreen.dart';

import '../../CommonWidget/CustomAppbar.dart';
import '../../CommonWidget/CustomLoadingIndicator.dart';
import '../../CommonWidget/CustomWidgets.dart';
import '../../Helper/AssetHelper.dart';
import '../../Helper/ColorHelper.dart';
import '../../Helper/StyleHelper.dart';
import '../../main.dart';
import '../DrawerView/NavigationDrawerController.dart';

class MyReportScreen extends StatefulWidget {
  const MyReportScreen({super.key});

  @override
  State<MyReportScreen> createState() => _MyReportScreenState();
}

class _MyReportScreenState extends State<MyReportScreen> {
  MyReportScreenController myReportScreenController =
      Get.put(MyReportScreenController());
  NavigationDrawerController navigationDrawerController =
      Get.find<NavigationDrawerController>();
  Function? userModelListen;

  // String? userName = AppConstants().getStorage.read(AppConstants.USER_NAME);

  @override
  void initState() {
    super.initState();
    if (navigationDrawerController.isLogin.value) {
      print("🔑 isLogin: ${navigationDrawerController.isLogin.value}");
      myReportScreenController.callGetReportApi();
      // myReportScreenController.callGetUploadedPdfsApi();

      userModelListen = AppConstants()
          .getStorage
          .listenKey(AppConstants.USER_DETAIL, (value) {
        setState(() {
          myReportScreenController.userModel.value =
              AppConstants().getUserDetails();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: false,
        title: Text('Reports', style: semiBoldBlack_18),
        leading: CustomSquareButton(
          backgroundColor: whiteColor,
          leftMargin: 15.w,
          icon: drawerIcon,
          shadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 5),
            )
          ],
          onTap: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [NotificationButtonCommon(), CartButtonCommon()],
      ),
      body: Obx(
        () => navigationDrawerController.isLogin.value
            ? Column(
                children: [
                  // Tab Bar
                  Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                    child: Material(
                      color: Colors.transparent,
                      child: TabBar(
                        controller: myReportScreenController.tabController,
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 3.h,
                          ),
                          insets: EdgeInsets.symmetric(horizontal: 0.w),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: primaryColor,
                        unselectedLabelColor: Colors.grey[600],
                        labelStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                        dividerColor: Colors.grey[300],
                        dividerHeight: 1.h,
                        tabs: [
                          Tab(
                            height: 50.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.fileLines, size: 16.sp),
                                SizedBox(width: 8.w),
                                Text('Lab Reports'),
                              ],
                            ),
                          ),
                          // Tab(
                          //   height: 50.h,
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.center,
                          //     children: [
                          //       FaIcon(FontAwesomeIcons.filePdf, size: 16.sp),
                          //       SizedBox(width: 8.w),
                          //       Text('Uploaded PDFs'),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  // Tab Bar View
                  Expanded(
                    child: TabBarView(
                      controller: myReportScreenController.tabController,
                      children: [
                        // Lab Reports Tab
                        _buildLabReportsTab(),
                        // Uploaded PDFs Tab
                        // _buildUploadedPdfsTab(),
                      ],
                    ),
                  ),
                ],
              )
            : NoLoginWidget(onLoginSuccess: () {
                setState(() {
                  myReportScreenController.callGetReportApi();
                  // myReportScreenController.callGetUploadedPdfsApi();
                });
              }),
      ),
    );
  }

Widget _buildLabReportsTab() {
  return Obx(() => myReportScreenController.pdfLinkList.isEmpty
      ? Center(
          child: NoDataFoundWidget(
            title: 'no_report_found'.tr,
            description: '',
          ),
        )
      : RefreshIndicator(
          backgroundColor: whiteColor,
          color: primaryColor,
          onRefresh: () async {
            myReportScreenController.callGetReportApi();
          },
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            itemCount: myReportScreenController.pdfLinkList.length,
            itemBuilder: (context, index) {
              PdfLinkModel pdfLink =
                  myReportScreenController.pdfLinkList[index];
              return Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: borderColor2),
                ),
                child: Row(
                  children: [
                    // PDF Icon
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: pendingColor,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        size: 24.h,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    
                    // PDF Info
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _openPdfUrl(pdfLink.url, index);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pdfLink.displayName,
                              style: mediumBlack_16,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'PDF Report',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Action Buttons
                    Row(
                      children: [
                        // View Button
                        IconButton(
                          onPressed: () {
                            _openPdfUrl(pdfLink.url, index);
                          },
                          icon: Icon(
                            Icons.visibility,
                            size: 20.sp,
                            color: primaryColor,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        SizedBox(width: 8.w),
                        
                        // Delete Button
                        IconButton(
                          onPressed: () {
                            _showDeleteConfirmation(pdfLink);
                          },
                          icon: Icon(
                            Icons.delete,
                            size: 20.sp,
                            color: Colors.red,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ));
}


void _showDeleteConfirmation(PdfLinkModel pdfLink) {
  Get.dialog(
    AlertDialog(
      title: Text(
        'Delete Report',
        style: semiBoldBlack_18,
      ),
      content: Text(
        'Are you sure you want to delete "${pdfLink.displayName}"?',
        style: regularBlack_14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close dialog
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14.sp,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Get.back(); // Close dialog
            myReportScreenController.deleteReport(pdfLink.id);
          },
          child: Text(
            'Delete',
            style: TextStyle(
              color: Colors.red,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

void _openPdfUrl(String url, int index) {
  // Calculate the display number based on total count and index
  int displayNumber = myReportScreenController.pdfLinkList.length - index;
  String displayTitle = 'Report $displayNumber';

  Get.to(
    () => PdfViewerScreen(
      pdfUrl: url,
      title: displayTitle,
    ),
    transition: Transition.cupertino,
  );
}

  void _startChatWithPdf(UploadedPdfModel pdfModel) {
    // Navigate to ChatSessionsScreen with slide transition
    AppConstants().loadWithCanBack(
      ChatSessionsScreen(pdfModel: pdfModel),
      transition: Transition.rightToLeft,
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
