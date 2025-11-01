class UserDetailModel {
  int? userId;
  int? patientId;
  int? parentId;
  String? userName;
  String? userEmail;
  String? email;
  String? userGender;
  String? userMobile;
  String? userCity;
  String? actualPassword;
  String? userProfile;
  String? relation;
  String? rememberToken;
  String? address;
  String? latitude;
  String? longitude;
  String? token;
  String? userType;
  String? pincode;
  String? rating;
  String? plateform;
  String? deviceInfo;
  String? deviceId;
  String? designation;
  String? degree;
  String? certificate;
  int? isProfileComplete;
  String? emergencyNo;
  String? helplineNo;
  String? userBloodgroup;
  int? userMarritalStatus;
  String? userDob;
  String? lastOtp;
  String? appVersion;
  int? userStatus;
  String? createdDate;

  int? id;
  String? firstName;
  String? lastName;
  String? mobile;
  String? dob;
  String? gender;
  int? status;
  List<UserDetailModel>? familyMember;

  UserDetailModel({
    this.userId,
    this.patientId,
    this.parentId,
    this.userName,
    this.userEmail,
    this.email,
    this.userGender,
    this.userMobile,
    this.userCity,
    this.actualPassword,
    this.userProfile,
    this.relation,
    this.rememberToken,
    this.address,
    this.latitude,
    this.longitude,
    this.token,
    this.userType,
    this.pincode,
    this.rating,
    this.plateform,
    this.deviceInfo,
    this.deviceId,
    this.designation,
    this.degree,
    this.certificate,
    this.isProfileComplete,
    this.emergencyNo,
    this.helplineNo,
    this.userBloodgroup,
    this.userMarritalStatus,
    this.userDob,
    this.lastOtp,
    this.appVersion,
    this.userStatus,
    this.createdDate,
    this.id,
    this.firstName,
    this.lastName,
    this.status,
    this.mobile,
    this.dob,
    this.gender,
    this.familyMember,
  });

  UserDetailModel.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    patientId = json['patient_id'];
    parentId = json['parent_id'];
    userName = json['user_name'];
    userEmail = json['user_email'];
    email = json['email'];
    userGender = json['user_gender'];
    userMobile = json['user_mobile'];
    userCity = json['user_city'];
    actualPassword = json['actual_password'];
    userProfile = json['user_profile'];
    relation = json['relation'];
    rememberToken = json['remember_token'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    token = json['token'];
    userType = json['user_type'];
    pincode = json['pincode'];
    rating = json['rating'].toString();
    plateform = json['plateform'];
    deviceInfo = json['device_info'];
    deviceId = json['device_id'];
    designation = json['designation'];
    degree = json['degree'];
    certificate = json['certificate'];
    isProfileComplete = json['is_profile_complete'];
    emergencyNo = json['emergency_no'];
    helplineNo = json['helpline_no'];
    userBloodgroup = json['user_bloodgroup'];
    userMarritalStatus = json['user_marrital_status'];
    userDob = json['user_dob'];
    lastOtp = json['last_otp'];
    appVersion = json['app_version'].toString();
    userStatus = json['user_status'];
    createdDate = json['created_date'];

    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    dob = json['dob'];
    gender = json['gender'];
    mobile = json['mobile'];
    status = json['status'];
    if (json['family_member'] != null) {
      familyMember = <UserDetailModel>[];
      json['family_member'].forEach((v) {
        familyMember!.add(UserDetailModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['patient_id'] = patientId;
    data['parent_id'] = parentId;
    data['user_name'] = userName;
    data['user_email'] = userEmail;
    data['email'] = email;
    data['user_gender'] = userGender;
    data['user_mobile'] = userMobile;
    data['user_city'] = userCity;
    data['actual_password'] = actualPassword;
    data['user_profile'] = userProfile;
    data['relation'] = relation;
    data['remember_token'] = rememberToken;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['token'] = token;
    data['user_type'] = userType;
    data['pincode'] = pincode;
    data['rating'] = rating;
    data['plateform'] = plateform;
    data['device_info'] = deviceInfo;
    data['device_id'] = deviceId;
    data['designation'] = designation;
    data['degree'] = degree;
    data['certificate'] = certificate;
    data['is_profile_complete'] = isProfileComplete;
    data['emergency_no'] = emergencyNo;
    data['helpline_no'] = helplineNo;
    data['user_bloodgroup'] = userBloodgroup;
    data['user_marrital_status'] = userMarritalStatus;
    data['user_dob'] = userDob;
    data['last_otp'] = lastOtp;
    data['app_version'] = appVersion;
    data['user_status'] = userStatus;
    data['created_date'] = createdDate;

    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['dob'] = dob;
    data['gender'] = gender;
    data['mobile'] = mobile;
    data['status'] = status;

    return data;
  }
}