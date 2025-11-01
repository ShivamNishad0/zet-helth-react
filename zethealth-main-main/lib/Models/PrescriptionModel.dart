
import 'package:zet_health/Models/LabModel.dart';
import 'package:zet_health/Models/PackageModel.dart';
import 'package:zet_health/Models/ProfileModel.dart';

import 'TestModel.dart';

class PrescriptionModel {
  int? id;
  int? userId;
  int? labId;
  String? document;
  String? selectedIds;
  String? type;
  int? isReply;
  String? createdDate;
  List<TestModel>? labTestList;
  PackageModel? packageModel;
  ProfileModel? profileModel;
  LabModel? labModel;

  PrescriptionModel({
    this.id,
    this.userId,
    this.labId,
    this.document,
    this.selectedIds,
    this.type,
    this.isReply,
    this.createdDate,
    this.labTestList,
    this.packageModel,
    this.profileModel,
    this.labModel,
  });

  PrescriptionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    labId = json['lab_id'];
    document = json['document'];
    selectedIds = json['selected_ids'];
    type = json['type'];
    isReply = json['is_reply'];
    createdDate = json['created_date'];
    packageModel = json['get_package'] != null
        ? PackageModel.fromJson(json['get_package'])
        : null;
    profileModel = json['get_profile'] != null
        ? ProfileModel.fromJson(json['get_profile'])
        : null;
    if (json['lab_tests'] != null) {
      labTestList = <TestModel>[];
      json['lab_tests'].forEach((v) {
        labTestList!.add(TestModel.fromJson(v));
      });
    }
    labModel =
        json['lab_list'] != null ? LabModel.fromJson(json['lab_list']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['lab_id'] = labId;
    data['document'] = document;
    data['selected_ids'] = selectedIds;
    data['type'] = type;
    data['is_reply'] = isReply;
    data['created_date'] = createdDate;
    if (packageModel != null) {
      data['get_package'] = packageModel!.toJson();
    }
    if (profileModel != null) {
      data['get_profile'] = profileModel!.toJson();
    }
    if (labTestList != null) {
      data['lab_tests'] = labTestList!.map((v) => v.toJson()).toList();
    }
    if (labModel != null) {
      data['lab_list'] = labModel!.toJson();
    }
    return data;
  }
}
