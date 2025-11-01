import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/AddressListModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import '../../../Models/CityModel.dart';
import '../../HomeScreen/HomeScreenController.dart';

class AddressScreenController extends GetxController {
  RxList<AddressList> addressList = <AddressList>[].obs;
  RxBool isLoading = false.obs;
  Rx<AddressList?> selectedAddress = Rx<AddressList?>(null);
  Rx<AddressList> currentAddress = Rx<AddressList>(AddressList());
  RxList<CityModel> cityList = <CityModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize selected address from AppConstants
    selectedAddress.value = AppConstants().getSelectedAddress();
  }

  void updateSelectedAddress() {
    selectedAddress.value = AppConstants().getSelectedAddress();
  }

  getAddressListApi({Function()? onComplete}) {
    isLoading.value = true;
    addressList.value = [];
    WebApiHelper()
        .callGetApi(null, AppConstants.getAddressList, true)
        .then((response) {
      isLoading.value = false;
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if (statusModel.status!) {
          addressList.addAll(statusModel.addressList!);
        }
      }
      // Call the completion callback if provided
      if (onComplete != null) {
        onComplete();
      }
    });
  }

  addressDeleteApi({required String id}) {
    // Check if the address being deleted is the currently selected one
    AddressList? currentSelected = AppConstants().getSelectedAddress();
    bool isDeletingSelectedAddress = currentSelected?.id.toString() == id;
    
    print('🗑️ Deleting address with ID: $id');
    print('🗑️ Currently selected address ID: ${currentSelected?.id}');
    print('🗑️ Is deleting selected address: $isDeletingSelectedAddress');
    
    WebApiHelper()
        .callGetApi(null, '${AppConstants.addressDelete}/$id', true)
        .then((response) {
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if (statusModel.status!) {
          // Refresh the address list first
          getAddressListApi(onComplete: () {
            _handleAddressSelectionAfterDeletion(isDeletingSelectedAddress);
          });
        }
      }
    });
  }

  void _handleAddressSelectionAfterDeletion(bool wasSelectedAddressDeleted) {
    print('🔄 Handling address selection after deletion');
    print('🔄 Was selected address deleted: $wasSelectedAddressDeleted');
    print('🔄 Remaining addresses count: ${addressList.length}');
    
    if (wasSelectedAddressDeleted) {
      if (addressList.isNotEmpty) {
        // Select the first available address
        AddressList newSelectedAddress = addressList.first;
        AppConstants().setSelectedAddress(newSelectedAddress);
        selectedAddress.value = newSelectedAddress;
        
        print('✅ Auto-selected new address: ${newSelectedAddress.address}');
        print('✅ New selected address ID: ${newSelectedAddress.id}');
        
        // Update HomeScreen
        _updateHomeScreen();
      } else {
        // No addresses left, fetch current location
        print('📍 No addresses left, fetching current location...');
        _fetchCurrentLocationAsAddress();
      }
    } else {
      // Deleted address was not the selected one, just show success message
      AppConstants().showToast(
        'Address deleted successfully',
        color: Colors.green,
        seconds: 2,
      );
    }
  }

  void _fetchCurrentLocationAsAddress() {
    print('📍 Fetching current location to set as active address...');
    
    // Clear the current selected address
    AppConstants().clearSelectedAddress();
    selectedAddress.value = null;
    
    // Update HomeScreen to show "Fetching location..." or similar
    _updateHomeScreen();
    
    // Check location permissions and get current location
    _getCurrentLocation().then((position) {
      if (position != null) {
        _getAddressFromCoordinates(position.latitude, position.longitude);
      } else {
        // Fallback if location access fails
        _setFallbackAddress();
      }
    }).catchError((error) {
      print('❌ Error getting location: $error');
      _setFallbackAddress();
    });
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled');
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      
      print('📍 Current location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting current location: $e');
      return null;
    }
  }

  void _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        
        // Create a formatted address
        String formattedAddress = _formatPlacemarkAddress(placemark);
        
        // Create a temporary address object for current location
        AddressList currentLocationAddress = AddressList(
          id: 0, // Temporary ID for current location
          address: formattedAddress,
          houseNo: placemark.subThoroughfare ?? '',
          landmark: placemark.name ?? '',
          location: placemark.subLocality ?? placemark.thoroughfare ?? '',
          pincode: placemark.postalCode ?? '',
          city: placemark.locality ?? placemark.subAdministrativeArea ?? '',
          state: placemark.administrativeArea ?? '',
          latitude: latitude.toString(),
          longitude: longitude.toString(),
          addressType: 'Current Location',
        );
        
        // Set as selected address
        AppConstants().setSelectedAddress(currentLocationAddress);
        selectedAddress.value = currentLocationAddress;
        
        print('✅ Current location set as active address: $formattedAddress');
        
        // Update HomeScreen
        _updateHomeScreen();
      } else {
        _setFallbackAddress();
      }
    } catch (e) {
      print('❌ Error getting address from coordinates: $e');
      _setFallbackAddress();
    }
  }

  String _formatPlacemarkAddress(Placemark placemark) {
    List<String> addressParts = [];
    
    if (placemark.subThoroughfare?.isNotEmpty == true) addressParts.add(placemark.subThoroughfare!);
    if (placemark.thoroughfare?.isNotEmpty == true) addressParts.add(placemark.thoroughfare!);
    if (placemark.subLocality?.isNotEmpty == true) addressParts.add(placemark.subLocality!);
    if (placemark.locality?.isNotEmpty == true) addressParts.add(placemark.locality!);
    if (placemark.subAdministrativeArea?.isNotEmpty == true) addressParts.add(placemark.subAdministrativeArea!);
    if (placemark.administrativeArea?.isNotEmpty == true) addressParts.add(placemark.administrativeArea!);
    if (placemark.postalCode?.isNotEmpty == true) addressParts.add(placemark.postalCode!);
    if (placemark.country?.isNotEmpty == true) addressParts.add(placemark.country!);
    
    return addressParts.join(', ');
  }

  void _setFallbackAddress() {
    print('⚠️ Setting fallback address');
    
    // Create a fallback address
    AddressList fallbackAddress = AddressList(
      id: 0,
      address: 'Location not available',
      houseNo: '',
      landmark: '',
      location: '',
      pincode: '',
      city: 'Unknown',
      state: '',
      latitude: '0',
      longitude: '0',
      addressType: 'Default',
    );
    
    AppConstants().setSelectedAddress(fallbackAddress);
    selectedAddress.value = fallbackAddress;
    
    // Update HomeScreen
    _updateHomeScreen();
    
    // Show toast
    AppConstants().showToast(
      'Unable to fetch location. Please add an address manually.',
      color: Colors.red,
      seconds: 4,
    );
  }

  void _updateHomeScreen() {
    try {
      if (Get.isRegistered<HomeScreenController>()) {
        HomeScreenController homeScreenController = Get.find<HomeScreenController>();
        homeScreenController.updateDisplayAddress();
        print('🏠 HomeScreen updated after address deletion/selection');
      }
    } catch (e) {
      print('❌ Error updating HomeScreen: $e');
    }
  }
}
