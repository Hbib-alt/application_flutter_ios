import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_service.dart';

class CaisseScreen extends StatefulWidget {
  const CaisseScreen({super.key});

  @override
  State<CaisseScreen> createState() => _CaisseScreenState();
}

class _CaisseScreenState extends State<CaisseScreen> {
  String filter = "all";

  Future<bool> canManageCaisse() async {
    final isAdmin = await UserService.isAdmin();
    final isTreasurer = await UserService.isTreasurer();
    return isAdmin || isTreasurer;
  }

  String formatDate(dynamic value) {
    if (value == null) return "";

    try {
      final date = (value as Timestamp).toDate();

      final day = date.day.toString().padLeft(2, "0");
      final month = date.month.toString().padLeft(2, "0");
      final year = date.year.toString();

      final hour = date.hour.toString().padLeft(2, "0");
      final minute = date.minute.toString().padLeft(2, "0");

      return "$day/$month/$year - $hour:$minute";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final docRef =
        FirebaseFirestore.instance.collection("finance").doc("main");

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("💰 الصندوق"),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final balance = (data["balance"] ?? 0).toDouble();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("transactions")
                .orderBy(
                  "createdAt",
                  descending: true,
                )
                .snapshots(),
            builder: (context, txSnapshot) {
              if (!txSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final transactions = txSnapshot.data!.docs;

              double totalIn = 0;
              double totalOut = 0;

              for (final doc in transactions) {
                final d =
                    doc.data() as Map<String, dynamic>? ?? {};

                final amount =
                    (d["amount"] ?? 0).toDouble();

                final type = d["type"] ?? "";

                if (type == "add") {
                  totalIn += amount;
                } else {
                  totalOut += amount;
                }
              }

              final filteredTransactions =
                  transactions.where((doc) {
                final d =
                    doc.data() as Map<String, dynamic>? ?? {};

                final type = d["type"] ?? "";

                if (filter == "all") return true;
                if (filter == "add") return type == "add";
                if (filter == "remove") return type != "add";

                return true;
              }).toList();

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _headerCard(
                      balance: balance,
                      totalIn: totalIn,
                      totalOut: totalOut,
                      operations: transactions.length,
                    ),

                    const SizedBox(height: 18),

                    FutureBuilder<bool>(
                      future: canManageCaisse(),
                      builder: (context, roleSnapshot) {
                        final canManage =
                            roleSnapshot.data ?? false;

                        if (!canManage) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: const Text(
                              "⚠️ ليس لديك صلاحية إدارة الصندوق",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.green,
                                  minimumSize:
                                      const Size(0, 50),
                                ),
                                onPressed: () {
                                  _showDialog(
                                    context,
                                    docRef,
                                    true,
                                    balance,
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label:
                                    const Text("إضافة مبلغ"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize:
                                      const Size(0, 50),
                                ),
                                onPressed: () {
                                  _showDialog(
                                    context,
                                    docRef,
                                    false,
                                    balance,
                                  );
                                },
                                icon:
                                    const Icon(Icons.remove),
                                label:
                                    const Text("صرف مبلغ"),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "📜 سجل العمليات",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        DropdownButton<String>(
                          value: filter,
                          items: const [
                            DropdownMenuItem(
                              value: "all",
                              child: Text("الكل"),
                            ),
                            DropdownMenuItem(
                              value: "add",
                              child: Text("التحصيل"),
                            ),
                            DropdownMenuItem(
                              value: "remove",
                              child: Text("الصرف"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              filter = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? const Center(
                              child: Text("لا توجد عمليات"),
                            )
                          : ListView.builder(
                              itemCount:
                                  filteredTransactions.length,
                              itemBuilder: (context, index) {
                                final doc =
                                    filteredTransactions[index];

                                final d = doc.data()
                                        as Map<String, dynamic>? ??
                                    {};

                                final amount =
                                    d["amount"] ?? 0;

                                final type =
                                    d["type"] ?? "add";

                                final isAdd =
                                    type == "add";

                                final createdByName =
                                    d["createdByName"]
                                            ?.toString() ??
                                        "";

                                final createdByRole =
                                    d["createdByRole"]
                                            ?.toString() ??
                                        "";

                                final note =
                                    d["note"]?.toString() ??
                                        "";

                                final date =
                                    formatDate(d["createdAt"]);

                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: 12,
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
                                        const EdgeInsets.all(
                                      14,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          isAdd
                                              ? Colors.green
                                              : Colors.red,
                                      child: Icon(
                                        isAdd
                                            ? Icons
                                                .arrow_downward
                                            : Icons.arrow_upward,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      isAdd
                                          ? "تحصيل $amount MRU"
                                          : "صرف $amount MRU",
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (createdByName
                                            .isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets
                                                    .only(top: 6),
                                            child: Text(
                                              "$createdByName • $createdByRole",
                                            ),
                                          ),
                                        if (note.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets
                                                    .only(top: 6),
                                            child: Text(
                                              "📝 $note",
                                            ),
                                          ),
                                        if (date.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets
                                                    .only(top: 6),
                                            child: Text(
                                              date,
                                              style: TextStyle(
                                                color: Colors
                                                    .grey
                                                    .shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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

  Widget _headerCard({
    required double balance,
    required double totalIn,
    required double totalOut,
    required int operations,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0057FF),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0057FF).withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 48,
          ),

          const SizedBox(height: 12),

          const Text(
            "الرصيد الحالي",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "$balance MRU",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _miniStat(
                title: "التحصيل",
                value: totalIn,
                icon: Icons.arrow_downward,
              ),
              _miniStat(
                title: "الصرف",
                value: totalOut,
                icon: Icons.arrow_upward,
              ),
              _miniStat(
                title: "العمليات",
                value: operations.toDouble(),
                icon: Icons.list_alt,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required String title,
    required double value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialog(
    BuildContext context,
    DocumentReference docRef,
    bool isAdd,
    double currentBalance,
  ) async {
    final controller = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            isAdd ? "إضافة مبلغ" : "صرف مبلغ",
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "المبلغ",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "ملاحظة",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () async {
                final value =
                    double.tryParse(controller.text.trim()) ?? 0;

                if (value <= 0) {
                  return;
                }

                if (!isAdd && value > currentBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("رصيد غير كاف"),
                    ),
                  );
                  return;
                }

                final newBalance =
                    isAdd ? currentBalance + value : currentBalance - value;

                final uid = UserService.currentUid;
                final userName = await UserService.getUserName();
                final userRole = await UserService.getUserRole();
                final userPhone = await UserService.getPhone();

                await docRef.set({
                  "balance": newBalance,
                  "updatedAt": FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                await FirebaseFirestore.instance
                    .collection("transactions")
                    .add({
                  "amount": value,
                  "type": isAdd ? "add" : "remove",
                  "createdBy": uid,
                  "createdByName": userName,
                  "createdByRole": userRole,
                  "createdByPhone": userPhone,
                  "note": noteController.text.trim(),
                  "createdAt": FieldValue.serverTimestamp(),
                });

                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAdd
                          ? "✅ تمت إضافة المبلغ"
                          : "✅ تم صرف المبلغ",
                    ),
                  ),
                );
              },
              child: const Text("تأكيد"),
            ),
          ],
        );
      },
    );
  }
}