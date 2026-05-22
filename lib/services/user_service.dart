import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {

  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ================= CURRENT USER =================

  static User? get currentUser {

    return _auth.currentUser;
  }

  // ================= CURRENT UID =================

  static String get currentUid {

    return currentUser?.uid ?? "";
  }

  // ================= GET CURRENT USER DOC =================

  static Future<Map<String, dynamic>?>
      getCurrentUserData() async {

    try {

      if (currentUid.isEmpty) {
        return null;
      }

      final doc =
          await _firestore
              .collection("users")
              .doc(currentUid)
              .get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();

    } catch (_) {

      return null;
    }
  }

  // ================= GET USER ROLE =================

  static Future<String> getUserRole() async {

    final data =
        await getCurrentUserData();

    return data?["role"] ?? "user";
  }

  // ================= GET USER NAME =================

  static Future<String> getUserName() async {

    final data =
        await getCurrentUserData();

    return data?["fullName"] ??
        "Utilisateur";
  }

  // ================= GET PHONE =================

  static Future<String> getPhone() async {

    final data =
        await getCurrentUserData();

    return data?["phone"] ?? "";
  }

  // ================= IS ACTIVE =================

  static Future<bool> isActive() async {

    final data =
        await getCurrentUserData();

    return data?["active"] ?? false;
  }

  // ================= MUST CHANGE PASSWORD =================

  static Future<bool>
      mustChangePassword() async {

    final data =
        await getCurrentUserData();

    return data?[
            "mustChangePassword"] ??
        false;
  }

  // ================= IS ADMIN =================

  static Future<bool> isAdmin() async {

    final role =
        await getUserRole();

    return role == "admin";
  }

  // ================= IS PRESIDENT =================

  static Future<bool>
      isPresident() async {

    final role =
        await getUserRole();

    return role == "president" ||
        role == "admin";
  }

  // ================= IS TREASURER =================

  static Future<bool>
      isTreasurer() async {

    final role =
        await getUserRole();

    return role == "treasurer" ||
        role == "admin";
  }

  // ================= IS COMMITTEE =================

  static Future<bool>
      isCommittee() async {

    final role =
        await getUserRole();

    return role == "committee" ||
        role == "admin";
  }

  // ================= UPDATE PASSWORD FLAG =================

  static Future<void>
      disableMustChangePassword()
      async {

    if (currentUid.isEmpty) return;

    await _firestore
        .collection("users")
        .doc(currentUid)
        .update({

      "mustChangePassword":
          false,
    });
  }

  // ================= CREATE USER DOCUMENT =================

  static Future<void>
      createUserDocument({

    required String uid,

    required String fullName,

    required String phone,

    required String role,

  }) async {

    await _firestore
        .collection("users")
        .doc(uid)
        .set({

      "fullName": fullName,

      "phone": phone,

      "role": role,

      "active": true,

      "mustChangePassword":
          true,

      "createdAt":
          FieldValue.serverTimestamp(),
    });
  }

  // ================= UPDATE ROLE =================

  static Future<void> updateRole({

    required String uid,

    required String role,

  }) async {

    await _firestore
        .collection("users")
        .doc(uid)
        .update({

      "role": role,
    });
  }

  // ================= ENABLE USER =================

  static Future<void> enableUser(
    String uid,
  ) async {

    await _firestore
        .collection("users")
        .doc(uid)
        .update({

      "active": true,
    });
  }

  // ================= DISABLE USER =================

  static Future<void> disableUser(
    String uid,
  ) async {

    await _firestore
        .collection("users")
        .doc(uid)
        .update({

      "active": false,
    });
  }

  // ================= LOGOUT =================

  static Future<void> logout() async {

    await _auth.signOut();
  }
}