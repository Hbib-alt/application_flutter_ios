import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FCMService {

  static Future<void> init() async {

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    String? token = await messaging.getToken();

    print("🔥 TOKEN: $token");

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && token != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "fcmToken": token,
      }, SetOptions(merge: true));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Notification reçue: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("👉 Notification cliquée");
    });
  }
}