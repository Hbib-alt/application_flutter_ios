import 'subscriptions_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'change_password_screen.dart';
import 'history_search_screen.dart';

import '../services/user_service.dart';
import '../services/auth_service.dart';

import 'members_screen.dart';
import 'export_database_screen.dart';

import 'export_database_pdf_screen.dart';

// 📌 Écrans
import 'cases_screen.dart';
import 'dashboard_screen.dart';
import 'caisse_screen.dart';
import 'notifications_screen.dart';
import 'late_people_screen.dart';
import 'add_case_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';

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
                  height: 25,
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

                // ================= GRID =================

                GridView.count(

                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  crossAxisCount: 2,

                  crossAxisSpacing:
                      15,

                  mainAxisSpacing:
                      15,

                  childAspectRatio:
                      1.05,

                  children: [

                    _card(
                      context,
                      Icons.add_circle,
                      "إضافة",
                      Colors.teal,
                      const AddCaseScreen(),
                    ),

                    _card(
                      context,
                      Icons.assignment,
                      "العمليات",
                      Colors.blue,
                      const CasesScreen(),
                    ),

                    _card(
                      context,
                      Icons.health_and_safety,
                      "الحالات",
                      Colors.pink,
                      const HealthCasesScreen(),
                    ),

                    _card(
                      context,
                      Icons.bar_chart,
                      "Dashboard",
                      Colors.orange,
                      const DashboardScreen(),
                    ),

                    _card(
                      context,
                      Icons.account_balance_wallet,
                      "الصندوق",
                      Colors.green,
                      const CaisseScreen(),
                    ),

                    _card(
                      context,
                      Icons.analytics,
                      "التقارير",
                      Colors.indigo,
                      const ReportsScreen(),
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
                      Icons.payments,
                      "الاشتراكات العامة",
                      Colors.deepPurple,
                      const SubscriptionsScreen(),
                    ),

                    _card(
                      context,
                      Icons.search,
                      "السجل العام",
                      Colors.brown,
                      const HistorySearchScreen(),
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
  Icons.table_view,
  "تصدير Excel",
  Colors.green,
  const ExportDatabaseScreen(),
),

_card(
  context,
  Icons.picture_as_pdf,
  "تصدير PDF",
  Colors.red,
  const ExportDatabasePdfScreen(),
),
                    // 🚪 LOGOUT

                    GestureDetector(

                      onTap: () async {

                        await AuthService
                            .logout();

                        if (context.mounted) {

                          Navigator.pushReplacement(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  const LoginScreen(),
                            ),
                          );
                        }
                      },

                      child: Container(

                        decoration:
                            BoxDecoration(

                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            32,
                          ),

                          boxShadow: [

                            BoxShadow(

                              color:
                                  Colors.red
                                      .withOpacity(
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

                              padding:
                                  const EdgeInsets.all(
                                18,
                              ),

                              decoration:
                                  BoxDecoration(

                                gradient:
                                    LinearGradient(

                                  colors: [

                                    Colors.red
                                        .withOpacity(
                                      0.25,
                                    ),

                                    Colors.red
                                        .withOpacity(
                                      0.10,
                                    ),
                                  ],
                                ),

                                shape:
                                    BoxShape.circle,
                              ),

                              child: const Icon(

                                Icons.logout,

                                color:
                                    Colors.red,

                                size: 42,
                              ),
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            const Text(

                              "خروج",

                              textAlign:
                                  TextAlign.center,

                              style:
                                  TextStyle(

                                fontSize: 18,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => page,
          ),
        );
      },

      child: AnimatedContainer(

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

              padding:
                  const EdgeInsets.all(
                18,
              ),

              decoration:
                  BoxDecoration(

                gradient:
                    LinearGradient(

                  colors: [

                    color.withOpacity(
                      0.25,
                    ),

                    color.withOpacity(
                      0.10,
                    ),
                  ],
                ),

                shape:
                    BoxShape.circle,
              ),

              child: Icon(

                icon,

                color: color,

                size: 42,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Text(

              title,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(

                fontSize: 18,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}