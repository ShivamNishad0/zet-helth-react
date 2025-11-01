class AddressComponentDetail {
  final String? longName;
  final String? shortName;
  final List<String>? types;

  AddressComponentDetail({
    this.longName,
    this.shortName,
    this.types,
  });

  factory AddressComponentDetail.fromJson(Map<String, dynamic> json) {
    return AddressComponentDetail(
      longName: json['long_name'],
      shortName: json['short_name'],
      types: json['types'] != null ? List<String>.from(json['types']) : null,
    );
  }
}

class ResultsModel {
  final List<AddressComponentDetail>? addressComponents;
  final String? formattedAddress;
  final GeometryModel? geometry;

  ResultsModel({
    this.addressComponents,
    this.formattedAddress,
    this.geometry,
  });

  factory ResultsModel.fromJson(Map<String, dynamic> json) {
    return ResultsModel(
      addressComponents: (json['address_components'] as List<dynamic>?)?.map((e) => AddressComponentDetail.fromJson(e)).toList(),
      formattedAddress: json['formatted_address'],
      geometry: json['geometry'] != null ? GeometryModel.fromJson(json['geometry']) : null,
    );
  }
}

class GeometryModel {
  final LatlngModel? location;

  GeometryModel({
    this.location,
  });

  factory GeometryModel.fromJson(Map<String, dynamic> json) {
    return GeometryModel(
      location: json['location'] != null ? LatlngModel.fromJson(json['location']) : null,
    );
  }
}

class PlusCodeModel {
  final String? compoundCode;
  final String? globalCode;

  PlusCodeModel({
    this.compoundCode,
    this.globalCode,
  });

  factory PlusCodeModel.fromJson(Map<String, dynamic> json) {
    return PlusCodeModel(
      compoundCode: json['compound_code'],
      globalCode: json['global_code'],
    );
  }
}

class PlaceDetailModel {
  final PlusCodeModel? plusCode;
  final List<ResultsModel>? results;
  final String? status;

  PlaceDetailModel({
    this.plusCode,
    this.results,
    this.status,
  });

  factory PlaceDetailModel.fromJson(Map<String, dynamic> json) {
    return PlaceDetailModel(
      plusCode: json['plus_code'] != null ? PlusCodeModel.fromJson(json['plus_code']) : null,
      results: (json['results'] as List<dynamic>?)?.map((e) => ResultsModel.fromJson(e)).toList(),
      status: json['status'],
    );
  }
}

class LatlngModel {
  final double? lat;
  final double? lng;

  LatlngModel({
    this.lat,
    this.lng,
  });

  factory LatlngModel.fromJson(Map<String, dynamic> json) {
    return LatlngModel(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}

class Description {
  final String? description;
  final String? placeId;
  final StrucuredFormatting? structuredFormatting;

  Description({
    this.description,
    this.placeId,
    this.structuredFormatting,
  });

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      description: json['description'],
      placeId: json['place_id'],
      structuredFormatting: json['structured_formatting'] != null
          ? StrucuredFormatting.fromJson(json['structured_formatting'])
          : null,
    );
  }
}

class StrucuredFormatting {
  final String? mainText;
  final String? secondaryText;

  StrucuredFormatting({
    this.mainText,
    this.secondaryText,
  });

  factory StrucuredFormatting.fromJson(Map<String, dynamic> json) {
    return StrucuredFormatting(
      mainText: json['main_text'],
      secondaryText: json['secondary_text'],
    );
  }
}

class PredictionModel {
  final List<Description>? predictions;

  PredictionModel({
    this.predictions,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      predictions: (json['predictions'] as List<dynamic>?)?.map((e) => Description.fromJson(e)).toList(),
    );
  }
}