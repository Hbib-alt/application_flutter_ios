import 'subscriptions_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'payment_screen.dart';
import 'change_password_screen.dart';
import 'history_search_screen.dart';
import 'trash_screen.dart';

import '../services/user_service.dart';
import '../services/auth_service.dart';

import 'members_screen.dart';
import 'export_database_screen.dart';

import 'export_database_pdf_screen.dart';
import 'annual_report_screen.dart';
import 'operations_cleanup_screen.dart';

// 📌 Écrans

import 'dashboard_screen.dart';
import 'caisse_screen.dart';
import 'notifications_screen.dart';
import 'late_people_screen.dart';
import 'add_case_screen.dart';
import 'monthly_contributions_status_screen.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/subscription_stats_service.dart';
// ❤️ Module santé
import 'health_cases_screen.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  // ================= COLLECTOR NAME =================

  String collectorName = "";

  @override
  void initState() {
    super.initState();

    loadCollectorName();
  }

  Future<void> loadCollectorName() async {

    final userData =
        await UserService
            .getCurrentUserData();

    setState(() {

      collectorName =
          userData?["fullName"] ?? "";
    });
  }

  // ================= NOTIFICATIONS =================

  Stream<int> getUnreadCount() {

    final user =
        UserService.currentUser;

    if (user == null) {

      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection("notifications")
        .where(
          "userId",
          isEqualTo: user.uid,
        )
        .where(
          "read",
          isEqualTo: false,
        )
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.length,
        );
  }

  // ================= ROLE LABEL =================

  String roleLabel(
    String role,
  ) {

    switch (role) {

      case "admin":
        return "ADMIN";

      case "president":
        return "PRÉSIDENT";

      case "treasurer":
        return "TRÉSORIER";

      case "committee":
        return "COMITÉ";

      default:
        return "UTILISATEUR";
    }
  }
