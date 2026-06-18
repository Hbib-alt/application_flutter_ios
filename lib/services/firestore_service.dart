import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =========================
  // 📂 HEALTH CASES
  // =========================

 
// =========================
// 📂 HEALTH CASES
// =========================

static Stream<
    QuerySnapshot<
        Map<String, dynamic>>>
    getCases() {

  return _firestore
      .collection("health_cases")

      .where(
        "isDeleted",
        isEqualTo: false,
      )

      .orderBy(
        "createdAt",
        descending: true,
      )

      .snapshots();
}
  // =========================
  // ➕ ADD HEALTH CASE
  // =========================

  static Future<void> addCase({

    required String fullName,

    required String phone,

    required String description,

    required String createdBy,

  }) async {

    await _firestore
        .collection("health_cases")
        .add({

      "fullName": fullName,

      "phone": phone,

      "description":
          description,

      "status":
          "submitted",

      "createdBy":
          createdBy,

      "createdAt":
          FieldValue.serverTimestamp(),
      "isDeleted": false,
    });
  }

  // =========================
  // ✏️ UPDATE STATUS
  // =========================

  static Future<void> updateCaseStatus({

    required String caseId,

    required String status,

  }) async {

    await _firestore
        .collection("health_cases")
        .doc(caseId)
        .update({

      "status": status,
    });
  }

  // =========================
  // 💰 FINANCE
  // =========================

  static Stream<
      DocumentSnapshot<Map<String, dynamic>>>
      getFinance() {

    return _firestore
        .collection("finance")
        .doc("main")
        .snapshots();
  }

  // =========================
 // =========================
// 📜 TRANSACTIONS
// =========================

static Stream<
    QuerySnapshot<
        Map<String, dynamic>>>
    getTransactions() {

  return _firestore
      .collection("transactions")

      .where(
        "isDeleted",
        isEqualTo: false,
      )

      .orderBy(
        "createdAt",
        descending: true,
      )

      .snapshots();
}

  // =========================
  // 💳 SUBSCRIPTIONS
  // =========================

  static Stream<QuerySnapshot<
      Map<String, dynamic>>>
      getSubscriptions() {

    return _firestore
        .collection("subscriptions")
        .snapshots();
  }

  // =========================
  // ❤️ DONATIONS
  // =========================

  static Stream<QuerySnapshot<
      Map<String, dynamic>>>
      getDonations() {

    return _firestore
        .collection("donations")
        .snapshots();
  }

  // =========================
  // 📦 LAWHA
  // =========================

  static Stream<QuerySnapshot<
      Map<String, dynamic>>>
      getLawha() {

    return _firestore
        .collection("lawha")
        .snapshots();
  }

  // =========================
  // 👥 PEOPLE
  // =========================

  static Stream<QuerySnapshot<
      Map<String, dynamic>>>
      getPeople() {

    return _firestore
        .collection("people")
        .snapshots();
  }

  // =========================
  // 📥 OPERATIONS
  // =========================

  static Stream<QuerySnapshot<
      Map<String, dynamic>>>
      getOperations() {

   return _firestore
    .collection("operations")

    .where(
      "isDeleted",
      isEqualTo: false,
    )

    .orderBy(
      "createdAt",
      descending: true,
    )

    .snapshots();
  }
}