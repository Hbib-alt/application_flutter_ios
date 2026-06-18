import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'member_details_screen.dart';

class MembersScreen extends StatefulWidget {

  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() =>
      _MembersScreenState();
}

class _MembersScreenState
    extends State<MembersScreen> {

  final searchController =
      TextEditingController();

  String search = "";

  // ================= GET MEMBERS =================

  Future<List<Map<String, dynamic>>>
      getMembers() async {

    final currentMonth =
        DateTime.now().month;

    final currentYear =
        DateTime.now().year;

    // ================= PEOPLE =================

    final peopleSnapshot =
    await FirebaseFirestore
        .instance
        .collection("people")
        .where(
          "collectorId",
          isEqualTo:
              FirebaseAuth
                  .instance
                  .currentUser!
                  .uid,
        )
        .get();

    // ================= OPERATIONS =================

   final statsSnapshot =
    await FirebaseFirestore.instance
        .collection("subscription_stats")
        .get();

    // ================= CALCULATE =================

    List<Map<String, dynamic>>
        members = [];

    for (var person
        in peopleSnapshot.docs) {

      final personData =
          person.data();

      final personId =
          person.id;

      

      // ================= STATUS =================

      final matches =
    statsSnapshot.docs.where(
  (e) => e.id == personId,
).toList();

if (matches.isEmpty) {
  continue;
}

final stats =
    matches.first.data();
final paidMonths =
    List<int>.from(
  stats["paidMonthsList"] ?? [],
);
final missingMonths =
    List<int>.from(
  stats["missingMonths"] ?? [],
);



final futureMonths =
    paidMonths
        .where(
          (m) => m > currentMonth,
        )
        .toList()
      ..sort();

String status = "";
Color statusColor = Colors.green;

if (missingMonths.isNotEmpty) {

  status =
      "🔴 متأخر ${missingMonths.length} شهر";

  statusColor = Colors.red;

} else if (futureMonths.isNotEmpty) {

  status =
      "🔵 مسبق ${futureMonths.length} شهر";

  statusColor = Colors.blue;

} else {

  status =
      "🟢 في المستوى";

  statusColor = Colors.green;
}
      

      final name =
          personData["name"] ?? "";

      final phone =
          personData["phone"] ?? "";

      // ================= SEARCH =================

      if (search.isNotEmpty) {

        if (!name
                .toLowerCase()
                .contains(
                  search
                      .toLowerCase(),
                ) &&
            !phone.contains(
                search)) {

          continue;
        }
      }

      members.add({

  "personId": personId,

  "name": name,

  "phone": phone,

  "status": status,

  "statusColor":
      statusColor,
});
    }

    return members;
  }

  // ================= WHATSAPP =================

  Future<void> openWhatsApp(
    String phone,
  ) async {

    final cleanPhone =
        phone.replaceAll(
      "+",
      "",
    );

    final url =
        "https://wa.me/$cleanPhone";

    final uri =
        Uri.parse(url);

    if (await canLaunchUrl(
        uri)) {

      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F6FA,
      ),

      appBar: AppBar(

        title: const Text(
          "قائمة المشتركين",
        ),

        centerTitle: true,
      ),

      body: Column(

        children: [

          // ================= SEARCH =================

          Padding(

            padding:
                const EdgeInsets
                    .all(16),

            child: TextField(

              controller:
                  searchController,

              onChanged: (v) {

                setState(() {

                  search = v;
                });
              },

              decoration:
                  InputDecoration(

                hintText:
                    "بحث بالاسم أو الهاتف",

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          // ================= LIST =================

          Expanded(

            child: FutureBuilder<
                List<Map<String,
                    dynamic>>>(

              future: getMembers(),

              builder:
                  (context,
                      snapshot) {

                if (!snapshot
                    .hasData) {

                  return const Center(

                    child:
                        CircularProgressIndicator(),
                  );
                }

                final members =
                    snapshot.data!;

                if (members
                    .isEmpty) {

                  return const Center(

                    child: Text(
                      "لا توجد بيانات",
                    ),
                  );
                }

                return ListView
                    .builder(

                  itemCount:
                      members.length,

                  itemBuilder:
                      (context,
                          index) {

                    final member =
                        members[index];

                    return Card(

                      margin:
                          const EdgeInsets
                              .symmetric(

                        horizontal:
                            16,

                        vertical: 8,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),

                      child:
                          ListTile(
onTap: () {

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (_) =>
          MemberDetailsScreen(

        personId:
            member["personId"],
      ),
    ),
  );
},
                        contentPadding:
                            const EdgeInsets
                                .all(16),

                        leading:
                            CircleAvatar(

                          backgroundColor:
                              member[
                                  "statusColor"],

                          child:
                              const Icon(

                            Icons.person,

                            color:
                                Colors.white,
                          ),
                        ),

                        title: Text(

                          member["name"],

                          style:
                              const TextStyle(

                            fontWeight:
                                FontWeight.bold,

                            fontSize:
                                18,
                          ),
                        ),

                        subtitle:
                            Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              member[
                                  "phone"],
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(

                              member[
                                  "status"],

                              style:
                                  TextStyle(

                                color:
                                    member[
                                        "statusColor"],

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        trailing:
                            IconButton(

                          icon:
                              const Icon(

                            Icons
                                .message,

                            color:
                                Colors.green,
                          ),

                          onPressed: () {

                            openWhatsApp(

                              member[
                                  "phone"],
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}