// class HomeModel {
//   bool? status;
//   String? message;
//   UserDetailModel? userDetail;
//   List<Slider>? sliderList;
//   List<PackageModel>? popularPackageList;
//   List<PackageModel>? lifestylePackageList;
//   List<ProfileModel>? profiles;
//   List<TestModel>? testList;
//   List<CartModel>? cartList;
//   List<CityModel>? cityList;
//   bool? isLogin;
//   int? wallet;
//   String? appVersion;
//   int? isForceUpdate;
//   String? updateMessage;
//   String? supportMobile;
//   String? supportEmail;
//   String? labOpenTime;
//   String? labCloseTime;
//
//   HomeModel(
//       {this.status,
//         this.message,
//         this.userDetail,
//         this.sliderList,
//         this.popularPackageList,
//         this.lifestylePackageList,
//         this.profiles,
//         this.testList,
//         this.cartList,
//         this.isLogin,
//         this.wallet,
//         this.appVersion,
//         this.isForceUpdate,
//         this.updateMessage,
//         this.supportMobile,
//         this.supportEmail,
//         this.cityList,
//         this.labOpenTime,
//         this.labCloseTime});
//
//   HomeModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     userDetail = json['user_detail'] != null
//         ? new UserDetailModel.fromJson(json['user_detail'])
//         : null;
//     if (json['slider'] != null) {
//       sliderList = <Slider>[];
//       json['slider'].forEach((v) {
//         sliderList!.add(new Slider.fromJson(v));
//       });
//     }
//     if (json['popular_package'] != null) {
//       popularPackageList = <PackageModel>[];
//       json['popular_package'].forEach((v) {
//         popularPackageList!.add(new PackageModel.fromJson(v));
//       });
//     }
//     if (json['lifestyle_package'] != null) {
//       lifestylePackageList = <PackageModel>[];
//       json['lifestyle_package'].forEach((v) {
//         lifestylePackageList!.add(new PackageModel.fromJson(v));
//       });
//     }
//     if (json['profiles'] != null) {
//       profiles = <ProfileModel>[];
//       json['profiles'].forEach((v) {
//         profiles!.add(new ProfileModel.fromJson(v));
//       });
//     }
//     if (json['tests'] != null) {
//       testList = <TestModel>[];
//       json['tests'].forEach((v) {
//         testList!.add(new TestModel.fromJson(v));
//       });
//     }
//     if (json['cart_list'] != null) {
//       cartList = <CartModel>[];
//       json['cart_list'].forEach((v) {
//         cartList!.add(new CartModel.fromJson(v));
//       });
//     }
//     isLogin = json['is_login'];
//     wallet = json['wallet'];
//     appVersion = json['app_version'];
//     isForceUpdate = json['is_force_update'];
//     updateMessage = json['update_message'];
//     supportMobile = json['support_mobile'];
//     supportEmail = json['support_email'];
//     if (json['city'] != null) {
//       cityList = <CityModel>[];
//       json['city'].forEach((v) {
//         cityList!.add(new CityModel.fromJson(v));
//       });
//     }
//     labOpenTime = json['lab_open_time'];
//     labCloseTime = json['lab_close_time'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['status'] = this.status;
//     data['message'] = this.message;
//     if (this.userDetail != null) {
//       data['user_detail'] = this.userDetail!.toJson();
//     }
//     if (this.sliderList != null) {
//       data['slider'] = this.sliderList!.map((v) => v.toJson()).toList();
//     }
//     if (this.popularPackageList != null) {
//       data['popular_package'] =
//           this.popularPackageList!.map((v) => v.toJson()).toList();
//     }
//     if (this.lifestylePackageList != null) {
//       data['lifestyle_package'] =
//           this.lifestylePackageList!.map((v) => v.toJson()).toList();
//     }
//     if (this.profiles != null) {
//       data['profiles'] = this.profiles!.map((v) => v.toJson()).toList();
//     }
//     if (this.testList != null) {
//       data['tests'] = this.testList!.map((v) => v.toJson()).toList();
//     }
//     if (this.cartList != null) {
//       data['cart_list'] = this.cartList!.map((v) => v.toJson()).toList();
//     }
//     data['is_login'] = this.isLogin;
//     data['wallet'] = this.wallet;
//     data['app_version'] = this.appVersion;
//     data['is_force_update'] = this.isForceUpdate;
//     data['update_message'] = this.updateMessage;
//     data['support_mobile'] = this.supportMobile;
//     data['support_email'] = this.supportEmail;
//     if (this.cityList != null) {
//       data['city'] = this.cityList!.map((v) => v.toJson()).toList();
//     }
//     data['lab_open_time'] = this.labOpenTime;
//     data['lab_close_time'] = this.labCloseTime;
//     return data;
//   }
// }
//
// class UserDetailModel {
//   int? userId;
//   int? patientId;
//   int? parentId;
//   String? userName;
//   String? userEmail;
//   String? email;
//   String? userGender;
//   String? userMobile;
//   String? userCity;
//   String? actualPassword;
//   String? userProfile;
//   String? relation;
//   String? rememberToken;
//   String? address;
//   String? latitude;
//   String? longitude;
//   String? token;
//   String? userType;
//   String? pincode;
//   int? rating;
//   String? plateform;
//   String? deviceInfo;
//   String? deviceId;
//   String? designation;
//   String? degree;
//   String? certificate;
//   int? isProfileComplete;
//   String? emergencyNo;
//   String? helplineNo;
//   String? userBloodgroup;
//   int? userMarritalStatus;
//   String? userDob;
//   String? lastOtp;
//   int? appVersion;
//   int? userStatus;
//   String? createdDate;
//
//   int? id;
//   String? firstName;
//   String? lastName;
//   String? mobile;
//   String? dob;
//   String? gender;
//   int? status;
//
//   UserDetailModel(
//       {this.userId,
//         this.patientId,
//         this.parentId,
//         this.userName,
//         this.userEmail,
//         this.email,
//         this.userGender,
//         this.userMobile,
//         this.userCity,
//         this.actualPassword,
//         this.userProfile,
//         this.relation,
//         this.rememberToken,
//         this.address,
//         this.latitude,
//         this.longitude,
//         this.token,
//         this.userType,
//         this.pincode,
//         this.rating,
//         this.plateform,
//         this.deviceInfo,
//         this.deviceId,
//         this.designation,
//         this.degree,
//         this.certificate,
//         this.isProfileComplete,
//         this.emergencyNo,
//         this.helplineNo,
//         this.userBloodgroup,
//         this.userMarritalStatus,
//         this.userDob,
//         this.lastOtp,
//         this.appVersion,
//         this.userStatus,
//         this.createdDate,
//         this.id,
//         this.firstName,
//         this.lastName,
//         this.status,
//         this.mobile,
//         this.dob,
//         this.gender
//       });
//
//   UserDetailModel.fromJson(Map<String, dynamic> json) {
//     userId = json['user_id'];
//     patientId = json['patient_id'];
//     parentId = json['parent_id'];
//     userName = json['user_name'];
//     userEmail = json['user_email'];
//     email = json['email'];
//     userGender = json['user_gender'];
//     userMobile = json['user_mobile'];
//     userCity = json['user_city'];
//     actualPassword = json['actual_password'];
//     userProfile = json['user_profile'];
//     relation = json['relation'];
//     rememberToken = json['remember_token'];
//     address = json['address'];
//     latitude = json['latitude'];
//     longitude = json['longitude'];
//     token = json['token'];
//     userType = json['user_type'];
//     pincode = json['pincode'];
//     rating = json['rating'];
//     plateform = json['plateform'];
//     deviceInfo = json['device_info'];
//     deviceId = json['device_id'];
//     designation = json['designation'];
//     degree = json['degree'];
//     certificate = json['certificate'];
//     isProfileComplete = json['is_profile_complete'];
//     emergencyNo = json['emergency_no'];
//     helplineNo = json['helpline_no'];
//     userBloodgroup = json['user_bloodgroup'];
//     userMarritalStatus = json['user_marrital_status'];
//     userDob = json['user_dob'];
//     lastOtp = json['last_otp'];
//     appVersion = json['app_version'];
//     userStatus = json['user_status'];
//     createdDate = json['created_date'];
//
//     id = json['id'];
//     firstName = json['first_name'];
//     lastName = json['last_name'];
//     dob = json['dob'];
//     gender = json['gender'];
//     mobile = json['mobile'];
//     status = json['status'];
//
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['user_id'] = this.userId;
//     data['patient_id'] = this.patientId;
//     data['parent_id'] = this.parentId;
//     data['user_name'] = this.userName;
//     data['user_email'] = this.userEmail;
//     data['email'] = email;
//     data['user_gender'] = this.userGender;
//     data['user_mobile'] = this.userMobile;
//     data['user_city'] = this.userCity;
//     data['actual_password'] = this.actualPassword;
//     data['user_profile'] = this.userProfile;
//     data['relation'] = this.relation;
//     data['remember_token'] = this.rememberToken;
//     data['address'] = this.address;
//     data['latitude'] = this.latitude;
//     data['longitude'] = this.longitude;
//     data['token'] = this.token;
//     data['user_type'] = this.userType;
//     data['pincode'] = this.pincode;
//     data['rating'] = this.rating;
//     data['plateform'] = this.plateform;
//     data['device_info'] = this.deviceInfo;
//     data['device_id'] = this.deviceId;
//     data['designation'] = this.designation;
//     data['degree'] = this.degree;
//     data['certificate'] = this.certificate;
//     data['is_profile_complete'] = this.isProfileComplete;
//     data['emergency_no'] = this.emergencyNo;
//     data['helpline_no'] = this.helplineNo;
//     data['user_bloodgroup'] = this.userBloodgroup;
//     data['user_marrital_status'] = this.userMarritalStatus;
//     data['user_dob'] = this.userDob;
//     data['last_otp'] = this.lastOtp;
//     data['app_version'] = this.appVersion;
//     data['user_status'] = this.userStatus;
//     data['created_date'] = this.createdDate;
//
//     data['id'] = this.id;
//     data['first_name'] = this.firstName;
//     data['last_name'] = this.lastName;
//     data['dob'] = this.dob;
//     data['gender'] = this.gender;
//     data['mobile'] = this.mobile;
//     data['status'] = this.status;
//
//     return data;
//   }
// }
//
// class CityModel {
//   int? id;
//   int? stateId;
//   String? cityName;
//   String? pincodes;
//   int? status;
//   String? createdDate;
//
//   CityModel(
//       {this.id, this.stateId, this.cityName, this.pincodes, this.status, this.createdDate});
//
//   CityModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     stateId = json['state_id'];
//     cityName = json['city_name'];
//     pincodes = json['pincodes'];
//     status = json['status'];
//     createdDate = json['created_date'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['state_id'] = this.stateId;
//     data['city_name'] = this.cityName;
//     data['pincodes'] = this.pincodes;
//     data['status'] = this.status;
//     data['created_date'] = this.createdDate;
//     return data;
//   }
// }
//
// class Slider {
//   int? id;
//   String? title;
//   String? description;
//   String? image;
//   String? pincode;
//   int? stateId;
//   int? cityId;
//   String? status;
//   String? createdAt;
//   String? updatedAt;
//
//   Slider({
//     this.id,
//     this.title,
//     this.description,
//     this.image,
//     this.pincode,
//     this.stateId,
//     this.cityId,
//     this.status,
//     this.createdAt,
//     this.updatedAt
//   });
//
//   Slider.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     title = json['title'];
//     description = json['description'];
//     image = json['image'];
//     pincode = json['pincode'];
//     stateId = json['state_id'];
//     cityId = json['city_id'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['title'] = this.title;
//     data['description'] = this.description;
//     data['image'] = this.image;
//     data['pincode'] = this.pincode;
//     data['state_id'] = this.stateId;
//     data['city_id'] = this.cityId;
//     data['status'] = this.status;
//     data['created_at'] = this.createdAt;
//     data['updated_at'] = this.updatedAt;
//     return data;
//   }
//
// }
//
// class LabTests {
//   int? id;
//   String? name;
//   int? isFree;
//   int? isFastRequired;
//   int? price;
//
//   LabTests({this.id, this.name, this.isFree, this.isFastRequired, this.price});
//
//   LabTests.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     isFree = json['is_free'];
//     isFastRequired = json['is_fast_required'];
//     price = json['price'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['is_free'] = this.isFree;
//     data['is_fast_required'] = this.isFastRequired;
//     data['price'] = this.price;
//     return data;
//   }
// }
//
// class ProfileTest {
//   int? id;
//   String? name;
//   int? isFree;
//   int? isFastRequired;
//   int? price;
//   List<LabTests>? labTests;
//   Null? labTestName;
//
//   ProfileTest(
//       {this.id,
//         this.name,
//         this.isFree,
//         this.isFastRequired,
//         this.price,
//         this.labTests,
//         this.labTestName});
//
//   ProfileTest.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     isFree = json['is_free'];
//     isFastRequired = json['is_fast_required'];
//     price = json['price'];
//     if (json['lab_tests'] != null) {
//       labTests = <LabTests>[];
//       json['lab_tests'].forEach((v) {
//         labTests!.add(new LabTests.fromJson(v));
//       });
//     }
//     labTestName = json['lab_test_name'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['is_free'] = this.isFree;
//     data['is_fast_required'] = this.isFastRequired;
//     data['price'] = this.price;
//     if (this.labTests != null) {
//       data['lab_tests'] = this.labTests!.map((v) => v.toJson()).toList();
//     }
//     data['lab_test_name'] = this.labTestName;
//     return data;
//   }
// }
//
// class ProfileModel {
//   int? id;
//   int? labId;
//   String? name;
//   String? description;
//   int? price;
//   int? discount;
//   int? catId;
//   String? categoryName;
//   String? labName;
//   String? testTime;
//   int? isFree;
//   int? isFastRequired;
//   String? image;
//   String? recommendationGender;
//   String? age;
//   String? sampleReportFile;
//   String? labTestIds;
//   int? status;
//   String? createdDate;
//   String? testIncludes;
//   List<TestModel>? labTestsList;
//
//
//   ProfileModel(
//       {this.id,
//         this.labId,
//         this.name,
//         this.description,
//         this.price,
//         this.discount,
//         this.catId,
//         this.categoryName,
//         this.labName,
//         this.testTime,
//         this.isFree,
//         this.isFastRequired,
//         this.image,
//         this.recommendationGender,
//         this.age,
//         this.sampleReportFile,
//         this.labTestIds,
//         this.status,
//         this.createdDate,
//         this.testIncludes,
//         this.labTestsList});
//
//   ProfileModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     labId = json['lab_id'];
//     name = json['name'];
//     description = json['description'];
//     price = json['price'];
//     discount = json['discount'];
//     catId = json['cat_id'];
//     categoryName = json['category_name'];
//     labName = json['lab_name'];
//     testTime = json['test_time'];
//     isFree = json['is_free'];
//     isFastRequired = json['is_fast_required'];
//     image = json['image'];
//     recommendationGender = json['recommendation_gender'];
//     age = json['age'];
//     sampleReportFile = json['sample_report_file'];
//     labTestIds = json['lab_test_ids'];
//     status = json['status'];
//     createdDate = json['created_date'];
//     testIncludes = json['test_includes'];
//     if (json['lab_tests'] != null) {
//       labTestsList = <TestModel>[];
//       json['lab_tests'].forEach((v) {
//         labTestsList!.add(new TestModel.fromJson(v));
//       });
//     }
//
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['lab_id'] = this.labId;
//     data['name'] = this.name;
//     data['description'] = this.description;
//     data['price'] = this.price;
//     data['discount'] = this.discount;
//     data['cat_id'] = this.catId;
//     data['category_name'] = this.categoryName;
//     data['lab_name'] = this.labName;
//     data['test_time'] = this.testTime;
//     data['is_free'] = this.isFree;
//     data['is_fast_required'] = this.isFastRequired;
//     data['image'] = this.image;
//     data['recommendation_gender'] = this.recommendationGender;
//     data['age'] = this.age;
//     data['sample_report_file'] = this.sampleReportFile;
//     data['lab_test_ids'] = this.labTestIds;
//     data['status'] = this.status;
//     data['created_date'] = this.createdDate;
//     data['test_includes'] = this.testIncludes;
//     if (this.labTestsList != null) {
//       data['lab_tests'] = this.labTestsList!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class TestModel {
//   int? id;
//   String? name;
//   String? detail;
//   String? testTime;
//   int? isFastRequired;
//   int? isFree;
//   String? testGenderRecommendation;
//   String? age;
//   String? image;
//   String? sampleReport;
//   int? catId;
//   String? categoryName;
//   String? testShortName;
//   int? status;
//   String? createdDate;
//   int? price;
//   bool? isTestSelect;
//
//   TestModel(
//       {this.id,
//         this.name,
//         this.detail,
//         this.testTime,
//         this.isFastRequired,
//         this.isFree,
//         this.testGenderRecommendation,
//         this.age,
//         this.image,
//         this.sampleReport,
//         this.catId,
//         this.categoryName,
//         this.testShortName,
//         this.status,
//         this.createdDate,
//         this.price,
//         this.isTestSelect
//       });
//
//   TestModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     detail = json['detail'];
//     testTime = json['test_time'];
//     isFastRequired = json['is_fast_required'];
//     isFree = json['is_free'];
//     testGenderRecommendation = json['test_gender_recommendation'];
//     age = json['age'];
//     image = json['image'];
//     sampleReport = json['sample_report'];
//     catId = json['cat_id'];
//     categoryName = json['category_name'];
//     testShortName = json['test_short_name'];
//     status = json['status'];
//     createdDate = json['created_date'];
//     price = json['price'];
//     isTestSelect = false;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['detail'] = this.detail;
//     data['test_time'] = this.testTime;
//     data['is_fast_required'] = this.isFastRequired;
//     data['is_free'] = this.isFree;
//     data['test_gender_recommendation'] = this.testGenderRecommendation;
//     data['age'] = this.age;
//     data['image'] = this.image;
//     data['sample_report'] = this.sampleReport;
//     data['cat_id'] = this.catId;
//     data['category_name'] = this.categoryName;
//     data['test_short_name'] = this.testShortName;
//     data['status'] = this.status;
//     data['created_date'] = this.createdDate;
//     data['price'] = this.price;
//     return data;
//   }
// }
//
// class Tests {
//   int? id;
//   String? name;
//   String? detail;
//   String? testTime;
//   int? isFastRequired;
//   int? isFree;
//   String? testGenderRecommendation;
//   String? age;
//   String? image;
//   String? sampleReport;
//   int? catId;
//   String? categoryName;
//   String? testShortName;
//   int? status;
//   String? createdDate;
//   int? price;
//
//   Tests(
//       {this.id,
//         this.name,
//         this.detail,
//         this.testTime,
//         this.isFastRequired,
//         this.isFree,
//         this.testGenderRecommendation,
//         this.age,
//         this.image,
//         this.sampleReport,
//         this.catId,
//         this.categoryName,
//         this.testShortName,
//         this.status,
//         this.createdDate,
//         this.price});
//
//   Tests.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     detail = json['detail'];
//     testTime = json['test_time'];
//     isFastRequired = json['is_fast_required'];
//     isFree = json['is_free'];
//     testGenderRecommendation = json['test_gender_recommendation'];
//     age = json['age'];
//     image = json['image'];
//     sampleReport = json['sample_report'];
//     catId = json['cat_id'];
//     categoryName = json['category_name'];
//     testShortName = json['test_short_name'];
//     status = json['status'];
//     createdDate = json['created_date'];
//     price = json['price'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['detail'] = this.detail;
//     data['test_time'] = this.testTime;
//     data['is_fast_required'] = this.isFastRequired;
//     data['is_free'] = this.isFree;
//     data['test_gender_recommendation'] = this.testGenderRecommendation;
//     data['age'] = this.age;
//     data['image'] = this.image;
//     data['sample_report'] = this.sampleReport;
//     data['cat_id'] = this.catId;
//     data['category_name'] = this.categoryName;
//     data['test_short_name'] = this.testShortName;
//     data['status'] = this.status;
//     data['created_date'] = this.createdDate;
//     data['price'] = this.price;
//     return data;
//   }
// }
//
//
// class PackageModel {
//   int? id;
//   int? labId;
//   String? type;
//   String? name;
//   String? description;
//   int? price;
//   int? discount;
//   int? catId;
//   String? testTime;
//   int? isFree;
//   int? isFastRequired;
//   String? recommendationGender;
//   String? age;
//   String? sampleReportFile;
//   String? labTestIds;
//   String? profileIds;
//   String? image;
//   int? isPopular;
//   int? sequence;
//   int? status;
//   List<TestModel>? labTestList;
//   List<ProfileModel>? profileTestList;
//   String? createdDate;
//
//   PackageModel(
//       {this.id,
//         this.labId,
//         this.type,
//         this.name,
//         this.description,
//         this.price,
//         this.discount,
//         this.catId,
//         this.testTime,
//         this.isFree,
//         this.isFastRequired,
//         this.recommendationGender,
//         this.age,
//         this.sampleReportFile,
//         this.labTestIds,
//         this.profileIds,
//         this.image,
//         this.isPopular,
//         this.sequence,
//         this.status,
//         this.labTestList,
//         this.profileTestList,
//         this.createdDate});
//
//   PackageModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     labId = json['lab_id'];
//     type = json['type'];
//     name = json['name'];
//     description = json['description'];
//     price = json['price'];
//     discount = json['discount'];
//     catId = json['cat_id'];
//     testTime = json['test_time'];
//     isFree = json['is_free'];
//     isFastRequired = json['is_fast_required'];
//     recommendationGender = json['recommendation_gender'];
//     age = json['age'];
//     sampleReportFile = json['sample_report_file'];
//     labTestIds = json['lab_test_ids'];
//     profileIds = json['profile_ids'];
//     image = json['image'];
//     isPopular = json['is_popular'];
//     sequence = json['sequence'];
//     status = json['status'];
//     if (json['lab_tests'] != null) {
//       labTestList = <TestModel>[];
//       json['lab_tests'].forEach((v) {
//         labTestList!.add(new TestModel.fromJson(v));
//       });
//     }
//     if (json['profile_test'] != null) {
//       profileTestList = <ProfileModel>[];
//       json['profile_test'].forEach((v) {
//         profileTestList!.add(new ProfileModel.fromJson(v));
//       });
//     }
//     createdDate = json['created_date'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['lab_id'] = this.labId;
//     data['type'] = this.type;
//     data['name'] = this.name;
//     data['description'] = this.description;
//     data['price'] = this.price;
//     data['discount'] = this.discount;
//     data['cat_id'] = this.catId;
//     data['test_time'] = this.testTime;
//     data['is_free'] = this.isFree;
//     data['is_fast_required'] = this.isFastRequired;
//     data['recommendation_gender'] = this.recommendationGender;
//     data['age'] = this.age;
//     data['sample_report_file'] = this.sampleReportFile;
//     data['lab_test_ids'] = this.labTestIds;
//     data['profile_ids'] = this.profileIds;
//     data['image'] = this.image;
//     data['is_popular'] = this.isPopular;
//     data['sequence'] = this.sequence;
//     data['status'] = this.status;
//     if (this.labTestList != null) {
//       data['lab_tests'] = this.labTestList!.map((v) => v.toJson()).toList();
//     }
//     if (this.profileTestList != null) {
//       data['profile_test'] = this.profileTestList!.map((v) => v.toJson()).toList();
//     }
//     data['created_date'] = this.createdDate;
//     return data;
//   }
// }
//
// class CartModel {
//   int? id;
//   int? labId;
//   int? userId;
//   String? cartJson;
//   String? dateTime;
//   int? subTotal;
//   String? createdDate;
//   LabModel? labModel;
//
//   // to handle cartJson
//   List<Item>? itemList;
//   String? name;
//   int? price;
//   String? type;
//   List<TestModel>? labTestsList;
//   List<ProfileModel>? profileTestList;
//
//   CartModel(
//       {this.id,
//         this.labId,
//         this.userId,
//         this.cartJson,
//         this.dateTime,
//         this.subTotal,
//         this.createdDate,
//         this.labModel,
//         this.itemList,
//         this.price,
//         this.labTestsList,
//         this.profileTestList,
//       });
//
//   CartModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     labId = json['lab_id'];
//     userId = json['user_id'];
//     name = json['name'];
//     price = json['price'];
//     type = json['type'];
//     cartJson = json['cart_json'];
//     dateTime = json['date_time'];
//     subTotal = json['sub_total'];
//     createdDate = json['created_date'];
//     labModel = json['lab'] != null ? new LabModel.fromJson(json['lab']) : null;
//     if (json['item'] != null) {
//       itemList = <Item>[];
//       json['item'].forEach((v) {
//         itemList!.add(new Item.fromJson(v));
//       });
//     }
//     if (json['lab_tests'] != null) {
//       labTestsList = <TestModel>[];
//       json['lab_tests'].forEach((v) {
//         labTestsList!.add(new TestModel.fromJson(v));
//       });
//     }
//     if (json['profile_test'] != null) {
//       profileTestList = <ProfileModel>[];
//       json['profile_test'].forEach((v) {
//         profileTestList!.add(new ProfileModel.fromJson(v));
//       });
//     }
//     price = json['price'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['lab_id'] = this.labId;
//     data['user_id'] = this.userId;
//     data['name'] = this.name;
//     data['price'] = this.price;
//     data['type'] = this.type;
//     data['cart_json'] = this.cartJson;
//     data['date_time'] = this.dateTime;
//     data['sub_total'] = this.subTotal;
//     data['created_date'] = this.createdDate;
//     if (this.labModel != null) {
//       data['lab'] = this.labModel!.toJson();
//     }
//     if (this.itemList != null) {
//       data['item'] = this.itemList!.map((v) => v.toJson()).toList();
//     }
//     if (this.labTestsList != null) {
//       data['lab_tests'] = this.labTestsList!.map((v) => v.toJson()).toList();
//     }
//     if (this.profileTestList != null) {
//       data['profile_test'] = this.profileTestList!.map((v) => v.toJson()).toList();
//     }
//     data['price'] = this.price;
//     return data;
//   }
//
// }
//
// class Item {
//   String? itemName;
//   String? itemType;
//   int? itemId;
//   int? itemPrice;
//
//   Item({this.itemName, this.itemType, this.itemId, this.itemPrice});
//
//   Item.fromJson(Map<String, dynamic> json) {
//     itemName = json['item_name'];
//     itemType = json['item_type'];
//     itemId = json['item_id'];
//     itemPrice = json['item_price'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['item_name'] = this.itemName;
//     data['item_type'] = this.itemType;
//     data['item_id'] = this.itemId;
//     data['item_price'] = this.itemPrice;
//     return data;
//   }
// }
//
// class LabModel {
//   int? labId;
//   String? labName;
//   String? labEmail;
//   String? labMobile;
//   String? labCity;
//   String? labProfile;
//   String? address;
//   String? latitude;
//   String? longitude;
//   LabDetailModel? labDetailModel;
//   int? rating;
//   List<TestPriceModel>? testPricesList;
//   int? totalPrice;
//
//   LabModel(
//       {this.labId,
//         this.labName,
//         this.labEmail,
//         this.labMobile,
//         this.labCity,
//         this.labProfile,
//         this.address,
//         this.latitude,
//         this.longitude,
//         this.labDetailModel,
//         this.rating,
//         this.totalPrice,
//         this.testPricesList});
//
//   LabModel.fromJson(Map<String, dynamic> json) {
//     labId = json['lab_id'];
//     labName = json['lab_name'];
//     labEmail = json['lab_email'];
//     labMobile = json['lab_mobile'];
//     labCity = json['lab_city'];
//     labProfile = json['lab_profile'];
//     address = json['address'];
//     latitude = json['latitude'];
//     longitude = json['longitude'];
//     labDetailModel = json['lab_details'] != null
//         ? new LabDetailModel.fromJson(json['lab_details'])
//         : null;
//     rating = json['rating'];
//     if (json['test_prices'] != null) {
//       testPricesList = <TestPriceModel>[];
//       json['test_prices'].forEach((v) {
//         testPricesList!.add(new TestPriceModel.fromJson(v));
//       });
//     }
//     totalPrice = json['total_price'];
//
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['lab_id'] = this.labId;
//     data['lab_name'] = this.labName;
//     data['lab_email'] = this.labEmail;
//     data['lab_mobile'] = this.labMobile;
//     data['lab_city'] = this.labCity;
//     data['lab_profile'] = this.labProfile;
//     data['address'] = this.address;
//     data['latitude'] = this.latitude;
//     data['longitude'] = this.longitude;
//     if (this.labDetailModel != null) {
//       data['lab_details'] = this.labDetailModel!.toJson();
//     }
//     data['rating'] = this.rating;
//     if (this.testPricesList != null) {
//       data['test_prices'] = this.testPricesList!.map((v) => v.toJson()).toList();
//     }
//     data['total_price'] = this.totalPrice;
//     return data;
//   }
//
// }
//
// class LabDetailModel {
//   int? id;
//   int? userId;
//   String? labOwner;
//   String? labDescription;
//   String? labOpenTime;
//   String? labCloseTime;
//   String? labTimingJson;
//   String? labBannerImg;
//   int? status;
//   String? createdDate;
//   List<Days>? daysList;
//
//   LabDetailModel(
//       {this.id,
//         this.userId,
//         this.labOwner,
//         this.labDescription,
//         this.labOpenTime,
//         this.labCloseTime,
//         this.labTimingJson,
//         this.labBannerImg,
//         this.status,
//         this.daysList,
//         this.createdDate});
//
//   LabDetailModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     userId = json['user_id'];
//     labOwner = json['lab_owner'];
//     labDescription = json['lab_description'];
//     labOpenTime = json['lab_open_time'];
//     labCloseTime = json['lab_close_time'];
//     labTimingJson = json['lab_timing_json'];
//     labBannerImg = json['lab_banner_img'];
//     status = json['status'];
//     createdDate = json['created_date'];
//     if (json['days'] != null) {
//       daysList = <Days>[];
//       json['days'].forEach((v) {
//         daysList!.add(new Days.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['user_id'] = this.userId;
//     data['lab_owner'] = this.labOwner;
//     data['lab_description'] = this.labDescription;
//     data['lab_open_time'] = this.labOpenTime;
//     data['lab_close_time'] = this.labCloseTime;
//     data['lab_timing_json'] = this.labTimingJson;
//     data['lab_banner_img'] = this.labBannerImg;
//     data['status'] = this.status;
//     data['created_date'] = this.createdDate;
//     if (this.daysList != null) {
//       data['days'] = this.daysList!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class TestPriceModel {
//   int? id;
//   String? name;
//   int? price;
//
//   TestPriceModel({this.id, this.name, this.price});
//
//   TestPriceModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     price = json['price'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['name'] = this.name;
//     data['price'] = this.price;
//     return data;
//   }
// }
//
// class Days {
//   String? name;
//   String? fromTime;
//   String? toTime;
//   bool? status;
//
//   Days({this.name, this.fromTime, this.toTime, this.status});
//
//   Days.fromJson(Map<String, dynamic> json) {
//     name = json['name'];
//     fromTime = json['from_time'];
//     toTime = json['to_time'];
//     status = json['status'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['name'] = this.name;
//     data['from_time'] = this.fromTime;
//     data['to_time'] = this.toTime;
//     data['status'] = this.status;
//     return data;
//   }
// }