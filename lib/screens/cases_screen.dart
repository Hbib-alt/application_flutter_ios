import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CasesScreen extends StatelessWidget {
  const CasesScreen({super.key});

  // ================= ROLE =================

  Future<String> getRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return "user";
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      return doc.data()?["role"] ?? "user";
    } catch (e) {
      return "user";
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("العمليات"),
        centerTitle: true,
      ),

      body: FutureBuilder<String>(
        future: getRole(),

        builder: (context, roleSnapshot) {

          if (roleSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final role = roleSnapshot.data ?? "user";

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("cases")
                .orderBy("createdAt", descending: true)
                .snapshots(),

            builder: (context, snapshot) {

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erreur Firestore:\n${snapshot.error}",
                  ),
                );
              }

              if (!snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("لا توجد عمليات"),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,

                itemBuilder: (context, index) {

                  final doc = docs[index];

                  final data =
                      doc.data() as Map<String, dynamic>? ?? {};

                  return _caseCard(
                    context,
                    doc.id,
                    data,
                    role,
                  );
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0057FF),

        onPressed: () {
          _showAddDialog(context);
        },

        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= STATUS COLOR =================

  Color statusColor(String status) {

    switch (status) {

      case "approved":
        return Colors.green;

      case "paid":
        return Colors.purple;

      default:
        return Colors.orange;
    }
  }

  // ================= CARD =================

  Widget _caseCard(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
    String role,
  ) {

    final title =
    data["name"]?.toString() ??
    data["title"]?.toString() ??
    "Sans titre";

final description =
    data["description"]?.toString() ??
    data["purpose"]?.toString() ??
    "";

final status =
    data["status"]?.toString() ??
    "pending";

final amount =
    (data["amount"] ?? 0).toString();

final paymentType =
    data["paymentType"]?.toString() ??
    data["type"]?.toString() ??
    "";

    final isAdmin = role == "admin";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // 📌 TITRE
          Text(
            title,

            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // 📝 DESCRIPTION
          if (description.isNotEmpty)
            Text(description),

          const SizedBox(height: 10),

          // 💰 MONTANT
          if (amount != "0")
            Text(
              "Montant : $amount",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

          // 📂 TYPE
          if (paymentType.isNotEmpty)
            Text("Type : $paymentType"),

          const SizedBox(height: 10),

          // 🚦 STATUS
          Text(
            "Status : $status",

            style: TextStyle(
              color: statusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,

            children: [

              // ✅ APPROUVER
              if (isAdmin && status == "submitted")
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),

                  onPressed: () async {

                    try {

                      await FirebaseFirestore.instance
                          .collection("cases")
                          .doc(id)
                          .update({
                        "status": "approved",
                      });

                    } catch (e) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text("Erreur: $e"),
                        ),
                      );
                    }
                  },

                  child: const Text("✔ Approuver"),
                ),

              // ✏️ EDIT
              if (isAdmin && status != "paid")
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),

                  onPressed: () {
                    _showEditDialog(
                      context,
                      id,
                      data,
                    );
                  },
                ),

              // 🗑 DELETE
              if (isAdmin)
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),

                  onPressed: () async {

                    try {

                      await FirebaseFirestore.instance
                          .collection("cases")
                          .doc(id)
                          .delete();

                    } catch (e) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text("Erreur: $e"),
                        ),
                      );
                    }
                  },
                ),

              // 💰 PAYER
              if (isAdmin && status == "approved")
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),

                  onPressed: () {
                    _payCase(context, id);
                  },

                  child: const Text("💰 Payer"),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ADD =================

  void _showAddDialog(BuildContext context) {

    final titleController =
        TextEditingController();

    final descController =
        TextEditingController();

    showDialog(
      context: context,

      builder: (_) => AlertDialog(

        title: const Text("Nouvelle opération"),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            TextField(
              controller: titleController,

              decoration: const InputDecoration(
                labelText: "Titre",
              ),
            ),

            TextField(
              controller: descController,

              decoration: const InputDecoration(
                labelText: "Description",
              ),
            ),
          ],
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("Annuler"),
          ),

          ElevatedButton(
            onPressed: () async {

              if (titleController.text
                  .trim()
                  .isEmpty) {
                return;
              }

              final user =
                  FirebaseAuth.instance.currentUser;

              try {

                await FirebaseFirestore.instance
                    .collection("cases")
                    .add({

                  "title":
                      titleController.text.trim(),

                  "description":
                      descController.text.trim(),

                  "status": "submitted",

                  "userId":
                      user?.uid ?? "",

                  "createdAt":
                      FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);

              } catch (e) {

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text("Erreur: $e"),
                  ),
                );
              }
            },

            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  // ================= EDIT =================

  void _showEditDialog(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {

    final titleController =
        TextEditingController(
      text: data["title"]?.toString() ?? "",
    );

    final descController =
        TextEditingController(
      text: data["description"]?.toString() ?? "",
    );

    showDialog(
      context: context,

      builder: (_) => AlertDialog(

        title: const Text("Modifier"),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            TextField(
              controller: titleController,
            ),

            TextField(
              controller: descController,
            ),
          ],
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text("Annuler"),
          ),

          ElevatedButton(
            onPressed: () async {

              try {

                await FirebaseFirestore.instance
                    .collection("cases")
                    .doc(id)
                    .update({

                  "title":
                      titleController.text.trim(),

                  "description":
                      descController.text.trim(),

                  "updatedAt":
                      FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);

              } catch (e) {

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text("Erreur: $e"),
                  ),
                );
              }
            },

            child: const Text("Sauvegarder"),
          ),
        ],
      ),
    );
  }

  // ================= PAYMENT =================

  Future<void> _payCase(
    BuildContext context,
    String caseId,
  ) async {

    try {

      final caseRef = FirebaseFirestore.instance
          .collection("cases")
          .doc(caseId);

      final financeRef = FirebaseFirestore.instance
          .collection("finance")
          .doc("main");

      final caseSnap = await caseRef.get();

      final data =
          caseSnap.data() as Map<String, dynamic>? ?? {};

      final amount =
          (data["amount"] ?? 1000);

      final financeSnap =
          await financeRef.get();

      final financeData =
          financeSnap.data() as Map<String, dynamic>? ?? {};

      final currentBalance =
          financeData["balance"] ?? 0;

      final newBalance =
          currentBalance - amount;

      // 💰 update balance
      await financeRef.set({

        "balance": newBalance,

      }, SetOptions(merge: true));

      // 🧾 transaction
      await FirebaseFirestore.instance
          .collection("transactions")
          .add({

        "amount": amount,
        "type": "payment",
        "caseId": caseId,

        "createdAt":
            FieldValue.serverTimestamp(),
      });

      // ✅ update status
      await caseRef.update({
        "status": "paid",
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text("✅ Paiement effectué"),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("Erreur paiement: $e"),
        ),
      );
    }
  }
}