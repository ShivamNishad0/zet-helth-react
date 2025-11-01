import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Models/UploadedPdfModel.dart';
import 'package:zet_health/Models/UserDetailModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyReportScreenController extends GetxController
    with GetSingleTickerProviderStateMixin {
  RxList<PdfLinkModel> pdfLinkList = <PdfLinkModel>[].obs;
  RxList<UploadedPdfModel> uploadedPdfList = <UploadedPdfModel>[].obs;
  RxInt currentTabIndex = 0.obs;

  late TabController tabController;
  Rx<UserDetailModel> userModel = AppConstants().getUserDetails().obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 1, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

Future<void> callGetReportApi() async {
  print("🟢 callGetReportApi invoked");
  pdfLinkList.value = [];

  final token = AppConstants().getStorage.read(AppConstants.TOKEN);
  final userMobile = AppConstants().getStorage.read(AppConstants.USER_MOBILE)?.toString();
  
  if (userMobile == null) {
    print("❌ User mobile not found in storage");
    Future.microtask(() => 
        AppConstants().showToast('User not found. Please login again.'));
    return;
  }

  final String url = "http://staging.zethealth.com/reports/pdf-links/$userMobile";
  print("🌐 Requesting: $url");

  try {
    final response = await http.get(Uri.parse(url), headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });

    print("📡 Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print("=== Response from fetch reports ===");
      print(data);
      print("=================================");

      // Handle the new response format with IDs
      if (data.containsKey('pdf_links') && data['pdf_links'] is List) {
        List<dynamic> pdfLinksData = data['pdf_links'];
        
        for (var pdfData in pdfLinksData) {
          String pdfUrl = pdfData['medical_pdf_link'];
          String reportId = pdfData['id'].toString();
          
          pdfLinkList.add(PdfLinkModel(
            id: reportId, // Now we have the actual report ID
            url: pdfUrl,
            displayName: 'Report ${pdfLinkList.length + 1}',
            originalFileName: _extractFileNameFromUrl(pdfUrl) ?? 'Report ${pdfLinkList.length + 1}',
          ));
        }
        
        print("✅ Successfully loaded ${pdfLinksData.length} PDF reports with IDs");
      } 
      // Handle alternative response format
      else if (data.containsKey('reports') && data['reports'] is List) {
        List<dynamic> reportsData = data['reports'];
        
        for (var report in reportsData) {
          pdfLinkList.add(PdfLinkModel(
            id: report['report_id'].toString(),
            url: report['pdf_url'],
            displayName: report['display_name'] ?? 'Report ${pdfLinkList.length + 1}',
            originalFileName: _extractFileNameFromUrl(report['pdf_url']) ?? 'Report',
          ));
        }
        
        print("✅ Successfully loaded ${reportsData.length} PDF reports");
      }
      else {
        print("❌ No PDF links found in response");
      }
    } else {
      print("❌ Request failed with status: ${response.statusCode}");
      print("❌ Body: ${response.body}");
    }
  } catch (e, st) {
    print("❌ Exception in callGetReportApi: $e");
    print("❌ Stack trace: $st");
  }
}

  // Helper method to extract file name from URL (kept for reference)
  String? _extractFileNameFromUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      String path = uri.path;
      return path.split('/').last;
    } catch (e) {
      return null;
    }
  }

  void refreshCurrentTab() {
    if (currentTabIndex.value == 0) {
      callGetReportApi();
    }
  }

  Future<void> deleteReport(String reportId) async {
  try {
    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: primaryColor)),
      barrierDismissible: false,
    );

    final token = AppConstants().getStorage.read(AppConstants.TOKEN);
    final userMobile = AppConstants().getStorage.read(AppConstants.USER_MOBILE)?.toString();

    if (userMobile == null) {
      Get.back();
      AppConstants().showToast('User not found. Please login again.');
      return;
    }

    final String deleteUrl = "https://staging.zethealth.com/delete/report";
    
    var response = await http.delete(
      Uri.parse(deleteUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "user_id": userMobile,
        "report_id": reportId,
      }),
    );

    Get.back();

    if (response.statusCode == 200) {
      // Remove from local list
      pdfLinkList.removeWhere((pdf) => pdf.id == reportId);
      update();
      
      AppConstants().showToast('Report deleted successfully');
    } else {
      AppConstants().showToast('Failed to delete report');
    }
  } catch (e) {
    Get.back();
    AppConstants().showToast('Error deleting report: $e');
  }
}

}

class PdfLinkModel {
  final String id;
  final String url;
  final String displayName;
  final String originalFileName;
  
  PdfLinkModel({
    required this.id,
    required this.url,
    required this.displayName,
    required this.originalFileName,
  });

  factory PdfLinkModel.fromJson(Map<String, dynamic> json) {
    return PdfLinkModel(
      id: json['id']?.toString() ?? json['report_id']?.toString() ?? '',
      url: json['medical_pdf_link'] ?? json['pdf_url'] ?? '',
      displayName: json['display_name'] ?? 'Report',
      originalFileName: json['original_file_name'] ?? 'Report',
    );
  }
}