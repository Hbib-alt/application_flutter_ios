import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCaseScreen extends StatefulWidget {

  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() =>
      _AddCaseScreenState();
}

class _AddCaseScreenState
    extends State<AddCaseScreen> {

  final nameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final purposeController =
      TextEditingController();

  String paymentType =
      "monthly";

  int category = 500;

  int months = 1;

  double amount = 0;

  // ================= CONFLICT =================

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

  // ================= CHECK PHONE =================

  Future<void> checkPhoneLive(
    String phone,
  ) async {

    phone =
        cleanPhoneNumber(phone);

    if (phone.length < 8) {

      setState(() {

        phoneConflict = false;

        conflictCollector = "";
      });

      return;
    }

    final currentUser =
        FirebaseAuth
            .instance
            .currentUser;

    if (currentUser == null) {

      return;
    }

    final currentCollectorId =
        currentUser.uid;

    final result =
        await FirebaseFirestore
            .instance
            .collection("people")
            .where(
              "phone",
              isEqualTo: "222$phone",
            )
            .get();

    // ================= NOT FOUND =================

    if (result.docs.isEmpty) {

      setState(() {

        phoneConflict = false;

        conflictCollector = "";
      });

      return;
    }

    final data =
        result.docs.first.data();

    final ownerCollectorId =

        (data["collectorId"] ?? "")
            .toString();

    final ownerCollectorName =

        (data["collectorName"] ?? "")
            .toString();

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

  // ================= FIND PERSON =================

  Future<void> findPerson() async {

    try {

      String phone =
          phoneController.text.trim();

      phone =
          cleanPhoneNumber(phone);

      final result =
          await FirebaseFirestore
              .instance
              .collection("people")
              .where(
                "phone",
                isEqualTo: "222$phone",
              )
              .get();

      if (result.docs.isNotEmpty) {

        final data =
            result.docs.first.data();

        nameController.text =
            data["name"] ?? "";
      }

    } catch (_) {}
  }

  // ================= GET OR CREATE PERSON =================

  Future<String> getOrCreatePerson(
    String phone,
    String name,
  ) async {

    final result =
        await FirebaseFirestore
            .instance
            .collection("people")
            .where(
              "phone",
              isEqualTo: phone,
            )
            .get();

    if (result.docs.isNotEmpty) {

      return result.docs.first.id;
    }

    final currentUser =
        FirebaseAuth
            .instance
            .currentUser;

    String collectorName =
        "غير معروف";

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
              "غير معروف";
    }

    final doc =
    await FirebaseFirestore
        .instance
        .collection("people")
        .add({

      "phone": phone,

      "name": name,

      "totalAmount": 0,

      "collectorId":
          currentUser?.uid ?? "",

      "collectorName":
          collectorName,

      "createdAt":
          FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ================= SUBMIT =================

  Future<void> submit() async {

    // ================= BLOCK SAVE =================

    if (phoneConflict) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            "⚠️ هذا الرقم تابع للمحصل: $conflictCollector",
          ),
        ),
      );

      return;
    }

    String phone =
        phoneController.text.trim();

    phone =
        cleanPhoneNumber(phone);

    if (!phone.startsWith("222")) {

      phone = "222$phone";
    }

    final name =
        nameController.text.trim();

    // ================= VALIDATION =================

    if (phone.isEmpty) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "رقم الهاتف إجباري",
          ),
        ),
      );

      return;
    }

    if (phone.length != 11) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "رقم الهاتف غير صحيح",
          ),
        ),
      );

      return;
    }

    if (name.isEmpty) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "الاسم إجباري",
          ),
        ),
      );

      return;
    }

    // ================= CALCULATE AMOUNT =================

    if (paymentType ==
        "monthly") {

      amount =
          (category * months)
              .toDouble();
    }

    try {

      final personId =
          await getOrCreatePerson(
        phone,
        name,
      );

      // ================= CURRENT YEAR =================

      final currentYear =
          DateTime.now().year;

      // ================= GET ALL OPERATIONS =================

      final existingPayments =
          await FirebaseFirestore
              .instance
              .collection("operations")
              .where(
                "personId",
                isEqualTo: personId,
              )
              .get();
              // ================= GET ADMIN =================

final adminSnapshot =
    await FirebaseFirestore
        .instance
        .collection("users")
        .where(
          "role",
          isEqualTo: "admin",
        )
        .limit(1)
        .get();

if (adminSnapshot.docs.isEmpty) {

  throw Exception(
    "Aucun admin trouvé",
  );
}

final adminId =
    adminSnapshot
        .docs
        .first
        .id;

// ================= CURRENT COLLECTOR =================

final currentUser =
    FirebaseAuth
        .instance
        .currentUser;

String collectorName =
    "غير معروف";

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
          "غير معروف";
}
// ================= CREATE NOTIFICATION =================

