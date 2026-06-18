import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

// ================= BACKGROUND HANDLER =================

Future<void>
firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {

  debugPrint(
    "Background message: "
    "${message.messageId}",
  );
}

class NotificationService {

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final AudioPlayer player =
      AudioPlayer();

  // ================= INIT =================

  Future<void> init() async {

    try {

      // 🔔 permission notifications

      await _messaging
          .requestPermission();

      // ✅ BACKGROUND NOTIFICATIONS

      FirebaseMessaging
          .onBackgroundMessage(

        firebaseMessagingBackgroundHandler,
      );

      // 🌐 WEB SAFE

      String? token;

      try {

        token =
            await _messaging
                .getToken();

      } catch (e) {

        debugPrint(
          "FCM Web ignoré",
        );
      }

      // 💾 SAVE TOKEN

      await _saveToken(token);

      // 🔄 TOKEN REFRESH

      FirebaseMessaging.instance
          .onTokenRefresh
          .listen(

        (newToken) async {

          await _saveToken(
            newToken,
          );
        },
      );

     // 🌍 GLOBAL TOPIC

if (!kIsWeb) {

  try {

    await _messaging
        .subscribeToTopic(
      "allUsers",
    );

  } catch (e) {

    debugPrint(
      "Erreur Topic",
    );
  }
}

      // 📩 FOREGROUND MESSAGE

      FirebaseMessaging.onMessage
          .listen(

        (
          RemoteMessage message,
        ) async {

          debugPrint(

            "Notification reçue: "
            "${message.notification?.title}",
          );

          // 🔊 PLAY SOUND

          try {

            await player.play(

              AssetSource(

                'sounds/notification.mp3',
              ),
            );

          } catch (e) {

            debugPrint(

              "Son notification indisponible",
            );
          }
        },
      );

      // 📲 CLICK NOTIFICATION

      FirebaseMessaging
          .onMessageOpenedApp
          .listen(

        (RemoteMessage message) {

          debugPrint(

            "Notification ouverte",
          );
        },
      );

    } catch (e) {

      debugPrint(
        "Erreur notification: $e",
      );
    }
  }

  // ================= SAVE TOKEN =================

  Future<void> _saveToken(
    String? token,
  ) async {

    if (token == null) return;

    final user =
        FirebaseAuth
            .instance
            .currentUser;

    if (user == null) return;

    try {

      await FirebaseFirestore
          .instance
          .collection("users")
          .doc(user.uid)
          .set({

        "fcmToken": token,

        "updatedAt":
            FieldValue.serverTimestamp(),

      }, SetOptions(
        merge: true,
      ));

    } catch (e) {

      debugPrint(
        "Erreur save token",
      );
    }
  }
}