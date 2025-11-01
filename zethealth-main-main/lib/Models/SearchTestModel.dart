

import 'package:zet_health/Models/PackageModel.dart';
import 'package:zet_health/Models/ProfileModel.dart';
import 'package:zet_health/Models/TestModel.dart';

class SearchTestModel {
  bool? status;
  String? message;
  List<SearchList>? searchList;

  SearchTestModel({this.status, this.message, this.searchList});

  SearchTestModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['search_list'] != null) {
      searchList = <SearchList>[];
      json['search_list'].forEach((v) {
        searchList!.add(SearchList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (searchList != null) {
      data['search_list'] = searchList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SearchList {
  int? userId;
  String? labIds;
  String? userName;
  String? userEmail;
  String? labEmail;
  String? userGender;
  String? userMobile;
  int? cityId;
  String? actualPassword;
  String? userProfile;
  String? relation;
  String? rememberToken;
  String? address;
  String? latitude;
  String? longitude;
  String? isOriginal;
  String? createdDate;
  List<TestModel>? test;
  List<PackageModel>? package;
  List<ProfileModel>? profile;

  SearchList({
    this.userId,
    this.labIds,
    this.userName,
    this.userEmail,
    this.labEmail,
    this.userGender,
    this.userMobile,
    this.cityId,
    this.actualPassword,
    this.userProfile,
    this.relation,
    this.rememberToken,
    this.address,
    this.latitude,
    this.longitude,
    this.isOriginal,
    this.createdDate,
    this.test,
    this.package,
    this.profile,
  });

  SearchList.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    labIds = json['lab_ids'];
    userName = json['user_name']?.toString();
    userEmail = json['user_email']?.toString();
    labEmail = json['lab_email']?.toString();
    userGender = json['user_gender']?.toString();
    userMobile = json['user_mobile']?.toString();
    cityId = json['city_id'];
    actualPassword = json['actual_password']?.toString();
    userProfile = json['user_profile']?.toString();
    relation = json['relation']?.toString();
    rememberToken = json['remember_token']?.toString();
    address = json['address']?.toString();
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
    isOriginal = json['is_original']?.toString();
    createdDate = json['created_date']?.toString();
    if (json['test'] != null) {
      test = <TestModel>[];
      json['test'].forEach((v) {
        test!.add(TestModel.fromJson(v));
      });
    }
    if (json['package'] != null) {
      package = <PackageModel>[];
      json['package'].forEach((v) {
        package!.add(PackageModel.fromJson(v));
      });
    }
    if (json['profile'] != null) {
      profile = <ProfileModel>[];
      json['profile'].forEach((v) {
        profile!.add(ProfileModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['lab_ids'] = labIds;
    data['user_name'] = userName;
    data['user_email'] = userEmail;
    data['lab_email'] = labEmail;
    data['user_gender'] = userGender;
    data['user_mobile'] = userMobile;
    data['city_id'] = cityId;
    data['actual_password'] = actualPassword;
    data['user_profile'] = userProfile;
    data['relation'] = relation;
    data['remember_token'] = rememberToken;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['is_original'] = isOriginal;
    data['created_date'] = createdDate;
    if (test != null) {
      data['test'] = test!.map((v) => v.toJson()).toList();
    }
    if (package != null) {
      data['package'] = package!.map((v) => v.toJson()).toList();
    }
    if (profile != null) {
      data['profile'] = profile!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
