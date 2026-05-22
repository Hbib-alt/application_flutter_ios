import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends State<AddTransactionScreen> {

  // ================= CONTROLLERS =================

  final TextEditingController amountController =
      TextEditingController();

  final TextEditingController noteController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  // ================= TYPE =================

  String type = "income";

  // ================= PHONE CONFLICT =================

  bool phoneConflict = false;

  String conflictCollector = "";

  // ================= CLEAN PHONE =================

  String cleanPhoneNumber(
    String phone,
  ) {

    phone =
        phone
            .replaceAll(" ", "")
            .replaceAll("+", "");

    if (phone.startsWith("222")) {

      phone = phone.substring(3);
    }

    return phone.trim();
  }

  // ================= LIVE CHECK =================

  Future<void> checkPhoneLive(
    String phone,
  ) async {

    // ================= CLEAN =================

    phone =
        cleanPhoneNumber(
      phone,
    );

    // ================= RESET =================

    if (phone.length < 8) {

      setState(() {

        phoneConflict = false;

        conflictCollector = "";
      });

      return;
    }

    // ================= CURRENT USER =================

    final currentUser =
        FirebaseAuth
            .instance
            .currentUser;

    if (currentUser == null) {

      return;
    }

    final currentCollectorId =
        currentUser.uid;

    // ================= DIRECT SEARCH =================

    final doc =
        await FirebaseFirestore
            .instance
            .collection("people")
            .doc("222$phone")
            .get();

    // ================= NOT FOUND =================

    if (!doc.exists) {

      setState(() {

        phoneConflict = false;

        conflictCollector = "";
      });

      return;
    }

    final data = doc.data()!;

    final ownerCollectorId =

        data["collectorId"] ?? "";

    final ownerCollectorName =

        data["collectorName"] ?? "";

    // ================= SAME COLLECTOR =================

    if (ownerCollectorId ==
        currentCollectorId) {

      setState(() {

        phoneConflict = false;

        conflictCollector = "";
      });

      return;
    }

    // ================= CONFLICT =================

    setState(() {

      phoneConflict = true;

      conflictCollector =
          ownerCollectorName;
    });
  }

  // ================= SAVE =================

  void saveData() async {

    // ================= BLOCK SAVE =================

    if (phoneConflict) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "⚠️ لا يمكن حفظ العملية",
          ),
        ),
      );

      return;
    }

    // ================= AMOUNT =================

    final amount =
        double.tryParse(
      amountController.text,
    );

    if (amount == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "⚠️ أدخل مبلغاً صحيحاً",
          ),
        ),
      );

      return;
    }

    // ================= CURRENT USER =================

    final currentUser =
        FirebaseAuth
            .instance
            .currentUser;

    String collectorName = "";

    if (currentUser != null) {

      final userDoc =
          await FirebaseFirestore
              .instance
              .collection("users")
              .doc(currentUser.uid)
              .get();

      collectorName =
          userDoc
                  .data()?["name"] ??
              "";
    }

    // ================= PHONE =================

    final phone =
        cleanPhoneNumber(
      phoneController.text,
    );

    // ================= CREATE PERSON =================

    final peopleDoc =
        await FirebaseFirestore
            .instance
            .collection("people")
            .doc("222$phone")
            .get();

    // ================= CREATE IF NOT EXISTS =================

    if (!peopleDoc.exists) {

      await FirebaseFirestore
          .instance
          .collection("people")
          .doc("222$phone")
          .set({

        "phone":
            "222$phone",

        "collectorName":
            collectorName,

        "collectorId":
            currentUser?.uid ?? "",

        "name":
            noteController.text,

        "createdAt":
            Timestamp.now(),

        "totalAmount": 0,
      });
    }

    // ================= DATA =================

    final data = {

      "amount": amount,

      "phone": "222$phone",

      "collectorName":
          collectorName,

      "collectorId":
          currentUser?.uid ?? "",

      "note":
          noteController.text,

      "createdAt":
          Timestamp.now(),
    };

    // ================= SAVE INCOME =================

    if (type == "income") {

      data["status"] =
          "validated";

      await FirebaseFirestore
          .instance
          .collection("income")
          .add(data);
    }

    // ================= SAVE EXPENSE =================

    else {

      data["status"] =
          "approved";

      await FirebaseFirestore
          .instance
          .collection("expenses")
          .add(data);
    }

    // ================= SUCCESS =================

    if (mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "✅ تم الحفظ بنجاح",
          ),
        ),
      );
    }

    Navigator.pop(context);
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "إضافة عملية",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          16,
        ),

        child: Column(

          children: [

            // ================= TYPE =================

            DropdownButton<String>(

              value: type,

              isExpanded: true,

              items: const [

                DropdownMenuItem(

                  value: "income",

                  child: Text(
                    "دخل",
                  ),
                ),

                DropdownMenuItem(

                  value: "expense",

                  child: Text(
                    "مصروف",
                  ),
                ),
              ],

              onChanged: (v) {

                setState(() {

                  type = v!;
                });
              },
            ),

            const SizedBox(
              height: 15,
            ),

            // ================= PHONE =================

            TextField(

              controller:
                  phoneController,

              keyboardType:
                  TextInputType.phone,

              onChanged:
                  (value) async {

                await checkPhoneLive(
                  value,
                );
              },

              decoration:
                  InputDecoration(

                labelText:
                    "رقم الهاتف",

                border:
                    const OutlineInputBorder(),

                errorText:

                    phoneConflict

                        ? "⚠️ هذا الرقم تابع للمحصل: $conflictCollector"

                        : null,

                prefixIcon:

                    phoneConflict

                        ? const Icon(
                            Icons.warning,
                            color: Colors.red,
                          )

                        : const Icon(
                            Icons.phone,
                          ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // ================= AMOUNT =================

            TextField(

              controller:
                  amountController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(

                labelText:
                    "المبلغ",

                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            // ================= NOTE =================

            TextField(

              controller:
                  noteController,

              decoration:
                  const InputDecoration(

                labelText:
                    "ملاحظة",

                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ================= BUTTON =================

            SizedBox(

              width: double.infinity,

              child: ElevatedButton(

                onPressed:
                    saveData,

                style:
                    ElevatedButton.styleFrom(

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),

                child: const Text(

                  "حفظ",

                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}