
import 'package:zet_health/Models/UserDetailModel.dart';
import 'package:zet_health/Models/custom_cart_model.dart';

class LabModel {
  int? labId;
  String? labName;
  String? labEmail;
  String? labMobile;
  String? labCity;
  String? labProfile;
  String? address;
  String? latitude;
  String? longitude;
  LabDetailModel? labDetailModel;
  UserDetailModel? hubDetails;
  String? rating;
  String? reviews;
  List<CustomCartModel>? testPricesList;
  String? totalPrice;

  LabModel(
      {this.labId,
      this.labName,
      this.labEmail,
      this.labMobile,
      this.labCity,
      this.labProfile,
      this.address,
      this.latitude,
      this.longitude,
      this.labDetailModel,
      this.hubDetails,
      this.rating,
      this.reviews,
      this.totalPrice,
      this.testPricesList});

  LabModel.fromJson(Map<String, dynamic> json) {
    labId = json['lab_id'];
    labName = json['lab_name'];
    labEmail = json['lab_email'];
    labMobile = json['lab_mobile'];
    labCity = json['lab_city'];
    labProfile = json['lab_profile'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    labDetailModel = json['lab_details'] != null
        ? LabDetailModel.fromJson(json['lab_details'])
        : null;
    hubDetails = json['hub_details'] != null
        ? UserDetailModel.fromJson(json['hub_details'])
        : null;
    rating = json['rating'].toString();
    reviews = json['reviews'].toString();
    if (json['test_prices'] != null) {
      testPricesList = <CustomCartModel>[];
      json['test_prices'].forEach((v) {
        testPricesList!.add(CustomCartModel.fromJson(v));
      });
    }
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
    if (labDetailModel != null) {
      data['lab_details'] = labDetailModel!.toJson();
    }
    if (hubDetails != null) {
      data['hub_details'] = hubDetails!.toJson();
    }
    data['rating'] = rating;
    data['reviews'] = reviews;
    if (testPricesList != null) {
      data['test_prices'] = testPricesList!.map((v) => v.toJson()).toList();
    }
    data['total_price'] = totalPrice;
    return data;
  }
}

class LabDetailModel {
  int? id;
  int? userId;
  String? labOwner;
  String? labDescription;
  String? labOpenTime;
  String? labCloseTime;
  String? labTimingJson;
  String? labBannerImg;
  int? status;
  String? createdDate;
  List<Days>? daysList;

  LabDetailModel(
      {this.id,
      this.userId,
      this.labOwner,
      this.labDescription,
      this.labOpenTime,
      this.labCloseTime,
      this.labTimingJson,
      this.labBannerImg,
      this.status,
      this.daysList,
      this.createdDate});

  LabDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    labOwner = json['lab_owner'];
    labDescription = json['lab_description'];
    labOpenTime = json['lab_open_time'];
    labCloseTime = json['lab_close_time'];
    labTimingJson = json['lab_timing_json'];
    labBannerImg = json['lab_banner_img'];
    status = json['status'];
    createdDate = json['created_date'];
    if (json['days'] != null) {
      daysList = <Days>[];
      json['days'].forEach((v) {
        daysList!.add(Days.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['lab_owner'] = labOwner;
    data['lab_description'] = labDescription;
    data['lab_open_time'] = labOpenTime;
    data['lab_close_time'] = labCloseTime;
    data['lab_timing_json'] = labTimingJson;
    data['lab_banner_img'] = labBannerImg;
    data['status'] = status;
    data['created_date'] = createdDate;
    if (daysList != null) {
      data['days'] = daysList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Days {
  String? name;
  String? fromTime;
  String? toTime;
  bool? status;

  Days({this.name, this.fromTime, this.toTime, this.status});

  Days.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    fromTime = json['from_time'];
    toTime = json['to_time'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['from_time'] = fromTime;
    data['to_time'] = toTime;
    data['status'] = status;
    return data;
  }
}
