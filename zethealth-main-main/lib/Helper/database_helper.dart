import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:zet_health/Models/custom_cart_model.dart';
import '../CommonWidget/CustomWidgets.dart';
import '../Models/StatusModel.dart';
import '../Network/WebApiHelper.dart';
import 'AppConstants.dart';

class DBHelper {
  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

Future<Database> initDatabase() async {
  String databasesPath = await getDatabasesPath();
  String dbPath = join(databasesPath, 'e_commerce.db');
  return await openDatabase(dbPath, version: 2, 
    onCreate: onCreate,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Add new columns for version 2
        await db.execute('ALTER TABLE cart_master ADD COLUMN item_detail TEXT');
        await db.execute('ALTER TABLE cart_master ADD COLUMN profiles_detail TEXT');
      }
    }
  );
}

  Future<void> onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE cart_master (
        cart_id INTEGER PRIMARY KEY AUTOINCREMENT, 
        id INTEGER,
        name TEXT,
        type TEXT,
        price TEXT,
        city_id TEXT,
        lab_id TEXT,
        lab_name TEXT,
        lab_address TEXT,
        item_detail TEXT,
        profiles_detail TEXT   
      )''');
  }

  Future<bool> insertRecordCart({required CustomCartModel cartModel}) async {
    if (AppConstants().getStorage.read(AppConstants.isCartExist)) {
      Get.dialog(CommonDialog(
        title: 'warning'.tr,
        description: 'msg_add_this_item_previously_added_test_will_removed'.tr,
        tapNoText: 'cancel'.tr,
        tapYesText: 'confirm'.tr,
        onTapNo: () => Get.back(),
        onTapYes: () {
          Get.back();
          WebApiHelper()
              .callGetApi(null, AppConstants.GET_CLEAR_CART_API, true)
              .then((response) async {
            if (response != null) {
              EasyLoading.dismiss();
              StatusModel statusModel = StatusModel.fromJson(response);
              if (statusModel.status!) {
                addToCartCart(cartModel: cartModel);
                AppConstants()
                    .getStorage
                    .write(AppConstants.isCartExist, false);
              }
            }
          });
        },
      ));
    } else {
      addToCart(cartModel: cartModel);
    }
    return true;
  }

  Future<bool> addToCart({required CustomCartModel cartModel}) async {
    if(AppConstants().getStorage.read(AppConstants.isCartExist)){
      WebApiHelper()
          .callGetApi(null, AppConstants.GET_CLEAR_CART_API, true)
          .then((response) async {
        if (response != null) {
          EasyLoading.dismiss();
          StatusModel statusModel = StatusModel.fromJson(response);
          if (statusModel.status!) {
            addToCartCart(cartModel: cartModel);
            AppConstants()
                .getStorage
                .write(AppConstants.isCartExist, false);
          }
        }
      });
    }
    else {
      addToCartCart(cartModel: cartModel);
    }
    return true;
  }

Future<bool> addToCartCart({required CustomCartModel cartModel}) async {
  final dbClient = await db;

  // Convert itemDetail and profilesDetail to JSON strings
  String itemDetailJson = '';
  if (cartModel.itemDetail != null) {
    itemDetailJson = jsonEncode(cartModel.itemDetail!.map((e) => e.toJson()).toList());
    debugPrint("📦 itemDetail to JSON - Count: ${cartModel.itemDetail!.length}");
    debugPrint("📦 itemDetail JSON: $itemDetailJson");
  } else {
    debugPrint("📦 itemDetail is NULL");
  }

  String profilesDetailJson = '';
  if (cartModel.profilesDetail != null) {
    profilesDetailJson = jsonEncode(cartModel.profilesDetail!.map((e) => e.toJson()).toList());
    debugPrint("📦 profilesDetail to JSON - Count: ${cartModel.profilesDetail!.length}");
    debugPrint("📦 profilesDetail JSON: $profilesDetailJson");
  } else {
    debugPrint("📦 profilesDetail is NULL");
  }

  final productJson = {
    'id': cartModel.id,
    'name': cartModel.name,
    'type': cartModel.type,
    'price': cartModel.price,
    'city_id': cartModel.cityId,
    'lab_id': cartModel.labId,
    'lab_name': cartModel.labName,
    'lab_address': cartModel.labAddress,
    'item_detail': itemDetailJson,
    'profiles_detail': profilesDetailJson,
  };

  debugPrint("🛒 Final productJson for DB: $productJson");

  final products = await dbClient.rawQuery(
      'SELECT * FROM cart_master WHERE id = ? AND type = ?',
      [cartModel.id, cartModel.type]);

  if (products.isNotEmpty) {
    int rowsAdded = await dbClient.update(
      'cart_master',
      productJson,
      where: 'id = ? AND type = ?',
      whereArgs: [cartModel.id, cartModel.type],
    );

    if (rowsAdded > 0) {
      debugPrint("🛒 Updated product in cart");
      await getCartCounter();
    }
    return rowsAdded > 0;
  } else {
    int rowsAdded = await dbClient.insert('cart_master', productJson);
    debugPrint("🛒 Inserted new product in cart, rows added: $rowsAdded");
    getCartCounter();
    return rowsAdded > 0;
  }
}

  Future<bool> checkRecordExist(
      {required String id, required String type}) async {
    final dbClient = await db;
    final products = await dbClient.rawQuery(
        'SELECT * FROM cart_master WHERE id = ? AND type = ?', [id, type]);
    return products.isNotEmpty;
  }

  getCartCounter() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('cart_master');
    AppConstants().getStorage.write(AppConstants.cartCounter, maps.length);
    AppConstants().getStorage.write(AppConstants.cartCounter, maps.length);
    debugPrint("🛒 Cart count updated: ${maps.length}");
  }

Future<List<CustomCartModel>> getCartList() async {
  final dbClient = await db;
  final List<Map<String, dynamic>> maps = await dbClient.query('cart_master');
  
  debugPrint("🛒 Fetching cart list - Total items: ${maps.length}");
  
  return List.generate(maps.length, (i) {
    debugPrint("🛒 Raw DB Row $i: ${maps[i]}");
    
    // Parse item_detail from JSON string
    List<ItemDetail>? itemDetail;
    if (maps[i]['item_detail'] != null && maps[i]['item_detail'].toString().isNotEmpty) {
      try {
        final itemDetailList = jsonDecode(maps[i]['item_detail']) as List;
        debugPrint("🛒 Parsed itemDetail JSON - Count: ${itemDetailList.length}");
        itemDetail = itemDetailList.map((e) => ItemDetail.fromJson(e)).toList();
        debugPrint("🛒 Successfully parsed itemDetail with ${itemDetail.length} items");
      } catch (e) {
        debugPrint("❌ Error parsing item_detail: $e");
        debugPrint("❌ Raw item_detail string: ${maps[i]['item_detail']}");
      }
    } else {
      debugPrint("🛒 item_detail is NULL or EMPTY in DB");
    }

    // Parse profiles_detail from JSON string
    List<ProfilesDetail>? profilesDetail;
    if (maps[i]['profiles_detail'] != null && maps[i]['profiles_detail'].toString().isNotEmpty) {
      try {
        final profilesDetailList = jsonDecode(maps[i]['profiles_detail']) as List;
        debugPrint("🛒 Parsed profilesDetail JSON - Count: ${profilesDetailList.length}");
        profilesDetail = profilesDetailList.map((e) => ProfilesDetail.fromJson(e)).toList();
        debugPrint("🛒 Successfully parsed profilesDetail with ${profilesDetail.length} items");
      } catch (e) {
        debugPrint("❌ Error parsing profiles_detail: $e");
        debugPrint("❌ Raw profiles_detail string: ${maps[i]['profiles_detail']}");
      }
    } else {
      debugPrint("🛒 profiles_detail is NULL or EMPTY in DB");
    }

    CustomCartModel result = CustomCartModel(
      id: maps[i]['id'] is int
          ? maps[i]['id']
          : int.tryParse(maps[i]['id'].toString()),
      name: maps[i]['name'],
      type: maps[i]['type'],
      price: maps[i]['price']?.toString(),
      cityId: maps[i]['city_id'] != null
          ? int.tryParse(maps[i]['city_id'].toString())
          : null,
      labId: maps[i]['lab_id'] != null
          ? int.tryParse(maps[i]['lab_id'].toString())
          : null,
      labName: maps[i]['lab_name'],
      labAddress: maps[i]['lab_address'],
      itemDetail: itemDetail,
      profilesDetail: profilesDetail,
    );
    
    debugPrint("🛒 Final CustomCartModel: ${result.toJson()}");
    return result;
  });
}

  Future<void> deleteFromCart({required String id, required String type}) async {
    if(AppConstants().getStorage.read(AppConstants.isCartExist)){
      WebApiHelper().callGetApi(null, AppConstants.GET_CLEAR_CART_API, true).then((response) {
        if(response != null) {
          EasyLoading.dismiss();
          StatusModel statusModel = StatusModel.fromJson(response);
          if(statusModel.status!) {
            AppConstants().getStorage.write(AppConstants.isCartExist,false);
          }
        }
      });
    }
    deleteRecordFormCart(id: id, type: type);
  }

  Future<bool> deleteRecordFormCart(
      {required String id, required String type}) async {
    final dbClient = await db;
    int rowsDeleted = await dbClient.delete(
      'cart_master',
      where: 'id = ? AND type = ?',
      whereArgs: [id, type],
    );
     if (rowsDeleted > 0) {
      debugPrint("🗑️ Deleted product (id:$id, type:$type) from cart");
      await getCartCounter();
    }
    return rowsDeleted > 0;
  }

  Future<void> clearAllRecord() async {
    final dbClient = await db;
    await dbClient.delete('cart_master');
    AppConstants().getStorage.write(AppConstants.cartCounter, 0);
    await getCartCounter();
    debugPrint("🗑️ Cleared all records from cart");
  }
}
