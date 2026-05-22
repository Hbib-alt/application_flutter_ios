import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/finance_service.dart';
import '../services/user_service.dart';

class PaymentScreen extends StatelessWidget {
  final Map data;
  final double balance;

  const PaymentScreen({
    super.key,
    required this.data,
    required this.balance,
  });

  Future<void> processPayment(BuildContext context) async {
    try {
      final canPayNow = FinanceService.canPay(balance, data);

      if (!canPayNow) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ لا يمكن تسديد المستحق"),
          ),
        );

        return;
      }

      final amount = FinanceService.getPayableAmount(balance, data);

      final safeAmount = double.tryParse(amount.toString()) ?? 0;

      if (safeAmount <= 0) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ مبلغ غير صالح"),
          ),
        );

        return;
      }

      final userName = await UserService.getUserName();

      final createdByUid = UserService.currentUid ?? "";

      final fullName = data["fullName"]?.toString() ?? "";
      final phone = data["phone"]?.toString() ?? "";
      final purpose = data["purpose"]?.toString() ?? "";

      await FirebaseFirestore.instance.collection("operations").add({

  "name": fullName,

  "phone": phone,

  "amount": safeAmount,

  "paymentType": "monthly",

  "purpose": purpose,

  "status": "pending",

  "createdByUid": createdByUid,

  "createdByName": userName,

  // ✅ IMPORTANT
  "collectorName": userName,

  "createdAt":
      FieldValue.serverTimestamp(),
});

      await FirebaseFirestore.instance.collection("notifications").add({
        "title": "💰 دخل جديد",
        "body": "يوجد دخل جديد يحتاج التحقق",
        "targetRole": "treasurer",
        "read": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ تم إرسال العملية إلى الصندوق للموافقة"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print("PAYMENT ERROR = $e");

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ حدث خطأ أثناء إرسال العملية"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = data["fullName"]?.toString() ?? "بدون اسم";
    final phone = data["phone"]?.toString() ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("تسديد المستحق"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (phone.isNotEmpty) Text("📱 $phone"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text(
                    "رصيد الصندوق الحالي",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$balance MRU",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            ElevatedButton.icon(
              onPressed: () {
                processPayment(context);
              },
              icon: const Icon(Icons.send),
              label: const Text("إرسال العملية للصندوق"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}