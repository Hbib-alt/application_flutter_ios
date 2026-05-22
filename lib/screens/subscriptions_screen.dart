import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionsScreen extends StatelessWidget {

  const SubscriptionsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(

        title:
            const Text("الاشتراكات"),

        centerTitle: true,
      ),

      floatingActionButton:
          FloatingActionButton(

        onPressed: () {

          _showAddDialog(context);
        },

        child:
            const Icon(Icons.add),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream:
            FirebaseFirestore.instance
                .collection("subscriptions")
                .orderBy(
                  "createdAt",
                  descending: true,
                )
                .snapshots(),

        builder:
            (context, snapshot) {

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
                "لا يوجد مشتركون",
              ),
            );
          }

          return ListView.builder(

            padding:
                const EdgeInsets.all(16),

            itemCount:
                docs.length,

            itemBuilder:
                (context, index) {

              final data =
                  docs[index].data()
                      as Map<String, dynamic>;

              final fullName =
                  data["fullName"] ?? "";

              final phone =
                  data["phone"] ?? "";

              final monthlyAmount =
                  data["monthlyAmount"] ?? 0;

              final paidMonths =
                  data["paidMonths"] ?? 0;

              final lateMonths =
                  data["lateMonths"] ?? 0;

              final totalLate =
                  data["totalLate"] ?? 0;

              return Container(

                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),

                padding:
                    const EdgeInsets.all(
                  18,
                ),

                decoration:
                    BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),

                  boxShadow: [

                    BoxShadow(

                      color:
                          Colors.black
                              .withOpacity(
                        0.04,
                      ),

                      blurRadius: 15,

                      offset:
                          const Offset(
                        0,
                        6,
                      ),
                    ),
                  ],
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Row(

                      children: [

                        CircleAvatar(

                          radius: 28,

                          backgroundColor:
                              Colors.deepPurple
                                  .withOpacity(
                            0.15,
                          ),

                          child: const Icon(

                            Icons.person,

                            color:
                                Colors.deepPurple,

                            size: 30,
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(

                          child: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Text(

                                fullName,

                                style:
                                    const TextStyle(

                                  fontSize: 20,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(

                                phone,

                                style:
                                    TextStyle(

                                  color:
                                      Colors
                                          .grey
                                          .shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Row(

                      children: [

                        _infoCard(
                          "الاشتراك",
                          "$monthlyAmount MRU",
                          Colors.green,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        _infoCard(
                          "المدفوع",
                          "$paidMonths",
                          Colors.blue,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(

                      children: [

                        _infoCard(
                          "المتأخر",
                          "$lateMonths",
                          Colors.orange,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        _infoCard(
                          "الدين",
                          "$totalLate MRU",
                          Colors.red,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    SizedBox(

                      width: double.infinity,

                      child: ElevatedButton.icon(

                        style:
                            ElevatedButton
                                .styleFrom(

                          backgroundColor:
                              Colors.deepPurple,

                          minimumSize:
                              const Size(
                            0,
                            50,
                          ),
                        ),

                        onPressed: () async {

                          await FirebaseFirestore
                              .instance
                              .collection(
                                "subscriptions",
                              )
                              .doc(
                                docs[index].id,
                              )
                              .update({

                            "paidMonths":
                                paidMonths + 1,

                            "lateMonths":
                                lateMonths > 0
                                    ? lateMonths - 1
                                    : 0,

                            "totalLate":
                                totalLate >
                                        monthlyAmount
                                    ? totalLate -
                                        monthlyAmount
                                    : 0,
                          });

                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(

                            const SnackBar(

                              content: Text(
                                "✅ تم تسجيل الدفع",
                              ),
                            ),
                          );
                        },

                        icon:
                            const Icon(Icons.check),

                        label:
                            const Text(
                          "تسجيل دفع",
                        ),
                      ),
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

  // ================= INFO CARD =================

  Widget _infoCard(

    String title,

    String value,

    Color color,
  ) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.all(14),

        decoration:
            BoxDecoration(

          color:
              color.withOpacity(0.10),

          borderRadius:
              BorderRadius.circular(18),
        ),

        child: Column(

          children: [

            Text(

              value,

              style: TextStyle(

                color: color,

                fontWeight:
                    FontWeight.bold,

                fontSize: 18,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(

              title,

              style:
                  TextStyle(

                color: Colors
                    .grey
                    .shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ADD =================

  void _showAddDialog(
    BuildContext context,
  ) {

    final nameController =
        TextEditingController();

    final phoneController =
        TextEditingController();

    final amountController =
        TextEditingController();

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title:
              const Text(
            "إضافة مشترك",
          ),

          content:
              SingleChildScrollView(

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                TextField(

                  controller:
                      nameController,

                  decoration:
                      const InputDecoration(

                    hintText:
                        "الاسم",
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextField(

                  controller:
                      phoneController,

                  decoration:
                      const InputDecoration(

                    hintText:
                        "الهاتف",
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                TextField(

                  controller:
                      amountController,

                  keyboardType:
                      TextInputType.number,

                  decoration:
                      const InputDecoration(

                    hintText:
                        "الاشتراك الشهري",
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

              child:
                  const Text(
                "إلغاء",
              ),
            ),

            ElevatedButton(

              onPressed: () async {

                final amount =
                    int.tryParse(

                          amountController
                              .text
                              .trim(),
                        ) ??
                        0;

                await FirebaseFirestore
                    .instance
                    .collection(
                      "subscriptions",
                    )
                    .add({

                  "fullName":
                      nameController
                          .text
                          .trim(),

                  "phone":
                      phoneController
                          .text
                          .trim(),

                  "monthlyAmount":
                      amount,

                  "paidMonths":
                      0,

                  "lateMonths":
                      0,

                  "totalLate":
                      0,

                  "createdAt":
                      FieldValue
                          .serverTimestamp(),
                });

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(
                  context,
                );

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(

                  const SnackBar(

                    content: Text(
                      "✅ تمت إضافة المشترك",
                    ),
                  ),
                );
              },

              child:
                  const Text(
                "إضافة",
              ),
            ),
          ],
        );
      },
    );
  }
}