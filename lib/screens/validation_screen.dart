import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/pdf_service.dart';

class ValidationScreen extends StatelessWidget {

  const ValidationScreen({super.key});

  // =========================
  // ✅ APPROVE OPERATION
  // =========================

  Future<void> approveOperation(
    String docId,
    Map<String, dynamic> data,
  ) async {

    try {

      final paymentType =
          data["paymentType"]
              ?.toString() ?? "";

      final amount =
          double.tryParse(
            data["amount"]
                .toString(),
          ) ?? 0;

      final name =
          data["name"]
              ?.toString() ?? "";

      final phone =
          data["phone"]
              ?.toString() ?? "";

      final purpose =
          data["purpose"]
              ?.toString() ?? "";

      // =========================
      // 💳 MONTHLY
      // =========================

      if (paymentType == "monthly") {

        final category =
            data["category"] ?? 500;

        final months =
            data["months"] ?? 1;

        final result =
            await FirebaseFirestore
                .instance
                .collection(
                  "subscriptions",
                )
                .where(
                  "phone",
                  isEqualTo: phone,
                )
                .get();

        if (result.docs.isNotEmpty) {

          final doc =
              result.docs.first;

          final subData =
              doc.data();

          final paidMonths =
              subData["paidMonths"] ?? 0;

          final lateMonths =
              subData["lateMonths"] ?? 0;

          final totalLate =
              subData["totalLate"] ?? 0;

          await FirebaseFirestore
              .instance
              .collection(
                "subscriptions",
              )
              .doc(doc.id)
              .update({

            "paidMonths":
                paidMonths + months,

            "lateMonths":
                lateMonths > months
                    ? lateMonths - months
                    : 0,

            "totalLate":
                totalLate > amount
                    ? totalLate - amount
                    : 0,
          });

        } else {

          await FirebaseFirestore
              .instance
              .collection(
                "subscriptions",
              )
              .add({

            "fullName":
                name,

            "phone":
                phone,

            "category":
                category,

            "monthlyAmount":
                category,

            "paidMonths":
                months,

            "lateMonths":
                0,

            "totalLate":
                0,

            "createdAt":
                FieldValue
                    .serverTimestamp(),
          });
        }
      }

      // =========================
      // 💝 DONATION
      // =========================

      if (paymentType == "donation") {

        await FirebaseFirestore
            .instance
            .collection(
              "donations",
            )
            .add({

          "fullName":
              name,

          "phone":
              phone,

          "amount":
              amount,

          "purpose":
              purpose,

          "operationId":
              docId,

          "createdAt":
              FieldValue
                  .serverTimestamp(),
        });
      }

      // =========================
      // 📦 PANEL
      // =========================

      if (paymentType == "panel") {

        await FirebaseFirestore
            .instance
            .collection(
              "lawha",
            )
            .add({

          "fullName":
              name,

          "phone":
              phone,

          "amount":
              amount,

          "purpose":
              purpose,

          "operationId":
              docId,

          "createdAt":
              FieldValue
                  .serverTimestamp(),
        });
      }

      // =========================
      // 📜 TRANSACTION
      // =========================

      await FirebaseFirestore
          .instance
          .collection(
            "transactions",
          )
          .add({

        "name":
            name,

        "phone":
            phone,

        "paymentType":
            paymentType,

        "type":
            "add",

        "amount":
            amount,

        "purpose":
            purpose,

        "operationId":
            docId,

        "status":
            "approved",

        "createdAt":
            FieldValue
                .serverTimestamp(),
      });

      // =========================
      // 💰 UPDATE BALANCE
      // =========================

      final financeRef =
          FirebaseFirestore
              .instance
              .collection(
                "finance",
              )
              .doc("main");

      final financeDoc =
          await financeRef.get();

      double currentBalance = 0;

      if (financeDoc.exists) {

        final financeData =
            financeDoc.data() ?? {};

        currentBalance =
            double.tryParse(
              financeData["balance"]
                  .toString(),
            ) ?? 0;
      }

      final newBalance =
          currentBalance + amount;

      await financeRef.set({

        "balance":
            newBalance,

        "updatedAt":
            FieldValue
                .serverTimestamp(),

      }, SetOptions(
        merge: true,
      ));

      // =========================
      // 🔔 NOTIFICATION COLLECTOR
      // =========================

      final createdByUid =
          data["createdByUid"]
                  ?.toString() ??
              "";

      if (createdByUid.isNotEmpty) {

        await FirebaseFirestore
            .instance
            .collection(
              "notifications",
            )
            .add({

          "userId":
              createdByUid,

          "title":
              "✅ تم قبول العملية",

          "body":
              "تمت الموافقة على الدخل بقيمة $amount MRU",

          "read":
              false,

          "createdAt":
              FieldValue
                  .serverTimestamp(),
        });
      }

      // =========================
      // 🔔 GLOBAL INFORMATION
      // =========================

      await FirebaseFirestore
          .instance
          .collection(
            "notifications",
          )
          .add({

        "title":
            "💰 تم تسديد حالة",

        "body":
            "الاسم: $name\n"
            "الهاتف: $phone\n"
            "المبلغ: $amount MRU\n"
            "النوع: $paymentType\n"
            "الغرض: $purpose",

        "type":
            "global_info",

        "forAll":
            true,

        "read":
            false,

        "createdAt":
            FieldValue
                .serverTimestamp(),
      });

      // =========================
      // 🖨 PDF
      // =========================

      try {

        await PdfService
            .printReceipt(

          name:
              name,

          phone:
              phone,

          type:
              paymentType,

          amount:
              amount.toInt(),

          date:
              DateTime.now()
                  .toString(),
        );

      } catch (e) {

        print(
          "PDF ERROR = $e",
        );
      }

      // =========================
      // ✅ UPDATE STATUS
      // =========================

      await FirebaseFirestore
          .instance
          .collection(
            "operations",
          )
          .doc(docId)
          .update({

        "status":
            "approved",

        "validatedAt":
            FieldValue
                .serverTimestamp(),
      });

      print(
        "✅ VALIDATION OK",
      );

    } catch (e) {

      print(
        "❌ ERROR = $e",
      );
    }
  }

