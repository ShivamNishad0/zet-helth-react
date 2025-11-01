class SlotModel {
  int? slotId;
  int? labId;
  String? slotDate;
  String? slotJson;
  int? slotStatus;
  String? createdDate;
  List<SlotDetailsModel>? slotDetailsList;

  SlotModel(
      {this.slotId,
      this.labId,
      this.slotDate,
      this.slotJson,
      this.slotStatus,
      this.createdDate});

  SlotModel.fromJson(Map<String, dynamic> json) {
    slotId = json['slot_id'];
    labId = json['lab_id'];
    slotDate = json['slot_date'];
    slotJson = json['slot_json'];
    slotStatus = json['slot_status'];
    createdDate = json['created_date'];
    if (json['slot_details'] != null) {
      slotDetailsList = <SlotDetailsModel>[];
      json['slot_details'].forEach((v) {
        slotDetailsList!.add(SlotDetailsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['slot_id'] = slotId;
    data['lab_id'] = labId;
    data['slot_date'] = slotDate;
    data['slot_json'] = slotJson;
    data['slot_status'] = slotStatus;
    data['created_date'] = createdDate;
    if (slotDetailsList != null) {
      data['slot_details'] = slotDetailsList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SlotDetailsModel {
  String? time;
  bool? isAvailable;
  bool? isBooked;

  SlotDetailsModel({this.time, this.isAvailable, this.isBooked});

  SlotDetailsModel.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    isAvailable = json['is_available'];
    isBooked = json['is_booked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['is_available'] = isAvailable;
    data['is_booked'] = isBooked;
    return data;
  }
}
