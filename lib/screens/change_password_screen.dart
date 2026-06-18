import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

class ChangePasswordScreen
    extends StatefulWidget {

  const ChangePasswordScreen({
    super.key,
  });

  @override
  State<ChangePasswordScreen>
      createState() =>
          _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<
        ChangePasswordScreen> {

  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();
final oldPasswordController =
    TextEditingController();
  
  bool loading = false;

bool obscureOldPassword = true;
bool obscurePassword = true;
bool obscureConfirm = true;

  // ================= CHANGE PASSWORD =================

  Future<void> changePassword() async {

    final oldPassword =
    oldPasswordController.text.trim();
    final password =
        passwordController.text.trim();

    final confirm =
        confirmController.text.trim();

    if (oldPassword.isEmpty ||
    password.isEmpty ||
    confirm.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "أدخل البيانات",
          ),
        ),
      );

      return;
    }

    if (password.length < 6) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "كلمة المرور ضعيفة",
          ),
        ),
      );

      return;
    }

    if (password != confirm) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "كلمتا المرور غير متطابقتين",
          ),
        ),
      );

      return;
    }

    try {

      setState(() {
        loading = true;
      });

      // =========================
      // UPDATE PASSWORD
      // =========================

      final user =
          FirebaseAuth.instance
              .currentUser;

      if (user == null) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "❌ المستخدم غير متصل",
            ),
          ),
        );

        return;
      }

      final credential =
    EmailAuthProvider.credential(
  email: user.email!,
  password: oldPassword,
);

await user
    .reauthenticateWithCredential(
  credential,
);

await user.updatePassword(
  password,
);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "✅ تم تغيير كلمة المرور",
          ),
        ),
      );

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),
      );

    } on FirebaseAuthException catch (e) {

      String message =
          "❌ حدث خطأ";
if (e.code ==
        "wrong-password" ||
    e.code ==
        "invalid-credential") {

  message =
      "❌ كلمة المرور الحالية غير صحيحة";
}
   
      if (e.code ==
          "requires-recent-login") {

        message =
            "❌ يرجى تسجيل الدخول من جديد";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(message),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Erreur: $e",
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          loading = false;
        });
      }
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(

        title: const Text(
          "تغيير كلمة المرور",
        ),

        centerTitle: true,

        elevation: 0,
      ),

      body: Center(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(24),

          child: Column(

            children: [

              const Icon(

                Icons.lock_reset,

                size: 90,

                color:
                    Color(0xFF0057FF),
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(

                "تحديث كلمة المرور",

                style: TextStyle(

                  fontSize: 28,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 40,
              ),
TextField(

  controller:
      oldPasswordController,

  obscureText:
      obscureOldPassword,

  decoration:
      InputDecoration(

    labelText:
        "كلمة المرور الحالية",

    prefixIcon:
        const Icon(Icons.lock),

    suffixIcon:
        IconButton(

      onPressed: () {

        setState(() {

          obscureOldPassword =
              !obscureOldPassword;
        });
      },

      icon: Icon(

        obscureOldPassword
            ? Icons.visibility
            : Icons.visibility_off,
      ),
    ),
  ),
),
const SizedBox(
  height: 18,
),

TextField(

  controller:
      passwordController,

  obscureText:
      obscurePassword,

  decoration:
      InputDecoration(

    labelText:
        "كلمة المرور الجديدة",

    suffixIcon:
        IconButton(

      onPressed: () {

        setState(() {

          obscurePassword =
              !obscurePassword;
        });
      },

      icon: Icon(

        obscurePassword
            ? Icons.visibility
            : Icons.visibility_off,
      ),
    ),
  ),
),

const SizedBox(
  height: 18,
),
             

              // =========================
              // CONFIRM PASSWORD
              // =========================

              TextField(

                controller:
                    confirmController,

                obscureText:
                    obscureConfirm,

                decoration:
                    InputDecoration(

                  labelText:
                      "تأكيد كلمة المرور",

                  suffixIcon:
                      IconButton(

                    onPressed: () {

                      setState(() {

                        obscureConfirm =
                            !obscureConfirm;
                      });
                    },

                    icon: Icon(

                      obscureConfirm
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  onPressed:
                      loading
                          ? null
                          : changePassword,

                  child:
                      loading
                          ? const CircularProgressIndicator(
                              color:
                                  Colors.white,
                            )
                          : const Text(
                              "حفظ",
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}