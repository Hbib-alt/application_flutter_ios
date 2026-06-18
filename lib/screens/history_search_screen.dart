import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';
class HistorySearchScreen extends StatefulWidget {
  const HistorySearchScreen({super.key});

  @override
  State<HistorySearchScreen> createState() =>
      _HistorySearchScreenState();
}

class _HistorySearchScreenState
    extends State<HistorySearchScreen> {
final _editNameController =
    TextEditingController();

final _editPhoneController =
    TextEditingController();

final _editAmountController =
    TextEditingController();
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

        .where(
          "status",
          isEqualTo: "approved",
        )

        .where(
          "isDeleted",
          isEqualTo: false,
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
final Map<String, Map<String, dynamic>> peopleSummary = {};

for (var doc in filtered) {

  final data =
      doc.data() as Map<String, dynamic>;

  final phone =
      data["phone"] ?? "";

  final amount =
      double.tryParse(
        data["amount"].toString(),
      ) ?? 0;

  final type =
      data["paymentType"] ?? "";

  if (!peopleSummary.containsKey(phone)) {

    peopleSummary[phone] = {

  "personId": data["personId"],

  "name": data["name"] ?? "",
  "phone": phone,

  "total": 0.0,
  "monthly": 0.0,
  "panel": 0.0,
  "donation": 0.0,
};
  }

  peopleSummary[phone]!["total"] += amount;

  if (type == "monthly") {
    peopleSummary[phone]!["monthly"] += amount;
  }

  if (type == "panel") {
    peopleSummary[phone]!["panel"] += amount;
  }

  if (type == "donation") {
    peopleSummary[phone]!["donation"] += amount;
  }
}

final peopleList =
    peopleSummary.values.toList();
                double total = 0;
double monthlyTotal = 0;
double panelTotal = 0;
double donationTotal = 0;
                for (var doc in filtered) {

  final data =
      doc.data()
          as Map<String, dynamic>;

  final amount =
      double.tryParse(
        data["amount"].toString(),
      ) ??
      0;

  final type =
      data["paymentType"] ?? "";

  total += amount;

  if (type == "monthly") {
    monthlyTotal += amount;
  }

  if (type == "panel") {
    panelTotal += amount;
  }

  if (type == "donation") {
    donationTotal += amount;
  }
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
Container(
   margin: const EdgeInsets.symmetric(
    horizontal: 16,
  ),
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
  ),
  child: Column(
    children: [

      Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Text("الاشتراكات"),
          Text(
            "${monthlyTotal.toStringAsFixed(0)} MRU",
          ),
        ],
      ),

      const Divider(),

      Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Text("اللوحات"),
          Text(
            "${panelTotal.toStringAsFixed(0)} MRU",
          ),
        ],
      ),

      const Divider(),

      Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          const Text("التبرعات"),
          Text(
            "${donationTotal.toStringAsFixed(0)} MRU",
          ),
        ],
      ),
    ],
  ),
),
                    // ================= LIST =================

                    Expanded(

                      child: ListView.builder(

                        itemCount:
    peopleList.length,

                        itemBuilder:
                            (context, index) {

                         final data = peopleList[index];

                          

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

                                backgroundColor: Colors.green,

                                child: Icon(

                                  Icons.check,
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

    Text(data["phone"]),

    const SizedBox(height: 4),

    Text(
      "الإجمالي : ${data["total"].toStringAsFixed(0)} MRU",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),

    Text(
      "الاشتراكات : ${data["monthly"].toStringAsFixed(0)} MRU",
    ),

    Text(
      "اللوحات : ${data["panel"].toStringAsFixed(0)} MRU",
    ),

    Text(
      "التبرعات : ${data["donation"].toStringAsFixed(0)} MRU",
    ),
  ],
),

                           trailing: FutureBuilder<bool>(

  future: UserService.isAdmin(),

  builder: (context, snapshot) {

    print("IS ADMIN = ${snapshot.data}");

    if (snapshot.data != true) {

      return const SizedBox();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        IconButton(
  icon: const Icon(
    Icons.edit,
    color: Colors.blue,
  ),
 onPressed: () async {

  final nameController =
      TextEditingController(
    text: data["name"],
  );

  final phoneController =
      TextEditingController(
    text: data["phone"],
  );

  final save =
      await showDialog<bool>(

    context: context,

    builder: (_) => AlertDialog(

      title: const Text(
        "تعديل البيانات",
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          TextField(
            controller: nameController,
            decoration:
                const InputDecoration(
              labelText: "الاسم",
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: phoneController,
            decoration:
                const InputDecoration(
              labelText: "الهاتف",
            ),
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              false,
            );
          },
          child: const Text(
            "إلغاء",
          ),
        ),

        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              true,
            );
          },
          child: const Text(
            "حفظ",
          ),
        ),
      ],
    ),
  );

 if (save == true) {

  final personId =
      data["personId"];

  await FirebaseFirestore.instance
      .collection("people")
      .doc(personId)
      .update({

    "name":
        nameController.text.trim(),

    "phone":
        phoneController.text.trim(),
  });

  final transactions =
      await FirebaseFirestore.instance
          .collection("transactions")
          .where(
            "personId",
            isEqualTo: personId,
          )
          .get();

  for (final doc
      in transactions.docs) {

    await doc.reference.update({

      "name":
          nameController.text.trim(),

      "phone":
          phoneController.text.trim(),
    });
  }

  final operations =
      await FirebaseFirestore.instance
          .collection("operations")
          .where(
            "personId",
            isEqualTo: personId,
          )
          .get();

  for (final doc
      in operations.docs) {

    await doc.reference.update({

      "name":
          nameController.text.trim(),

      "phone":
          phoneController.text.trim(),
    });
  }

  if (context.mounted) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content: Text(
          "✅ تم التعديل بنجاح",
        ),
      ),
    );
  }
}
},
),

        IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {},
        ),
      ],
    );
  },
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