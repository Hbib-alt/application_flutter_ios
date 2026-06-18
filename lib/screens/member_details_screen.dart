import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberDetailsScreen extends StatelessWidget {
  final String personId;

  const MemberDetailsScreen({
    super.key,
    required this.personId,
  });

  static const List<String> monthNames = [
    "",
    "يناير",
    "فبراير",
    "مارس",
    "أبريل",
    "مايو",
    "يونيو",
    "يوليو",
    "أغسطس",
    "سبتمبر",
    "أكتوبر",
    "نوفمبر",
    "ديسمبر",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text(
          "تفاصيل الزبون",
        ),
        centerTitle: true,
      ),

      body: FutureBuilder(

        future: Future.wait([

          FirebaseFirestore.instance
              .collection("people")
              .doc(personId)
              .get(),

          FirebaseFirestore.instance
              .collection(
                "subscription_stats",
              )
              .doc(personId)
              .get(),
        ]),

        builder: (
          context,
          snapshot,
        ) {

          if (!snapshot.hasData) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final personDoc =
              snapshot.data![0]
                  as DocumentSnapshot;

          final statsDoc =
              snapshot.data![1]
                  as DocumentSnapshot;

          if (!personDoc.exists) {

            return const Center(
              child: Text(
                "الزبون غير موجود",
              ),
            );
          }

          final person =
              personDoc.data()
                  as Map<String, dynamic>;

          final stats =
              statsDoc.exists
                  ? statsDoc.data()
                      as Map<String,
                          dynamic>
                  : <String,
                      dynamic>{};

          final paidMonths =
              List<int>.from(
            stats["paidMonthsList"] ??
                [],
          );

          final missingMonths =
              List<int>.from(
            stats["missingMonths"] ??
                [],
          );

          
final currentMonth =
    DateTime.now().month;

final futureMonths =
    paidMonths
        .where(
          (m) => m > currentMonth,
        )
        .toList()
      ..sort();
final monthlyAmount =
    (person["monthlyAmount"] ?? 0)
        as int;

final dynamicAdvance =
    futureMonths.length *
        monthlyAmount;

          return ListView(

            padding:
                const EdgeInsets.all(
              16,
            ),

            children: [

              // ================= INFO =================

              Card(

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Padding(

                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  child: Column(

                    children: [

                      const CircleAvatar(

                        radius: 40,

                        child: Icon(
                          Icons.person,
                          size: 40,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(

                        person["name"] ??
                            "",

                        style:
                            const TextStyle(

                          fontSize: 24,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        person["phone"] ??
                            "",
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Container(

                        padding:
                            const EdgeInsets
                                .symmetric(

                          horizontal:
                              16,

                          vertical: 8,
                        ),

                        decoration:
                            BoxDecoration(

                          color: Colors
                              .deepPurple
                              .withOpacity(
                            0.1,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            30,
                          ),
                        ),

                        child: Text(

                          "الفئة : ${person["monthlyAmount"] ?? 0} MRU",

                          style:
                              const TextStyle(

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // ================= FINANCE =================

              Card(

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Padding(

                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

  const Text(
    "الوضعية المالية",
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(
    height: 16,
  ),

  Text(
    "💰 المبلغ المدفوع : ${stats["totalPaid"] ?? 0} MRU",
  ),

  const SizedBox(
    height: 8,
  ),

  Text(
    "⚠️ الديون : ${stats["debt"] ?? 0} MRU",
  ),

  const SizedBox(
    height: 8,
  ),

  Text(
    "🔵 الرصيد المسبق : $dynamicAdvance MRU",
  ),
],
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // ================= PAID =================

              _monthsCard(
                title:
                    "✅ الأشهر المدفوعة",
                months:
                    paidMonths,
                color:
                    Colors.green,
              ),

              const SizedBox(
                height: 12,
              ),

              // ================= MISSING =================

              _monthsCard(
                title:
                    "❌ الأشهر غير المدفوعة",
                months:
                    missingMonths,
                color:
                    Colors.red,
              ),

              const SizedBox(
                height: 12,
              ),

              // ================= FUTURE =================

              _monthsCard(
                title:
                    "🔵 الأشهر المدفوعة مسبقاً",
                months:
                    futureMonths,
                color:
                    Colors.blue,
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _monthsCard({

    required String title,

    required List<int> months,

    required Color color,
  }) {

    return Card(

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text(

              title,

              style:
                  const TextStyle(

                fontSize: 18,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            if (months.isEmpty)

              const Text(
                "لا توجد بيانات",
              )

            else

              Wrap(

                spacing: 8,

                runSpacing: 8,

                children: months
                    .map(

                  (month) {

                    return Chip(

                      backgroundColor:
                          color
                              .withOpacity(
                        0.1,
                      ),

                      label: Text(

                        monthNames[
                            month],

                        style:
                            TextStyle(
                          color:
                              color,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
          ],
        ),
      ),
    );
  }
}