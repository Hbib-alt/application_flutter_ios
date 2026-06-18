import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'payment_screen.dart';

class AddCaseScreen extends StatefulWidget {

  const AddCaseScreen({
    super.key,
  });

  @override
  State<AddCaseScreen> createState() =>
      _AddCaseScreenState();
}

class _AddCaseScreenState
    extends State<AddCaseScreen> {

  // ================= CONTROLLERS =================

  final nameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final purposeController =
      TextEditingController();
final amountController =
    TextEditingController();

  // ================= DATA =================

  String paymentType =
      "monthly";

  int? category;

  double amount = 0;

  // ================= CONFLICT =================

  bool phoneConflict = false;

  String conflictCollector = "";

  // ================= CLEAN PHONE =================

 String cleanPhoneNumber(String phone) {

  phone = phone
      .replaceAll(" ", "")
      .replaceAll("+", "")
      .trim();

  if (phone.length == 11 &&
      phone.startsWith("222")) {

    phone = phone.substring(3);
  }

  return phone;
}


  // ================= CHECK PHONE =================

  Future<void> checkPhoneLive(
    String phone,
  ) async {

    phone =
        cleanPhoneNumber(
      phone,
    );

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
            .collection(
              "people",
            )
            .where(
              "phone",
              isEqualTo:
                  "222$phone",
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
if (ownerCollectorId.isEmpty) {

  setState(() {

    phoneConflict = false;

    conflictCollector = "";
  });

  return;
}
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
          phoneController.text
              .trim();

      phone =
          cleanPhoneNumber(
        phone,
      );

      final result =
          await FirebaseFirestore
              .instance
              .collection(
                "people",
              )
              .where(
                "phone",
                isEqualTo:
                    "222$phone",
              )
              .get();

    if (result.docs.isNotEmpty) {

  final data =
      result.docs.first.data();

  nameController.text =
      data["name"] ?? "";

  category =
    data["monthlyAmount"] as int?;

  setState(() {});

} else {

  nameController.clear();

  setState(() {

    category = null;
  });
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
            .collection(
              "people",
            )
            .where(
              "phone",
              isEqualTo: phone,
            )
            .get();

    if (result.docs.isNotEmpty) {

      return result
          .docs
          .first
          .id;
    }

    
final currentUser =
    FirebaseAuth.instance.currentUser;

String collectorName = "";

if (currentUser != null) {

  final userDoc =
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

  collectorName =
      userDoc.data()?["name"] ?? "";
}
    final doc =
    await FirebaseFirestore
        .instance
        .collection("people")
        .add({

  "phone": phone,

  "name": name,

  "totalAmount": 0,

  "monthlyAmount": category,

  "collectorId":
    FirebaseAuth.instance.currentUser?.uid ?? "",

"collectorName":
    collectorName,
    
  "createdAt":
      FieldValue
          .serverTimestamp(),
});

    return doc.id;
  }

  // ================= SUBMIT =================

  Future<void> submit() async {

    // ================= BLOCK SAVE =================

    if (phoneConflict) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(

          content: Text(

            "⚠️ هذا الرقم تابع للمحصل: $conflictCollector",
          ),
        ),
      );

      return;
    }

    String phone =
        phoneController.text
            .trim();

   phone =
    cleanPhoneNumber(phone);

if (phone.length != 8) {

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(
      content: Text(
        "رقم الهاتف يجب أن يتكون من 8 أرقام",
      ),
    ),
  );

  return;
}

phone = "222$phone";

    final name =
        nameController.text
            .trim();

    // ================= VALIDATION =================

    if (phone.isEmpty) {

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            "رقم الهاتف إجباري",
          ),
        ),
      );

      return;
    }

   

    if (name.isEmpty) {

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            "الاسم إجباري",
          ),
        ),
      );

      return;
    }

    try {
if (paymentType == "monthly" &&
    category == null) {

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(

      content: Text(
        "يرجى اختيار فئة الاشتراك",
      ),
    ),
  );

  return;
}
      final personId =
          await getOrCreatePerson(
        phone,
        name,
      );

// ================= PANEL + DONATION =================

if (paymentType != "monthly") {
final purpose =
    purposeController.text.trim();

if (purpose.length < 10) {

  ScaffoldMessenger.of(context)
      .showSnackBar(

    const SnackBar(

      content: Text(
        "يرجى إدخال موضوع واضح للعملية (10 أحرف على الأقل)",
      ),
    ),
  );

  return;
}
  final amount =
      double.tryParse(
            amountController.text.trim(),
          ) ??
          0;

  if (amount <= 0) {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(
          "يرجى إدخال مبلغ صحيح",
        ),
      ),
    );

    return;
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
              .collection(
                "users",
              )
              .doc(
                currentUser.uid,
              )
              .get();

      collectorName =
          userDoc.data()?[
                  "fullName"] ??
              "غير معروف";
    }
 final operationRef =
    await FirebaseFirestore.instance
        .collection("operations")
        .add({

  "personId": personId,

  "name": name,

  "phone": phone,

  "paymentType": paymentType,

  "purpose":
      purposeController.text.trim(),

  "amount": amount,

  "collectorName":
      collectorName,

  "createdByName":
      collectorName,

  "status": "pending",

  "isDeleted": false,

  "createdAt":
      FieldValue.serverTimestamp(),

  "createdByUid":
      FirebaseAuth.instance.currentUser?.uid,
});
// ================= NOTIFICATION TRESORIER =================

