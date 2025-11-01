import 'TestModel.dart';
import 'custom_cart_model.dart';

class ProfileModel {
  int? id;
  int? labId;
  String? name;
  String? description;
  int? price;
  int? discount;
  int? catId;
  String? categoryName;
  String? labName;
  String? testTime;
  int? isFree;
  int? isFastRequired;
  String? image;
  String? recommendationGender;
  String? age;
  String? sampleReportFile;
  String? labTestIds;
  int? status;
  String? createdDate;
  String? testIncludes;
  List<TestModel>? labTestsList;
  bool? isProfileSelect;
  List<ItemDetail>? itemDetail;
  List<ProfilesDetail>? profilesDetail;
  String? parametersCount;
  String? parameters;


  ProfileModel({
    this.id,
    this.labId,
    this.name,
    this.description,
    this.price,
    this.discount,
    this.catId,
    this.categoryName,
    this.labName,
    this.testTime,
    this.isFree,
    this.isFastRequired,
    this.image,
    this.recommendationGender,
    this.age,
    this.sampleReportFile,
    this.labTestIds,
    this.status,
    this.createdDate,
    this.testIncludes,
    this.labTestsList,
    this.isProfileSelect,
    this.itemDetail,
    this.profilesDetail,
    this.parametersCount,
    this.parameters,
  });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    labId = json['lab_id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    discount = json['discount'];
    catId = json['cat_id'];
    categoryName = json['category_name'];
    labName = json['lab_name'];
    testTime = json['test_time'];
    isFree = json['is_free'];
    isFastRequired = json['is_fast_required'];
    image = json['image'];
    recommendationGender = json['recommendation_gender'];
    age = json['age'];
    sampleReportFile = json['sample_report_file'];
    labTestIds = json['lab_test_ids'];
    status = json['status'];
    createdDate = json['created_date'];
    testIncludes = json['test_includes'];
    if (json['lab_tests'] != null) {
      labTestsList = <TestModel>[];
      json['lab_tests'].forEach((v) {
        labTestsList!.add(TestModel.fromJson(v));
      });
    }
    if (json['item_detail'] != null) {
      itemDetail = <ItemDetail>[];
      json['item_detail'].forEach((v) {
        itemDetail!.add(ItemDetail.fromJson(v));
      });
    }
    if (json['profiles_detail'] != null) {
      profilesDetail = <ProfilesDetail>[];
      json['profiles_detail'].forEach((v) {
        profilesDetail!.add(ProfilesDetail.fromJson(v));
      });
    }
    parametersCount = json['parameters_count']?.toString();
    parameters = json['parameters']?.toString();
    isProfileSelect = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['lab_id'] = labId;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['discount'] = discount;
    data['cat_id'] = catId;
    data['category_name'] = categoryName;
    data['lab_name'] = labName;
    data['test_time'] = testTime;
    data['is_free'] = isFree;
    data['is_fast_required'] = isFastRequired;
    data['image'] = image;
    data['recommendation_gender'] = recommendationGender;
    data['age'] = age;
    data['sample_report_file'] = sampleReportFile;
    data['lab_test_ids'] = labTestIds;
    data['status'] = status;
    data['created_date'] = createdDate;
    data['test_includes'] = testIncludes;
    if (labTestsList != null) {
      data['lab_tests'] = labTestsList!.map((v) => v.toJson()).toList();
    }
    if (itemDetail != null) {
      data['item_detail'] = itemDetail!.map((v) => v.toJson()).toList();
    }
    if (profilesDetail != null) {
      data['profiles_detail'] = profilesDetail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
