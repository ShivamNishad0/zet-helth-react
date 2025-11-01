class ReviewRatingModel {
  bool? status;
  String? message;
  List<GetRating>? getRating;
  int? totalCount;
  List<RatingList>? ratingList;

  ReviewRatingModel(
      {this.status,
      this.message,
      this.getRating,
      this.totalCount,
      this.ratingList});

  ReviewRatingModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['get_rating'] != null) {
      getRating = <GetRating>[];
      json['get_rating'].forEach((v) {
        getRating!.add(GetRating.fromJson(v));
      });
    }
    totalCount = json['totalCount'];
    if (json['rating_list'] != null) {
      ratingList = <RatingList>[];
      json['rating_list'].forEach((v) {
        ratingList!.add(RatingList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (getRating != null) {
      data['get_rating'] = getRating!.map((v) => v.toJson()).toList();
    }
    data['totalCount'] = totalCount;
    if (ratingList != null) {
      data['rating_list'] = ratingList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetRating {
  int? rating;
  int? count;

  GetRating({this.rating, this.count});

  GetRating.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating'] = rating;
    data['count'] = count;
    return data;
  }
}

class RatingList {
  int? id;
  String? userName;
  String? userProfile;
  int? rating;
  String? review;
  String? createdDate;

  RatingList(
      {this.id,
      this.userName,
      this.userProfile,
      this.rating,
      this.review,
      this.createdDate});

  RatingList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userName = json['user_name'];
    userProfile = json['user_profile'];
    rating = json['rating'];
    review = json['review'];
    createdDate = json['created_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_name'] = userName;
    data['user_profile'] = userProfile;
    data['rating'] = rating;
    data['review'] = review;
    data['created_date'] = createdDate;
    return data;
  }
}
