import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistorySearchScreen extends StatefulWidget {
  const HistorySearchScreen({super.key});

  @override
  State<HistorySearchScreen> createState() =>
      _HistorySearchScreenState();
}

class _HistorySearchScreenState
    extends State<HistorySearchScreen> {

  final TextEditingController searchController =
      TextEditingController();

  String searchText = "";

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(

        backgroundColor:
            const Color(0xFF0057FF),

        title: const Text(
          "البحث في السجل",
        ),

        centerTitle: true,
      ),

      body: Column(

        children: [

          // ================= SEARCH =================

          Padding(

            padding:
                const EdgeInsets.all(16),

            child: TextField(

              controller:
                  searchController,

              onChanged: (value) {

                setState(() {

                  searchText =
                      value.trim()
                          .toLowerCase();
                });
              },

              decoration: InputDecoration(

                hintText:
                    "بحث بالاسم أو الهاتف",

                prefixIcon:
                    const Icon(Icons.search),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          // ================= RESULTS =================

          Expanded(

            child: StreamBuilder<QuerySnapshot>(

              stream:
                  FirebaseFirestore.instance
                      .collection(
                        "operations",
                      )
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

                final filtered =
                    docs.where((doc) {

                  final data =
                      doc.data()
                          as Map<String, dynamic>;

                  final name =
                      data["name"]
                              ?.toString()
                              .toLowerCase() ??
                          "";

                  final phone =
                      data["phone"]
                              ?.toString()
                              .toLowerCase() ??
                          "";

                  return name.contains(
                            searchText,
                          ) ||
                      phone.contains(
                        searchText,
                      );
                }).toList();

                double total = 0;

                for (var doc in filtered) {

                  final data =
                      doc.data()
                          as Map<String, dynamic>;

                  total +=
                      double.tryParse(
                            data["amount"]
                                .toString(),
                          ) ??
                          0;
                }

                return Column(

                  children: [

                    // ================= TOTAL =================

                    Container(

                      margin:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),

                      padding:
                          const EdgeInsets.all(16),

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.deepPurple,

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),

                      child: Row(

                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [

                          const Text(

                            "إجمالي المدفوعات",

                            style: TextStyle(

                              color:
                                  Colors.white,

                              fontSize: 18,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(

                            "${total.toStringAsFixed(0)} MRU",

                            style: const TextStyle(

                              color:
                                  Colors.white,

                              fontSize: 20,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ================= LIST =================

                    Expanded(

                      child: ListView.builder(

                        itemCount:
                            filtered.length,

                        itemBuilder:
                            (context, index) {

                          final data =
                              filtered[index].data()
                                  as Map<String, dynamic>;

                          final status =
                              data["status"] ??
                                  "";

                          final approved =
                              status ==
                                  "approved";

                          return Container(

                            margin:
                                const EdgeInsets.symmetric(

                              horizontal: 16,

                              vertical: 6,
                            ),

                            decoration:
                                BoxDecoration(

                              color:
                                  Colors.white,

                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),

                              boxShadow: [

                                BoxShadow(

                                  color:
                                      Colors.black12,

                                  blurRadius: 8,

                                  offset:
                                      const Offset(
                                    0,
                                    4,
                                  ),
                                ),
                              ],
                            ),

                            child: ListTile(

                              leading:
                                  CircleAvatar(

                                backgroundColor:
                                    approved
                                        ? Colors.green
                                        : Colors.orange,

                                child: Icon(

                                  approved
                                      ? Icons.check
                                      : Icons.pending,

                                  color:
                                      Colors.white,
                                ),
                              ),

                              title: Text(

                                data["name"] ?? "",
                              ),

                              subtitle: Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    data["phone"] ?? "",
                                  ),

                                  Text(
                                    "${data["amount"]} MRU",
                                  ),

                                  Text(
                                    status,
                                  ),
                                ],
                              ),

                              trailing: Text(

                                data["paymentType"] ??
                                    "",

                                style: const TextStyle(

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}