import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/workflow.dart';
import '../services/vote_service.dart';
import '../services/exception_service.dart';
import '../services/finance_service.dart';

class CaseDetailsScreen extends StatelessWidget {
  final String caseId;

  const CaseDetailsScreen({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تفاصيل الحالة")),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("cases")
            .doc(caseId)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 🧾 معلومات الحالة
                Text(
                  data["title"] ?? "",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(data["description"] ?? ""),

                const SizedBox(height: 10),

                Text("📊 الحالة: ${_statusText(data["workflowStatus"])}"),

                const SizedBox(height: 10),

                Text(
                  data["caseType"] == "social_monthly"
                      ? "❤️ أسرة متعففة"
                      : "📁 حالة عادية",
                ),

                const SizedBox(height: 20),

                // 🔘 الأزرار
                _buildButtons(context, data),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔄 تحويل الحالة لنص
  String _statusText(String? status) {
    switch (status) {
      case Workflow.submitted:
        return "طلب جديد";
      case Workflow.underReview:
        return "قيد الدراسة";
      case Workflow.approved:
        return "تم الاعتماد";
      case Workflow.paid:
        return "تم تسديد المستحق";
      default:
        return status ?? "";
    }
  }

  // 🔘 الأزرار حسب الحالة
  Widget _buildButtons(BuildContext context, Map data) {

    final user = FirebaseAuth.instance.currentUser;
    final phone = user?.phoneNumber;

    // 🔍 بدء الدراسة
    if (data["workflowStatus"] == Workflow.submitted) {
      return ElevatedButton(
        onPressed: () {
          FirebaseFirestore.instance
              .collection("cases")
              .doc(caseId)
              .update({"workflowStatus": Workflow.underReview});
        },
        child: const Text("🔍 بدء الدراسة"),
      );
    }

    // 🗳 التصويت + اعتماد
    if (data["workflowStatus"] == Workflow.underReview) {
      return Column(
        children: [

          ElevatedButton(
            onPressed: () async {
              final result = await VoteService.vote(caseId);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result)),
              );
            },
            child: const Text("🗳 إبداء الرأي"),
          ),

          const SizedBox(height: 10),

          Text("عدد الآراء: ${data["votesCount"] ?? 0}"),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {

              if ((data["votesCount"] ?? 0) < 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("❌ يلزم 3 آراء قبل الاعتماد"),
                  ),
                );
                return;
              }

              FirebaseFirestore.instance
                  .collection("cases")
                  .doc(caseId)
                  .update({"workflowStatus": Workflow.approved});
            },
            child: const Text("👑 اعتماد القرار"),
          ),
        ],
      );
    }

    // ⚠️ استثناء + 💰 دفع
    if (data["workflowStatus"] == Workflow.approved) {
      return Column(
        children: [

          // 🗳 تصويت استثنائي
          ElevatedButton(
            onPressed: () async {
              final result =
                  await ExceptionService.voteException(caseId);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result)),
              );
            },
            child: const Text("⚠️ تصويت استثنائي"),
          ),

          const SizedBox(height: 10),

          Text(
            "أصوات الاستثناء: ${data["exceptionVotesCount"] ?? 0}/5",
          ),

          const SizedBox(height: 20),

          // 💰 الدفع
          ElevatedButton(
            onPressed: () async {

              double balance = 20000; // 🔁 مؤقت (اربطه لاحقاً بالصندوق)

              final canPayNow =
                  FinanceService.canPay(balance, data);

              if (!canPayNow) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("❌ لا يمكن التسديد (الرصيد محجوز)"),
                  ),
                );
                return;
              }

              final amount =
                  FinanceService.getPayableAmount(balance, data);

              await FirebaseFirestore.instance
                  .collection("cases")
                  .doc(caseId)
                  .update({
                "workflowStatus": Workflow.paid,
                "paidAmount": amount,
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("✅ تم تسديد $amount MRU"),
                ),
              );
            },
            child: const Text("💰 تسديد المستحق"),
          ),
        ],
      );
    }

    // ✅ انتهت
    return const Text("✅ تم الانتهاء");
  }
}