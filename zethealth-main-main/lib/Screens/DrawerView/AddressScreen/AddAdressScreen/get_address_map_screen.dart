import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zet_health/CommonWidget/CustomButton.dart';
import 'package:zet_health/CommonWidget/CustomWidgets.dart';
import 'package:zet_health/Helper/StyleHelper.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../../../Helper/AppConstants.dart';
import '../../../../Helper/AssetHelper.dart';
import '../../../../Helper/ColorHelper.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../../Models/UserDetailModel.dart';
import '../../../../Models/auto_search_model.dart';
import '../../../BookingScreen/MapScreen/Repo.dart';

class GetAddressMapScreen extends StatefulWidget {
  const GetAddressMapScreen({super.key, required this.callBack});
  final Function(Map<String, dynamic>) callBack;
  @override
  State<GetAddressMapScreen> createState() => _GetAddressMapScreenState();
}

class _GetAddressMapScreenState extends State<GetAddressMapScreen> {
  Rx<MapType> currentMapType = MapType.normal.obs;
  GoogleMapController? googleMapController;
  Location location = Location();
  Marker? _marker;
  RxString selectAddress = ''.obs;
  RxString displayAddress = ''.obs;
  RxString pinCode = ''.obs;
  RxString city = ''.obs;
  RxString houseNo = ''.obs;
  RxString area = ''.obs;
  RxString landmark = ''.obs;
  RxDouble lat = 0.0.obs;
  RxDouble long = 0.0.obs;
  Rx<LatLng> currentCameraPosition = const LatLng(22.2871, 70.7925).obs;
  Rx<UserDetailModel> userModel = AppConstants().getUserDetails().obs;

  Future<void> onMapCreated(GoogleMapController controller) async {
    googleMapController = controller;
    try {
      LocationData locationData = await location.getLocation();

      if (locationData.latitude != null || locationData.longitude != null) {
        _setMarker(LatLng(locationData.latitude!, locationData.longitude!));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getAddress(double? late, double? lang) async {
    if (late == null || lang == null) return "";
    var address = await geo.placemarkFromCoordinates(late, lang);

    final placemark = address[0];

    // 🔍 LOG THE PLACEMARK STRUCTURE
    debugPrint('🔍 Full Placemark:');
    debugPrint('name: ${placemark.name}');
    debugPrint('street: ${placemark.street}');
    debugPrint('thoroughfare: ${placemark.thoroughfare}');
    debugPrint('subThoroughfare: ${placemark.subThoroughfare}');
    debugPrint('subLocality: ${placemark.subLocality}');
    debugPrint('locality: ${placemark.locality}');
    debugPrint('subAdministrativeArea: ${placemark.subAdministrativeArea}');
    debugPrint('administrativeArea: ${placemark.administrativeArea}');
    debugPrint('postalCode: ${placemark.postalCode}');
    debugPrint('country: ${placemark.country}');
    debugPrint('isoCountryCode: ${placemark.isoCountryCode}');
    debugPrint('latitude: $late');
    debugPrint('longitude: $lang');

    // Build complete address for display and selection
    List<String> completeAddressParts = [];
    List<String> selectAddressParts = [];

    // Add street/name (house number equivalent)
    if (placemark.street != null && placemark.street!.isNotEmpty) {
      completeAddressParts.add(placemark.street!);
      selectAddressParts.add(placemark.street!);
    } else if (placemark.name != null && placemark.name!.isNotEmpty) {
      completeAddressParts.add(placemark.name!);
      selectAddressParts.add(placemark.name!);
    }

    // Add thoroughfare if different from street
    if (placemark.thoroughfare != null && 
        placemark.thoroughfare!.isNotEmpty && 
        placemark.thoroughfare != placemark.street) {
      completeAddressParts.add(placemark.thoroughfare!);
      selectAddressParts.add(placemark.thoroughfare!);
    }

    // Add subLocality (area/sector)
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      completeAddressParts.add(placemark.subLocality!);
    }

    // Add locality (city)
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      completeAddressParts.add(placemark.locality!);
    }

    // Add subAdministrativeArea if available
    if (placemark.subAdministrativeArea != null && placemark.subAdministrativeArea!.isNotEmpty) {
      completeAddressParts.add(placemark.subAdministrativeArea!);
    }

    // Add administrativeArea (state)
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      completeAddressParts.add(placemark.administrativeArea!);
    }

    // Add postal code
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      completeAddressParts.add(placemark.postalCode!);
    }

