import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import 'package:zet_health/Screens/DrawerView/NavigationDrawerController.dart';
import 'package:zet_health/services/job_status_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Network/PdfApiHelper.dart';

class NoInsightsWidget extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoInsightsWidget({super.key, this.onRefresh});

  void _showPdfUploadDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.file_present_outlined,
                color: primaryColor,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Upload Medical Report',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please upload your medical report in PDF format for AI analysis.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Supported format: PDF only\nMax file size: 10MB',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              _pickPdfFile();
            },
            icon: Icon(
              Icons.upload,
              size: 14,
              color: Colors.white,
            ),
            label: Text(
              'Choose PDF',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        
        // Get user mobile number (user ID)
        String? userMobile = AppConstants()
            .getStorage
            .read(AppConstants.USER_MOBILE)
            ?.toString();
        if (userMobile == null) {
          AppConstants().showToast('User not found. Please login again.');
          return;
        }

        // Upload PDF in background
        PdfApiHelper pdfApiHelper = PdfApiHelper();
        await pdfApiHelper.uploadPdfInBackground(filePath, userMobile,
            (success, message) async {
          if (success) {
            // Start polling for job status
            final JobStatusService jobStatusService = Get.find<JobStatusService>();
            jobStatusService.startPolling(userMobile, isNewUpload: true);
            
            // Call refresh callback if provided
            if (onRefresh != null) {
              // Wait a bit before refreshing to allow backend processing
              Future.delayed(Duration(seconds: 2), onRefresh);
            }
          } else {
            AppConstants().showToast(message ?? 'Upload failed');
          }
        });
      }
    } catch (e) {
      AppConstants().showToast('Error picking file: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/no-insights.svg',
              width: 350,
              height: 350,
            ),
            const SizedBox(height: 20),
            const Column(
              children: [
                Text(
                  "No Insights Found",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Kindly upload your medical report to get your Insights",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _showPdfUploadDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Upload Medical Report",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}