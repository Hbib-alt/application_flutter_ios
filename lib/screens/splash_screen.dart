import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {

    super.initState();

    Timer(

      const Duration(
        seconds: 3,
      ),

      () {

        final user =
            FirebaseAuth
                .instance
                .currentUser;

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) {

              if (user == null) {

                return const LoginScreen();
              }

              return const HomeScreen();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        width: double.infinity,

        decoration:
            const BoxDecoration(

          gradient:
              LinearGradient(

            colors: [

              Color(0xFF0057FF),

              Color(0xFF3B82F6),
            ],

            begin:
                Alignment.topLeft,

            end:
                Alignment.bottomRight,
          ),
        ),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            // ✅ LOGO

            Container(

              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  BoxDecoration(

                color:
                    Colors.white
                        .withOpacity(
                  0.15,
                ),

                shape:
                    BoxShape.circle,
              ),

              child: Image.asset(

                "assets/images/logo.png",

                height: 120,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ✅ TITLE

            const Text(

              "لجنة كونكل الخير",

              style: TextStyle(

                color: Colors.white,

                fontSize: 34,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ✅ SUBTITLE

            const Text(

              "ذوو القربى أولى بالمعروف",

              style: TextStyle(

                color: Colors.white70,

                fontSize: 18,
              ),
            ),

            const SizedBox(
              height: 50,
            ),

            // ✅ LOADING

            const CircularProgressIndicator(

              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}