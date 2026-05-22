import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_service.dart';

class NotificationsScreen extends StatelessWidget {

  const NotificationsScreen({
    super.key,
  });

  // ================= MARK AS READ =================

  Future<void> markAsRead(
    String id,
  ) async {

    try {

      await FirebaseFirestore
          .instance
          .collection(
            "notifications",
          )
          .doc(id)
          .update({

        "read": true,
      });

    } catch (_) {}
  }

  // ================= MARK ALL =================

  Future<void>
      markAllAsRead() async {

    final user =
        UserService.currentUser;

    if (user == null) return;

    try {

      final snapshot =
          await FirebaseFirestore
              .instance
              .collection(
                "notifications",
              )
              .where(
                "userId",
                isEqualTo:
                    user.uid,
              )
              .where(
                "read",
                isEqualTo:
                    false,
              )
              .get();

      for (var doc
          in snapshot.docs) {

        await doc.reference
            .update({

          "read": true,
        });
      }

    } catch (_) {}
  }

  // ================= BUILD =================

  @override
  Widget build(
    BuildContext context,
  ) {

    final user =
        UserService.currentUser;

    // ================= SAFE =================

    if (user == null) {

      return Scaffold(

        appBar: AppBar(

          title: const Text(
            "الإشعارات",
          ),
        ),

        body: const Center(

          child: Text(
            "يرجى تسجيل الدخول",
          ),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F6FA,
      ),

      appBar: AppBar(

        title: const Text(
          "الإشعارات",
        ),

        centerTitle: true,

        actions: [

          IconButton(

            icon: const Icon(
              Icons.done_all,
            ),

            onPressed:
                () async {

              await markAllAsRead();
            },
          ),
        ],
      ),

      body:
          StreamBuilder<
              QuerySnapshot>(

        stream:
            FirebaseFirestore
                .instance
                .collection(
                  "notifications",
                )
                .where(
                  "userId",
                  isEqualTo:
                      user.uid,
                )
                .snapshots(),

        builder:
            (
              context,
              snapshot,
            ) {

          // ================= LOADING =================

          if (snapshot
                  .connectionState ==
              ConnectionState
                  .waiting) {

            return const Center(

              child:
                  CircularProgressIndicator(),
            );
          }

          // ================= ERROR =================

          if (snapshot
              .hasError) {

            return Center(

              child: Text(
                "Erreur: ${snapshot.error}",
              ),
            );
          }

          // ================= EMPTY =================

          if (!snapshot
                  .hasData ||
              snapshot.data!
                  .docs
                  .isEmpty) {

            return const Center(

              child: Text(
                "لا توجد إشعارات",
              ),
            );
          }

          final docs =
              snapshot
                  .data!.docs;

          return ListView
              .builder(

            padding:
                const EdgeInsets
                    .all(
              12,
            ),

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

              final isRead =
                  data["read"] ??
                      false;

              final title =
                  data["title"]
                          ?.toString() ??
                      "إشعار";

              final body =
                  data["body"]
                          ?.toString() ??
                      "";

              final createdByName =
                  data["createdByName"]
                          ?.toString() ??
                      "";

              final createdByRole =
                  data["createdByRole"]
                          ?.toString() ??
                      "";

              final operationId =
                  data["operationId"]
                          ?.toString() ??
                      "";

              final type =
                  data["type"]
                          ?.toString() ??
                      "";

              return Card(

                elevation: 2,

                shape:
                    RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius
                          .circular(
                    18,
                  ),
                ),

                margin:
                    const EdgeInsets
                        .only(
                  bottom: 12,
                ),

                child: ListTile(

                  contentPadding:
                      const EdgeInsets
                          .all(
                    16,
                  ),

                  leading:
                      CircleAvatar(

                    backgroundColor:
                        isRead
                            ? Colors
                                .grey
                                .shade300
                            : Colors
                                .deepPurple,

                    child: Icon(

                      isRead
                          ? Icons
                              .notifications_none
                          : Icons
                              .notifications_active,

                      color:
                          Colors.white,
                    ),
                  ),

                  title: Text(

                    title,

                    style:
                        TextStyle(

                      fontWeight:
                          isRead
                              ? FontWeight
                                  .normal
                              : FontWeight
                                  .bold,

                      fontSize:
                          16,
                    ),
                  ),

                  subtitle:
                      Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      if (body
                          .isNotEmpty)

                        Padding(

                          padding:
                              const EdgeInsets
                                  .only(
                            top: 8,
                          ),

                          child:
                              Text(
                            body,
                          ),
                        ),

                      if (createdByName
                          .isNotEmpty)

                        Padding(

                          padding:
                              const EdgeInsets
                                  .only(
                            top: 8,
                          ),

                          child:
                              Text(

                            "$createdByName • $createdByRole",

                            style:
                                TextStyle(

                              color:
                                  Colors
                                      .grey
                                      .shade700,

                              fontSize:
                                  12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  trailing:

                      type == "operation"
                          ? ElevatedButton(

                              onPressed:
                                  () async {

                                try {

                                  // ✅ APPROVE OPERATION

                                  await FirebaseFirestore
                                      .instance
                                      .collection(
                                        "operations",
                                      )
                                      .doc(
                                        operationId,
                                      )
                                      .update({

                                    "status":
                                        "approved",
                                  });
// ================= GET OPERATION =================

final operationDoc =
    await FirebaseFirestore
        .instance
        .collection("operations")
        .doc(operationId)
        .get();

if (operationDoc.exists) {

  final operationData =
      operationDoc.data()!;

  // ================= COLLECTOR =================

  final collectorId =
      operationData["createdBy"] ??
          "";

  // ================= CASHIER =================

  // ================= CASHIER =================

String cashierName =
    "أمين الصندوق";

final cashierUser =
    UserService.currentUser;

if (cashierUser != null) {

  final cashierDoc =
      await FirebaseFirestore
          .instance
          .collection("users")
          .doc(cashierUser.uid)
          .get();

  cashierName =
      cashierDoc
              .data()?["name"] ??
          "أمين الصندوق";
}

  // ================= SEND RETURN NOTIFICATION =================

  await FirebaseFirestore
      .instance
      .collection("notifications")
      .add({

    "userId":
        collectorId,

    "title":
        "تمت الموافقة على العملية",

    "body":

        "الزبون: "
        "${operationData["name"] ?? ""}\n\n"

        "الهاتف: "
        "${operationData["phone"] ?? ""}\n\n"

        "نوع العملية: "
        "${operationData["paymentType"] == "monthly"
            ? "اشتراك"
            : operationData["paymentType"] == "donation"
                ? "تبرع"
                : "لوحة"}\n\n"

        "المبلغ: "
        "${operationData["amount"] ?? 0} "
        "أوقية جديدة\n\n"

        "تم إدخال المبلغ للصندوق بواسطة "
        "$cashierName",

    "read": false,

    "type":
        "approved",

    "createdAt":
        FieldValue.serverTimestamp(),
  });
}
                                  // ✅ MARK READ

                                  await markAsRead(
                                    doc.id,
                                  );

                                  if (context
                                      .mounted) {

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(

                                      const SnackBar(

                                        content:
                                            Text(
                                          "تمت المصادقة",
                                        ),
                                      ),
                                    );
                                  }

                                } catch (e) {

                                  if (context
                                      .mounted) {

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(

                                      SnackBar(

                                        content:
                                            Text(
                                          "Erreur: $e",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },

                              style:
                                  ElevatedButton.styleFrom(

                                backgroundColor:
                                    Colors.green,
                              ),

                              child: const Text(
                                "✅",
                              ),
                            )

                          : isRead
                              ? null
                              : const Icon(

                                  Icons.circle,

                                  color:
                                      Colors.red,

                                  size: 10,
                                ),

                  onTap: () {

                    markAsRead(
                      doc.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}