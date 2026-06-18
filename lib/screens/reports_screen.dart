import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Future<Map<String, dynamic>> getReports() async {

    final snapshot =
        await FirebaseFirestore
            .instance
            .collection("transactions")
            .where(
              "isDeleted",
              isEqualTo: false,
            )
            .get();

    double monthlyTotal = 0;
    double donationTotal = 0;
    double panelTotal = 0;

    int monthlyCount = 0;
    int donationCount = 0;
    int panelCount = 0;

    for (var doc in snapshot.docs) {

      final data = doc.data();

      // ✅ uniquement les ajouts
      final type =
          data["type"]
              ?.toString()
              .trim()
              .toLowerCase() ?? "";

      if (type != "add") {
        continue;
      }

      // ✅ payment type
      final paymentType =
          data["paymentType"]
              ?.toString()
              .trim()
              .toLowerCase() ?? "";

      final amount =
          double.tryParse(
                data["amount"]
                    .toString(),
              ) ??
              0;

      // =========================
      // 💳 اشتراكات
      // =========================

      if (
          paymentType == "monthly" ||
          paymentType == "subscription"
      ) {

        monthlyTotal += amount;

        monthlyCount++;
      }

      // =========================
      // ❤️ تبرعات
      // =========================

      else if (
          paymentType == "donation"
      ) {

        donationTotal += amount;

        donationCount++;
      }

      // =========================
      // 📦 لوحة
      // =========================

      else if (
          paymentType == "panel"
      ) {

        panelTotal += amount;

        panelCount++;
      }
    }

    return {

      "monthlyTotal":
          monthlyTotal,

      "donationTotal":
          donationTotal,

      "panelTotal":
          panelTotal,

      "monthlyCount":
          monthlyCount,

      "donationCount":
          donationCount,

      "panelCount":
          panelCount,
    };
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(

        title: const Text(
          "التقارير",
        ),

        centerTitle: true,
      ),

      body:
          FutureBuilder<
              Map<String, dynamic>>(

        future: getReports(),

        builder:
            (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(

              child:
                  CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!;

          final total =
              data["monthlyTotal"] +
              data["donationTotal"] +
              data["panelTotal"];

          return ListView(

            padding:
                const EdgeInsets.all(16),

            children: [

              // =========================
              // 💳 اشتراكات
              // =========================

              _card(

                "الاشتراكات",

                data["monthlyTotal"],

                data["monthlyCount"],

                Colors.blue,
              ),

              // =========================
              // ❤️ تبرعات
              // =========================

              _card(

                "التبرعات",

                data["donationTotal"],

                data["donationCount"],

                Colors.green,
              ),

              // =========================
              // 📦 لوحة
              // =========================

              _card(

                "اللوحة",

                data["panelTotal"],

                data["panelCount"],

                Colors.purple,
              ),

              const SizedBox(
                height: 20,
              ),

              // =========================
              // 📊 TOTAL
              // =========================

              Card(

                elevation: 2,

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),

                child: ListTile(

                  leading:
                      const Icon(
                    Icons.summarize,
                    size: 30,
                  ),

                  title:
                      const Text(

                    "المجموع الكلي",

                    style: TextStyle(

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 18,
                    ),
                  ),

                  trailing:
                      Text(

                    "${total.toStringAsFixed(0)} MRU",

                    style:
                        const TextStyle(

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================
  // CARD
  // =========================

  Widget _card(
    String title,
    double total,
    int count,
    Color color,
  ) {

    return Card(

      elevation: 2,

      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),

      child: ListTile(

        contentPadding:
            const EdgeInsets.all(16),

        leading:
            Icon(

          Icons.analytics,

          color: color,

          size: 34,
        ),

        title:
            Text(

          title,

          style:
              const TextStyle(

            fontWeight:
                FontWeight.bold,

            fontSize: 20,
          ),
        ),

        subtitle:
            Padding(

          padding:
              const EdgeInsets.only(
            top: 8,
          ),

          child: Text(

            "عدد العمليات: $count",

            style:
                const TextStyle(
              fontSize: 16,
            ),
          ),
        ),

        trailing:
            Text(

          "${total.toStringAsFixed(0)} MRU",

          style: TextStyle(

            color: color,

            fontWeight:
                FontWeight.bold,

            fontSize: 18,
          ),
        ),
      ),
    );
  }
}