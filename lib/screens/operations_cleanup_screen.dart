import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_service.dart';

class OperationsCleanupScreen
    extends StatefulWidget {

  const OperationsCleanupScreen({
    super.key,
  });

  @override
  State<OperationsCleanupScreen>
      createState() =>
          _OperationsCleanupScreenState();
}

class _OperationsCleanupScreenState
    extends State<
        OperationsCleanupScreen> {

  // ================= DELETE =================

  Future<void>
      deleteOperationSilently(

    String operationId,

  ) async {

    try {

      // ================= GET OPERATION =================

      final operationDoc =

          await FirebaseFirestore
              .instance
              .collection(
                "operations",
              )
              .doc(operationId)
              .get();

      if (!operationDoc.exists) {
        return;
      }

      final data =
          operationDoc.data()!;

      final status =
          data["status"] ?? "";

      final amount =

          (data["amount"] ?? 0)
              .toDouble();

      // ================= HIDE OPERATION =================

      await FirebaseFirestore
          .instance
          .collection(
            "operations",
          )
          .doc(operationId)
          .update({

        "isDeleted": true,

        "deletedAt":
            FieldValue.serverTimestamp(),

        "deletedBy":
            UserService.currentUid,
      });

     // ================= DELETE NOTIFICATIONS =================

final notifications =

    await FirebaseFirestore
        .instance
        .collection(
          "notifications",
        )
        .get();

for (final doc
    in notifications.docs) {

  final notifData =
      doc.data();

  final notifOperationId =

      notifData["operationId"] ??
      notifData["transactionId"] ??
      "";

  if (notifOperationId ==
      operationId) {

    await FirebaseFirestore
        .instance
        .collection(
          "notifications",
        )
        .doc(doc.id)
        .delete();
  }
}
      // ================= UPDATE FINANCE ONLY IF APPROVED =================

      if (status == "approved") {

        final financeRef =

            FirebaseFirestore
                .instance
                .collection(
                  "finance",
                )
                .doc("main");

        final financeDoc =
            await financeRef.get();

        final financeData =
            financeDoc.data() ??
                {};

        final currentBalance =

            (financeData[
                        "balance"] ??
                    0)
                .toDouble();

        final newBalance =
            currentBalance -
                amount;

        await financeRef.update({

          "balance":
              newBalance,

          "updatedAt":
              FieldValue
                  .serverTimestamp(),
        });
      }

      // ================= SUCCESS =================

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            "✅ تم حذف العملية",
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(

          content: Text(
            "Erreur: $e",
          ),
        ),
      );
    }
  }

  // ================= EDIT =================

  Future<void> editOperation({

    required String id,

    required Map<String, dynamic>
        data,

  }) async {

    final amountController =
        TextEditingController(

      text:
          data["amount"]
              .toString(),
    );

    final purposeController =
        TextEditingController(

      text:
          data["purpose"] ?? "",
    );

    await showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            "تعديل العملية",
          ),

          content: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              TextField(

                controller:
                    amountController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    const InputDecoration(

                  labelText:
                      "المبلغ",
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              TextField(

                controller:
                    purposeController,

                decoration:
                    const InputDecoration(

                  labelText:
                      "الهدف",
                ),
              ),
            ],
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                  context,
                );
              },

              child: const Text(
                "إلغاء",
              ),
            ),

            ElevatedButton(

              onPressed: () async {

                await FirebaseFirestore
                    .instance
                    .collection(
                      "operations",
                    )
                    .doc(id)
                    .update({

                  "amount":
                      int.tryParse(
                            amountController
                                .text,
                          ) ??
                          0,

                  "purpose":
                      purposeController
                          .text,
                });

                if (!mounted) return;

                Navigator.pop(
                  context,
                );

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(

                  const SnackBar(

                    content: Text(
                      "✅ تم التعديل",
                    ),
                  ),
                );
              },

              child: const Text(
                "حفظ",
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "تنظيف العمليات",
        ),
      ),

      body: StreamBuilder<

          QuerySnapshot<
              Map<String, dynamic>>>(

       stream:

    FirebaseFirestore
        .instance
        .collection(
          "operations",
        )

        .where(
          "isDeleted",
          isEqualTo: false,
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

          final docs =
              snapshot.data!.docs;

          if (docs.isEmpty) {

            return const Center(

              child: Text(
                "لا توجد عمليات",
              ),
            );
          }

          return ListView.builder(

            itemCount:
                docs.length,

            itemBuilder:
                (context, index) {

              final doc =
                  docs[index];

              final data =
                  doc.data();

              return Card(

                margin:
                    const EdgeInsets
                        .all(10),

                child: ListTile(

                  title: Text(

                    data["name"] ??
                        "",
                  ),

                  subtitle: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(
                        "الهاتف: ${data["phone"]}",
                      ),

                      Text(
                        "المبلغ: ${data["amount"]} MRU",
                      ),

                      Text(
                        "المحصل: ${data["collectorName"]}",
                      ),

                      Text(
                        "الحالة: ${data["status"]}",
                      ),
                    ],
                  ),

                  trailing: Row(

                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      // ================= EDIT =================

                      IconButton(

                        icon: const Icon(
                          Icons.edit,
                          color:
                              Colors.orange,
                        ),

                        onPressed: () {

                          editOperation(

                            id: doc.id,

                            data: data,
                          );
                        },
                      ),

                      // ================= DELETE =================

                      IconButton(

                        icon: const Icon(
                          Icons.delete,
                          color:
                              Colors.red,
                        ),

                        onPressed: () async {

                          final confirm =
                              await showDialog<
                                  bool>(

                            context:
                                context,

                            builder: (_) {

                              return AlertDialog(

                                title:
                                    const Text(
                                  "تأكيد الحذف",
                                ),

                                content:
                                    const Text(

                                  "سيتم حذف العملية والتنبيهات المرتبطة بها بشكل نهائي",
                                ),

                                actions: [

                                  TextButton(

                                    onPressed:
                                        () {

                                      Navigator.pop(
                                        context,
                                        false,
                                      );
                                    },

                                    child:
                                        const Text(
                                      "إلغاء",
                                    ),
                                  ),

                                  ElevatedButton(

                                    onPressed:
                                        () {

                                      Navigator.pop(
                                        context,
                                        true,
                                      );
                                    },

                                    style:
                                        ElevatedButton.styleFrom(

                                      backgroundColor:
                                          Colors.red,
                                    ),

                                    child:
                                        const Text(
                                      "حذف",
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm !=
                              true) {

                            return;
                          }

                          await deleteOperationSilently(
                            doc.id,
                          );
                        },
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