  // =========================
  // ❌ REJECT
  // =========================

  Future<void> rejectOperation(
    String docId,
  ) async {

    try {

      await FirebaseFirestore
          .instance
          .collection(
            "operations",
          )
          .doc(docId)
          .update({

        "status":
            "rejected",

        "rejectedAt":
            FieldValue
                .serverTimestamp(),
      });

    } catch (e) {

      print(
        "REJECT ERROR = $e",
      );
    }
  }

  // =========================
  // BUILD
  // =========================

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
          "التحقق من العمليات",
        ),

        centerTitle: true,
      ),

      body:
          StreamBuilder<QuerySnapshot>(

        stream:
            FirebaseFirestore
                .instance
                .collection(
                  "operations",
                )
                .where(
                  "status",
                  isEqualTo:
                      "pending",
                )
                .orderBy(
                  "createdAt",
                  descending: true,
                )
                .snapshots(),

        builder: (
          context,
          snapshot,
        ) {

          if (snapshot.hasError) {

            return Center(
              child: Text(
                snapshot.error
                    .toString(),
              ),
            );
          }

          if (!snapshot.hasData) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data!.docs;

          if (docs.isEmpty) {

            return const Center(
              child: Text(
                "لا توجد عمليات معلقة",
              ),
            );
          }

          return ListView.builder(

            padding:
                const EdgeInsets
                    .all(16),

            itemCount:
                docs.length,

            itemBuilder:
                (
              context,
              index,
            ) {

              final doc =
                  docs[index];

              final data =
                  doc.data()
                          as Map<
                              String,
                              dynamic>? ??
                      {};

              final name =
                  data["name"]
                          ?.toString() ??
                      "";

              final phone =
                  data["phone"]
                          ?.toString() ??
                      "";

              final type =
                  data["paymentType"]
                          ?.toString() ??
                      "";

              final amount =
                  data["amount"]
                          ?.toString() ??
                      "0";

              final purpose =
                  data["purpose"]
                          ?.toString() ??
                      "";

              return Container(

                margin:
                    const EdgeInsets
                        .only(
                  bottom: 16,
                ),

                padding:
                    const EdgeInsets
                        .all(18),

                decoration:
                    BoxDecoration(

                  color:
                      Colors.white,

                  borderRadius:
                      BorderRadius
                          .circular(
                    24,
                  ),
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(

                      name,

                      style:
                          const TextStyle(

                        fontSize: 20,

                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      phone,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _row(
                      "النوع",
                      type,
                    ),

                    _row(
                      "المبلغ",
                      "$amount MRU",
                    ),

                    if (purpose
                        .isNotEmpty)

                      _row(
                        "الغرض",
                        purpose,
                      ),

                    const SizedBox(
                      height: 18,
                    ),

                    Row(

                      children: [

                        Expanded(

                          child:
                              ElevatedButton.icon(

                            style:
                                ElevatedButton
                                    .styleFrom(

                              backgroundColor:
                                  Colors.green,
                            ),

                            onPressed:
                                () async {

                              await approveOperation(
                                doc.id,
                                data,
                              );

                              if (!context
                                  .mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(

                                const SnackBar(
                                  content: Text(
                                    "✅ تمت الموافقة",
                                  ),
                                ),
                              );
                            },

                            icon:
                                const Icon(
                              Icons.check,
                            ),

                            label:
                                const Text(
                              "موافقة + PDF",
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(

                          child:
                              ElevatedButton.icon(

                            style:
                                ElevatedButton
                                    .styleFrom(

                              backgroundColor:
                                  Colors.red,
                            ),

                            onPressed:
                                () async {

                              await rejectOperation(
                                doc.id,
                              );

                              if (!context
                                  .mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(

                                const SnackBar(
                                  content: Text(
                                    "❌ تم الرفض",
                                  ),
                                ),
                              );
                            },

                            icon:
                                const Icon(
                              Icons.close,
                            ),

                            label:
                                const Text(
                              "رفض",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _row(
    String title,
    String value,
  ) {

    return Padding(

      padding:
          const EdgeInsets
              .symmetric(
        vertical: 4,
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [

          Text(title),

          Text(

            value,

            style:
                const TextStyle(

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}