class CityModel {
  String? id;
  int? stateId;
  String? cityName;
  String? pincodes;
  int? status;
  String? createdDate;

  CityModel(
      {this.id,
      this.stateId,
      this.cityName,
      this.pincodes,
      this.status,
      this.createdDate});

  CityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    stateId = json['state_id'];
    cityName = json['city_name'];
    pincodes = json['pincodes'];
    status = json['status'];
    createdDate = json['created_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['state_id'] = stateId;
    data['city_name'] = cityName;
    data['pincodes'] = pincodes;
    data['status'] = status;
    data['created_date'] = createdDate;
    return data;
  }
}
