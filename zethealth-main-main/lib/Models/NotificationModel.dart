class NotificationModel {
  int? notificationId;
  int? userId;
  int? fromId;
  int? toId;
  String? notificationTitle;
  String? notificationMessage;
  String? type;
  int? anyId;
  int? isRead;
  String? imagePath;
  int? notificationStatus;
  String? createdDate;

  NotificationModel(
      {this.notificationId,
      this.userId,
      this.fromId,
      this.toId,
      this.notificationTitle,
      this.notificationMessage,
      this.type,
      this.anyId,
      this.isRead,
      this.imagePath,
      this.notificationStatus,
      this.createdDate});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    notificationId = json['notification_id'];
    userId = json['user_id'];
    fromId = json['from_id'];
    toId = json['to_id'];
    notificationTitle = json['notification_title'];
    notificationMessage = json['notification_message'];
    type = json['type'];
    anyId = json['any_id'];
    isRead = json['is_read'];
    imagePath = json['image_path'];
    notificationStatus = json['notification_status'];
    createdDate = json['created_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notification_id'] = notificationId;
    data['user_id'] = userId;
    data['from_id'] = fromId;
    data['to_id'] = toId;
    data['notification_title'] = notificationTitle;
    data['notification_message'] = notificationMessage;
    data['type'] = type;
    data['any_id'] = anyId;
    data['is_read'] = isRead;
    data['image_path'] = imagePath;
    data['notification_status'] = notificationStatus;
    data['created_date'] = createdDate;
    return data;
  }
}
