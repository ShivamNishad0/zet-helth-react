import 'custom_cart_model.dart';

class PackageModel {
  int? id;
  int? labId;
  String? type;
  String? name;
  String? description;
  int? price;
  int? discount;
  int? catId;
  String? testTime;
  int? isFree;
  int? isFastRequired;
  String? recommendationGender;
  String? age;
  String? sampleReportFile;
  String? labTestIds;
  String? profileIds;
  String? image;
  int? isPopular;
  int? sequence;
  int? status;
  List<ItemDetail>? itemDetail;
  List<ProfilesDetail>? profilesDetail;
  String? createdDate;
  bool? isPackageSelect;
  String? parametersCount;
  String? parameters;

  PackageModel({
    this.id,
    this.labId,
    this.type,
    this.name,
    this.description,
    this.price,
    this.discount,
    this.catId,
    this.testTime,
    this.isFree,
    this.isFastRequired,
    this.recommendationGender,
    this.age,
    this.sampleReportFile,
    this.labTestIds,
    this.profileIds,
    this.image,
    this.isPopular,
    this.sequence,
    this.status,
    this.createdDate,
    this.isPackageSelect,
    this.itemDetail,
    this.profilesDetail,
    this.parametersCount,
    this.parameters,
  });

  PackageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    labId = json['lab_id'];
    type = json['type'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    discount = json['discount'];
    catId = json['cat_id'];
    testTime = json['test_time'];
    isFree = json['is_free'];
    isFastRequired = json['is_fast_required'];
    recommendationGender = json['recommendation_gender'];
    age = json['age'];
    sampleReportFile = json['sample_report_file'];
    labTestIds = json['lab_test_ids'];
    profileIds = json['profile_ids'];
    image = json['image'];
    isPopular = json['is_popular'];
    sequence = json['sequence'];
    status = json['status'];
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
    createdDate = json['created_date'];
    parametersCount = json['parameters_count']?.toString();
    parameters = json['parameters']?.toString();
    isPackageSelect = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['lab_id'] = labId;
    data['type'] = type;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['discount'] = discount;
    data['cat_id'] = catId;
    data['test_time'] = testTime;
    data['is_free'] = isFree;
    data['is_fast_required'] = isFastRequired;
    data['recommendation_gender'] = recommendationGender;
    data['age'] = age;
    data['sample_report_file'] = sampleReportFile;
    data['lab_test_ids'] = labTestIds;
    data['profile_ids'] = profileIds;
    data['image'] = image;
    data['is_popular'] = isPopular;
    data['sequence'] = sequence;
    data['status'] = status;
    if (itemDetail != null) {
      data['item_detail'] = itemDetail!.map((v) => v.toJson()).toList();
    }
    if (profilesDetail != null) {
      data['profiles_detail'] = profilesDetail!.map((v) => v.toJson()).toList();
    }
    data['created_date'] = createdDate;
    return data;
  }
}

class NewPackageModel {
  int? id;
  String? name;
  String? type;
  String? price;
  String? image;
  String? isFastRequired;
  String? testTime;
  List<ItemDetail>? itemDetail;
  String? profilesDetail;
  int? cityId;
  int? labId;
  String? labName;
  String? labAddress;
  String? description;

  NewPackageModel({
    this.id,
    this.name,
    this.type,
    this.price,
    this.image,
    this.isFastRequired,
    this.testTime,
    this.itemDetail,
    // this.profilesDetail,
    this.cityId,
    this.labId,
    this.labName,
    this.labAddress,
    this.description,
  });

  NewPackageModel.fromJson(Map<String, dynamic> json) {
    final rawItemDetail = json['itemDetail'];

    List<ItemDetail> parsedDetails = [];
    if (rawItemDetail is String) {
      parsedDetails = rawItemDetail
          .split(';')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => ItemDetail(name: e))
          .toList();
    } else if (rawItemDetail is List) {
      parsedDetails = rawItemDetail
          .map((e) => ItemDetail.fromJson(e))
          .toList()
          .cast<ItemDetail>();
    }

    id = json['id'];
    name = json['name']?.toString();
    type = json['type']?.toString();
    price = json['price']?.toString();
    image = json['image']?.toString();
    isFastRequired = json['isFastRequired']?.toString();
    testTime = json['testTime']?.toString();
    itemDetail = parsedDetails;
    // profilesDetail = json['profiles_detail']?.toString();
    cityId = json['cityId'];
    labId = json['labId'];
    labName = json['labName']?.toString();
    labAddress = json['labAddress']?.toString();
    description = json['description']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['price'] = price;
    data['image'] = image;
    data['isFastRequired'] = isFastRequired;
    data['testTime'] = testTime;
    data['itemDetail'] = itemDetail?.map((e) => e.toJson()).toList();
    // data['profiles_detail'] = profilesDetail;
    data['cityId'] = cityId;
    data['labId'] = labId;
    data['labName'] = labName;
    data['labAddress'] = labAddress;
    data['description'] = description;
    return data;
  }
}
