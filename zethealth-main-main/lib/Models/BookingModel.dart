import 'LabModel.dart';

class BookingModel {
  String? bookingName;
  int? id;
  int? userId;
  int? labId;
  int? boyId;
  String? bookingNo;
  int? bookingById;
  String? pickupAddress;
  String? deliveryAddress;
  String? fromLatitude;
  String? fromLongitude;
  String? toLatitude;
  String? toLongitude;
  String? patientName;
  String? patientMobile;
  String? bookingJson;
  String? bookingDate;
  String? bookingTime;
  String? bookingSlot;
  int? kilometer;
  int? labRating;
  int? isOriginal;
  String? bookingType;
  String? bookingStatus;
  String? bookingFor;
  String? createdDate;
  String? labName;
  String? boyName;
  String? boyNumber;
  String? paymentStatus;
  String? totalPayableAmount;
  LabDetailModel? labDetailModel;

  BookingModel({
    this.bookingName,
    this.id,
    this.userId,
    this.labId,
    this.boyId,
    this.bookingNo,
    this.bookingById,
    this.pickupAddress,
    this.deliveryAddress,
    this.fromLatitude,
    this.fromLongitude,
    this.toLatitude,
    this.toLongitude,
    this.patientName,
    this.patientMobile,
    this.bookingJson,
    this.bookingDate,
    this.bookingTime,
    this.bookingSlot,
    this.kilometer,
    this.labRating,
    this.isOriginal,
    this.bookingType,
    this.bookingStatus,
    this.bookingFor,
    this.createdDate,
    this.labName,
    this.boyName,
    this.boyNumber,
    this.paymentStatus,
    this.totalPayableAmount,
    this.labDetailModel,
  });

  BookingModel.fromJson(Map<String, dynamic> json) {
    bookingName = json['booking_name'];
    id = json['id'];
    userId = json['user_id'];
    labId = json['lab_id'];
    boyId = json['boy_id'];
    bookingNo = json['booking_no'];
    bookingById = json['booking_by_id'];
    pickupAddress = json['pickup_address'];
    deliveryAddress = json['delivery_address'];
    fromLatitude = json['from_latitude'];
    fromLongitude = json['from_longitude'];
    toLatitude = json['to_latitude'];
    toLongitude = json['to_longitude'];
    patientName = json['patient_name'];
    patientMobile = json['patient_mobile'];
    bookingJson = json['booking_json'];
    bookingDate = json['booking_date'];
    bookingTime = json['booking_time'];
    bookingSlot = json['booking_slot'];
    kilometer = json['kilometer'];
    labRating = json['lab_rating'];
    isOriginal = json['is_original'];
    bookingType = json['booking_type'];
    bookingStatus = json['booking_status'];
    bookingFor = json['booking_for'];
    createdDate = json['created_date'];
    labName = json['lab_name'];
    boyName = json['boy_name'];
    boyNumber = json['boy_number'];
    paymentStatus = json['payment_status'];
    totalPayableAmount = json['total_payable_amount'].toString();
    labDetailModel = json['lab_details'] != null ? LabDetailModel.fromJson(json['lab_details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_name'] = bookingName;
    data['id'] = id;
    data['user_id'] = userId;
    data['lab_id'] = labId;
    data['boy_id'] = boyId;
    data['booking_no'] = bookingNo;
    data['booking_by_id'] = bookingById;
    data['pickup_address'] = pickupAddress;
    data['delivery_address'] = deliveryAddress;
    data['from_latitude'] = fromLatitude;
    data['from_longitude'] = fromLongitude;
    data['to_latitude'] = toLatitude;
    data['to_longitude'] = toLongitude;
    data['patient_name'] = patientName;
    data['patient_mobile'] = patientMobile;
    data['booking_json'] = bookingJson;
    data['booking_date'] = bookingDate;
    data['booking_time'] = bookingTime;
    data['booking_slot'] = bookingSlot;
    data['kilometer'] = kilometer;
    data['lab_rating'] = labRating;
    data['booking_type'] = bookingType;
    data['booking_status'] = bookingStatus;
    data['booking_for'] = bookingFor;
    data['created_date'] = createdDate;
    data['lab_name'] = labName;
    data['boy_name'] = boyName;
    data['boy_number'] = boyNumber;
    data['payment_status'] = paymentStatus;
    data['total_payable_amount'] = totalPayableAmount;
    if (labDetailModel != null) {
      data['lab_details'] = labDetailModel!.toJson();
    }
    return data;
  }

}