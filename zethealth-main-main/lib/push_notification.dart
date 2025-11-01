import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zet_health/Helper/AppConstants.dart';
import 'Screens/DrawerView/PrescriptionScreen/PrescriptionScreen.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

class PushNotificationManager {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final AndroidNotificationChannel channel = androidNotificationChannel();

  static Future<void> notificationSetup() async {
    await Firebase.initializeApp();
    enableIOSNotifications();
    await registerNotificationListeners();
  }

  static Future<void> registerNotificationListeners() async {
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@drawable/ic_launcher');
    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) parseNotificationMessage(message, false);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) async {
      parseNotificationMessage(message, false);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      parseNotificationMessage(message, true);
    });

  }



  static parseNotificationMessage(RemoteMessage? message, bool isBackground) async {
    if (message != null) {
      final RemoteNotification? notification = message.notification;
      if (( // getStorage.read(IS_NOTIFICATION)==null || getStorage.read(IS_NOTIFICATION) &&
          message.data.isNotEmpty &&
              message.data['message'] != null &&
              message.data['message'].isNotEmpty)) {
        Map<String, dynamic> result = json.decode(message.data['message']);
        String payload = message.data['message'];
        BigPictureStyleInformation? bigPictureStyleInformation = await getNotificationImage(result: result);
        if (Platform.isAndroid) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            result['title'],
            result['message'],
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: 'mipmap/ic_launcher',
                styleInformation: bigPictureStyleInformation,
              ),
            ),
            payload: payload,
          );
        }
        else {
          const DarwinNotificationDetails iosPlatformSpecifics = DarwinNotificationDetails();
          const NotificationDetails iosChannelSpecific = NotificationDetails(iOS: iosPlatformSpecifics);
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            result['title'],
            result['message'],
            iosChannelSpecific,
            payload: payload,
            // payload: '${message.data['currency_trigger'] ?? message.data['currency_trigger']}|${message.data['currency_value'] ?? message.data['currency_value']}|${message.data['condition_value'] ?? message.data['condition_value']}|${message.data['currency_base'] ?? message.data['currency_base']}|${message.data['alert_type'] ?? message.data['alert_type']}',
          );
        }
        /*if (isBackground) {
          handleNotificationClick(payload);
        }*/
      }
    }
  }

  static void handleNotificationClick(String payload) {
    Map<String, dynamic> result = json.decode(payload);
    // print("handleNotificationClick ${result['booking_id']} , ${result['type']}");
      if (result['type'] == "UpdatePrescription") {
        AppConstants().loadWithCanBack(const PrescriptionScreen());
      }
  }


  static Future<void> onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    String? payload = notificationResponse.payload;
    if (payload != null) {
      handleNotificationClick(payload);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    parseNotificationMessage(message, true);
  }

  static Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
  }

  static Future<BigPictureStyleInformation?> getNotificationImage({required Map<String, dynamic> result}) async {
    if(result['image']==null || result['image'].isEmpty) return null;
    final http.Response response = await http.get(Uri.parse(AppConstants.IMG_URL + result['image']));
    if (response.statusCode == 200) {
      final Uint8List image = response.bodyBytes;
      return BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(base64Encode(image)),
        hideExpandedLargeIcon: true,
        // largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Encode(image)),
      );
    } else {
      return null;
    }
  }
}



AndroidNotificationChannel androidNotificationChannel() =>
    const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.', // description
      importance: Importance.max,
    );
