import 'package:zet_health/Models/UserDetailModel.dart';

class OfferModel {
  int? id;
  String? couponTitle;
  String? couponDescription;
  String? couponCode;
  String? discountType;
  int? discount;
  String? startDate;
  String? expiryDate;
  int? perUserReedemLimit;
  int? totalReedemLimit;
  int? totalRedemed;
  int? minimumAmount;
  int? maxAmount;
  String? validUserIds;
  String? timeRange;
  String? validDays;
  String? isExpired;
  String? couponType;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? anyId;
  String? itemName;
  String? itemType;
  UserDetailModel? labModel;


  OfferModel(
      {this.id,
        this.couponTitle,
        this.couponDescription,
        this.couponCode,
        this.discountType,
        this.discount,
        this.startDate,
        this.expiryDate,
        this.perUserReedemLimit,
        this.totalReedemLimit,
        this.totalRedemed,
        this.minimumAmount,
        this.maxAmount,
        this.validUserIds,
        this.timeRange,
        this.validDays,
        this.isExpired,
        this.couponType,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.anyId,
        this.itemType,
        this.itemName,
        this.labModel,
      });

  OfferModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    couponTitle = json['coupon_title'];
    couponDescription = json['coupon_description'];
    couponCode = json['coupon_code'];
    discountType = json['discount_type'];
    discount = json['discount'];
    startDate = json['start_date'];
    expiryDate = json['expiry_date'];
    perUserReedemLimit = json['per_user_reedem_limit'];
    totalReedemLimit = json['total_reedem_limit'];
    totalRedemed = json['total_redemed'];
    minimumAmount = json['minimum_amount'];
    maxAmount = json['max_amount'];
    validUserIds = json['valid_user_ids'];
    timeRange = json['time_range'];
    validDays = json['valid_days'];
    isExpired = json['is_expired'];
    couponType = json['coupon_type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    anyId = json['any_id'].toString();
    itemName = json['item_name'].toString();
    itemType = json['item_type'].toString();
    labModel = json['lab'] != null ? UserDetailModel.fromJson(json['lab']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['coupon_title'] = couponTitle;
    data['coupon_description'] = couponDescription;
    data['coupon_code'] = couponCode;
    data['discount_type'] = discountType;
    data['discount'] = discount;
    data['start_date'] = startDate;
    data['expiry_date'] = expiryDate;
    data['per_user_reedem_limit'] = perUserReedemLimit;
    data['total_reedem_limit'] = totalReedemLimit;
    data['total_redemed'] = totalRedemed;
    data['minimum_amount'] = minimumAmount;
    data['max_amount'] = maxAmount;
    data['valid_user_ids'] = validUserIds;
    data['time_range'] = timeRange;
    data['valid_days'] = validDays;
    data['is_expired'] = isExpired;
    data['coupon_type'] = couponType;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

}