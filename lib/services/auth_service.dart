import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ================= LOGIN =================

  static Future<UserCredential>
      login({

    required String phone,

    required String password,

  }) async {

    final email =
        "${phone.trim()}@3enter.app";

    return await _auth
        .signInWithEmailAndPassword(

      email: email,

      password: password,
    );
  }

  // ================= REGISTER =================

  static Future<UserCredential>
      register({

    required String phone,

    required String password,

  }) async {

    final email =
        "${phone.trim()}@3enter.app";

    return await _auth
        .createUserWithEmailAndPassword(

      email: email,

      password: password,
    );
  }

  // ================= CURRENT USER =================

  static User? get currentUser {

    return _auth.currentUser;
  }

  // ================= LOGOUT =================

  static Future<void> logout()
      async {

    await _auth.signOut();
  }
}