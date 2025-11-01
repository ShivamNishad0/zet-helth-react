class WalletTransactionModel {
  bool? status;
  String? message;
  String? walletBalance;
  List<WalletTransaction>? walletTransaction;

  WalletTransactionModel({this.status, this.message, this.walletTransaction});

  WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    walletBalance = json['wallet_balance']?.toString();
    if (json['wallet_transaction'] != null) {
      walletTransaction = <WalletTransaction>[];
      json['wallet_transaction'].forEach((v) {
        walletTransaction!.add(WalletTransaction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['wallet_balance'] = walletBalance;
    if (walletTransaction != null) {
      data['wallet_transaction'] = walletTransaction!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WalletTransaction {
  String? id;
  String? userId;
  String? bookingId;
  String? bookingResponseId;
  String? prefix;
  String? type;
  String? amount;
  String? title;
  String? message;
  String? transactionDate;
  String? transactionResponse;
  String? razorpaySignature;
  String? razorpayOrderId;
  String? razorpayPaymentId;
  String? createdDate;
  String? updateAt;

  WalletTransaction({
    this.id,
    this.userId,
    this.bookingId,
    this.bookingResponseId,
    this.prefix,
    this.type,
    this.amount,
    this.title,
    this.message,
    this.transactionDate,
    this.transactionResponse,
    this.razorpaySignature,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.createdDate,
    this.updateAt
  });

  WalletTransaction.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = json['user_id']?.toString();
    bookingId = json['booking_id']?.toString();
    bookingResponseId = json['booking_response_id']?.toString();
    prefix = json['prefix']?.toString();
    type = json['type']?.toString();
    amount = json['amount']?.toString();
    title = json['title']?.toString();
    message = json['message']?.toString();
    transactionDate = json['transaction_date']?.toString();
    transactionResponse = json['transaction_response']?.toString();
    razorpaySignature = json['razorpay_signature']?.toString();
    razorpayOrderId = json['razorpay_order_id']?.toString();
    razorpayPaymentId = json['razorpay_payment_id']?.toString();
    createdDate = json['created_date']?.toString();
    updateAt = json['update_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['booking_id'] = bookingId;
    data['booking_response_id'] = bookingResponseId;
    data['prefix'] = prefix;
    data['type'] = type;
    data['amount'] = amount;
    data['title'] = title;
    data['message'] = message;
    data['transaction_date'] = transactionDate;
    data['transaction_response'] = transactionResponse;
    data['razorpay_signature'] = razorpaySignature;
    data['razorpay_order_id'] = razorpayOrderId;
    data['razorpay_payment_id'] = razorpayPaymentId;
    data['created_date'] = createdDate;
    data['update_at'] = updateAt;
    return data;
  }
}