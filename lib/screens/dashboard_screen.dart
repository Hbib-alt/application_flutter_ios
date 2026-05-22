import 'package:flutter/material.dart';

import '../services/firestore_service.dart';

import '../utils/workflow.dart';

class DashboardScreen
    extends StatelessWidget {

  const DashboardScreen({
    super.key,
  });

  // ================= CARD =================

  Widget buildCard({

    required String title,

    required int value,

    required Color color,

    required IconData icon,

  }) {

    return Container(

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black
                    .withOpacity(
              0.05,
            ),

            blurRadius: 10,

            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          CircleAvatar(

            radius: 28,

            backgroundColor:
                color.withOpacity(
              0.15,
            ),

            child: Icon(

              icon,

              color: color,

              size: 28,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(

            value.toString(),

            style:
                const TextStyle(

              fontSize: 28,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(

            title,

            textAlign:
                TextAlign.center,

            style:
                TextStyle(

              color:
                  Colors.grey
                      .shade700,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F6FA,
      ),

      appBar: AppBar(

        title: const Text(
          "📊 Dashboard",
        ),

        centerTitle: true,
      ),

      body: StreamBuilder(

        stream:
            FirestoreService
                .getCases(),

        builder:
            (
              context,
              snapshot,
            ) {

          // ================= LOADING =================

          if (!snapshot.hasData) {

            return const Center(

              child:
                  CircularProgressIndicator(),
            );
          }

          final cases =
              snapshot.data!;

          // ================= COUNTERS =================

          int total = 0;

          int submitted = 0;

          int underReview = 0;

          int committeeApproved = 0;

          int approved = 0;

          int discretionary = 0;

          int paid = 0;

          int rejected = 0;

          total = cases.length;

          for (var c in cases) {

            final status =
                c["status"]
                        ?.toString() ??
                    Workflow
                        .submitted;

            if (status ==
                Workflow
                    .submitted) {

              submitted++;
            }

            if (status ==
                Workflow
                    .underReview) {

              underReview++;
            }

            if (status ==
                Workflow
                    .committeeApproved) {

              committeeApproved++;
            }

            if (status ==
                Workflow
                    .approved) {

              approved++;
            }

            if (status ==
                Workflow
                    .discretionarySupport) {

              discretionary++;
            }

            if (status ==
                Workflow
                    .paid) {

              paid++;
            }

            if (status ==
                Workflow
                    .rejected) {

              rejected++;
            }
          }

          // ================= GRID =================

          return Padding(

            padding:
                const EdgeInsets.all(
              16,
            ),

            child: GridView.count(

              crossAxisCount: 2,

              crossAxisSpacing:
                  14,

              mainAxisSpacing:
                  14,

              childAspectRatio:
                  1.05,

              children: [

                // ================= TOTAL =================

                buildCard(

                  title:
                      "إجمالي الملفات",

                  value: total,

                  color:
                      Colors.grey,

                  icon:
                      Icons.folder,
                ),

                // ================= SUBMITTED =================

                buildCard(

                  title:
                      "قيد الدراسة",

                  value:
                      submitted,

                  color:
                      Colors.orange,

                  icon:
                      Icons.hourglass_top,
                ),

                // ================= REVIEW =================

                buildCard(

                  title:
                      "تحت المراجعة",

                  value:
                      underReview,

                  color:
                      Colors.blue,

                  icon:
                      Icons.search,
                ),

                // ================= COMMITTEE =================

                buildCard(

                  title:
                      "موافقة اللجنة",

                  value:
                      committeeApproved,

                  color:
                      Colors.teal,

                  icon:
                      Icons.groups,
                ),

                // ================= APPROVED =================

                buildCard(

                  title:
                      "مقبولة",

                  value:
                      approved,

                  color:
                      Colors.green,

                  icon:
                      Icons.check_circle,
                ),

                // ================= DISCRETIONARY =================

                buildCard(

                  title:
                      "دعم استثنائي",

                  value:
                      discretionary,

                  color:
                      Colors.purple,

                  icon:
                      Icons.star,
                ),

                // ================= PAID =================

                buildCard(

                  title:
                      "تم الدفع",

                  value:
                      paid,

                  color:
                      Colors.indigo,

                  icon:
                      Icons.payments,
                ),

                // ================= REJECTED =================

                buildCard(

                  title:
                      "مرفوضة",

                  value:
                      rejected,

                  color:
                      Colors.red,

                  icon:
                      Icons.cancel,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}