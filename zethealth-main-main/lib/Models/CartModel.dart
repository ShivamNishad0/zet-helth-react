

import 'package:zet_health/Models/LabModel.dart';
import 'package:zet_health/Models/ProfileModel.dart';
import 'package:zet_health/Models/TestModel.dart';
import 'package:zet_health/Models/custom_cart_model.dart';

class CartModel {
  int? id;
  int? labId;
  int? userId;
  String? cartJson;
  String? dateTime;
  String? subTotal;
  String? createdDate;
  LabModel? labModel;

  // to handle cartJson
  List<CustomCartModel>? itemList;
  String? name;
  String? price;
  String? type;
  List<TestModel>? labTestsList;
  List<ProfileModel>? profileTestList;

  CartModel({
    this.id,
    this.labId,
    this.userId,
    this.cartJson,
    this.dateTime,
    this.subTotal,
    this.createdDate,
    this.labModel,
    this.itemList,
    this.price,
    this.labTestsList,
    this.profileTestList,
  });

  CartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    labId = json['lab_id'];
    userId = json['user_id'];
    name = json['name'];
    price = json['price'].toString();
    type = json['type'];
    cartJson = json['cart_json'];
    dateTime = json['date_time'];
    subTotal = json['sub_total'].toString();
    createdDate = json['created_date'];
    labModel = json['lab'] != null ? LabModel.fromJson(json['lab']) : null;
    if (json['item'] != null) {
      itemList = <CustomCartModel>[];
      json['item'].forEach((v) {
        itemList!.add(CustomCartModel.fromJson(v));
      });
    }
    if (json['lab_tests'] != null) {
      labTestsList = <TestModel>[];
      json['lab_tests'].forEach((v) {
        labTestsList!.add(TestModel.fromJson(v));
      });
    }
    if (json['profile_test'] != null) {
      profileTestList = <ProfileModel>[];
      json['profile_test'].forEach((v) {
        profileTestList!.add(ProfileModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['lab_id'] = labId;
    data['user_id'] = userId;
    data['name'] = name;
    data['price'] = price;
    data['type'] = type;
    data['cart_json'] = cartJson;
    data['date_time'] = dateTime;
    data['sub_total'] = subTotal;
    data['created_date'] = createdDate;
    if (labModel != null) {
      data['lab'] = labModel!.toJson();
    }
    if (itemList != null) {
      data['item'] = itemList!.map((v) => v.toJson()).toList();
    }
    if (labTestsList != null) {
      data['lab_tests'] = labTestsList!.map((v) => v.toJson()).toList();
    }
    if (profileTestList != null) {
      data['profile_test'] = profileTestList!.map((v) => v.toJson()).toList();
    }
    data['price'] = price;
    return data;
  }
}
