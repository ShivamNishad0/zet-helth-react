class ReportModel {
  int? id;
  String? folderName;
  List<Reports>? reportList;

  ReportModel({this.id, this.folderName, this.reportList});

  ReportModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    folderName = json['folder_name'];
    if (json['reports'] != null) {
      reportList = <Reports>[];
      json['reports'].forEach((v) {
        reportList!.add(Reports.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['folder_name'] = folderName;
    if (reportList != null) {
      data['reports'] = reportList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Reports {
  int? id;
  int? userId;
  int? bookingId;
  String? path;
  String? createdDate;
  String? folder;

  Reports(
      {this.id,
      this.userId,
      this.bookingId,
      this.path,
      this.createdDate,
      this.folder});

  Reports.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    bookingId = json['booking_id'];
    path = json['path'];
    createdDate = json['created_date'];
    folder = json['folder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['booking_id'] = bookingId;
    data['path'] = path;
    data['created_date'] = createdDate;
    data['folder'] = folder;
    return data;
  }
}