Future<void> deleteOperation(

  BuildContext context,

  String operationId,
) async {

  try {
final firestore =
    FirebaseFirestore.instance;
    final operationDoc =
    await firestore
        .collection("operations")
        .doc(operationId)
        .get();

if (!operationDoc.exists) {
  throw Exception(
    "Opération introuvable",
  );
}

final operationData =
    operationDoc.data()!;

final status =
    operationData["status"]
            ?.toString() ??
        "";
    // ================= DELETE NOTIFICATIONS =================

    final notifications =

        await FirebaseFirestore
            .instance
            .collection(
              "notifications",
            )
            .where(
              "operationId",
              isEqualTo:
                  operationId,
            )
            .get();

    for (var doc
        in notifications.docs) {

      await doc.reference
          .delete();
    }
if (status == "approved") {

  final transactionDoc =
      await firestore
          .collection(
            "transactions",
          )
          .doc(
            operationId,
          )
          .get();

  if (transactionDoc.exists) {

    final transactionData =
        transactionDoc.data()!;

    final paymentType =
        transactionData["paymentType"]
                ?.toString() ??
            "";

    if (paymentType == "monthly") {

      final personId =
          transactionData["personId"]
                  ?.toString() ??
              "";

      final year =
          transactionData["year"] ??
          DateTime.now().year;

      final coveredMonths =
          List<int>.from(
        transactionData[
                "coveredMonths"] ??
            [],
      );

      for (final month
          in coveredMonths) {

        await firestore
            .collection(
              "monthly_locks",
            )
            .doc(
              "${personId}_${year}_$month",
            )
            .delete();
      }
    }

    await transactionDoc.reference
        .update({

      "isDeleted": true,

      "status":
          "cancelled",
    });
    if (paymentType == "monthly") {

  final personId =
      transactionData["personId"]
              ?.toString() ??
          "";

  final subscriptionDoc =
      await firestore
          .collection(
            "subscriptions",
          )
          .doc(personId)
          .get();

  if (subscriptionDoc.exists) {

    final category =
        subscriptionDoc.data()?[
                "category"] ??
            500;

    await SubscriptionStatsService
        .updateSubscriptionStats(
      personId,
      category,
    );
  }
}
  }
}

    // ================= LOGICAL DELETE =================

    await FirebaseFirestore
        .instance
        .collection(
          "operations",
        )
        .doc(
          operationId,
        )
        .update({

      "isDeleted": true,
    });

    if (context.mounted) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            "✅ تم حذف العملية",
          ),
        ),
      );
    }

  } catch (e) {

    if (context.mounted) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(

          content:
              Text(
            "Erreur : $e",
          ),
        ),
      );
    }
  }
}
  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF7F9FC),

      body: SafeArea(

        child: Padding(

          padding:
              const EdgeInsets.all(
            20,
          ),

          child: SingleChildScrollView(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ================= HEADER =================

                FutureBuilder<Map<String, dynamic>?>(

                  future:
                      UserService
                          .getCurrentUserData(),

                  builder:
                      (
                        context,
                        snapshot,
                      ) {

                    final userData =
                        snapshot.data ??
                            {};

                    final fullName =
                        userData["fullName"]
                                ?.toString() ??
                            "Utilisateur";

                    final role =
                        roleLabel(

                      userData["role"]
                              ?.toString() ??
                          "user",
                    );

                    return Container(

                      width:
                          double.infinity,

                      padding:
                          const EdgeInsets.symmetric(

                        horizontal: 24,

                        vertical: 18,
                      ),

                      decoration:
                          BoxDecoration(

                        borderRadius:
                            BorderRadius.circular(
                          34,
                        ),

                        gradient:
                            const LinearGradient(

                          colors: [

                            Color(
                              0xFF0057FF,
                            ),

                            Color(
                              0xFF3B82F6,
                            ),
                          ],

                          begin:
                              Alignment.topLeft,

                          end:
                              Alignment
                                  .bottomRight,
                        ),

                        boxShadow: [

                          BoxShadow(

                            color:
                                const Color(
                              0xFF0057FF,
                            ).withOpacity(
                              0.25,
                            ),

                            blurRadius:
                                28,

                            offset:
                                const Offset(
                              0,
                              12,
                            ),
                          ),
                        ],
                      ),

                      child: Column(

                        children: [

                          // ✅ LOGO

                          Container(

                            padding:
                                const EdgeInsets.all(
                              10,
                            ),

                            decoration:
                                BoxDecoration(

                              color:
                                  Colors.white
                                      .withOpacity(
                                0.12,
                              ),

                              shape:
                                  BoxShape.circle,

                              border:
                                  Border.all(

                                color:
                                    Colors.white
                                        .withOpacity(
                                  0.2,
                                ),

                                width: 1.5,
                              ),
                            ),

                            child: Image.asset(

                              "assets/images/logo.png",

                              height: 58,
                            ),
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ✅ TITRE

                          const Text(

                            "لجنة كونكل الخير",

                            textAlign:
                                TextAlign.center,

                            style:
                                TextStyle(

                              color:
                                  Colors.white,

                              fontSize: 30,

                              fontWeight:
                                  FontWeight.bold,

                              height: 1.2,
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          // ✅ NOM

                          Text(

                            fullName,

                            textAlign:
                                TextAlign.center,

                            style:
                                const TextStyle(

                              color:
                                  Colors.white,

                              fontSize: 22,

                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          // ✅ ROLE

                          Container(

                            padding:
                                const EdgeInsets.symmetric(

                              horizontal: 18,

                              vertical: 8,
                            ),

                            decoration:
                                BoxDecoration(

                              color:
                                  Colors.white
                                      .withOpacity(
                                0.18,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                30,
                              ),
                            ),

                            child: Text(

                              role,

                              style:
                                  const TextStyle(

                                color:
                                    Colors.white,

                                fontSize: 15,

                                fontWeight:
                                    FontWeight.bold,

                                letterSpacing:
                                    1.2,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          // ✅ SLOGAN

                          const Text(

                            "ذوو القربى أولى بالمعروف",

                            textAlign:
                                TextAlign.center,

                            style:
                                TextStyle(

                              color:
                                  Colors.white70,

                              fontSize: 16,

                              fontStyle:
                                  FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(
  height: 12,
),

                // ================= TOP BAR =================

                Row(

                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                  children: [

                    const Text(

                      "Tableau de bord",

                      style: TextStyle(

                        fontSize: 28,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    // 🔔 NOTIFICATIONS

                    StreamBuilder<int>(

                      stream:
                          getUnreadCount(),

                      builder:
                          (
                            context,
                            snapshot,
                          ) {

                        final count =
                            snapshot.data ??
                                0;

                        return Stack(

                          children: [

                            IconButton(

                              icon:
                                  const Icon(

                                Icons
                                    .notifications,

                                size: 32,
                              ),

                              onPressed:
                                  () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder: (_) =>
                                        const NotificationsScreen(),
                                  ),
                                );
                              },
                            ),

                            if (count > 0)

                              Positioned(

                                right: 5,
                                top: 5,

                                child: Container(

                                  padding:
                                      const EdgeInsets.all(
                                    5,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        Colors.red,

                                    borderRadius:
                                        BorderRadius.circular(
                                      20,
                                    ),
                                  ),

                                  constraints:
                                      const BoxConstraints(

                                    minWidth:
                                        20,

                                    minHeight:
                                        20,
                                  ),

                                  child: Text(

                                    count > 9
                                        ? "9+"
                                        : "$count",

                                    textAlign:
                                        TextAlign.center,

                                    style:
                                        const TextStyle(

                                      color:
                                          Colors.white,

                                      fontSize:
                                          11,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

               // ================= CARDS =================

Wrap(

  spacing: 15,

  runSpacing: 15,

  children: [

   _card(
  context,
  Icons.add_circle,
  "إضافة مبلغ ",
  Colors.teal,
  const AddCaseScreen(),
),
   
    _card(
      context,
      Icons.health_and_safety,
      "إعلان حالة",
      Colors.pink,
      const HealthCasesScreen(),
    ),

    _card(
      context,
      Icons.bar_chart,
      "وضعية الحالات",
      Colors.orange,
      const DashboardScreen(),
    ),

    _card(
      context,
      Icons.account_balance_wallet,
      "رصيد الصندوق",
      Colors.green,
      const CaisseScreen(),
    ),

    _card(
  context,
  Icons.analytics,
  "وضعية الاشتراكات الشهرية",
  Colors.indigo,
  const MonthlyContributionsStatusScreen(),
),

    _card(
      context,
      Icons.warning_amber,
      "متأخري $collectorName",
      Colors.red,
      const LatePeopleScreen(),
    ),

    _card(
      context,
      Icons.people,
      "مشتركي $collectorName",
      Colors.cyan,
      const MembersScreen(),
    ),

   
    _card(
      context,
      Icons.search,
      "السجل العام",
      Colors.brown,
      const HistorySearchScreen(),
    ),

FutureBuilder<bool>(

  future: UserService.isAdmin(),

  builder: (context, snapshot) {

    if (snapshot.data != true) {

      return const SizedBox();
    }

    return _card(

      context,

      Icons.restore_from_trash,

      "سلة المحذوفات",

      Colors.grey,

      const TrashScreen(),
    );
  },
),
    _card(
      context,
      Icons.lock_reset,
      "تغيير كلمة المرور",
      Colors.deepPurple,
      const ChangePasswordScreen(),
    ),
_card(
  context,
  Icons.logout,
  "خروج",
  Colors.red,
  const LoginScreen(),
),
    FutureBuilder<bool>(

      future: UserService.isAdmin(),

      builder: (context, snapshot) {

        if (snapshot.data != true) {

          return const SizedBox();
        }

        return _card(

          context,

          Icons.table_view,

          "تصدير Excel",

          Colors.green,

          const ExportDatabaseScreen(),
        );
      },
    ),

    FutureBuilder<bool>(

      future: UserService.isAdmin(),

      builder: (context, snapshot) {

        if (snapshot.data != true) {

          return const SizedBox();
        }

        return _card(

          context,

          Icons.picture_as_pdf,

          "تصدير PDF",

          Colors.red,

          const ExportDatabasePdfScreen(),
        );
      },
    ),

    FutureBuilder<bool>(

      future: UserService.isAdmin(),

      builder: (context, snapshot) {

        if (snapshot.data != true) {

          return const SizedBox();
        }

        return _card(

          context,

          Icons.analytics,

          "التقرير السنوي",

          Colors.blue,

          const AnnualReportScreen(),
        );
      },
    ),

    FutureBuilder<bool>(

      future: UserService.isAdmin(),

      builder: (context, snapshot) {

        if (snapshot.data != true) {

          return const SizedBox();
        }

        return _card(

          context,

          Icons.cleaning_services,

          "تنظيف العمليات",

          Colors.red,

          const OperationsCleanupScreen(),
        );
      },
    ),

   
  ],
),
 
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= CARD =================

  Widget _card(

    BuildContext context,

    IconData icon,

    String title,

    Color color,

    Widget page,
  ) {
final screenWidth =
    MediaQuery.of(context).size.width;

final titleFontSize =
    screenWidth < 360
        ? 13.0
        : screenWidth < 400
            ? 15.0
            : 17.0;
         return GestureDetector(

  onTap: () async {

    if (title == "خروج") {

      await AuthService.logout();

     if (context.mounted) {

  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

      builder: (_) =>
          const LoginScreen(),
    ),
  );
}

      return;
    }

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => page,
      ),
    );
  },

  child: AnimatedContainer(


  width: (screenWidth - 70) / 2,
height: 160,

  duration:
      const Duration(
    milliseconds: 250,
  ),

        decoration:
            BoxDecoration(

          color: Colors.white,

          border: Border.all(

            color:
                Colors.white
                    .withOpacity(0.6),

            width: 1.2,
          ),

          borderRadius:
              BorderRadius.circular(
            32,
          ),

          boxShadow: [

            BoxShadow(

              color:
                  color.withOpacity(
                0.10,
              ),

              blurRadius: 30,

              offset:
                  const Offset(
                0,
                10,
              ),
            ),
          ],
        ),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

         Container(

  padding: EdgeInsets.all(
    screenWidth < 360 ? 14 : 18,
  ),

  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        color.withOpacity(0.25),
        color.withOpacity(0.10),
      ],
    ),
    shape: BoxShape.circle,
  ),

  child: Icon(
    icon,
    color: color,
    size: screenWidth < 360 ? 34 : 42,
  ),
),

            const SizedBox(
              height: 18,
            ),

            Text(
  title,
  textAlign: TextAlign.center,
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    fontSize: titleFontSize,
    fontWeight: FontWeight.bold,
  ),
),
          ],
        ),
      ),
    );
  }
}