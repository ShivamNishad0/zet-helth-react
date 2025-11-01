import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/OfferModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';

class OfferScreenController extends GetxController {
  RxList<OfferModel> offerList = <OfferModel>[].obs;
  RxBool isLoading = false.obs;

  callGetOfferCouponApi({required String labId}) {
    isLoading.value = true;
    offerList.value = [];
    WebApiHelper()
        .callGetApi(null, '${AppConstants.GET_OFFER_COUPON_API}/$labId', true)
        .then((response) {
      isLoading.value = false;
      if (response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if (statusModel.status!) {
          if (statusModel.offerList!.isNotEmpty) {
            offerList.addAll(statusModel.offerList!);
          }
        }
      }
    });
  }
}
