import 'package:flutter/material.dart';

import '../services/auth_service.dart';

import 'home_screen.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final phoneController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;

  // ================= LOGIN =================

  Future<void> login() async {

    final phone =
        phoneController.text.trim();

    final password =
        passwordController.text.trim();

    if (phone.isEmpty ||
        password.isEmpty) {

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

    try {

      setState(() {
        loading = true;
      });

      await AuthService.login(

        phone: phone,

        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
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

      body: Container(

        width: double.infinity,

        height: double.infinity,

        decoration: const BoxDecoration(

          image: DecorationImage(

            image: AssetImage(
              "assets/images/login_bg.jpg",
            ),

            fit: BoxFit.cover,
          ),
        ),

        child: Container(

          decoration: BoxDecoration(

            gradient: LinearGradient(

              begin: Alignment.topCenter,

              end: Alignment.bottomCenter,

              colors: [

                Colors.blue.withOpacity(
                  0.10,
                ),

                Colors.black.withOpacity(
                  0.45,
                ),
              ],
            ),
          ),

          child: SafeArea(

            child: Center(

              child: SingleChildScrollView(

                padding:
                    const EdgeInsets.all(24),

                child: Column(

                  children: [

                    const SizedBox(
                      height: 20,
                    ),

                    Image.asset(

                      "assets/images/logo.png",

                      height: 120,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(

                      "مرحباً بك",

                      style: TextStyle(

                        color: Colors.white,

                        fontSize: 42,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(

                      "سجل الدخول للوصول إلى حسابك",

                      textAlign:
                          TextAlign.center,

                      style: TextStyle(

                        color: Colors.white70,

                        fontSize: 20,
                      ),
                    ),

                    const SizedBox(
                      height: 40,
                    ),

                    // ================= GLASS FORM =================

                    Container(

                      padding:
                          const EdgeInsets.all(
                        24,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.white
                                .withOpacity(
                          0.12,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          30,
                        ),

                        border: Border.all(

                          color:
                              Colors.white
                                  .withOpacity(
                            0.25,
                          ),

                          width: 1.5,
                        ),

                        boxShadow: [

                          BoxShadow(

                            color:
                                Colors.black
                                    .withOpacity(
                              0.15,
                            ),

                            blurRadius: 25,

                            offset:
                                const Offset(
                              0,
                              10,
                            ),
                          ),
                        ],
                      ),

                      child: Column(

                        children: [

                          // ================= PHONE =================

                          TextField(

                            controller:
                                phoneController,

                            keyboardType:
                                TextInputType.phone,

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                            ),

                            decoration:
                                InputDecoration(

                              labelText:
                                  "رقم الهاتف",

                              labelStyle:
                                  const TextStyle(
                                color:
                                    Colors.white,
                              ),

                              prefixIcon:
                                  const Icon(
                                Icons.phone,
                                color:
                                    Color(
                                  0xFF0057FF,
                                ),
                              ),

                              filled: true,

                              fillColor:
                                  Colors.white
                                      .withOpacity(
                                0.15,
                              ),

                              border:
                                  OutlineInputBorder(

                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),

                                borderSide:
                                    BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ================= PASSWORD =================

                          TextField(

                            controller:
                                passwordController,

                            obscureText: true,

                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                            ),

                            decoration:
                                InputDecoration(

                              labelText:
                                  "كلمة المرور",

                              labelStyle:
                                  const TextStyle(
                                color:
                                    Colors.white,
                              ),

                              prefixIcon:
                                  const Icon(
                                Icons.lock,
                                color:
                                    Color(
                                  0xFF0057FF,
                                ),
                              ),

                              filled: true,

                              fillColor:
                                  Colors.white
                                      .withOpacity(
                                0.15,
                              ),

                              border:
                                  OutlineInputBorder(

                                borderRadius:
                                    BorderRadius.circular(
                                  18,
                                ),

                                borderSide:
                                    BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 30,
                          ),

                          // ================= LOGIN BUTTON =================

                          SizedBox(

                            width:
                                double.infinity,

                            height: 58,

                            child:
                                ElevatedButton(

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    const Color(
                                  0xFF0057FF,
                                ),

                                shape:
                                    RoundedRectangleBorder(

                                  borderRadius:
                                      BorderRadius.circular(
                                    18,
                                  ),
                                ),
                              ),

                              onPressed:
                                  loading
                                      ? null
                                      : login,

                              child:
                                  loading
                                      ? const CircularProgressIndicator(
                                          color:
                                              Colors.white,
                                        )
                                      : const Text(

                                          "تسجيل الدخول",

                                          style:
                                              TextStyle(

                                            fontSize:
                                                20,

                                            fontWeight:
                                                FontWeight.bold,

                                            color:
                                                Colors.white,
                                          ),
                                        ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // ================= REGISTER =================

                          TextButton(

                            onPressed: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      const RegisterScreen(),
                                ),
                              );
                            },

                            child: const Text(

                              "إنشاء حساب جديد",

                              style: TextStyle(

                                color: Colors.white,

                                fontSize: 16,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    const Text(

                      "2026 © جميع الحقوق محفوظة",

                      style: TextStyle(

                        color: Colors.white70,

                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}