import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionsScreen extends StatelessWidget {

  const SubscriptionsScreen({
    super.key,
  });
Future<int> getAnnualRecoveryRate() async {

  final peopleSnapshot =
      await FirebaseFirestore.instance
          .collection("people")
          .get();

  final statsSnapshot =
      await FirebaseFirestore.instance
          .collection("subscription_stats")
          .get();

  int annualExpected = 0;
  int totalCollected = 0;

  for (final doc in peopleSnapshot.docs) {

    final data = doc.data();

    annualExpected +=
        ((data["monthlyAmount"] ?? 0)
                as num)
            .toInt() *
        12;
  }

  for (final doc in statsSnapshot.docs) {

    final data = doc.data();

    totalCollected +=
        ((data["totalPaid"] ?? 0)
                as num)
            .toInt();
  }

  if (annualExpected == 0) {
    return 0;
  }

  return ((totalCollected /
              annualExpected) *
          100)
      .clamp(0, 100)
      .toInt();
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F6FA,
      ),

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
            Colors.white,

        foregroundColor:
            Colors.black,

        centerTitle: true,

        title: const Text(

          "المساهمات",

          style: TextStyle(

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body:
          StreamBuilder<
              QuerySnapshot>(

        stream:
            FirebaseFirestore
                .instance
                .collection(
                  "subscription_stats",
                )
                .snapshots(),

        builder: (
          context,
          snapshot,
        ) {

          if (snapshot
                  .connectionState ==
              ConnectionState
                  .waiting) {

            return const Center(

              child:
                  CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!
                  .docs
                  .isEmpty) {

            return const Center(

              child: Text(
                "لا توجد بيانات",
              ),
            );
          }

          final docs =
              snapshot.data!.docs;

          int totalExpected = 0;

          int totalCollected = 0;

          int totalDebt = 0;

          int totalAdvance = 0;

         for (final doc in docs) {

  final data =
      doc.data()
          as Map<String, dynamic>;

  totalExpected +=
      (data["expectedAmount"] ?? 0)
          as int;

  totalCollected +=
      (data["totalPaid"] ?? 0)
          as int;

  totalDebt +=
      (data["debt"] ?? 0)
          as int;

  totalAdvance +=
      (data["advance"] ?? 0)
          as int;
}
          

         final collectedUntilToday =
    totalCollected - totalAdvance;

final collectionRate =
    totalExpected == 0
        ? 0
        : ((collectedUntilToday / totalExpected) * 100)
            .clamp(0, 100)
            .toInt();

          return SafeArea(

            child:
                SingleChildScrollView(

              padding:
                  const EdgeInsets
                      .all(
                16,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  _headerCard(),

                  const SizedBox(
                    height: 24,
                  ),

                  Row(

                    children: [

                      _dashboardCard(

                        title:
                            "المبلغ المتوقع حتى اليوم",

                        value:
                            "$totalExpected MRU",

                        description:
                            "إجمالي الإشتراكات المطلوبة حتى اليوم",

                        icon:
                            Icons.account_balance_wallet,

                        color:
                            const Color(
                          0xFF34C759,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      _dashboardCard(

                        title:
                            "المبلغ المحصل",

                        value:
                            "$totalCollected MRU",

                        description:
                            "إجمالي التحصيلات",

                        icon:
                            Icons.check_circle,

                        color:
                            const Color(
                          0xFF0A84FF,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Row(

                    children: [

                      _dashboardCard(

  title:
      "الرصيد المسبق",

  value:
      "$totalAdvance MRU",

  description:
      "المبالغ المدفوعة مقدماً",

  icon:
      Icons.trending_up,

  color:
      const Color(
    0xFFAF52DE,
  ),
),
                      const SizedBox(
                        width: 12,
                      ),

                      _dashboardCard(

                        title:
                            "إجمالي الديون",

                        value:
                            "$totalDebt MRU",

                        description:
                            "إجمالي الديون الحالية",

                        icon:
                            Icons.warning,

                        color:
                            const Color(
                          0xFFFF453A,
                        ),
                      ),
                    ],
                  ),

                  
            
                  const SizedBox(
                    height: 24,
                  ),

                  FutureBuilder<int>(

  future:
      getAnnualRecoveryRate(),

  builder:
      (context, annualSnapshot) {

    final annualRate =
        annualSnapshot.data ?? 0;

    return _summaryCard(

      collectionRate:
          collectionRate,

      annualRate:
          annualRate,
    );
  },
)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _headerCard() {

    return Container(

      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        24,
      ),

      decoration:
          BoxDecoration(

        gradient:
            const LinearGradient(

          colors: [

            Color(
              0xFF6C4DFF,
            ),

            Color(
              0xFF3F2DBF,
            ),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          30,
        ),
      ),

      child: const Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Icon(

            Icons.analytics,

            color:
                Colors.white,

            size: 38,
          ),

          SizedBox(
            height: 18,
          ),

          Text(

            "الوضعية السنوية",

            style: TextStyle(

              color:
                  Colors.white,

              fontSize: 28,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _dashboardCard({

    required String title,

    required String value,

    required String description,

    required IconData icon,

    required Color color,
  }) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.all(
          20,
        ),

        decoration:
            BoxDecoration(

          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            26,
          ),
        ),

        child: Column(

          children: [

            Icon(

              icon,

              color:
                  color,

              size: 32,
            ),

            const SizedBox(
              height: 14,
            ),

            Text(

              value,

              textAlign:
                  TextAlign.center,

              style: TextStyle(

                color:
                    color,

                fontSize: 20,

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

              style: TextStyle(

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(

              description,

              textAlign:
                  TextAlign.center,

              style: TextStyle(

                color:
                    Colors.grey
                        .shade600,

                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

   
  static Widget _summaryCard({
  required int collectionRate,
  required int annualRate,
}) {

    return Container(

      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        24,
      ),

      decoration:
          BoxDecoration(

        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          30,
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          const Text(

            "ملخص الوضعية",

            style: TextStyle(

              fontSize: 22,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Text(
  "نسبة التغطية حتى اليوم",



            style: TextStyle(

              color:
                  Colors.grey
                      .shade700,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ClipRRect(

            borderRadius:
                BorderRadius.circular(
              20,
            ),

            child:
                LinearProgressIndicator(

              value:
                  collectionRate / 100,

              minHeight:
                  12,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(

            "$collectionRate%",

            style: const TextStyle(

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(
  height: 24,
),

Text(
  "نسبة التحصيل السنوية",
  style: TextStyle(
    color: Colors.grey.shade700,
  ),
),

const SizedBox(
  height: 12,
),

ClipRRect(
  borderRadius:
      BorderRadius.circular(20),
  child: LinearProgressIndicator(
    value: annualRate / 100,
    minHeight: 12,
  ),
),

const SizedBox(
  height: 12,
),

Text(
  "$annualRate%",
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
        ],
      ),
    );
  }
}