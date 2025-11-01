import 'LabModel.dart';

class OrderDetailModel {
  bool? status;
  String? message;
  BookingDetails? bookingDetails;

  OrderDetailModel({this.status, this.message, this.bookingDetails});

  OrderDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    bookingDetails = json['booking_details'] != null
        ? BookingDetails.fromJson(json['booking_details'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (bookingDetails != null) {
      data['booking_details'] = bookingDetails!.toJson();
    }
    return data;
  }
}

class BookingDetails {
  int? id;
  int? userId;
  String? bookingNo;
  String? patientName;
  String? patientMobile;
  String? patientGender;
  String? couponCode;
  String? couponPrice;
  String? serviceCharge;
  String? totalPayableAmount;
  String? bookingDate;
  String? pickupAddress;
  String? devliveryBoyName;
  String? devliveryBoyMobile;
  String? devliveryBoyProfile;
  Lab? lab;
  List<Reports>? reports;

  BookingDetails(
      {this.id,
      this.userId,
      this.bookingNo,
      this.patientName,
      this.patientMobile,
      this.patientGender,
      this.couponCode,
      this.couponPrice,
      this.serviceCharge,
      this.totalPayableAmount,
      this.bookingDate,
      this.pickupAddress,
      this.devliveryBoyName,
      this.devliveryBoyMobile,
      this.devliveryBoyProfile,
      this.lab,
      this.reports});

  BookingDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    bookingNo = json['booking_no'];
    patientName = json['patient_name'];
    patientMobile = json['patient_mobile'];
    patientGender = json['patient_gender'];
    couponCode = json['coupon_code'];
    couponPrice = json['coupon_price'].toString();
    serviceCharge = json['service_charge'].toString();
    totalPayableAmount = json['total_payable_amount'].toString();
    bookingDate = json['booking_date'];
    pickupAddress = json['pickup_address'];
    devliveryBoyName = json['devlivery_boy_name'];
    devliveryBoyMobile = json['devlivery_boy_mobile'];
    devliveryBoyProfile = json['devlivery_boy_profile'];
    lab = json['lab'] != null ? Lab.fromJson(json['lab']) : null;
    if (json['reports'] != null) {
      reports = <Reports>[];
      json['reports'].forEach((v) {
        reports!.add(Reports.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['booking_no'] = bookingNo;
    data['patient_name'] = patientName;
    data['patient_mobile'] = patientMobile;
    data['patient_gender'] = patientGender;
    data['coupon_code'] = couponCode;
    data['coupon_price'] = couponPrice;
    data['service_charge'] = serviceCharge;
    data['total_payable_amount'] = totalPayableAmount;
    data['booking_date'] = bookingDate;
    data['pickup_address'] = pickupAddress;
    data['devlivery_boy_name'] = devliveryBoyName;
    data['devlivery_boy_mobile'] = devliveryBoyMobile;
    data['devlivery_boy_profile'] = devliveryBoyProfile;
    if (lab != null) {
      data['lab'] = lab!.toJson();
    }
    if (reports != null) {
      data['reports'] = reports!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Lab {
  int? labId;
  String? labName;
  String? labEmail;
  String? labMobile;
  String? labCity;
  String? labProfile;
  String? address;
  String? latitude;
  String? longitude;
  LabDetailModel? labDetails;
  String? rating;
  String? reviews;
  String? totalPrice;

  Lab(
      {this.labId,
      this.labName,
      this.labEmail,
      this.labMobile,
      this.labCity,
      this.labProfile,
      this.address,
      this.latitude,
      this.longitude,
      this.labDetails,
      this.rating,
      this.reviews,
      this.totalPrice});

  Lab.fromJson(Map<String, dynamic> json) {
    labId = json['lab_id'];
    labName = json['lab_name'];
    labEmail = json['lab_email'];
    labMobile = json['lab_mobile'];
    labCity = json['lab_city'];
    labProfile = json['lab_profile'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    labDetails = json['lab_details'] != null
        ? LabDetailModel.fromJson(json['lab_details'])
        : null;
    rating = json['rating'].toString();
    reviews = json['reviews'].toString();
    totalPrice = json['total_price'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lab_id'] = labId;
    data['lab_name'] = labName;
    data['lab_email'] = labEmail;
    data['lab_mobile'] = labMobile;
    data['lab_city'] = labCity;
    data['lab_profile'] = labProfile;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    if (labDetails != null) {
      data['lab_details'] = labDetails!.toJson();
    }
    data['rating'] = rating;
    data['reviews'] = reviews;
    data['total_price'] = totalPrice;
    return data;
  }
}

class Reports {
  int? id;
  int? bookingId;
  int? userId;
  String? folderName;
  String? path;
  String? createdDate;

  Reports(
      {this.id,
      this.bookingId,
      this.userId,
      this.folderName,
      this.path,
      this.createdDate});

  Reports.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    userId = json['user_id'];
    folderName = json['folder_name'];
    path = json['path'];
    createdDate = json['created_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['user_id'] = userId;
    data['folder_name'] = folderName;
    data['path'] = path;
    data['created_date'] = createdDate;
    return data;
  }
}
