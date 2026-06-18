import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LatePeopleScreen extends StatefulWidget {

  const LatePeopleScreen({super.key});

  @override
  State<LatePeopleScreen> createState() =>
      _LatePeopleScreenState();
}

class _LatePeopleScreenState
    extends State<LatePeopleScreen> {

  Future<List<Map<String, dynamic>>>
      getLatePeople() async {

    // ================= CURRENT DATE =================

    final currentUserId =
    FirebaseAuth.instance.currentUser!.uid;

final peopleSnapshot =
    await FirebaseFirestore.instance
        .collection("people")
        .where(
          "collectorId",
          isEqualTo: currentUserId,
        )
        .get();

final statsSnapshot =
    await FirebaseFirestore.instance
        .collection("subscription_stats")
        .get();

List<Map<String, dynamic>>
    latePeople = [];

for (final personDoc
    in peopleSnapshot.docs) {

  final matches =
    statsSnapshot.docs.where(
  (e) => e.id == personDoc.id,
).toList();

if (matches.isEmpty) {
  continue;
}

final stats =
    matches.first.data();

  final missingMonths =
      List<int>.from(
    stats["missingMonths"] ?? [],
  );

  if (missingMonths.isEmpty) {
    continue;
  }

  latePeople.add({

    "name":
        personDoc["name"],

    "phone":
        personDoc["phone"],

    "remaining":
        missingMonths.length,
  });
}

return latePeople;
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "المتأخرين",
        ),
      ),

      body: FutureBuilder<
          List<Map<String,
              dynamic>>>(

        future:
            getLatePeople(),

        builder:
            (context, snapshot) {
if (snapshot.hasError) {
  return Center(
    child: Text(
      "Erreur: ${snapshot.error}",
    ),
  );
}
          if (!snapshot
              .hasData) {

            return const Center(

              child:
                  CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!;

          // ================= EMPTY =================

          if (data.isEmpty) {

            return const Center(

              child: Text(
                "✅ الجميع في المستوى المطلوب",
              ),
            );
          }

          // ================= LIST =================

          return ListView.builder(

            itemCount:
                data.length,

            itemBuilder:
                (context, index) {

              final person =
                  data[index];

              return Card(

                margin:
                    const EdgeInsets
                        .symmetric(

                  horizontal: 12,
                  vertical: 6,
                ),

                child: ListTile(

                  leading:
                      const Icon(

                    Icons.warning,

                    color:
                        Colors.red,
                  ),

                  title: Text(

                    person["name"],

                    style:
                        const TextStyle(

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle:
                      Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Text(
                        person["phone"],
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(

                        "متأخر ${person["remaining"]} شهر",

                        style:
                            const TextStyle(

                          color:
                              Colors.red,

                          fontWeight:
                              FontWeight.bold,
                        ),
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