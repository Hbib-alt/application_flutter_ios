import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    final operationsSnapshot =
        await FirebaseFirestore
            .instance
            .collection("operations")
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

      int totalMonths = 0;

      for (var operation
          in operationsSnapshot.docs) {

        final op =
            operation.data();

        if (op["personId"] ==
                personId &&
            op["paymentType"] ==
                "monthly" &&
            op["year"] ==
                currentYear) {

          totalMonths +=
              ((op["months"] ?? 1)
                      as num)
                  .toInt();
        }
      }

      // ================= STATUS =================

      String status = "";

      Color statusColor =
          Colors.green;

      // ✅ payé toute l'année

      if (totalMonths >= 12) {

        status =
            "🟢 مكتمل السنة";

        statusColor =
            Colors.green;
      }

      // ✅ en retard

      else if (totalMonths <
          currentMonth) {

        final remaining =
            currentMonth -
                totalMonths;

        status =
            "🔴 متأخر $remaining شهر";

        statusColor =
            Colors.red;
      }

      // ✅ exactement à jour

      else if (totalMonths ==
          currentMonth) {

        status =
            "🟢 في المستوى";

        statusColor =
            Colors.green;
      }

      // ✅ en avance

      else {

        final advance =
            totalMonths -
                currentMonth;

        status =
            "🔵 مسبق $advance شهر";

        statusColor =
            Colors.blue;
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