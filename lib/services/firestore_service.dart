import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =========================
  // 📂 HEALTH CASES
  // =========================

  static Stream<List<Map<String, dynamic>>>
      getCases() {

    return _firestore
        .collection("health_cases")
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots()
        .map((snapshot) {

      return snapshot.docs.map((doc) {

        return {

          "id": doc.id,

          ...doc.data(),
        };

      }).toList();
    });
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
  // 📜 TRANSACTIONS
  // =========================

  static Stream<QuerySnapshot<
      Map<String, dynamic>>>
      getTransactions() {

    return _firestore
        .collection("transactions")
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
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots();
  }
}