final treasurerQuery =
    await FirebaseFirestore.instance
        .collection("users")
        .where(
          "role",
          isEqualTo: "treasurer",
        )
        .limit(1)
        .get();

if (treasurerQuery.docs.isNotEmpty) {

 String paymentTypeArabic = "";

switch (paymentType) {
  case "monthly":
    paymentTypeArabic = "اشتراك شهري";
    break;

  case "donation":
    paymentTypeArabic = "تبرع";
    break;

  case "panel":
    paymentTypeArabic = "اللوحة";
    break;

  default:
    paymentTypeArabic = paymentType;
}
final currentUser =
    FirebaseAuth.instance.currentUser;

String collectorName = "";

if (currentUser != null) {

  final userDoc =
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();

  collectorName =
      userDoc.data()?["name"] ?? "";
}
await FirebaseFirestore.instance
    .collection("notifications")
    .add({

  "userId":
      treasurerQuery.docs.first.id,

  "title":
      "💰 طلب إدخال مبلغ للصندوق",

  "body":
    "المحصل: $collectorName\n"
    "إسم الزبون: $name\n"
    "الهاتف: $phone\n"
    "النوع: $paymentTypeArabic\n"
    "المبلغ: ${amount.toInt()} MRU\n"
    "الغرض: ${purposeController.text.trim()}",

  "type":
      "operation",

  "operationId":
      operationRef.id,

  "read":
      false,

  "createdAt":
      FieldValue.serverTimestamp(),
});
}
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(

    const SnackBar(

      content: Text(
        "تم إرسال العملية للصندوق",
      ),
    ),
  );

  Navigator.pop(context);

  return;
}
      // ================= OPEN PAYMENT SCREEN =================

      if (!mounted) return;

      Navigator.push(

        context,

        MaterialPageRoute(

          builder:
              (_) => PaymentScreen(

            data: {

              "personId":
                  personId,

              "fullName":
                  name,

              "phone":
                  phone,

              "monthlyAmount":
                  category,

              "paymentType":
                  paymentType,

              "purpose":
    purposeController.text.trim(),
            },

            balance: 100000,
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

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
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F6FA,
      ),

      appBar: AppBar(

        title: const Text(
          "تسجيل دخل",
        ),

        centerTitle: true,

        elevation: 0,
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          16,
        ),

        child: ListView(

          children: [

            // ================= PHONE =================

            TextField(

              controller:
                  phoneController,

              keyboardType:
                  TextInputType
                      .number,

              onChanged:
                  (value) async {

                await checkPhoneLive(
                  value,
                );

                if (value.length >=
                    8) {

                  findPerson();
                }
              },

              decoration:
                  InputDecoration(

                labelText:
                    "رقم الهاتف (8 أرقام) ",

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

                labelText:
                    "الاسم",
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

                  value:
                      "monthly",

                  child: Text(
                    "اشتراك",
                  ),
                ),

                DropdownMenuItem(

                  value:
                      "donation",

                  child: Text(
                    "تبرع",
                  ),
                ),

                DropdownMenuItem(

                  value:
                      "panel",

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

           if (paymentType == "monthly" &&
    category == null)
  DropdownButtonFormField<int>(
    decoration: const InputDecoration(
      labelText: "فئة الاشتراك",
    ),
    items: const [
      DropdownMenuItem(
        value: 200,
        child: Text("200 MRU"),
      ),
      DropdownMenuItem(
        value: 500,
        child: Text("500 MRU"),
      ),
    ],
    onChanged: (v) {
      setState(() {
        category = v;
      });
    },
  ),
           if (paymentType == "monthly" &&
    category != null)
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      "فئة الزبون: ${category!} أوقية",
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

                

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

  controller:
      amountController,

  keyboardType:
      TextInputType
          .number,

  decoration:
      const InputDecoration(

    labelText:
        "المبلغ بالأوقية الجديدة",
  ),
),
            ],

            const SizedBox(
              height: 24,
            ),

            // ================= SAVE BUTTON =================

            ElevatedButton(

              onPressed: submit,

              child: const Text(
                "متابعة",
              ),
            ),
          ],
        ),
      ),
    );
  }
}