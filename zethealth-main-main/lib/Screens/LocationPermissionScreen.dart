import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Helper/ColorHelper.dart';
import '../Helper/StyleHelper.dart';
import 'SplashScreen.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.deniedForever) {
      // permission = await Geolocator.requestPermission();
      AppConstants().showToast("Please enable location permission from app settings.", seconds: 2);
    }

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // ✅ Permission granted → go to Splash
      Get.offAll(() => const SplashScreen());
    }
    if (permission == LocationPermission.denied) {
      // ❌ Still denied → stay here
      AppConstants().showToast("Location permission is required to proceed.", seconds: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 📍 Top Image
            Expanded(
              flex: 3,
              child: Center(
                child: Image.asset(
                  "assets/images/location_map.png",
                  fit: BoxFit.contain,
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Please share your location",
                      textAlign: TextAlign.center,
                      style: semiBoldBlack_22,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "We need your location to provide better services.",
                      textAlign: TextAlign.center,
                      style: semiBoldGray_16,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => _requestPermission(context),
                        child: const Text(
                          "Enable device location",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