    // Add country
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      completeAddressParts.add(placemark.country!);
    }

    // Set the formatted addresses
    selectAddress.value = selectAddressParts.join(', ');
    displayAddress.value = completeAddressParts.join(', ');
    
    // Set individual components for form fields
    pinCode.value = placemark.postalCode ?? "";
    city.value = placemark.locality ?? "";
    
    // Extract house number (from street, name, or subThoroughfare)
    houseNo.value = "";
    if (placemark.subThoroughfare != null && placemark.subThoroughfare!.isNotEmpty) {
      houseNo.value = placemark.subThoroughfare!;
    } else if (placemark.name != null && placemark.name!.isNotEmpty) {
      // If name looks like a house number (contains digits), use it
      if (RegExp(r'\d').hasMatch(placemark.name!)) {
        houseNo.value = placemark.name!;
      }
    }
    
    // Extract area (from subLocality or thoroughfare)
    area.value = "";
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      area.value = placemark.subLocality!;
    } else if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
      area.value = placemark.thoroughfare!;
    }
    
    // Extract landmark (from name if it's not used as house number, or thoroughfare)
    landmark.value = "";
    if (placemark.name != null && placemark.name!.isNotEmpty && placemark.name != houseNo.value) {
      landmark.value = placemark.name!;
    } else if (placemark.thoroughfare != null && 
               placemark.thoroughfare!.isNotEmpty && 
               placemark.thoroughfare != area.value) {
      landmark.value = placemark.thoroughfare!;
    }
    
    lat.value = late;
    long.value = lang;
    
    // 🔍 Debug log extracted components
    debugPrint('📍 Extracted Components:');
    debugPrint('Complete Address: ${displayAddress.value}');
    debugPrint('Select Address: ${selectAddress.value}');
    debugPrint('House No: ${houseNo.value}');
    debugPrint('Area: ${area.value}');
    debugPrint('Landmark: ${landmark.value}');
    debugPrint('City: ${city.value}');
    debugPrint('Pin Code: ${pinCode.value}');
  }

  getAddressFromAddress(String address) async {
    try {
      var latLong = await geo.locationFromAddress(address);
      LatLng latLng = LatLng(latLong[0].latitude, latLong[0].longitude);
      _setMarker(latLng);
    } catch (e) {
      e.toString();
    }
  }

  void _setMarker(LatLng location) {
    setState(() {
      _marker = Marker(
        markerId: const MarkerId('selected_location'),
        position: location,
      );
      currentCameraPosition.value =
          LatLng(location.latitude, location.longitude);
      googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: currentCameraPosition.value, zoom: 18.0)));
      getAddress(location.latitude, location.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              GoogleMap(
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                tiltGesturesEnabled: true,
                mapType: currentMapType.value,
                initialCameraPosition: CameraPosition(
                    target: currentCameraPosition.value, zoom: 18.0),
                onMapCreated: onMapCreated,
                onTap: (LatLng location) {
                  _setMarker(location);
                },
                markers: Set.of((_marker != null) ? [_marker!] : []),
              ),
              Positioned(
                top: 15.h,
                left: 15.w,
                right: 15.w,
                child: SizedBox(
                  width: Get.width,
                  child: Row(
                    children: [
                      CustomSquareButton(
                        icon: backArrow,
                        rightMargin: 10.w,
                        onTap: () => Get.back(),
                      ),
                      Expanded(
                        child: autoComplete(),
                      ),
                      CustomSquareButton(
                        icon: closeIcon,
                        iconColor: whiteColor,
                        leftMargin: 10.w,
                        onTap: () {
                          setState(() {
                            placeController = TextEditingController();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 110,
                right: 7,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () async {
                    LocationData locationData = await location.getLocation();
                    if (locationData.latitude != null && locationData.longitude != null) {
                      LatLng latLng =
                      LatLng(locationData.latitude!, locationData.longitude!);
                      _setMarker(latLng);
                      googleMapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(latLng, 18),
                      );
                    }
                  },
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
          elevation: 5,
          backgroundColor: primaryColor,
          onPressed: () {
            currentMapType.value = currentMapType.value == MapType.normal
                ? MapType.satellite
                : MapType.normal;
          },
          child: const Icon(Icons.layers, color: whiteColor)),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PaddingHorizontal15(
              top: 5.h,
              bottom: 5.h,
              child: Text(displayAddress.value, style: semiBoldBlack_15)),
          CustomButton(
            bottomMargin: MediaQuery.of(context).viewPadding.bottom > 15 ? 50.h : 20.h,
            horizontalMargin: 15.w,
            text: 'select'.tr.toUpperCase(),
            onTap: () {
              if (_marker != null) {
                Get.back();
                Map<String, dynamic> temp = {
                  'address': displayAddress.value, // Always use complete address
                  'latitude': lat.value.toStringAsFixed(6),
                  'longitude': long.value.toStringAsFixed(6),
                  'pincode': pinCode.value,
                  'city': city.value,
                  'house_no': houseNo.value,
                  'area': area.value,
                  'landmark': landmark.value,
                };
                // 🔍 Debug log to verify all data
                debugPrint("📍 Map Callback Data: $temp");
                widget.callBack.call(temp);
              } else {
                showToast(message: 'select_location'.tr);
              }
            },
          ),
        ],
      ),
    );
  }

  TextEditingController placeController = TextEditingController();
  FocusNode placeFocus = FocusNode();
  SuggestionsController<Description>? suggestionsController =
      SuggestionsController();

  Widget autoComplete() {
    return TypeAheadField<Description>(
      controller: placeController,
      focusNode: placeFocus,
      hideOnEmpty: true,
      hideOnError: true,
      suggestionsController: suggestionsController,
      suggestionsCallback: (String pattern) async {
        PredictionModel? predictionModel =
            await Repo.placeAutoComplete(placeInput: pattern);
        if (predictionModel != null) {
          return predictionModel.predictions!
              .where((element) => element.description!
                  .toLowerCase()
                  .contains(pattern.toLowerCase()))
              .toList();
        } else {
          return [];
        }
      },
      builder: (context, controller, focusNode) {
        return CustomTextFormField(
            controller: controller,
            hintText: 'search'.tr,
            focusNode: focusNode);
      },
      itemBuilder: (context, city) {
        return ListTile(
          title: Text("${city.structuredFormatting?.mainText}",
              style: semiBoldBlack_13),
          subtitle: city.structuredFormatting?.secondaryText != null
              ? Text("${city.structuredFormatting?.secondaryText}",
                  style: mediumGray_12)
              : null,
        );
      },
      onSelected: (city) {
        if (city.description != null) {
          placeFocus.unfocus();
          selectAddress.value = city.description.toString();
          displayAddress.value = city.description.toString();
          getAddressFromAddress(city.description.toString());
          placeController = TextEditingController();
        }
      },
    );
  }
}
