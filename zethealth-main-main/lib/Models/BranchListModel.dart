class BranchListModel {
  bool? status;
  String? message;
  List<BranchData>? data;

  BranchListModel({this.status, this.message, this.data});

  BranchListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BranchData>[];
      json['data'].forEach((v) {
        data!.add(BranchData.fromJson(v));
      });
    }
  }
}

class BranchData {
  String? branchUuid;
  String? branchName;
  String? branchAddress;
  String? branchCity;
  String? branchState;
  String? branchPincode;
  List<String>? partnerEmailsActive;
  List<String>? partnerEmailsInactive;
  bool? isActive;

  BranchData({
    this.branchUuid,
    this.branchName,
    this.branchAddress,
    this.branchCity,
    this.branchState,
    this.branchPincode,
    this.partnerEmailsActive,
    this.partnerEmailsInactive,
    this.isActive,
  });

  BranchData.fromJson(Map<String, dynamic> json) {
    branchUuid = json['branch_uuid'];
    branchName = json['branch_name'];
    branchAddress = json['branch_address'];
    branchCity = json['branch_city'];
    branchState = json['branch_state'];
    branchPincode = json['branch_pincode'];
    isActive = json['is_active'];

    // ✅ Null-safe handling of optional lists
    partnerEmailsActive = json['partner_emails_active'] != null
        ? List<String>.from(json['partner_emails_active'])
        : [];

    partnerEmailsInactive = json['partner_emails_inactive'] != null
        ? List<String>.from(json['partner_emails_inactive'])
        : [];
  }
}
