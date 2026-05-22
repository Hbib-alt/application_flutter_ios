import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersScreen extends StatelessWidget {

  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "إدارة المستخدمين",
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream:
            FirebaseFirestore.instance
                .collection("users")
                .snapshots(),

        builder:
            (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final users =
              snapshot.data!.docs;

          if (users.isEmpty) {

            return const Center(

              child: Text(
                "لا يوجد مستخدمون",
              ),
            );
          }

          return ListView.builder(

            itemCount:
                users.length,

            itemBuilder:
                (context, index) {

              final user =
                  users[index];

              final data =
                  user.data()
                      as Map<String, dynamic>;

              final uid =
                  user.id;

              final name =
                  data["name"] ?? "";

              final email =
                  data["email"] ?? "";

              final role =
                  data["role"] ??
                  "collector";

              final active =
                  data["active"] ??
                  true;

              return Card(

                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                child: Padding(

                  padding:
                      const EdgeInsets.all(16),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(

                        name,

                        style:
                            const TextStyle(

                          fontSize: 18,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(email),

                      const SizedBox(
                        height: 16,
                      ),

                      Row(

                        children: [

                          // =====================
                          // ROLE
                          // =====================

                          Expanded(

                            child:
                                DropdownButton<String>(

                              value: role,

                              isExpanded: true,

                              items: const [

                                DropdownMenuItem(
                                  value: "admin",
                                  child: Text(
                                    "Admin",
                                  ),
                                ),

                                DropdownMenuItem(
                                  value:
                                      "treasurer",
                                  child: Text(
                                    "Treasurer",
                                  ),
                                ),

                                DropdownMenuItem(
                                  value:
                                      "collector",
                                  child: Text(
                                    "Collector",
                                  ),
                                ),

                                DropdownMenuItem(
                                  value:
                                      "president",
                                  child: Text(
                                    "President",
                                  ),
                                ),
                              ],

                              onChanged:
                                  (value) async {

                                if (value == null)
                                  return;

                                await FirebaseFirestore
                                    .instance
                                    .collection(
                                      "users",
                                    )
                                    .doc(uid)
                                    .update({

                                  "role":
                                      value,
                                });
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 16,
                          ),

                          // =====================
                          // ACTIVE SWITCH
                          // =====================

                          Column(

                            children: [

                              const Text(
                                "Active",
                              ),

                              Switch(

                                value: active,

                                onChanged:
                                    (value) async {

                                  await FirebaseFirestore
                                      .instance
                                      .collection(
                                        "users",
                                      )
                                      .doc(uid)
                                      .update({

                                    "active":
                                        value,
                                  });
                                },
                              ),
                            ],
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
      ),
    );
  }
}