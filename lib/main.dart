import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';

import 'screens/home_screen.dart';

import 'screens/login_screen.dart';

import 'services/notification_service.dart';

import 'screens/splash_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase initialization
  await Firebase.initializeApp(

    options:
        DefaultFirebaseOptions
            .currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() =>
      _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {

    super.initState();

    // 🔔 Notifications
    NotificationService().init();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      title: '3enter',

      theme: ThemeData(

        // ✅ GOOGLE FONTS
        textTheme:
            GoogleFonts.cairoTextTheme(),

        useMaterial3: true,

        primaryColor:
            const Color(0xFF0057FF),

        scaffoldBackgroundColor:
            const Color(0xFFF5F6FA),

        colorScheme:
            ColorScheme.fromSeed(

          seedColor:
              const Color(
            0xFF3F2DBF,
          ),
        ),

        appBarTheme:
            const AppBarTheme(

          elevation: 0,

          backgroundColor:
              Colors.white,

          foregroundColor:
              Colors.black,

          centerTitle: true,
        ),

        floatingActionButtonTheme:
            const FloatingActionButtonThemeData(

          backgroundColor:
              Color(0xFF0057FF),

          foregroundColor:
              Colors.white,
        ),

        elevatedButtonTheme:
            ElevatedButtonThemeData(

          style:
              ElevatedButton
                  .styleFrom(

            elevation: 0,

            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 18,
              vertical: 14,
            ),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                14,
              ),
            ),
          ),
        ),

        inputDecorationTheme:
            InputDecorationTheme(

          filled: true,

          fillColor: Colors.white,

          contentPadding:
              const EdgeInsets
                  .symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          border:
              OutlineInputBorder(

            borderRadius:
                BorderRadius
                    .circular(
              14,
            ),

            borderSide:
                BorderSide(
              color:
                  Colors.grey
                      .shade300,
            ),
          ),

          enabledBorder:
              OutlineInputBorder(

            borderRadius:
                BorderRadius
                    .circular(
              14,
            ),

            borderSide:
                BorderSide(
              color:
                  Colors.grey
                      .shade300,
            ),
          ),

          focusedBorder:
              OutlineInputBorder(

            borderRadius:
                BorderRadius
                    .circular(
              14,
            ),

            borderSide:
                const BorderSide(

              color:
                  Color(
                0xFF3F2DBF,
              ),

              width: 2,
            ),
          ),
        ),

        cardTheme:
            CardThemeData(

          elevation: 2,

          color: Colors.white,

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius
                    .circular(
              18,
            ),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}