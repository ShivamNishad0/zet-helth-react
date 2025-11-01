import 'dart:convert';
import 'package:get/get.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'package:zet_health/Models/CityModel.dart';
import 'package:zet_health/Models/StatusModel.dart';
import 'package:zet_health/Network/WebApiHelper.dart';
import '../../../CommonWidget/CustomWidgets.dart';
import '../../../Helper/database_helper.dart';
import '../../../Models/CartModel.dart';
import '../../../Models/LabModel.dart';
import '../../../Models/custom_cart_model.dart';
import '../../MyCartScreen/MyCartScreen.dart';
import '../HomeScreenController.dart';

class ItemDetailScreenController extends GetxController {

  CityModel? selectedCity;

  CustomCartModel customCartModel = CustomCartModel();
  String type = "";
  final DBHelper dbHelper = DBHelper();

  List<String> filterOptions = ['Sort By','Price','Name'];
  String selectedFilter = "Sort By";

  RxList<LabModel> testWiseLabList = <LabModel>[].obs;
  RxList<LabModel> filterList = <LabModel>[].obs;

  callTestWiseLabApi() {
    testWiseLabList.value = [];
    filterList.value = [];
    Map<String, dynamic> params = {
      "test_ids": type == AppConstants.test ? customCartModel.id.toString() : '',
      "city_name": selectedCity != null ? selectedCity!.id : "1",
      "package_names": type == AppConstants.package ? customCartModel.name.toString() : '',
      "profile_names": type == AppConstants.profile ? customCartModel.name.toString() : '',
      "sort_by": selectedFilter == "Sort By" ? "" : selectedFilter,
    };
    WebApiHelper().callFormDataPostApi(null, AppConstants.getLabListV2, params, true).then((response) {
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          if(statusModel.labList!.isNotEmpty) {
            testWiseLabList.addAll(statusModel.labList!);
            filterList.addAll(statusModel.labList!);
          }
        }
      }
    });
  }


  addToCartApi({required LabModel labModel}) {
    Map<String, dynamic> params = {
      "id": 0,
      "lab_id": labModel.labId!,
      "user_id": AppConstants().getStorage.read(AppConstants.USER_ID),
      "date_time": AppConstants().currentDateTimeApi(),
      "cart_json": jsonEncode({
        "price": labModel.totalPrice,
        "item": labModel.testPricesList
      }),
    };
    WebApiHelper().callFormDataPostApi(null, AppConstants.ADD_TO_CART_API, params, true).then((response) async {
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(jsonDecode(response));
        if(statusModel.status!) {
          await dbHelper.addToCartCart(cartModel : customCartModel);
          Get.until((route)=> route.isFirst);
          AppConstants().loadWithCanBack(const MyCartScreen());
          HomeScreenController homeScreenController = Get.put(HomeScreenController());
          homeScreenController.callHomeApi();
        }
        else {
          showToast(message: statusModel.message!);
        }
      }
    });
  }

  getCartApi({required LabModel labModel}) async {
    await WebApiHelper().callGetApi(null, AppConstants.GET_CART_API, true).then((response) async {
      if(response != null) {
        StatusModel statusModel = StatusModel.fromJson(response);
        if(statusModel.status!) {
          if(statusModel.cartList!=null && statusModel.cartList!.isNotEmpty) {
            if(statusModel.cartList![0].labId == labModel.labId){
              CartModel cartModel = CartModel.fromJson(json.decode(statusModel.cartList![0].cartJson!));
              bool flag = false;
              for(int i =0; i<cartModel.itemList!.length; i++){
                if(cartModel.itemList![i].id == customCartModel.id && cartModel.itemList![i].type == customCartModel.type){
                  flag = true;
                }
              }
              if(flag){
                Get.until((route)=> route.isFirst);
                AppConstants().loadWithCanBack(const MyCartScreen());
                HomeScreenController homeScreenController = Get.put(HomeScreenController());
                homeScreenController.callHomeApi();
              } else {
                // print(cartModel.itemList);
                labModel.testPricesList?.addAll(cartModel.itemList!);
                addToCartApi(labModel: labModel);
              }
            }
            else {
              Get.dialog(CommonDialog(
                title: 'warning'.tr,
                description: 'msg_add_this_item_previously_added_test_will_removed'.tr,
                tapNoText: 'cancel'.tr,
                tapYesText: 'confirm'.tr,
                onTapNo: ()=> Get.back(),
                onTapYes: () {
                  Get.back();
                  addToCartApi(labModel: labModel);
                },
              ));
            }
          }
          // else {
          //   addToCartApi(labModel: labModel);
          // }
        }
      }
    });
  }
}