import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_service.dart';
import '../utils/workflow.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
  });

  // ================= CARD =================

  Widget buildCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        18,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.05,
            ),

            blurRadius: 12,

            offset: const Offset(
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

          /// ICON
          CircleAvatar(
            radius: 30,

            backgroundColor:
                color.withOpacity(
              0.15,
            ),

            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          /// VALUE
         FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(
    value,
    textAlign: TextAlign.center,
    maxLines: 2,
    style: const TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
  ),
),

          const SizedBox(
            height: 10,
          ),

          /// TITLE
         Text(
  title,
  textAlign: TextAlign.center,
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
    color: Colors.grey.shade700,
    fontWeight: FontWeight.w600,
    fontSize: 15,
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

      body:
          StreamBuilder<QuerySnapshot>(

        stream:
            FirestoreService
                .getCases(),

        builder: (
          context,
          snapshot,
        ) {

          // ================= LOADING =================

          if (snapshot.connectionState ==
              ConnectionState
                  .waiting) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          // ================= ERROR =================

          if (snapshot.hasError) {

            return Center(
              child: Text(
                "Erreur : ${snapshot.error}",
              ),
            );
          }

          // ================= EMPTY =================

          if (!snapshot.hasData ||
              snapshot.data == null) {

            return const Center(
              child: Text(
                "لا توجد بيانات",
              ),
            );
          }

          final cases =
              snapshot.data!;

          // ================= COUNTERS =================

          int total = 0;

int submitted = 0;

int paid = 0;

int standardCases = 0;

int committeeCases = 0;

int exceptionalCases = 0;

double totalPaidAmount = 0;

total = cases.docs.length;

for (var c in cases.docs) {

  final data =
      c.data()
          as Map<String, dynamic>;

  final status =
      data["status"]
              ?.toString() ??
          "";

  final procedureType =
      data["procedureType"]
              ?.toString() ??
          "";

  if (status ==
      Workflow.submitted) {
    submitted++;
  }

  if (status ==
      Workflow.paid) {

    paid++;

    totalPaidAmount +=
        (data["paidAmount"] ?? 0)
            .toDouble();
  }

  if (procedureType ==
      "standard_procedure") {
    standardCases++;
  }

  if (procedureType ==
      "committee_evaluation") {
    committeeCases++;
  }

  if (procedureType ==
      "exceptional_case") {
    exceptionalCases++;
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

             childAspectRatio: 0.90,

             children: [

  buildCard(
  title: "إجمالي الحالات ",
  value: total.toString(),
  color: Colors.grey,
  icon: Icons.folder,
),

 buildCard(
  title: "عدد الحلات قيد الدراسة",
  value: submitted.toString(),
  color: Colors.orange,
  icon: Icons.hourglass_top,
),

buildCard(
  title: "عدد الحلات المعوضة",
  value: paid.toString(),
  color: Colors.green,
  icon: Icons.payments,
),

buildCard(
  title: "العدد حسب المسطرة العادية",
  value: standardCases.toString(),
  color: Colors.blue,
  icon: Icons.description,
),



buildCard(
  title: "العدد حسب الدعم الاستثنائي",
  value: exceptionalCases.toString(),
  color: Colors.purple,
  icon: Icons.star,
),

  buildCard(
  title: "إجمالي المبالغ المصروفة",
  value: totalPaidAmount.toInt().toString(),
  color: Colors.red,
  icon: Icons.account_balance_wallet,
),
],
            ),
          );
        },
      ),
    );
  }
}