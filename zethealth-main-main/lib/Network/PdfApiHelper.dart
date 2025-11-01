import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';

import '../CommonWidget/CustomWidgets.dart';
import '../Helper/AppConstants.dart';
import '../Screens/SplashScreen.dart';

class PdfApiHelper {
  var loadingMessage = "Please Wait...";
  var networkErrorMessage = "";
  var networkError;
  bool isNetworkError = false;
  String serverTakingLong = 'Time out';
  String internetConnectionProblem = 'Internet connection problem';
  String somethingWentWrong = 'Something went wrong';

  static const String PDF_UPLOAD_URL = "https://staging.zethealth.com/categorize_v2";

  static const String PDF_REPORTS_URL = "https://staging.zethealth.com/reports";

  static const String JOB_STATUS_URL = "https://staging.zethealth.com/jobs/latest";

  static dynamic getHeaders() async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':
          AppConstants().getStorage.read(AppConstants.TOKEN) == null
              ? ''
              : "Bearer ${AppConstants().getStorage.read(AppConstants.TOKEN)}",
    };
    return headers;
  }

  // Upload PDF in background with response data
  Future<dynamic> uploadPdfInBackgroundWithData(
      String filePath, String userId, Function(bool success, String? message, Map<String, dynamic>? responseData) onComplete) async {
    try {
      var formData = FormData.fromMap({
        'user_id': userId,
        'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      });

      Map<String, String> headers = await getHeaders();
      headers['content-type'] = "multipart/form-data";

      var dio = Dio();
      dio.options.headers.addAll(headers);

      final response = await dio.post(
        PDF_UPLOAD_URL,
        data: formData,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data',
          followRedirects: false,
          validateStatus: (status) {
            return true;
          }
        )
      );

      if (response.statusCode == 202 || response.statusCode == 200) {
        Map<String, dynamic>? responseData;
        try {
          responseData = response.data is Map<String, dynamic> 
              ? response.data 
              : jsonDecode(response.data.toString());
        } catch (e) {
          print("Error parsing response data: $e");
        }
        onComplete(true, "PDF uploaded successfully", responseData);
        return jsonEncode(response.data);
      } else if (response.statusCode == 500) {
        onComplete(false, "500 : Internal Server Error", null);
      } else if (response.statusCode == 404) {
        onComplete(false, "404 : Not Found", null);
      } else if (response.statusCode == 401) {
        onComplete(false, "Unauthorized", null);
        GetStorage().write(AppConstants.USER_MOBILE, null);
        AppConstants().loadWithCanNotAllBack(const SplashScreen());
      } else if (response.statusCode == 400) {
        onComplete(false, "400 : Bad Request", null);
      } else {
        onComplete(false, "Something Went Wrong", null);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        isNetworkError = true;
        networkErrorMessage = serverTakingLong;
      } else if (e.type == DioExceptionType.connectionError ||
          e.message!.contains('SocketException')) {
        isNetworkError = true;
        networkErrorMessage = internetConnectionProblem;
      } else {
        isNetworkError = true;
        networkErrorMessage = somethingWentWrong;
      }
      onComplete(false, networkErrorMessage, null);
    } on TimeoutException catch (e) {
      onComplete(false, "Upload timeout", null);
      isNetworkError = true;
      networkError = e;
    } on SocketException catch (e) {
      onComplete(false, "Network connection error", null);
      isNetworkError = true;
      networkError = e;
    } on Error catch (e) {
      onComplete(false, "Something went wrong during upload", null);
      isNetworkError = true;
      networkError = e;
    }
    return null;
  }

  // Upload PDF in background (backward compatibility)
  Future<dynamic> uploadPdfInBackground(
      String filePath, String userId, Function(bool success, String? message) onComplete) async {
    return uploadPdfInBackgroundWithData(filePath, userId, (success, message, responseData) {
      onComplete(success, message);
    });
  }

  // Get uploaded PDFs for user
  Future<dynamic> getUserUploadedPdfs(String userId, bool isShowLoader) async {
    try {
      if (isShowLoader) {
        await EasyLoading.show(
            status: 'Loading reports...', maskType: EasyLoadingMaskType.black);
      }

      Map<String, String> headers = await getHeaders();
      headers['content-type'] = "application/json";
      headers['accept'] = "application/json";

      var dio = Dio();
      dio.options.headers.addAll(headers);

      final response = await dio.get(
        "$PDF_REPORTS_URL/$userId",
        options: Options(headers: headers)
      );

      debugPrint("$response");

      if (isShowLoader) {
        await EasyLoading.dismiss();
      }

      if (response.statusCode == 200 || response.statusCode == 202) {
        // Handle the new JSON structure
        var responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['result'] != null) {
          return responseData['result'];
        }
        return responseData;
      } else if (response.statusCode == 400) {
        AppConstants().showToast("400 : Bad Request");
      } else if (response.statusCode == 401) {
        AppConstants().showToast("Unauthorized");
        GetStorage().write(AppConstants.USER_MOBILE, null);
        AppConstants().loadWithCanNotAllBack(const SplashScreen());
      } else if (response.statusCode == 404) {
        AppConstants().showToast("404 : Not Found");
      } else if (response.statusCode == 500) {
        AppConstants().showToast("500 : Internal Server Error");
      } else {
        AppConstants().showToast("Something Went Wrong");
      }
    } on DioException catch (e) {

       print("DioException: ${e.type}, ${e.message}, ${e.error}");

      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        isNetworkError = true;
        networkErrorMessage = serverTakingLong;
      } else if (e.type == DioExceptionType.connectionError ||
          e.message!.contains('SocketException')) {
        isNetworkError = true;
        networkErrorMessage = internetConnectionProblem;
      } else {
        isNetworkError = true;
        networkErrorMessage = somethingWentWrong;
      }
    } on TimeoutException {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      isNetworkError = true;
      networkErrorMessage = serverTakingLong;
    } on SocketException {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      isNetworkError = true;
      networkErrorMessage = internetConnectionProblem;
    } on Error {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      isNetworkError = true;
      networkErrorMessage = somethingWentWrong;
    }

    if (isNetworkError) {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      showToast(message: networkErrorMessage);
    }
    return null;
  }

 Future<Map<String, dynamic>> getLatestJob(String userId) async {
    try {
      Map<String, String> headers = await getHeaders();
      headers['content-type'] = "application/json";
      headers['accept'] = "application/json";

      var dio = Dio();
      dio.options.headers.addAll(headers);

      final response = await dio.get(
        "$JOB_STATUS_URL?user_id=$userId",
        options: Options(headers: headers)
      );

      debugPrint("Job Status Response: $response");

      if (response.statusCode == 200 || response.statusCode == 202) {
        Map<String, dynamic> responseData;
        if (response.data is Map<String, dynamic>) {
          responseData = response.data;
        } else {
          responseData = jsonDecode(response.data.toString());
        }
        return responseData;
      } else if (response.statusCode == 401) {
        AppConstants().showToast("Unauthorized");
        GetStorage().write(AppConstants.USER_MOBILE, null);
        AppConstants().loadWithCanNotAllBack(const SplashScreen());
        throw Exception("Unauthorized");
      } else if (response.statusCode == 404) {
        return {'success': false, 'job_exists': false, 'message': 'Job not found'};
      } else {
        throw Exception('Failed to fetch job status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint("DioException in getLatestJob: ${e.type}, ${e.message}, ${e.error}");
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError ||
          e.message!.contains('SocketException')) {
        throw Exception('Internet connection problem');
      } else {
        throw Exception('Something went wrong while fetching job status');
      }
    } on TimeoutException {
      throw Exception('Request timeout');
    } on SocketException {
      throw Exception('Network connection error');
    } catch (e) {
      throw Exception('Error fetching job status: $e');
    }
  }

}