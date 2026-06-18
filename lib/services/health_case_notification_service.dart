import 'package:cloud_firestore/cloud_firestore.dart';

class HealthCaseNotificationService {

  static final _db =
      FirebaseFirestore.instance;

  // ================= COMMITTEE =================

  static Future<void> notifyCommittee({
    required String title,
    required String body,
    required String caseId,
  }) async {

    final users =
        await _db
            .collection("users")
            .where(
              "role",
              whereIn: [
                "committee",
                "president",
                "treasurer",
                "admin",
              ],
            )
            .get();

    for (final user in users.docs) {

      await _db
          .collection("notifications")
          .add({

        "userId": user.id,

        "title": title,

        "body": body,

        "caseId": caseId,

        "read": false,

        "createdAt":
            FieldValue.serverTimestamp(),
      });
    }
  }

  // ================= PRESIDENT =================

  static Future<void> notifyPresident({
    required String title,
    required String body,
    required String caseId,
  }) async {

    final presidents =
        await _db
            .collection("users")
            .where(
              "role",
              isEqualTo:
                  "president",
            )
            .get();

    for (final user
        in presidents.docs) {

     await _db
    .collection("notifications")
    .add({

  "userId": user.id,

  "title": title,

  "body": body,

  "caseId": caseId,

  "type": "health_case",

  "read": false,

  "createdAt":
      FieldValue.serverTimestamp(),
});

    }
  }

  // ================= TREASURER =================

  static Future<void> notifyTreasurer({
    required String title,
    required String body,
    required String caseId,
  }) async {

    final treasurers =
        await _db
            .collection("users")
            .where(
              "role",
              isEqualTo:
                  "treasurer",
            )
            .get();

    for (final user
        in treasurers.docs) {

      await _db
          .collection("notifications")
          .add({

        "userId": user.id,

        "title": title,

        "body": body,

        "caseId": caseId,

        "type": "health_case",
        
        "read": false,

        "createdAt":
            FieldValue.serverTimestamp(),
      });
    }
  }
}