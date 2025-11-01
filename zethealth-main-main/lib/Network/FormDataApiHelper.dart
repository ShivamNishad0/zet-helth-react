import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';

import '../CommonWidget/CustomWidgets.dart';
import '../Helper/AppConstants.dart';
import '../Screens/SplashScreen.dart';
import 'package:dio/dio.dart';

class FormDataApiHelper {
  var loadingMessage = "Please Wait...";
  var networkErrorMessage = "";
  var networkError;
  bool isNetworkError = false;
  String serverTakingLong = 'Time out';
  String internetConnectionProblem = 'Internet connection problem';
  String somethingWentWrong = 'Something wnt wrong';

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

  Future<dynamic> callFormDataPostApi(
      BuildContext? context, var url, var formData, bool isShowLoader,
      {String? file, String? imageKey}) async {
    try {
      FormData apiData = FormData.fromMap(formData);

      if (isShowLoader) {
        await EasyLoading.show(
            status: 'Please Wait...', maskType: EasyLoadingMaskType.black);
      }

      Map<String, String> headers = await getHeaders();
      headers['content-type'] = "application/json";
      headers['accept'] = "application/json";
      headers['authorization'] =
          AppConstants().getStorage.read(AppConstants.TOKEN) == null
              ? ''
              : "Bearer ${AppConstants().getStorage.read(AppConstants.TOKEN)}";

      var dio = Dio();
      dio.options.headers.addAll(headers);

      if (file != null && file.isNotEmpty) {
        apiData.files.add(MapEntry(
          imageKey!,
          await MultipartFile.fromFile(file, filename: file.split('/').last),
        ));
      }

      final response = await Dio().post(AppConstants.BASE_URL + url,
          data: apiData,
          options: Options(
              headers: headers,
              contentType: 'multipart/form-data',
              followRedirects: false,
              validateStatus: (status) {
                return true;
              }));

      if (isShowLoader) {
        await EasyLoading.dismiss();
      }

      if (response.statusCode == 200) {
        return jsonEncode(response.data);
      } else if (response.statusCode == 500) {
        AppConstants().showToast("500 : Internal Server Error");
      } else if (response.statusCode == 404) {
        AppConstants().showToast("404 : Not Found");
      } else if (response.statusCode == 401) {
        GetStorage().write(AppConstants.USER_MOBILE, null);
        AppConstants().loadWithCanNotAllBack(const SplashScreen());
        AppConstants().showToast("Unauthorized");
      } else if (response.statusCode == 400) {
        AppConstants().showToast("400 : Bad Request");
      } else {
        AppConstants().showToast("Something Went Wrong");
      }
    } on DioException catch (e) {
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
    } on TimeoutException catch (e) {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      showToast(message: "Something Went Wrong");
      isNetworkError = true;
      networkError = e;
    } on SocketException catch (e) {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      showToast(message: "Something Went Wrong");
      isNetworkError = true;
      networkError = e;
    } on Error catch (e) {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      showToast(message: "Something Went Wrong");
      isNetworkError = true;
      networkError = e;
    }
    if (isNetworkError) {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      showToast(message: networkErrorMessage);
    }
    return null;
  }

  Future<dynamic> callNewNodeApi(BuildContext? context, String url, Map<String, dynamic> params,  bool isShowLoader) async {
    try {
      if (isShowLoader) {
        await EasyLoading.show(
            status: 'Please Wait...', maskType: EasyLoadingMaskType.black);
      }

      var dio = Dio();
      dio.options.headers['accept'] = "application/json";

      final response = await dio.get(
        'http://15.207.229.70/api/$url',
        queryParameters: params,
        options: Options(
          followRedirects: false,
          validateStatus: (status) => true,
        ),
      );

      if (isShowLoader) {
        await EasyLoading.dismiss();
      }

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 500) {
        AppConstants().showToast("500 : Internal Server Error");
      } else if (response.statusCode == 404) {
        AppConstants().showToast("404 : Not Found");
      } else if (response.statusCode == 401) {
        GetStorage().write(AppConstants.USER_MOBILE, null);
        AppConstants().loadWithCanNotAllBack(const SplashScreen());
        AppConstants().showToast("Unauthorized");
      } else if (response.statusCode == 400) {
        // Check for specific error message in the response
        if (response.data != null && response.data is Map) {
          dynamic errorData = response.data;

          if (errorData['error'] != null &&
              errorData['error'] == "Pincode is not serviceable") {
            return {'error': 'PINCODE_NOT_SERVICEABLE', 'message': 'Pincode not serviceable'};
          } else if (errorData['message'] != null &&
              errorData['message'].toString().contains("not serviceable")) {
             return {'error': 'PINCODE_NOT_SERVICEABLE', 'message': 'Pincode not serviceable'};
          } else {
            String errorMessage = errorData['error']?.toString() ??
                errorData['message']?.toString() ??
                "Bad Request";
            AppConstants().showToast("400 : $errorMessage");
          }
        } else {
          AppConstants().showToast("400 : Bad Request");
        }
      } else {
        AppConstants().showToast("Something Went Wrong");
      }
    } on DioException catch (e) {
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
    } on TimeoutException catch (e) {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      showToast(message: "Something Went Wrong");
      isNetworkError = true;
      networkError = e;
    } on SocketException catch (e) {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      showToast(message: "Something Went Wrong");
      isNetworkError = true;
      networkError = e;
    } on Error catch (e) {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      showToast(message: "Something Went Wrong");
      isNetworkError = true;
      networkError = e;
    }
    if (isNetworkError) {
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      showToast(message: networkErrorMessage);
    }
    return null;
  }
}
