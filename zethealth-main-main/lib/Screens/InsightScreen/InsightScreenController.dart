import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/UserDetailModel.dart';
import 'package:zet_health/Models/CategorizeValueModel.dart';
import 'package:zet_health/Screens/InsightScreen/InsightService.dart';

class Insightscreencontroller extends GetxController {
  Rx<UserDetailModel> userModel = AppConstants().getUserDetails().obs;
  RxBool isLogin = false.obs;

  /// Store API insights
  Rx<CategorizeValueResponse?> insights = Rx<CategorizeValueResponse?>(null);
  
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInsights();
  }

  Future<void> fetchInsights({bool forceRefresh = false}) async {
    if (isLoading.value && !forceRefresh) {
      return;
    }
    
    isLoading.value = true;
    
    try {
      // Load user details when controller initializes
      final user = AppConstants().getUserDetails();

      if (user != null) {
        userModel.value = user;

        print("📱 User Mobile Number: ${user.userMobile}");

        // Fetch insights from API
        await fetchUserInsights(user.userMobile.toString(), forceRefresh: forceRefresh);
      } else {
        print("⚠️ No user details found.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserInsights(String userId, {bool forceRefresh = false}) async {
    print("🔄 Fetching insights (forceRefresh: $forceRefresh)");
    
    final result = await InsightService.fetchInsights(userId);
    if (result != null) {
      insights.value = result;
      print("✅ Insights fetched successfully");
    } else {
      print("❌ Failed to fetch insights.");
      // If force refresh, ensure we clear any stale data
      if (forceRefresh) {
        insights.value = null;
      }
    }
  }
}