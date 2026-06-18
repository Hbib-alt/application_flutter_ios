import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CaisseScreen extends StatelessWidget {

  const CaisseScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(

        centerTitle: true,

        elevation: 0,

        backgroundColor:
            Colors.white,

        foregroundColor:
            Colors.black,

        title: const Text(

          "💰 الصندوق",

          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body:
          StreamBuilder<QuerySnapshot>(

        stream:
            FirebaseFirestore
                .instance
                .collection(
                  "transactions",
                )
                .snapshots(),

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

          final transactions =
              snapshot.data!.docs;

          // =========================
          // TOTALS
          // =========================

          double totalIn = 0;

          double totalOut = 0;

          // =========================
          // UNIQUE CLIENTS
          // =========================

          final uniqueClients =
              <String>{};

          for (final doc in transactions) {

            final data =
                doc.data()
                    as Map<String, dynamic>;

            // =========================
            // IGNORE DELETED
            // =========================

            if (data["isDeleted"] ==
                true) {

              continue;
            }

            // =========================
            // AMOUNT
            // =========================

            final amount =
                double.tryParse(

                      data["amount"]
                          .toString(),
                    ) ??
                    0;

            // =========================
            // TYPE
            // =========================

            final type =
                data["type"]
                        ?.toString()
                        .trim()
                        .toLowerCase() ??
                    "";

            // =========================
            // PERSON ID
            // =========================

            final personId =
                data["personId"]
                        ?.toString() ??
                    "";

            // =========================
            // UNIQUE CLIENTS
            // =========================

            if (personId.isNotEmpty) {

              uniqueClients.add(
                personId,
              );
            }

            // =========================
            // INCOME
            // =========================

            if (type == "add") {

              totalIn += amount;
            }

            // =========================
            // EXPENSES
            // =========================

            else if (
    type == "remove" ||
    type == "health_case_payment") {

  totalOut += amount;
            }
          }

          // =========================
          // TOTAL CLIENTS
          // =========================

          final totalClients =
              uniqueClients.length;

          // =========================
          // REAL BALANCE
          // =========================

          final balance =
              totalIn - totalOut;

          return SingleChildScrollView(

            child: Padding(

              padding:
                  const EdgeInsets.all(
                16,
              ),

              child: Column(

                children: [

                  _headerCard(

                    balance:
                        balance,

                    totalIn:
                        totalIn,

                    totalOut:
                        totalOut,

                    totalSubscribers:
                        totalClients,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================
  // HEADER CARD
  // =========================

  Widget _headerCard({

    required double balance,

    required double totalIn,

    required double totalOut,

    required int totalSubscribers,
  }) {

    return Container(

      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        26,
      ),

      decoration:
          BoxDecoration(

        gradient:
            const LinearGradient(

          colors: [

            Color(0xFF0F172A),

            Color(0xFF1E293B),

            Color(0xFF334155),
          ],

          begin:
              Alignment.topLeft,

          end:
              Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(
          34,
        ),

        boxShadow: [

          BoxShadow(

            color:
                Colors.black
                    .withOpacity(
              0.18,
            ),

            blurRadius: 30,

            offset:
                const Offset(
              0,
              14,
            ),
          ),
        ],
      ),

      child: Column(

        children: [

          // =========================
          // ICON
          // =========================

          Container(

            width: 120,

            height: 120,

            decoration:
                BoxDecoration(

              gradient:
                  LinearGradient(

                colors: [

                  Colors.green
                      .shade400,

                  Colors.green
                      .shade700,
                ],
              ),

              shape:
                  BoxShape.circle,

              boxShadow: [

                BoxShadow(

                  color:
                      Colors.green
                          .withOpacity(
                    0.35,
                  ),

                  blurRadius: 25,

                  offset:
                      const Offset(
                    0,
                    10,
                  ),
                ),
              ],
            ),

            child: const Icon(

              Icons
                  .account_balance_wallet,

              color:
                  Colors.white,

              size: 60,
            ),
          ),

          const SizedBox(
            height: 26,
          ),

          // =========================
          // TITLE
          // =========================

          const Text(

            "الصندوق",

            style: TextStyle(

              fontSize: 36,

              fontWeight:
                  FontWeight.bold,

              color:
                  Colors.white,
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // =========================
          // BALANCE
          // =========================

          Container(

            width:
                double.infinity,

            padding:
                const EdgeInsets
                    .symmetric(

              vertical: 22,

              horizontal: 20,
            ),

            decoration:
                BoxDecoration(

              gradient:
                  LinearGradient(

                colors: [

                  Colors.green
                      .shade500,

                  Colors.green
                      .shade700,
                ],
              ),

              borderRadius:
                  BorderRadius
                      .circular(
                24,
              ),
            ),

            child: Column(

              children: [

                const Text(

                  "الرصيد الحالي",

                  style: TextStyle(

                    fontSize: 16,

                    fontWeight:
                        FontWeight.bold,

                    color:
                        Colors.white70,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(

                  "${balance.toStringAsFixed(0)} MRU",

                  style:
                      const TextStyle(

                    fontSize: 42,

                    fontWeight:
                        FontWeight.bold,

                    color:
                        Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          // =========================
          // CLIENTS
          // =========================

          _modernStatItem(

            icon:
                Icons.people,

            title:
                "عدد الزبناء",

            value:
                totalSubscribers
                    .toString(),

            color:
                const Color(
              0xFF3B82F6,
            ),
          ),

          const SizedBox(
            height: 30,
          ),

          // =========================
          // TOTALS
          // =========================

          Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceAround,

            children: [

              _modernStatItem(

                icon:
                    Icons
                        .arrow_downward,

                title:
                    "الإيرادات",

                value:
                    totalIn
                        .toStringAsFixed(
                  0,
                ),

                color:
                    const Color(
                  0xFF22C55E,
                ),
              ),

              _modernStatItem(

                icon:
                    Icons
                        .arrow_upward,

                title:
                    "المصاريف",

                value:
                    totalOut
                        .toStringAsFixed(
                  0,
                ),

                color:
                    const Color(
                  0xFFEF4444,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // STAT ITEM
  // =========================

  Widget _modernStatItem({

    required IconData icon,

    required String title,

    required String value,

    required Color color,
  }) {

    return Container(

      padding:
          const EdgeInsets
              .symmetric(

        horizontal: 20,

        vertical: 16,
      ),

      decoration:
          BoxDecoration(

        color:
            Colors.white
                .withOpacity(
          0.08,
        ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),

      child: Column(

        children: [

          Container(

            width: 52,

            height: 52,

            decoration:
                BoxDecoration(

              color:
                  color.withOpacity(
                0.15,
              ),

              shape:
                  BoxShape.circle,
            ),

            child: Icon(

              icon,

              color:
                  color,

              size: 28,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(

            value,

            style:
                const TextStyle(

              color:
                  Colors.white,

              fontSize: 22,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(

            title,

            style: TextStyle(

              color:
                  Colors.grey
                      .shade300,

              fontSize: 13,

              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}