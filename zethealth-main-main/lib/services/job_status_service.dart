import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zet_health/Network/PdfApiHelper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zet_health/Screens/DrawerView/NavigationDrawerController.dart';

class JobStatusService extends GetxService {
  final PdfApiHelper _apiHelper = PdfApiHelper();
  
  Timer? _pollingTimer;
  final RxString _currentStatus = 'idle'.obs;
  final RxString _statusDescription = ''.obs;
  final RxBool _isProcessing = false.obs;
  final RxString _reportId = ''.obs;
  final RxBool _isNewJob = false.obs;
  
  final List<VoidCallback> _refreshCallbacks = [];

  String get currentStatus => _currentStatus.value;
  String get statusDescription => _statusDescription.value;
  bool get isProcessing => _isProcessing.value;
  String get reportId => _reportId.value;
  bool get isNewJob => _isNewJob.value;

  void addRefreshCallback(VoidCallback callback) {
    if (!_refreshCallbacks.contains(callback)) {
      _refreshCallbacks.add(callback);
    }
  }

  void removeRefreshCallback(VoidCallback callback) {
    _refreshCallbacks.remove(callback);
  }

  void _notifyRefreshCallbacks() {
    for (var callback in _refreshCallbacks) {
      callback();
    }
  }

  void startPolling(String userId, {String? initialJobId, bool isNewUpload = false}) {
    _isProcessing.value = true;
    _currentStatus.value = 'processing';
    _statusDescription.value = 'Uploading and processing your medical report...';
    _isNewJob.value = isNewUpload;
    
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await _checkJobStatus(userId, timer);
    });
    
    // Also check immediately
    if (initialJobId != null) {
      Future.microtask(() {
        if (_pollingTimer != null) {
          _checkJobStatus(userId, _pollingTimer!);
        }
      });
    }
  }

  Future<void> _checkJobStatus(String userId, Timer timer) async {
    try {
      final response = await _apiHelper.getLatestJob(userId);
      
      if (response['success'] == true && response['job_exists'] == true) {
        final job = response['job'];
        final status = job['status'];
        final description = job['status_description'] ?? '';
        _currentStatus.value = status;
        _statusDescription.value = description;
        _reportId.value = job['report_id']?.toString() ?? '';

        switch (status) {
          case 'completed':
            _handleCompletedStatus();
            timer.cancel();
            break;
          case 'failed':
            _handleFailedStatus(description);
            timer.cancel();
            break;
          case 'processing':
            break;
          default:
            break;
        }
      } else {
        _currentStatus.value = 'processing';
        _statusDescription.value = 'Waiting for processing to start...';
      }
    } catch (e) {
      print('Error checking job status: $e');
    }
  }

  void _handleCompletedStatus() {
    _isProcessing.value = false;
    
    _notifyRefreshCallbacks();
    
    if (_isNewJob.value) {
      _showCompletionToast();
    }
    
    _isNewJob.value = false;
  }

  void _handleFailedStatus(String errorDescription) {
    _isProcessing.value = false;
    
    _notifyRefreshCallbacks();
    
    if (_isNewJob.value) {
      _showErrorToast(errorDescription);
    }
    
    _isNewJob.value = false;
  }

void _showCompletionToast() {
  if (Get.isSnackbarOpen) {
    Get.back();
  }
  
  Future.delayed(Duration(milliseconds: 300), () {
    Get.snackbar(
      '',
      '',
      titleText: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16.w,
              height: 16.w,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.green,
                size: 10.sp,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Report Processed Successfully!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Your analyzed medical report is ready to view.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            TextButton(
              onPressed: () {
                if (Get.isSnackbarOpen) {
                  Get.back();
                }
                _navigateToInsights();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
        ),
      ),
      messageText: SizedBox.shrink(),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 70.h),
      padding: EdgeInsets.zero,
      borderRadius: 10.r,
      duration: Duration(seconds: 6),
      backgroundColor: Colors.green.withOpacity(0.95),
      colorText: Colors.white,
      isDismissible: true,
      dismissDirection: DismissDirection.down,
      boxShadows: [
        BoxShadow(
          color: Colors.green.withOpacity(0.3),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  });
}

void _showErrorToast(String errorDescription) {
  Future.delayed(Duration(milliseconds: 300), () {
    Get.snackbar(
      '',
      '',
      titleText: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16.w,
              height: 16.w,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 10.sp,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Processing Failed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    errorDescription.isNotEmpty 
                      ? errorDescription 
                      : 'There was an error processing your report. Please try again.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      messageText: SizedBox.shrink(),
      backgroundColor: Colors.red.withOpacity(0.95),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 70.h),
      padding: EdgeInsets.zero,
      borderRadius: 10.r,
      duration: Duration(seconds: 6),
      boxShadows: [
        BoxShadow(
          color: Colors.red.withOpacity(0.3),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  });
}

  void _navigateToInsights() {
      final NavigationDrawerController navigationDrawerController = 
        Get.find<NavigationDrawerController>();
    navigationDrawerController.pageIndex.value = 2;
    print("Navigation index set to: ${navigationDrawerController.pageIndex.value}");
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isProcessing.value = false;
    _isNewJob.value = false;
  }

  void checkExistingJobsSilently(String userId) {
    if (!_isProcessing.value) {
      // Start polling but mark it as not a new job
      startPolling(userId, isNewUpload: false);
    }
  }

  @override
  void onClose() {
    _refreshCallbacks.clear();
    stopPolling();
    super.onClose();
  }
}