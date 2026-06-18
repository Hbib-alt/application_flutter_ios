import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/user_service.dart';
import '../services/subscription_stats_service.dart';
import 'health_case_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
  });

  Future<void> markAsRead(String id) async {
  try {
    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(id)
        .update({
      "read": true,
      "readAt": FieldValue.serverTimestamp(),
    });
  } catch (_) {}
}

  Future<void> markAllAsRead() async {
    final user = UserService.currentUser;

    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("notifications")
          .where("userId", isEqualTo: user.uid)
          .where("read", isEqualTo: false)
          .get();

      for (final doc in snapshot.docs) {
       await doc.reference.update({
  "read": true,
  "readAt": FieldValue.serverTimestamp(),
});
      }
    } catch (_) {}
  }
Future<void> deleteOldReadNotifications() async {

  final user = UserService.currentUser;

  if (user == null) return;

  try {

    final limitDate =
        DateTime.now().subtract(
      const Duration(hours: 24),
    );

    final snapshot =
        await FirebaseFirestore.instance
            .collection("notifications")
            .where(
              "userId",
              isEqualTo: user.uid,
            )
            .where(
              "read",
              isEqualTo: true,
            )
            .get();

    for (final doc in snapshot.docs) {

      final data = doc.data();

      final readAt =
          (data["readAt"]
                  as Timestamp?)
              ?.toDate();

      if (readAt != null &&
          readAt.isBefore(
            limitDate,
          )) {

        await doc.reference.delete();
      }
    }

  } catch (_) {}
}
  String formatNotificationDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final yesterday = today.subtract(
      const Duration(days: 1),
    );

    final target = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final time =
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

    if (target == today) {
      return "اليوم • $time";
    }

    if (target == yesterday) {
      return "أمس • $time";
    }

    return "${date.day}/${date.month}/${date.year} • $time";
  }

  String operationTypeText(dynamic paymentType) {
    if (paymentType == "monthly") {
      return "اشتراك شهري";
    }

    if (paymentType == "panel") {
      return "لوحة";
    }

    if (paymentType == "donation") {
      return "تبرع";
    }

    return "عملية مالية";
  }

  String monthsText(List months) {
    const names = [
      "يناير",
      "فبراير",
      "مارس",
      "أبريل",
      "مايو",
      "يونيو",
      "يوليو",
      "أغسطس",
      "سبتمبر",
      "أكتوبر",
      "نوفمبر",
      "ديسمبر",
    ];

    final result = <String>[];

    for (final m in months) {
      final month = int.tryParse(m.toString()) ?? 0;

      if (month >= 1 && month <= 12) {
        result.add(names[month - 1]);
      }
    }

    return result.join(" - ");
  }

  Future<void> approveOperation({
    required BuildContext context,
    required String notificationId,
    required Map<String, dynamic> notificationData,
  }) async {
    final operationId = notificationData["operationId"]?.toString() ?? "";

    if (operationId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection("notifications")
          .doc(notificationId)
          .update({
        "locked": true,
      });

      final operationDoc = await FirebaseFirestore.instance
          .collection("operations")
          .doc(operationId)
          .get();

      if (!operationDoc.exists) return;

      final operationData = operationDoc.data() ?? {};

      if (operationData["status"] != "pending") {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تمت معالجة هذه العملية مسبقاً"),
            ),
          );
        }

        return;
      }

      final amount = double.tryParse(
            operationData["amount"].toString(),
          ) ??
          0;

      final collectorId =
          operationData["createdByUid"] ?? operationData["createdBy"] ?? "";

      final paymentType = operationData["paymentType"];
      final typeText = operationTypeText(paymentType);

      final subject = operationData["purpose"]?.toString() ?? "";

      final months = (operationData["coveredMonths"] as List?) ?? [];

      final monthsLine =
          months.isNotEmpty ? "\n\nالأشهر: ${monthsText(months)}" : "";

      await FirebaseFirestore.instance
          .collection("operations")
          .doc(operationId)
          .update({
        "status": "approved",
        "approvedAt": FieldValue.serverTimestamp(),
        "validatedBy": FirebaseAuth.instance.currentUser?.uid ?? "",
      });

      await FirebaseFirestore.instance.collection("transactions").add({
        "amount": amount,
        "type": "add",
        "paymentType": paymentType,
        "operationId": operationId,
        "personId": operationData["personId"],
        "name": operationData["name"],
        "phone": operationData["phone"],
        "createdBy": collectorId,
        "collectorName": operationData["collectorName"],
        "validatedBy": FirebaseAuth.instance.currentUser?.uid ?? "",
        "coveredMonths": months,
        "year": DateTime.now().year,
        "createdAt": FieldValue.serverTimestamp(),
        "isDeleted": false,
      });

      if (paymentType == "monthly") {
        await SubscriptionStatsService.updateSubscriptionStats(
          operationData["personId"],
          operationData["monthlyAmount"] ?? 500,
        );
      }

      await FirebaseFirestore.instance.collection("notifications").add({
        "userId": collectorId,
        "title": "يؤكد لكم أمين الصندوق",
        "body": "بأنه تم إدخال المبلغ الخاص بطلبكم التالي إلى الصندوق\n\n"
            "الزبون: ${operationData["name"] ?? ""}\n\n"
            "نوع العملية: $typeText\n\n"
            "${subject.isNotEmpty ? "موضوع العملية: $subject\n\n" : ""}"
            "المبلغ المقبول: ${amount.toInt()} MRU"
            "$monthsLine",
        "type": "approved",
        "read": false,
        "operationId": operationId,
        "createdAt": FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection("notifications")
          .doc(notificationId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تمت الموافقة على العملية"),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
          ),
        );
      }
    }
  }

  Future<void> rejectOperation({
    required BuildContext context,
    required String notificationId,
    required Map<String, dynamic> notificationData,
  }) async {
    final operationId = notificationData["operationId"]?.toString() ?? "";

    if (operationId.isEmpty) return;

    final operationDoc = await FirebaseFirestore.instance
        .collection("operations")
        .doc(operationId)
        .get();

    if (!operationDoc.exists) return;

    final operationData = operationDoc.data() ?? {};

    if (operationData["status"] != "pending") {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تمت معالجة هذه العملية مسبقاً"),
          ),
        );
      }

      return;
    }

    final reasons = [
      "المبلغ لم يصل بعد إلى أمين الصندوق",
      "المبلغ غير مطابق",
      "بيانات الزبون غير صحيحة",
      "سبب آخر",
    ];

    String selectedReason = reasons.first;

    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (
            context,
            setState,
          ) {
            return AlertDialog(
              title: const Text("سبب الرفض"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    items: reasons.map((reason) {
                      return DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedReason == "سبب آخر")
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "اكتب السبب",
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("إلغاء"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final finalReason = selectedReason == "سبب آخر"
                        ? controller.text.trim()
                        : selectedReason;

                    final collectorId = operationData["createdByUid"] ??
                        operationData["createdBy"] ??
                        "";

                    final paymentType = operationData["paymentType"];
                    final typeText = operationTypeText(paymentType);

                    final subject =
                        operationData["purpose"]?.toString() ?? "";

                    await FirebaseFirestore.instance
                        .collection("notifications")
                        .doc(notificationId)
                        .update({
                      "locked": true,
                    });

                    await FirebaseFirestore.instance
                        .collection("operations")
                        .doc(operationId)
                        .update({
                      "status": "rejected",
                      "rejectedAt": FieldValue.serverTimestamp(),
                      "rejectReason": finalReason,
                    });

                    await FirebaseFirestore.instance
                        .collection("notifications")
                        .add({
                      "userId": collectorId,
                      "title": "يشعركم أمين الصندوق",
                      "body": "برفض طلبكم التالي للسبب المذكور أدناه\n\n"
                          "الزبون: ${operationData["name"] ?? ""}\n\n"
                          "نوع العملية: $typeText\n\n"
                          "${subject.isNotEmpty ? "موضوع العملية: $subject\n\n" : ""}"
                          "سبب الرفض:\n$finalReason",
                      "type": "rejected",
                      "read": false,
                      "operationId": operationId,
                      "createdAt": FieldValue.serverTimestamp(),
                    });

                    await FirebaseFirestore.instance
                        .collection("notifications")
                        .doc(notificationId)
                        .delete();

                    if (context.mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("تم رفض العملية"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("رفض"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;
    deleteOldReadNotifications();
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("الإشعارات"),
        ),
        body: const Center(
          child: Text("يرجى تسجيل الدخول"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("الإشعارات"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await markAllAsRead();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notifications")
            .where("userId", isEqualTo: user.uid)
            .orderBy("createdAt", descending: true)
            .limit(50)
            .snapshots(),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("لا توجد إشعارات"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (
              context,
              index,
            ) {
              final doc = docs[index];

              final data =
                  doc.data() as Map<String, dynamic>? ?? {};

              final title = data["title"]?.toString() ?? "";

              final body = data["body"]?.toString() ?? "";

              final type = data["type"]?.toString() ?? "";

              final locked = data["locked"] ?? false;
              final isRead = data["read"] ?? false;

              Color statusColor = Colors.amber.shade700;

              Color statusBg = Colors.amber.shade50;

              IconData statusIcon = Icons.pending_actions;

              String statusText = "قيد الانتظار";

              if (type == "approved") {
                statusColor = Colors.green.shade700;
                statusBg = Colors.green.shade50;
                statusIcon = Icons.check_circle;
                statusText = "تم قبول طلبكم";
              } else if (type == "rejected") {
                statusColor = Colors.red.shade700;
                statusBg = Colors.red.shade50;
                statusIcon = Icons.cancel;
                statusText = "تم رفض طلبكم";
              }

              String formattedDate = "";

              if (data["createdAt"] != null) {
                final date = (data["createdAt"] as Timestamp).toDate();

                formattedDate = formatNotificationDate(date);
              }

              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {

  if (!isRead) {
    await markAsRead(doc.id);
  }

  final caseId =
      data["caseId"]?.toString();

  if (caseId == null ||
      caseId.isEmpty) {
    return;
  }

  if (!context.mounted) return;

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (_) =>
          HealthCaseDetailsScreen(
        caseId: caseId,
      ),
    ),
  );
},
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                  color:

    isRead

        ? Colors.white

        : const Color(
            0xFFE8F5E9,
          ),

border: Border.all(

  color:

      isRead

          ? Colors.grey.shade300

          : const Color(
              0xFF2E7D32,
            ),

  width:
      isRead ? 1 : 2,
),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [

  BoxShadow(

    blurRadius:
        isRead ? 4 : 10,

    color:
        isRead
            ? Colors.black12
         : Colors.green.withOpacity(0.18),   

    offset: const Offset(
      0,
      3,
    ),
  ),

  const BoxShadow(

    blurRadius: 6,

    color: Colors.black12,

    offset: Offset(
      0,
      2,
    ),
  ),
],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              color: statusColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                     Row(

  children: [

    if (!isRead) ...[

      Container(

        width: 10,

        height: 10,

        decoration:
            const BoxDecoration(

          color: Color(
            0xFF2E7D32,
          ),

          shape: BoxShape.circle,
        ),
      ),

      const SizedBox(width: 8),
    ],

    Expanded(

      child: Text(

        title,

        style: TextStyle(

          fontSize: 18,

          fontWeight:
              isRead
                  ? FontWeight.w600
                  : FontWeight.bold,

          color:
              isRead
                  ? Colors.black87
                  : Colors.black,
        ),
      ),
    ),
  ],
),
                      
                      const SizedBox(height: 12),
                      Text(
                        body,
                     style: TextStyle(

  fontSize: 15,

  height: 1.5,

  color:
      isRead
          ? Colors.grey.shade700
          : Colors.black87,
),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 15,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      if (type == "operation") ...[
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: locked
                                      ? null
                                      : () async {
                                          await approveOperation(
                                            context: context,
                                            notificationId: doc.id,
                                            notificationData: data,
                                          );
                                        },
                                  icon: const Icon(
                                    Icons.check_circle,
                                    size: 18,
                                  ),
                                  label: const Text("موافقة"),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton.icon(
                                  onPressed: locked
                                      ? null
                                      : () async {
                                          await rejectOperation(
                                            context: context,
                                            notificationId: doc.id,
                                            notificationData: data,
                                          );
                                        },
                                  icon: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.red.shade700,
                                  ),
                                  label: Text(
                                    "رفض",
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.red.shade300,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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