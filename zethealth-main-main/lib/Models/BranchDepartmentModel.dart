class BranchDepartmentModel {
  bool? status;
  String? message;
  List<Data>? data;

  BranchDepartmentModel({this.status, this.message, this.data});

  BranchDepartmentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? departmentName;
  String? departmentUuid;
  bool? isActive;

  Data({this.departmentName, this.departmentUuid, this.isActive});

  Data.fromJson(Map<String, dynamic> json) {
    departmentName = json['department_name'];
    departmentUuid = json['department_uuid'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['department_name'] = departmentName;
    data['department_uuid'] = departmentUuid;
    data['is_active'] = isActive;
    return data;
  }
}
