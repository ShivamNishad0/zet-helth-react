import 'custom_cart_model.dart';

class TestModel {
  int? id;
  String? name;
  String? detail;
  String? testTime;
  int? isFastRequired;
  int? isFree;
  String? testGenderRecommendation;
  String? age;
  String? image;
  String? sampleReport;
  int? catId;
  String? categoryName;
  String? testShortName;
  int? status;
  String? createdDate;
  int? price;
  bool? isTestSelect;
  List<ItemDetail>? itemDetail;
  List<ProfilesDetail>? profilesDetail;
  String? parametersCount;
  String? parameters;

  TestModel({
    this.id,
    this.name,
    this.detail,
    this.testTime,
    this.isFastRequired,
    this.isFree,
    this.testGenderRecommendation,
    this.age,
    this.image,
    this.sampleReport,
    this.catId,
    this.categoryName,
    this.testShortName,
    this.status,
    this.createdDate,
    this.price,
    this.isTestSelect,
    this.itemDetail,
    this.profilesDetail,
    this.parametersCount,
    this.parameters,
  });

  TestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    detail = json['detail'];
    testTime = json['test_time'];
    isFastRequired = json['is_fast_required'];
    isFree = json['is_free'];
    testGenderRecommendation = json['test_gender_recommendation'];
    age = json['age'];
    image = json['image'];
    sampleReport = json['sample_report'];
    catId = json['cat_id'];
    categoryName = json['category_name'];
    testShortName = json['test_short_name'];
    status = json['status'];
    createdDate = json['created_date'];
    price = json['price'];
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
    isTestSelect = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['detail'] = detail;
    data['test_time'] = testTime;
    data['is_fast_required'] = isFastRequired;
    data['is_free'] = isFree;
    data['test_gender_recommendation'] = testGenderRecommendation;
    data['age'] = age;
    data['image'] = image;
    data['sample_report'] = sampleReport;
    data['cat_id'] = catId;
    data['category_name'] = categoryName;
    data['test_short_name'] = testShortName;
    data['status'] = status;
    data['created_date'] = createdDate;
    data['price'] = price;
    if (itemDetail != null) {
      data['item_detail'] = itemDetail!.map((v) => v.toJson()).toList();
    }
    if (profilesDetail != null) {
      data['profiles_detail'] = profilesDetail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}