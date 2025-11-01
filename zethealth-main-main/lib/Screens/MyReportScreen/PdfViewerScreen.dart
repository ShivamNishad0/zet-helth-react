import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:zet_health/CommonWidget/CustomLoadingIndicator.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Helper/StyleHelper.dart';
import '../../CommonWidget/CustomAppbar.dart';
import '../../CommonWidget/CustomWidgets.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    Key? key,
    required this.pdfUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  PDFViewController? controller;

  @override
  void initState() {
    super.initState();
    downloadAndOpenPdf();
  }

  Future<void> downloadAndOpenPdf() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final fileName = widget.pdfUrl.split('/').last;
      final filePath = '${dir.path}/$fileName';

      // Download the PDF file
      await dio.download(widget.pdfUrl, filePath);

      setState(() {
        localPath = filePath;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to load PDF: ${e.toString()}';
      });
    }
  }

  Future<void> sharePdf() async {
    if (localPath != null) {
      try {
        await Share.shareXFiles([XFile(localPath!)], text: 'Sharing PDF: ${widget.title}');
      } catch (e) {
        showToast(message: 'Failed to share PDF: ${e.toString()}', seconds: 2);
      }
    }
  }

  Future<void> downloadPdfToDevice() async {
    if (localPath == null) return;

    try {
      // Check and request storage permission
      bool hasPermission = await _checkStoragePermission();
      if (!hasPermission) {
        showToast(message: 'Storage permission is required to download files', seconds: 3);
        return;
      }

      EasyLoading.show(status: 'Downloading...');
      
      final fileName = widget.pdfUrl.split('/').last;
      String downloadPath;
      
      if (Platform.isAndroid) {
        // For Android, use Downloads directory
        Directory? downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
        downloadPath = '${downloadsDir!.path}/$fileName';
      } else {
        // For iOS, use Documents directory (Downloads folder is not accessible)
        final dir = await getApplicationDocumentsDirectory();
        downloadPath = '${dir.path}/$fileName';
      }
      
      // Copy file to download location
      await File(localPath!).copy(downloadPath);
      
      EasyLoading.dismiss();
      showToast(message: 'PDF downloaded successfully to ${Platform.isAndroid ? 'Downloads' : 'Documents'} folder', seconds: 3);
    } catch (e) {
      EasyLoading.dismiss();
      showToast(message: 'Failed to download PDF: ${e.toString()}', seconds: 2);
    }
  }

  Future<bool> _checkStoragePermission() async {
    if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission for app documents
      return true;
    }

    // For Android
    if (Platform.isAndroid) {
      // Check Android version
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+ doesn't need WRITE_EXTERNAL_STORAGE for Downloads
        return true;
      } else {
        // Android 12 and below
        var status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        }

        if (status.isDenied) {
          status = await Permission.storage.request();
          return status.isGranted;
        }

        if (status.isPermanentlyDenied) {
          // Show dialog to open app settings
          _showPermissionDialog();
          return false;
        }
      }
    }

    return false;
  }

  void _showPermissionDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Storage Permission Required'),
        content: Text('Please grant storage permission from app settings to download files.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        centerTitle: true,
        isLeading: true,
        onTap: () => Get.back(),
        title: Text(
          widget.title,
          style: semiBoldBlack_18,
        ),
        actions: [
          if (!isLoading && !hasError && localPath != null) ...[
            IconButton(
              icon: Icon(Icons.download, color: blackColor),
              onPressed: downloadPdfToDevice,
              tooltip: 'Download PDF',
            ),
            IconButton(
              icon: Icon(Icons.share, color: blackColor),
              onPressed: sharePdf,
              tooltip: 'Share PDF',
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CustomLoadingIndicator(),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: redColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading PDF',
              style: semiBoldBlack_16,
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                errorMessage,
                style: regularBlack_14,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: downloadAndOpenPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                'Retry',
                style: semiBoldWhite_14,
              ),
            ),
          ],
        ),
      );
    }

    if (localPath == null) {
      return Center(
        child: Text(
          'PDF file not found',
          style: regularBlack_14,
        ),
      );
    }

    return Column(
      children: [
        // PDF Page indicator
        if (pages != null && pages! > 0)
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            color: greyColor,
            child: Center(
              child: Text(
                'Page ${(currentPage ?? 0) + 1} of $pages',
                style: regularBlack_12,
              ),
            ),
          ),
        // PDF Viewer
        Expanded(
          child: PDFView(
            filePath: localPath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage!,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                this.pages = pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                hasError = true;
                errorMessage = error.toString();
              });
            },
            onPageError: (page, error) {
              setState(() {
                hasError = true;
                errorMessage = 'Page $page: ${error.toString()}';
              });
            },
            onViewCreated: (PDFViewController pdfViewController) {
              controller = pdfViewController;
            },
            onLinkHandler: (String? uri) {
              // Handle link clicks if needed
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                currentPage = page;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Clean up the downloaded file
    if (localPath != null) {
      try {
        File(localPath!).deleteSync();
      } catch (e) {
        // Ignore cleanup errors
      }
    }
    super.dispose();
  }
}