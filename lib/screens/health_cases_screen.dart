import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/workflow.dart';

import '../services/user_service.dart';

import 'add_health_case_screen.dart';
import 'health_case_payment_screen.dart';

class HealthCasesScreen
    extends StatelessWidget {

  const HealthCasesScreen({
    super.key,
  });

  // ================= CURRENT USER =================

  String get currentUserId {

    return UserService.currentUid;
  }

  // ================= STATUS COLOR =================

  Color statusColor(
    String status,
  ) {

    switch (status) {

      case Workflow.committeeApproved:
        return Colors.green;

      case Workflow.approved:
        return Colors.teal;

      case Workflow.specialDonation:
        return Colors.orange;

      case Workflow.discretionarySupport:
        return Colors.purple;

      case Workflow.paid:
        return Colors.indigo;

      case Workflow.rejected:
        return Colors.red;

      default:
        return Colors.blueGrey;
    }
  }

  // ================= STATUS LABEL =================

  String statusLabel(
    String status,
  ) {

    return Workflow.label(status);
  }

  // ================= PROCEDURE LABEL =================

  String procedureLabel(
    String procedureType,
  ) {

    switch (procedureType) {

      case "standard_procedure":
        return "داخل المسطرة";

      case "special_donation":
        return "فتح تبرع / لوحة";

      case "committee_evaluation":
        return "تقييم اللجنة";

      case "exceptional_case":
        return "حالة استثنائية";

      default:
        return "غير محدد";
    }
  }

  // ================= GIVE OPINION =================

  Future<void> giveOpinion(

    BuildContext context,

    String caseId,

    List opinions,

  ) async {

    final uid =
        currentUserId;

    if (uid.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "يرجى تسجيل الدخول",
          ),
        ),
      );

      return;
    }

    if (opinions.contains(uid)) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "لقد أبديت رأيك مسبقاً",
          ),
        ),
      );

      return;
    }

    try {

      final userName =
          await UserService
              .getUserName();

      final newOpinions = [
        ...opinions,
        uid,
      ];

      final newCount =
          newOpinions.length;

      final newStatus =
          newCount >= 5
              ? Workflow
                  .committeeApproved
              : Workflow
                  .submitted;

      await FirebaseFirestore
    .instance
    .collection(
      "health_cases",
    )
    .doc(caseId)
    .update({

  "votes":
      newOpinions,

  "votesCount":
      newCount,

  "status":
      newStatus,

  "lastOpinionBy":
      userName,

  "updatedAt":
      FieldValue
          .serverTimestamp(),
});

if (!context.mounted) return;

ScaffoldMessenger.of(context)
    .showSnackBar(

  const SnackBar(
    content: Text(
      "✅ تم تسجيل الرأي",
    ),
  ),
);
    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Erreur: $e",
          ),
        ),
      );
    }
  }

  // ================= PRESIDENT DECISION =================

  Future<void> presidentDecision(

    BuildContext context,

    String caseId,

    String decisionType,

  ) async {

    final noteController =
        TextEditingController();

    await showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            "قرار الرئيس",
          ),

          content: TextField(

            controller:
                noteController,

            maxLines: 3,

            decoration:
                const InputDecoration(

              labelText:
                  "ملاحظة الرئيس",

              border:
                  OutlineInputBorder(),
            ),
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

              onPressed:
                  () async {

                final uid =
                    UserService
                        .currentUid;

                if (uid.isEmpty) {
                  return;
                }

                try {

                  final userName =
                      await UserService
                          .getUserName();

                  final userRole =
                      await UserService
                          .getUserRole();

                  await FirebaseFirestore
                      .instance
                      .collection(
                        "health_cases",
                      )
                      .doc(caseId)
                      .update({

                    "status":
                        decisionType,

                    "decisionType":
                        decisionType,

                    "decisionBy":
                        uid,

                    "decisionByName":
                        userName,

                    "decisionByRole":
                        userRole,

                    "decisionNote":
                        noteController
                            .text
                            .trim(),

                    "presidentDecisionAt":
                        FieldValue
                            .serverTimestamp(),
                  });

                  Navigator.pop(
                    context,
                  );

                  

if (!context.mounted) return;

ScaffoldMessenger.of(
  context,
).showSnackBar(

  const SnackBar(
    content: Text(
      "✅ تم حفظ القرار",
    ),
  ),
);

                } catch (e) {

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

  // ================= DISCRETIONARY SUPPORT =================

  Future<void>
      discretionarySupport(

    BuildContext context,

    String caseId,

  ) async {

    final amountController =
        TextEditingController();

    final noteController =
        TextEditingController();

    await showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            "دعم استثنائي",
          ),

          content:
              SingleChildScrollView(

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                TextField(

                  controller:
                      amountController,

                  keyboardType:
                      TextInputType
                          .number,

                  decoration:
                      const InputDecoration(

                    labelText:
                        "المبلغ بالأوقية الجديدة",

                    helperText:
                        "لا يتجاوز 10000",

                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextField(

                  controller:
                      noteController,

                  maxLines: 3,

                  decoration:
                      const InputDecoration(

                    labelText:
                        "ملاحظة الرئيس",

                    border:
                        OutlineInputBorder(),
                  ),
                ),
              ],
            ),
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

              onPressed:
                  () async {

                final amount =
                    double.tryParse(

                          amountController
                              .text
                              .trim(),
                        ) ??
                        0;

                if (amount <= 0 ||
                    amount > 10000) {

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(

                    const SnackBar(
                      content: Text(
                        "المبلغ يجب أن يكون بين 1 و 10000",
                      ),
                    ),
                  );

                  return;
                }

                final uid =
                    UserService
                        .currentUid;

                if (uid.isEmpty) {
                  return;
                }

                final userName =
                    await UserService
                        .getUserName();

                final userRole =
                    await UserService
                        .getUserRole();

                await FirebaseFirestore
                    .instance
                    .collection(
                      "health_cases",
                    )
                    .doc(caseId)
                    .update({

                  "status":
                      Workflow
                          .discretionarySupport,

                  "decisionType":
                      Workflow
                          .discretionarySupport,

                  "approvedAmount":
                      amount,

                  "decisionBy":
                      uid,

                  "decisionByName":
                      userName,

                  "decisionByRole":
                      userRole,

                  "decisionNote":
                      noteController
                          .text
                          .trim(),

                  "presidentDecisionAt":
                      FieldValue
                          .serverTimestamp(),
                });

                Navigator.pop(
                  context,
                );

               

if (!context.mounted) return;

ScaffoldMessenger.of(
  context,
).showSnackBar(

  const SnackBar(
    content: Text(
      "✅ تم اعتماد الدعم الاستثنائي",
    ),
  ),
);
              },

              child: const Text(
                "اعتماد",
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= BUILD =================

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
            Colors.white,

        foregroundColor:
            Colors.black,

        centerTitle: true,

        title: const Text(

          "الحالات الصحية",

          style: TextStyle(

            fontWeight:
                FontWeight.bold,

            fontSize: 22,
          ),
        ),
      ),

      body:
          FutureBuilder<String>(

        future:
            UserService
                .getUserRole(),

        builder:
            (
              context,
              roleSnapshot,
            ) {

          if (roleSnapshot
                  .connectionState ==
              ConnectionState
                  .waiting) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final role =
              roleSnapshot.data ??
                  "user";

          final isPresident =
              role ==
                      "president" ||
                  role ==
                      "admin";

          final isTreasurer =
              role ==
                      "treasurer" ||
                  role ==
                      "admin";

          return StreamBuilder<
              QuerySnapshot>(

            stream:
                FirebaseFirestore
                    .instance
                    .collection(
                      "health_cases",
                    )
                    .orderBy(
                      "createdAt",
                      descending: true,
                    )
                    .snapshots(),

            builder:
                (
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

              if (snapshot
                  .hasError) {

                return Center(

                  child: Text(
                    "Erreur: ${snapshot.error}",
                  ),
                );
              }

              if (!snapshot
                      .hasData ||
                  snapshot.data!
                      .docs
                      .isEmpty) {

                return const Center(

                  child: Text(
                    "لا توجد حالات",
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
                  16,
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

                  final data = doc
                              .data()
                          as Map<
                              String,
                              dynamic>? ??
                      {};

                  final fullName =
                      data["fullName"]
                              ?.toString() ??
                          "بدون اسم";

                  final phone =
                      data["phone"]
                              ?.toString() ??
                          "";

                  final status =
                      data["status"]
                              ?.toString() ??
                          Workflow
                              .submitted;

                  final opinions =
                      data["votes"]
                              as List? ??
                          [];

                  final alreadyGaveOpinion =
                      opinions.contains(
                    currentUserId,
                  );

                  return Card(

                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 16,
                    ),

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                    ),

                    child: Padding(

                      padding:
                          const EdgeInsets
                              .all(
                        18,
                      ),

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [

                          Text(

                            fullName,

                            style:
                                const TextStyle(

                              fontSize:
                                  20,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          if (phone
                              .isNotEmpty)

                            Text(
                              "📱 $phone",
                            ),

                          const SizedBox(
                            height: 12,
                          ),

                          Chip(

                            backgroundColor:
                                statusColor(
                              status,
                            ),

                            label: Text(

                              statusLabel(
                                status,
                              ),

                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Wrap(

                            spacing: 10,

                            runSpacing:
                                10,

                            children: [

                              if (!alreadyGaveOpinion &&
                                  status ==
                                      Workflow
                                          .submitted)

                                ElevatedButton(

                                  onPressed:
                                      () {

                                    giveOpinion(

                                      context,

                                      doc.id,

                                      opinions,
                                    );
                                  },

                                  child:
                                      const Text(
                                    "إبداء الرأي",
                                  ),
                                ),

                              if (isPresident &&
                                  status ==
                                      Workflow
                                          .committeeApproved)

                                ElevatedButton(

                                  onPressed:
                                      () {

                                    presidentDecision(

                                      context,

                                      doc.id,

                                      Workflow
                                          .approved,
                                    );
                                  },

                                  child:
                                      const Text(
                                    "✔ قبول",
                                  ),
                                ),

                              if (isPresident &&
                                  status ==
                                      Workflow
                                          .committeeApproved)

                                ElevatedButton(

                                  onPressed:
                                      () {

                                    discretionarySupport(

                                      context,

                                      doc.id,
                                    );
                                  },

                                  child:
                                      const Text(
                                    "⭐ دعم استثنائي",
                                  ),
                                ),

                              if (isTreasurer &&
                                  Workflow
                                      .needsPayment(
                                    status,
                                  ))

                                ElevatedButton(

                                  onPressed:
                                      () {

                                    Navigator
                                        .push(

                                      context,

                                      MaterialPageRoute(

                                        builder:
                                            (_) =>
                                                HealthCasePaymentScreen(

                                          caseId:
                                              doc.id,

                                          data:
                                              data,
                                        ),
                                      ),
                                    );
                                  },

                                  child:
                                      const Text(
                                    "💰 صرف المستحق",
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton
              .extended(

        backgroundColor:
            const Color(0xFF0057FF),

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  const AddHealthCaseScreen(),
            ),
          );
        },

        icon: const Icon(
          Icons.add,
        ),

        label: const Text(
          "إضافة حالة",
        ),
      ),
    );
  }
}