class AddressList {
  int? id;
  int? userId;
  String? address;
  String? houseNo;
  String? landmark;
  String? location;
  String? pincode;
  String? latitude;
  String? longitude;
  String? status;
  String? createdDate;
  String? city;
  String? state;
  String? addressType;

  AddressList({
    this.id,
    this.userId,
    this.address,
    this.houseNo,
    this.landmark,
    this.location,
    this.pincode,
    this.latitude,
    this.longitude,
    this.status,
    this.createdDate,
    this.city,
    this.state,
    this.addressType,
  });

  AddressList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    address = json['address'].toString();
    houseNo = json['house_no'].toString();
    landmark = json['landmark'].toString();
    location = json['location'].toString();
    pincode = json['pincode'].toString();
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    status = json['status'].toString();
    createdDate = json['created_date'].toString();
    city = json['city'].toString();
    state = json['state'].toString();
    addressType = json['address_type']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['address'] = address;
    data['house_no'] = houseNo;
    data['landmark'] = landmark;
    data['location'] = location;
    data['pincode'] = pincode;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['status'] = status;
    data['created_date'] = createdDate;
    data['city'] = city;
    data['state'] = state;
    return data;
  }
}
