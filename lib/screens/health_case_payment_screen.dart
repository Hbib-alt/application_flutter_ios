import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/health_case_notification_service.dart';
import '../utils/workflow.dart';

import '../services/user_service.dart';

class HealthCasePaymentScreen
    extends StatefulWidget {

  final String caseId;

  final Map<String, dynamic> data;

  const HealthCasePaymentScreen({

    super.key,

    required this.caseId,

    required this.data,
  });

  @override
  State<HealthCasePaymentScreen>
      createState() =>
          _HealthCasePaymentScreenState();
}

class _HealthCasePaymentScreenState
    extends State<
        HealthCasePaymentScreen> {

  final amountController =
      TextEditingController();

  final noteController =
      TextEditingController();

  bool isLoading = false;

  @override
  void initState() {

    super.initState();

    final approvedAmount =
        widget.data[
            "approvedAmount"];

    final suggestedAmount =
        widget.data[
            "suggestedAmount"];

    final amount =
        approvedAmount ??
            suggestedAmount ??
            0;

    if (amount != 0) {

      amountController.text =
          amount.toString();
    }
  }

  @override
  void dispose() {

    amountController.dispose();

    noteController.dispose();

    super.dispose();
  }

  // ================= CONFIRM PAYMENT =================

  Future<void>
      confirmPayment() async {

    if (isLoading) return;

    final uid =
        UserService.currentUid;

    if (uid.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "يرجى تسجيل الدخول",
          ),
        ),
      );

      return;
    }

    final amount =
        double.tryParse(

              amountController
                  .text
                  .trim(),
            ) ??
            0;

    if (amount <= 0) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "أدخل مبلغاً صحيحاً",
          ),
        ),
      );

      return;
    }

    setState(() {

      isLoading = true;
    });

    try {

      final userName =
          await UserService
              .getUserName();

      final userRole =
          await UserService
              .getUserRole();

      final userPhone =
          await UserService
              .getPhone();
final fullName =
    widget.data["fullName"]
        ?.toString() ??
    "مستفيد";
    
      final caseRef =
          FirebaseFirestore.instance
              .collection(
                "health_cases",
              )
              .doc(
                widget.caseId,
              );

      final caisseRef =
          FirebaseFirestore.instance
              .collection(
                "finance",
              )
              .doc("main");

      final caisseSnap =
          await caisseRef.get();

      final caisseData =
          caisseSnap.data() ??
              {};

      final currentBalance =
          (caisseData[
                      "balance"] ??
                  0)
              .toDouble();

      // ================= CHECK BALANCE =================

      if (currentBalance <
          amount) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content: Text(
              "رصيد الصندوق غير كاف",
            ),
          ),
        );

        setState(() {

          isLoading = false;
        });

        return;
      }

      // ================= UPDATE CAISSE =================

      await caisseRef.set({

        "balance":
            currentBalance -
                amount,

        "updatedAt":
            FieldValue
                .serverTimestamp(),

      }, SetOptions(
        merge: true,
      ));

      // ================= TRANSACTION =================

      await FirebaseFirestore
          .instance
          .collection(
            "transactions",
          )
          .add({

        "type":
            "health_case_payment",

        "caseId":
            widget.caseId,

        "amount":
            amount,

        "paidBy":
            uid,

        "paidByName":
            userName,

        "paidByRole":
            userRole,

        "paidByPhone":
            userPhone,

        "note":
            noteController.text
                .trim(),

        "createdAt":
            FieldValue
                .serverTimestamp(),
      });

      // ================= UPDATE CASE =================
await caseRef.update({

  "status":
      Workflow.paid,

  "paidAmount":
      amount,

  "paidBy":
      uid,

  "paidByName":
      userName,

  "paidByRole":
      userRole,

  "paidByPhone":
      userPhone,

  "paymentNote":
      noteController.text
          .trim(),

  "paidAt":
      FieldValue
          .serverTimestamp(),
});

await HealthCaseNotificationService
    .notifyCommittee(
  title: "✅ تم صرف المستحق",

  body:
      "$fullName استفاد من ${amount.toInt()} MRU",

  caseId: widget.caseId,
);
    

      // ================= SUCCESS =================

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "✅ تم صرف المستحق",
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

    } finally {

      if (mounted) {

        setState(() {

          isLoading = false;
        });
      }
    }
  }

  // ================= BUILD =================

  @override
  Widget build(
    BuildContext context,
  ) {

    final fullName =
        widget.data["fullName"]
                ?.toString() ??
            "بدون اسم";

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "صرف المستحق",
        ),

        centerTitle: true,
      ),

      backgroundColor:
          const Color(
        0xFFF5F6FA,
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
          16,
        ),

        child: ListView(

          children: [

            // ================= INFO CARD =================

            Card(

              child: ListTile(

                title: Text(
                  fullName,
                ),

                subtitle:
                    const Text(
                  "تأكيد صرف مبلغ من الصندوق",
                ),

                leading:
                    const Icon(
                  Icons
                      .health_and_safety,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ================= AMOUNT =================

            TextField(

              controller:
                  amountController,

              keyboardType:
                  TextInputType
                      .number,

              decoration:
                  const InputDecoration(

                labelText:
                    "المبلغ المصروف بالأوقية الجديدة",

                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            // ================= NOTE =================

            TextField(

              controller:
                  noteController,

              maxLines: 3,

              decoration:
                  const InputDecoration(

                labelText:
                    "ملاحظة أمين الصندوق",

                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ================= BUTTON =================

ElevatedButton.icon(

  onPressed:
      isLoading
          ? null
          : confirmPayment,

  icon: const Icon(
    Icons.payments,
  ),

  label:

      isLoading

          ? const Padding(

              padding:
                  EdgeInsets.all(8),

              child:
                  CircularProgressIndicator(
                color: Colors.white,
              ),
            )

          : const Text(
              "تأكيد صرف المستحق",
            ),

  style:
      ElevatedButton.styleFrom(

    backgroundColor:
        Colors.green,

    foregroundColor:
        Colors.white,

    minimumSize:
        const Size.fromHeight(55),
  ),
),

          ],
        ),
      ),
    );
  }
}