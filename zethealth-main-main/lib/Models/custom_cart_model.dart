class CustomCartModel {
  int? id;
  String? name;
  String? type;
  String? price;
  String? image;
  String? isFastRequired;
  String? testTime;
  bool isSelected = false;
  List<ItemDetail>? itemDetail;
  List<ProfilesDetail>? profilesDetail;
  String? parametersCount;
  String? parameters;
  int? cityId;
  int? labId;
  String? labName;
  String? labProfile;
  String? labAddress;

  CustomCartModel({
    this.id,
    this.name,
    this.type,
    this.price,
    this.image,
    this.isFastRequired,
    this.testTime,
    this.isSelected = false,
    this.itemDetail,
    this.profilesDetail,
    this.parametersCount,
    this.parameters,
    this.cityId,
    this.labId,
    this.labName,
    this.labProfile,
    this.labAddress,
  });

  CustomCartModel.fromJson(Map<String, dynamic> json) {
  id = json['id'];
  name = json['name'];
  type = json['type'];
  price = json['price']?.toString();
  image = json['image'];
  isFastRequired = json['isFastRequired']?.toString();
  testTime = json['test_time'];
  
  // 🔥 FIX: Handle semicolon-separated string for itemDetail
  if (json['item_detail'] != null) {
    itemDetail = <ItemDetail>[];
    
    if (json['item_detail'] is String) {
      // Handle: "Liver Function Test; Kidney Profile; CBC"
      String itemDetailString = json['item_detail'];
      List<String> testNames = itemDetailString.split(';');
      
      for (String testName in testNames) {
        if (testName.trim().isNotEmpty) {
          itemDetail!.add(ItemDetail(
            name: testName.trim(),
            detail: null,
            testTime: null,
            sampleCollection: null,
          ));
        }
      }
    } else if (json['item_detail'] is List) {
      // Handle array format (backward compatibility)
      json['item_detail'].forEach((v) {
        itemDetail!.add(ItemDetail.fromJson(v));
      });
    }
  }
  
  if (json['profiles_detail'] != null) {
    profilesDetail = <ProfilesDetail>[];
    json['profiles_detail'].forEach((v) {
      profilesDetail!.add(ProfilesDetail.fromJson(v));
    });
  }
  
  parametersCount = json['parameters_count']?.toString();
  parameters = json['parameters']?.toString();
  cityId = json['city_id'];
  labId = json['lab_id'];
  labName = json['lab_name']?.toString();
  labProfile = json['lab_profile']?.toString();
  labAddress = json['lab_address']?.toString();
}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
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

class ItemDetail {
  String? name;
  String? detail;
  String? testTime;
  String? sampleCollection;

  ItemDetail({this.name, this.detail, this.testTime, this.sampleCollection});

  ItemDetail.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    detail = json['detail'];
    testTime = json['test_time'];
    sampleCollection = json['sample_collection'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['detail'] = detail;
    data['test_time'] = testTime;
    data['sample_collection'] = sampleCollection;
    return data;
  }
}

class ProfilesDetail {
  int? id;
  String? name;
  String? description;
  String? testTime;
  List<ItemDetail>? itemDetail;

  ProfilesDetail(
      {this.id, this.name, this.description, this.testTime, this.itemDetail});

  ProfilesDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    testTime = json['test_time'];
    if (json['item_detail'] != null) {
      itemDetail = <ItemDetail>[];
      json['item_detail'].forEach((v) {
        itemDetail!.add(ItemDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['test_time'] = testTime;
    if (itemDetail != null) {
      data['item_detail'] = itemDetail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}