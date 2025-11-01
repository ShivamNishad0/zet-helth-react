import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

import '../CommonWidget/CustomWidgets.dart';
import '../Helper/AppConstants.dart';
import '../Screens/SplashScreen.dart';
import 'FormDataApiHelper.dart';

class WebApiHelper extends FormDataApiHelper {
  @override
  var networkError;
  @override
  bool isNetworkError = false;

  Future<dynamic> callPostApi(BuildContext context, String url,
      Map<String, dynamic>? params, bool isShowLoader) async {
    try {
      if (isShowLoader) {
        await EasyLoading.show(
            status: 'Please Wait...', maskType: EasyLoadingMaskType.black);
      }

      Map<String, String> headers = await FormDataApiHelper.getHeaders();
      headers['content-type'] = "application/json";
      headers['accept'] = "application/json";
      headers['authorization'] =
          "Bearer ${AppConstants().getStorage.read(AppConstants.TOKEN) ?? ''}";

      var response = await http.post(Uri.parse(AppConstants.BASE_URL + url),
          body: json.encode(params),
          headers: headers,
          encoding: Encoding.getByName("utf-8"));

      if (isShowLoader) {
        await EasyLoading.dismiss();
      }

      if (response.statusCode == 200) {
        return jsonEncode(response.body);
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
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        isNetworkError = true;
        networkErrorMessage = serverTakingLong;
      } else if (e.type == DioExceptionType.connectionError &&
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

  Future<dynamic> callGetApi(
      BuildContext? context, String url, bool isShowLoader) async {
    try {
      if (isShowLoader) {
        await EasyLoading.show(
            status: 'Please Wait...', maskType: EasyLoadingMaskType.black);
      }

      Map<String, String> headers = await FormDataApiHelper.getHeaders();
      headers['content-type'] = "application/json";
      headers['accept'] = "application/json";
      headers['authorization'] =
          "Bearer ${AppConstants().getStorage.read(AppConstants.TOKEN) ?? ''}";

      var response = await http.get(Uri.parse(AppConstants.BASE_URL + url),
          headers: headers);

      if (isShowLoader) {
        await EasyLoading.dismiss();
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
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
      if (isShowLoader) {
        await EasyLoading.dismiss();
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        isNetworkError = true;
        networkErrorMessage = serverTakingLong;
      } else if (e.type == DioExceptionType.connectionError &&
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
}
