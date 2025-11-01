import 'package:zet_health/Models/BookingModel.dart';
import 'package:zet_health/Models/BranchListModel.dart';
import 'package:zet_health/Models/ProfileModel.dart';


import 'AddressListModel.dart';
import 'CartModel.dart';
import 'CmsModel.dart';
import 'PrescriptionModel.dart';
import 'LabModel.dart';
import 'NotificationModel.dart';
import 'OfferModel.dart';
import 'ReportModel.dart';
import 'SlotModel.dart';
import 'TestModel.dart';
import 'PackageModel.dart';
import 'SliderModel.dart';
import 'CityModel.dart';
import 'UserDetailModel.dart';

class StatusModel {
  bool? status;
  String? message;
  int? unreadNotification;
  String? userAndroidAppVersion;
  String? userAndroidUpdateMessage;
  String? userIosAppVersion;
  String? userIsoUpdateMessage;
  UserDetailModel? userDetail;
  List<SliderModel>? sliderList;
  List<PackageModel>? popularPackageList;
  List<PackageModel>? lifestylePackageList;
  List<ProfileModel>? popularProfilesList;
  List<BranchListModel>? branchList;
  List<TestModel>? testList;
  List<CartModel>? cartList;
  List<CityModel>? cityList;
  bool? isLogin;
  int? wallet;
  String? appVersion;
  int? isForceUpdate;
  String? updateMessage;
  String? token;
  String? lastOtp;
  String? supportMobile;
  String? supportEmail;
  String? serviceCharge;
  String? serviceChargeDisplay;
  List<AddressList>? addressList;
  List<PackageModel>? packageList;
  List<TestModel>? labTestList;
  List<LabModel>? labList;
  List<UserDetailModel>? patientList;
  List<UserDetailModel>? customerList;
  List<ProfileModel>? profileList;
  SlotModel? slotModel;
  List<BookingModel>? bookingList;
  List<TestModel>? labWiseTestList;
  List<OfferModel>? offerList;
  List<ReportModel>? reportList;
  CmsModel? result;
  List<NotificationModel>? notificationList;
  List<PrescriptionModel>? prescriptionList;

  StatusModel(
    this.status,
    this.message,
    this.userAndroidAppVersion,
    this.userAndroidUpdateMessage,
    this.userIosAppVersion,
    this.userIsoUpdateMessage,
    this.userDetail,
    this.sliderList,
    this.popularPackageList,
    this.lifestylePackageList,
    this.popularProfilesList,
    this.testList,
    this.cartList,
    this.cityList,
    this.isLogin,
    this.wallet,
    this.appVersion,
    this.isForceUpdate,
    this.updateMessage,
    this.packageList,
    this.labList,
    this.token,
    this.lastOtp,
    this.labTestList,
    this.patientList,
    this.customerList,
    this.slotModel,
    this.profileList,
    this.bookingList,
    this.supportMobile,
    this.labWiseTestList,
    this.offerList,
    this.reportList,
    this.result,
    this.notificationList,
    this.prescriptionList,
    this.addressList,
    this.serviceCharge,
    this.serviceChargeDisplay,
    this.unreadNotification,
  );

  StatusModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    unreadNotification = json['unread_notification'];
    userAndroidAppVersion = json['user_android_app_version'];
    userAndroidUpdateMessage = json['user_android_update_message'];
    userIosAppVersion = json['user_ios_app_version'];
    userIsoUpdateMessage = json['user_iso_update_message'];
    userDetail = json['user_detail'] != null
        ? UserDetailModel.fromJson(json['user_detail'])
        : null;
    supportEmail = json['support_email'];
    if (json['city'] != null) {
      cityList = <CityModel>[];
      json['city'].forEach((v) {
        cityList!.add(CityModel.fromJson(v));
      });
    }
    if (json['slider'] != null) {
      sliderList = <SliderModel>[];
      json['slider'].forEach((v) {
        sliderList!.add(SliderModel.fromJson(v));
      });
    }
    if (json['popular_package'] != null) {
      popularPackageList = <PackageModel>[];
      json['popular_package'].forEach((v) {
        popularPackageList!.add(PackageModel.fromJson(v));
      });
    }
    if (json['lifestyle_package'] != null) {
      lifestylePackageList = <PackageModel>[];
      json['lifestyle_package'].forEach((v) {
        lifestylePackageList!.add(PackageModel.fromJson(v));
      });
    }
    if (json['profiles'] != null) {
      popularProfilesList = <ProfileModel>[];
      json['profiles'].forEach((v) {
        popularProfilesList!.add(ProfileModel.fromJson(v));
      });
    }
    if (json['tests'] != null) {
      testList = <TestModel>[];
      json['tests'].forEach((v) {
        testList!.add(TestModel.fromJson(v));
      });
    }
    if (json['cart_list'] != null) {
      cartList = <CartModel>[];
      json['cart_list'].forEach((v) {
        cartList!.add(CartModel.fromJson(v));
      });
    }
    if (json['package_list'] != null) {
      packageList = <PackageModel>[];
      json['package_list'].forEach((v) {
        packageList!.add(PackageModel.fromJson(v));
      });
    }
    if (json['lab_test_list'] != null) {
      labTestList = <TestModel>[];
      json['lab_test_list'].forEach((v) {
        labTestList!.add(TestModel.fromJson(v));
      });
    }
    if (json['lab_list'] != null) {
      labList = <LabModel>[];
      json['lab_list'].forEach((v) {
        labList!.add(LabModel.fromJson(v));
      });
    }
    if (json['patient_list'] != null) {
      patientList = <UserDetailModel>[];
      json['patient_list'].forEach((v) {
        patientList!.add(UserDetailModel.fromJson(v));
      });
    }
    if (json['customer_list'] != null) {
      customerList = <UserDetailModel>[];
      json['customer_list'].forEach((v) {
        customerList!.add(UserDetailModel.fromJson(v));
      });
    }
    if (json['test_profile'] != null) {
      profileList = <ProfileModel>[];
      json['test_profile'].forEach((v) {
        profileList!.add(ProfileModel.fromJson(v));
      });
    }
    if (json['booking_list'] != null) {
      bookingList = <BookingModel>[];
      json['booking_list'].forEach((v) {
        bookingList!.add(BookingModel.fromJson(v));
      });
    }
    if (json['lab_wise_test'] != null) {
      labWiseTestList = <TestModel>[];
      json['lab_wise_test'].forEach((v) {
        labWiseTestList!.add(TestModel.fromJson(v));
      });
    }
    if (json['coupon_list'] != null) {
      offerList = <OfferModel>[];
      json['coupon_list'].forEach((v) {
        offerList!.add(OfferModel.fromJson(v));
      });
    }
    if (json['report_file'] != null) {
      reportList = <ReportModel>[];
      json['report_file'].forEach((v) {
        reportList!.add(ReportModel.fromJson(v));
      });
    }
    if (json['notifications'] != null) {
      notificationList = <NotificationModel>[];
      json['notifications'].forEach((v) {
        notificationList!.add(NotificationModel.fromJson(v));
      });
    }
    if (json['get_prescription'] != null) {
      prescriptionList = <PrescriptionModel>[];
      json['get_prescription'].forEach((v) {
        prescriptionList!.add(PrescriptionModel.fromJson(v));
      });
    }
    result = json['result'] != null ? CmsModel.fromJson(json['result']) : null;
    supportMobile = json['support_mobile'];
    slotModel = json['slot_list'] != null
        ? SlotModel.fromJson(json['slot_list'])
        : null;
    isLogin = json['is_login'];
    wallet = json['wallet'];
    appVersion = json['app_version'];
    isForceUpdate = json['is_force_update'];
    updateMessage = json['update_message'];
    token = json['token'];
    serviceCharge = json['service_charge']?.toString();
    serviceChargeDisplay = json['service_charge_display']?.toString();
    lastOtp = json['last_otp'];
    if (json['address_list'] != null) {
      addressList = <AddressList>[];
      json['address_list'].forEach((v) {
        addressList!.add(AddressList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['user_android_app_version'] = userAndroidAppVersion;
    data['user_android_update_message'] = userAndroidUpdateMessage;
    data['user_ios_app_version'] = userIosAppVersion;
    data['user_iso_update_message'] = userIsoUpdateMessage;
    if (userDetail != null) {
      data['user_detail'] = userDetail!.toJson();
    }
    if (sliderList != null) {
      data['slider'] = sliderList!.map((v) => v.toJson()).toList();
    }
    if (popularPackageList != null) {
      data['popular_package'] =
          popularPackageList!.map((v) => v.toJson()).toList();
    }
    if (lifestylePackageList != null) {
      data['lifestyle_package'] =
          lifestylePackageList!.map((v) => v.toJson()).toList();
    }
    if (popularProfilesList != null) {
      data['profiles'] = popularProfilesList!.map((v) => v.toJson()).toList();
    }
    if (testList != null) {
      data['tests'] = testList!.map((v) => v.toJson()).toList();
    }
    if (cartList != null) {
      data['cart_list'] = cartList!.map((v) => v.toJson()).toList();
    }
    if (packageList != null) {
      data['package_list'] = packageList!.map((v) => v.toJson()).toList();
    }
    if (labTestList != null) {
      data['lab_test_list'] = labTestList!.map((v) => v.toJson()).toList();
    }
    if (labList != null) {
      data['lab_list'] = labList!.map((v) => v.toJson()).toList();
    }
    if (patientList != null) {
      data['patient_list'] = patientList!.map((v) => v.toJson()).toList();
    }
    if (slotModel != null) {
      data['slot_list'] = slotModel!.toJson();
    }
    if (profileList != null) {
      data['test_profile'] = profileList!.map((v) => v.toJson()).toList();
    }
    if (bookingList != null) {
      data['booking_list'] = bookingList!.map((v) => v.toJson()).toList();
    }
    if (labWiseTestList != null) {
      data['lab_wise_test'] = labWiseTestList!.map((v) => v.toJson()).toList();
    }
    if (offerList != null) {
      data['coupon_list'] = offerList!.map((v) => v.toJson()).toList();
    }
    if (reportList != null) {
      data['report_file'] = reportList!.map((v) => v.toJson()).toList();
    }
    if (result != null) {
      data['result'] = result!.toJson();
    }
    if (notificationList != null) {
      data['notifications'] = notificationList!.map((v) => v.toJson()).toList();
    }
    if (prescriptionList != null) {
      data['get_prescription'] =
          prescriptionList!.map((v) => v.toJson()).toList();
    }
    data['support_mobile'] = supportMobile;
    data['is_login'] = isLogin;
    data['wallet'] = wallet;
    data['app_version'] = appVersion;
    data['is_force_update'] = isForceUpdate;
    data['update_message'] = updateMessage;
    data['token'] = token;
    data['last_otp'] = lastOtp;
    data['support_email'] = supportEmail;
    data['service_charge'] = serviceCharge;
    if (cityList != null) {
      data['city'] = cityList!.map((v) => v.toJson()).toList();
    }
    if (addressList != null) {
      data['address_list'] = addressList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
