import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Screens/DrawerView/NavigationDrawerView.dart';

import '../Helper/AssetHelper.dart';
import 'LocationPermissionScreen.dart';
import 'WelcomeScreen/WelcomeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  GetStorage getStorage = GetStorage();
  Location location = Location();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showWelcomeScreen();
    });
    // getCurrentLocation();
    // Future.delayed(const Duration(seconds: 2), () => requestLocationPermission());
  }

  Future<void> showWelcomeScreen() async {
    await Future.delayed(const Duration(seconds: 2)); // 2 seconds splash duration

    bool alreadyShown = AppConstants().isWelcomeScreenShown();

    if (!alreadyShown) {
      await Get.to(() => WelcomeScreen(),
        transition: Transition.upToDown,
        duration: const Duration(milliseconds: 400),
      );
      // await AppConstants().loadWithCanBack(WelcomeScreen());
      // await AppConstants().markWelcomeScreenAsShown();
    }

    await fetchCurrentLocationAndPostalCode();
  }

   Future<void> fetchCurrentLocationAndPostalCode() async {
    print('=== FETCHING CURRENT LOCATION AND POSTAL CODE ===');
    
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // If user doesn't enable location service, proceed without location
        _goToLocationPermissionScreen();
        return;
      }
    }
    
    await checkLocationPermission();
  }


/*
  Future<void> requestLocationPermission() async {
    final PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus == PermissionStatus.granted) {
      getLocation();
    }
    else {
      AppConstants().getStorage.write(AppConstants.CURRENT_LOCATION, "Bengaluru");
      AppConstants().loadWithCanNotAllBack(const NavigationDrawerView());
    }
  }

  Future<void> getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String address = placemarks[0].locality ?? 'Unknown';
      AppConstants().getStorage.write(AppConstants.CURRENT_LOCATION, address);
      AppConstants().loadWithCanNotAllBack(NavigationDrawerView());
    } catch (e) {
      print('Error getting location: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error Getting Location'),
            content: Text('Failed to get location. Please try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }*/

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // If user doesn't enable location service, proceed without location
        // _proceedWithoutLocation();
        // If user doesn’t enable → go to location screen
        _goToLocationPermissionScreen();
        return;
      }
    }
    checkLocationPermission();
  }

   Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      _goToLocationPermissionScreen();
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      _goToLocationPermissionScreen();
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await _getCurrentLocationData();
    }
  }

  Future<void> _getCurrentLocationData() async {
    try {
      print('=== GETTING FRESH LOCATION DATA ===');
      
      // Get fresh position data
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
      );
      
      // Get fresh placemarks data
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude, 
        position.longitude,
      );
      
      if (placemarks.isEmpty) {
        print('No placemarks found, using default location');
        await _proceedWithoutLocation();
        return;
      }
      
      geo.Placemark placemark = placemarks[0];
      
      // Extract location details
      String locality = placemark.locality ?? '';
      String subLocality = placemark.subLocality ?? '';
      String administrativeArea = placemark.administrativeArea ?? '';
      String country = placemark.country ?? '';
      String? postalCode = placemark.postalCode;
      
      // Create address components
      List<String> addressParts = [];
      if (subLocality.isNotEmpty) addressParts.add(subLocality);
      if (locality.isNotEmpty) addressParts.add(locality);
      if (administrativeArea.isNotEmpty) addressParts.add(administrativeArea);
      if (country.isNotEmpty) addressParts.add(country);
      
      String fullAddress = addressParts.join(', ');
      String cityName = locality.isNotEmpty ? locality : administrativeArea.isNotEmpty ? administrativeArea : 'Unknown';
      
      // Log the fresh location details
      print('=== FRESH LOCATION DETAILS ===');
      print('Latitude: ${position.latitude}');
      print('Longitude: ${position.longitude}');
      print('Full Address: $fullAddress');
      print('City: $cityName');
      print('Fresh Postal Code: $postalCode');
      print('Sub Locality: $subLocality');
      print('Administrative Area: $administrativeArea');
      print('Country: $country');
      print('Timestamp: ${DateTime.now()}');
      print('=============================');
      
      // Always store fresh data (overwrite any existing data)
      AppConstants().getStorage.write(AppConstants.CURRENT_LOCATION, cityName);
      AppConstants().getStorage.write(AppConstants.FULL_ADDRESS, fullAddress);
      
      // Always update postal code if available
      if (postalCode != null && postalCode.isNotEmpty) {
        AppConstants().getStorage.write(AppConstants.CURRENT_PINCODE, postalCode);
        print('✅ Postal code updated: $postalCode');
      } else {
        // If no postal code found, try to get it from previous storage or use default
        String? storedPincode = AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE);
        if (storedPincode == null) {
          print('⚠️ No postal code found, using default');
          AppConstants().getStorage.write(AppConstants.CURRENT_PINCODE, '560001'); // Default fallback
        }
      }
      
      // Handle address setup and navigate
      await _handleInitialAddressSetup();
      
      // Navigate to main screen
      AppConstants().loadWithCanNotAllBack(const NavigationDrawerView());
      
    } catch (e) {
      print('❌ Error fetching location: $e');
      await _proceedWithoutLocation();
    }
  }

  void _goToLocationPermissionScreen() {
    AppConstants().loadWithCanNotAllBack(const LocationPermissionScreen());
  }

  Future<void> _handleInitialAddressSetup() async {
    print('=== HANDLING ADDRESS SETUP ===');
    
    if (checkLogin()) {
      print('User is logged in, fetching saved addresses...');
      await AppConstants().fetchUserAddressesAfterLogin();
    } else {
      print('User is not logged in, using current fresh location');
      String currentLocation = AppConstants().getStorage.read(AppConstants.CURRENT_LOCATION) ?? 'Unknown';
      String fullAddress = AppConstants().getStorage.read(AppConstants.FULL_ADDRESS) ?? currentLocation;
      String pincode = AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE) ?? 'Unknown';
      print('Fresh location data - City: $currentLocation, Pincode: $pincode');
    }
    
    print('================================');
  }

