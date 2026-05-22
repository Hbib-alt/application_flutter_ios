import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LatePeopleScreen extends StatefulWidget {

  const LatePeopleScreen({super.key});

  @override
  State<LatePeopleScreen> createState() =>
      _LatePeopleScreenState();
}

class _LatePeopleScreenState
    extends State<LatePeopleScreen> {

  Future<List<Map<String, dynamic>>>
      getLatePeople() async {

    // ================= CURRENT DATE =================

    final currentMonth =
        DateTime.now().month;

    final currentYear =
        DateTime.now().year;

    // ================= CURRENT USER =================

    final currentUserId =
        FirebaseAuth
            .instance
            .currentUser!
            .uid;

    // ================= PEOPLE OF COLLECTOR =================

    final peopleSnapshot =
        await FirebaseFirestore
            .instance
            .collection("people")
            .where(
              "collectorId",
              isEqualTo:
                  currentUserId,
            )
            .get();

    // ================= MONTHLY PAYMENTS =================

    final paymentsSnapshot =
        await FirebaseFirestore
            .instance
            .collection("operations")
            .where(
              "paymentType",
              isEqualTo:
                  "monthly",
            )
            .where(
              "year",
              isEqualTo:
                  currentYear,
            )
            .get();

    // ================= COUNT MONTHS =================

    Map<String, int>
        paidMonths = {};

    for (var doc
        in paymentsSnapshot.docs) {

      final data =
          doc.data();

      final personId =
          data["personId"];

      final int months =
          ((data["months"] ??
                      1)
                  as num)
              .toInt();

      if (paidMonths
          .containsKey(
              personId)) {

        paidMonths[personId] =
            paidMonths[
                    personId]! +
                months;

      } else {

        paidMonths[personId] =
            months;
      }
    }

    // ================= LATE PEOPLE =================

    List<Map<String, dynamic>>
        latePeople = [];

    for (var doc
        in peopleSnapshot.docs) {

      final data =
          doc.data();

      final paid =
          paidMonths[
                  doc.id] ??
              0;

      // ✅ Ignore completed year

      if (paid >= 12) {
        continue;
      }

      // ✅ Only late people

      if (paid <
          currentMonth) {

        final remaining =
            currentMonth -
                paid;

        latePeople.add({

          "name":
              data["name"],

          "phone":
              data["phone"],

          "remaining":
              remaining,
        });
      }
    }

    return latePeople;
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "المتأخرين",
        ),
      ),

      body: FutureBuilder<
          List<Map<String,
              dynamic>>>(

        future:
            getLatePeople(),

        builder:
            (context, snapshot) {

          if (!snapshot
              .hasData) {

            return const Center(

              child:
                  CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!;

          // ================= EMPTY =================

          if (data.isEmpty) {

            return const Center(

              child: Text(
                "✅ الجميع في المستوى المطلوب",
              ),
            );
          }

          // ================= LIST =================

          return ListView.builder(

            itemCount:
                data.length,

            itemBuilder:
                (context, index) {

              final person =
                  data[index];

              return Card(

                margin:
                    const EdgeInsets
                        .symmetric(

                  horizontal: 12,
                  vertical: 6,
                ),

                child: ListTile(

                  leading:
                      const Icon(

                    Icons.warning,

                    color:
                        Colors.red,
                  ),

                  title: Text(

                    person["name"],

                    style:
                        const TextStyle(

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle:
                      Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(
                        person["phone"],
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(

                        "متأخر ${person["remaining"]} شهر",

                        style:
                            const TextStyle(

                          color:
                              Colors.red,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}