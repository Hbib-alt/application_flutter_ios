import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("سلة المحذوفات"),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("transactions")
            .where(
              "isDeleted",
              isEqualTo: true,
            )
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "لا توجد عمليات محذوفة",
              ),
            );
          }

          return ListView.builder(

            itemCount: docs.length,

            itemBuilder: (context, index) {

              final data =
                  docs[index].data()
                      as Map<String, dynamic>;

              return ListTile(

                title: Text(
                  data["name"] ?? "",
                ),

                subtitle: Text(
                  "${data["amount"]} MRU",
                ),

                trailing: IconButton(

                  icon: const Icon(
                    Icons.restore,
                    color: Colors.green,
                  ),

                  onPressed: () async {

                    await FirebaseFirestore.instance
                        .collection("transactions")
                        .doc(docs[index].id)
                        .update({

                      "isDeleted": false,
                    });

                    ScaffoldMessenger.of(context)
                        .showSnackBar(

                      const SnackBar(
                        content: Text(
                          "تمت الاستعادة",
                        ),
                      ),
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