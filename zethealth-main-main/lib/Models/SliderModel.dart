class SliderModel {
  int? id;
  String? title;
  String? description;
  String? image;
  String? pincode;
  int? stateId;
  int? cityId;
  String? status;
  String? createdAt;
  String? updatedAt;

  SliderModel(
      {this.id,
      this.title,
      this.description,
      this.image,
      this.pincode,
      this.stateId,
      this.cityId,
      this.status,
      this.createdAt,
      this.updatedAt});

  SliderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    pincode = json['pincode'];
    stateId = json['state_id'];
    cityId = json['city_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['pincode'] = pincode;
    data['state_id'] = stateId;
    data['city_id'] = cityId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