Future<void> _proceedWithoutLocation() async {
    print('=== PROCEEDING WITHOUT LOCATION ===');
    
    // Check if we have existing data, otherwise use defaults
    String existingLocation = AppConstants().getStorage.read(AppConstants.CURRENT_LOCATION) ?? "Bengaluru";
    String existingAddress = AppConstants().getStorage.read(AppConstants.FULL_ADDRESS) ?? "Bengaluru, Karnataka, India";
    String existingPincode = AppConstants().getStorage.read(AppConstants.CURRENT_PINCODE) ?? "560001";
    
    print('Using existing/stored data:');
    print('Location: $existingLocation');
    print('Address: $existingAddress');
    print('Pincode: $existingPincode');
    
    // Handle initial address setup
    await _handleInitialAddressSetup();
    
    // Navigate to main app
    AppConstants().loadWithCanNotAllBack(const NavigationDrawerView());
    
    print('====================================');
  }
  
  void showSettingsRedirectDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Location Permission"),
        content: const Text(
            "Location permission helps us provide better services. You can continue without it or enable it in settings."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _proceedWithoutLocation();
            },
            child: const Text("Continue Without Location"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              bool opened = await Geolocator.openAppSettings();
              if (opened) {
                await Future.delayed(const Duration(seconds: 1));
                checkLocationPermission();
              } else {
                _proceedWithoutLocation();
              }
            },
            child: const Text("Enable Location"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned(
            top: 0,
            left: 0,
            child: SvgPicture.asset(
              splashHeaderImg,
            )),
        Positioned(
            right: 0,
            bottom: 0,
            child: SvgPicture.asset(
              splashFooterImg,
            )),
        Center(child: Image.asset(appLogo, width: 183.w, height: 110.h)),
      ],
    ));
  }
}