await FirebaseFirestore.instance
    .collection("notifications")
    .add({

  "userId": adminId,

  "title":
      "طلب إدخال مبلغ للصندوق",

  "body":

      "المحصل: $collectorName\n\n"

      "الزبون: $name\n\n"

      "الهاتف: $phone\n\n"

      "نوع العملية: "

      "${paymentType == "monthly"
          ? "اشتراك"
          : paymentType == "donation"
              ? "تبرع"
              : "لوحة"}\n\n"

      "المبلغ: ${amount.toInt()} أوقية جديدة\n\n"

      "${purposeController.text.trim().isNotEmpty
          ? "الهدف: ${purposeController.text.trim()}\n\n"
          : ""}"

      "يرجى الموافقة من أجل إدخال المبلغ للصندوق.",

  "clientName": name,

  "phone": phone,

  "amount": amount,

  "paymentType": paymentType,

  "purpose":
      purposeController.text.trim(),

  "collectorName":
      collectorName,

  "collectorId":
      FirebaseAuth
              .instance
              .currentUser
              ?.uid ??
          "",

  "createdByName":
      collectorName,

  "createdByRole":
      "محصل",

  "read": false,

  "type": "operation",

  "createdAt":
      FieldValue.serverTimestamp(),
});
      // ================= COUNT MONTHS =================

      int totalMonths = 0;

      for (var doc
          in existingPayments.docs) {

        final data = doc.data();

        final type =
            data["paymentType"] ?? "";

        final year =
            data["year"] ??
                currentYear;

        if (type == "monthly" &&
            year == currentYear) {

          totalMonths +=
              ((data["months"] ??
                          1)
                      as num)
                  .toInt();
        }
      }

      // ================= BLOCK IF 12 MONTHS =================

      if (paymentType ==
          "monthly") {

        if (totalMonths >= 12) {

          if (!mounted) return;

          ScaffoldMessenger.of(
                  context)
              .showSnackBar(

            const SnackBar(

              content: Text(
                "هذا الشخص أكمل اشتراك 12 شهر",
              ),
            ),
          );

          return;
        }

        if ((totalMonths +
                months) >
            12) {

          if (!mounted) return;

          ScaffoldMessenger.of(
                  context)
              .showSnackBar(

            const SnackBar(

              content: Text(
                "لا يمكن تجاوز 12 شهر",
              ),
            ),
          );

          return;
        }
      }

      // ================= SAVE =================

      await FirebaseFirestore
          .instance
          .collection("operations")
          .add({

        "name": name,

        "phone": phone,

        "amount":
            amount.toInt(),

        "paymentType":
            paymentType,

        "type":
            paymentType,

        "category":
            category,

        "months":
            months,

        "purpose":
            purposeController.text
                .trim(),

        "personId":
            personId,

        "status":
            "pending",

        "year":
            currentYear,

        "createdBy":
            FirebaseAuth
                    .instance
                    .currentUser
                    ?.uid ??
                "admin",

        "createdAt":
            FieldValue
                .serverTimestamp(),
      });

      // ================= SUCCESS =================

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "✅ تم الحفظ",
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            "Erreur: $e",
          ),
        ),
      );
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(

        title: const Text(
          "تسجيل دخل",
        ),

        centerTitle: true,

        elevation: 0,
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: ListView(

          children: [

            // ================= PHONE =================

            TextField(

              controller:
                  phoneController,

              keyboardType:
                  TextInputType.number,

              onChanged: (value) async {

                await checkPhoneLive(
                  value,
                );

                if (value.length >= 8) {

                  findPerson();
                }
              },

              decoration:
                  InputDecoration(

                labelText:
                    "رقم الهاتف (بدون 222)",

                errorText:

                    phoneConflict

                        ? "⚠️ هذا الرقم تابع للمحصل: $conflictCollector"

                        : null,
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ================= NAME =================

            TextField(

              controller:
                  nameController,

              decoration:
                  const InputDecoration(

                labelText: "الاسم",
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ================= TYPE =================

            DropdownButtonFormField<
                String>(

              value: paymentType,

              decoration:
                  const InputDecoration(

                labelText:
                    "نوع الدخل",
              ),

              items: const [

                DropdownMenuItem(

                  value: "monthly",

                  child: Text(
                    "اشتراك",
                  ),
                ),

                DropdownMenuItem(

                  value: "donation",

                  child: Text(
                    "تبرع",
                  ),
                ),

                DropdownMenuItem(

                  value: "panel",

                  child: Text(
                    "لوحة",
                  ),
                ),
              ],

              onChanged: (v) {

                setState(() {

                  paymentType =
                      v!;
                });
              },
            ),

            const SizedBox(
              height: 14,
            ),

            // ================= MONTHLY =================

            if (paymentType ==
                "monthly")
              ...[

              DropdownButtonFormField<
                  int>(

                value: category,

                decoration:
                    const InputDecoration(

                  labelText:
                      "الفئة",
                ),

                items: const [

                  DropdownMenuItem(

                    value: 500,

                    child:
                        Text("500"),
                  ),

                  DropdownMenuItem(

                    value: 200,

                    child:
                        Text("200"),
                  ),
                ],

                onChanged: (v) {

                  setState(() {

                    category = v!;
                  });
                },
              ),

              const SizedBox(
                height: 14,
              ),

              TextField(

                keyboardType:
                    TextInputType.number,

                decoration:
                    const InputDecoration(

                  labelText:
                      "عدد الأشهر",
                ),

                onChanged: (v) {

                  months =
                      int.tryParse(v) ??
                          1;
                },
              ),
            ],

            // ================= DONATION / PANEL =================

            if (paymentType ==
                    "donation" ||
                paymentType ==
                    "panel")
              ...[

              TextField(

                controller:
                    purposeController,

                decoration:
                    const InputDecoration(

                  labelText:
                      "الهدف",
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              TextField(

  keyboardType:
      TextInputType.number,

  decoration: InputDecoration(

    labelText:
        paymentType == "donation" ||
                paymentType == "panel"
            ? "المبلغ بالأوقية الجديدة"
            : "المبلغ",

    helperText:
        paymentType == "donation" ||
                paymentType == "panel"
            ? "يرجى إدخال المبلغ بالأوقية الجديدة"
            : null,
  ),

  onChanged: (v) {

    amount =
        double.tryParse(v) ?? 0;
  },
),
            ],

            const SizedBox(
              height: 24,
            ),

            // ================= SAVE BUTTON =================

            ElevatedButton(

              onPressed: submit,

              child: const Text(
                "حفظ",
              ),
            ),
          ],
        ),
      ),
    );
  }
}