import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/pdf_service.dart';
import '../services/subscription_stats_service.dart';

Future<void> approveOperation(
  String docId,
  Map<String, dynamic> data,
) async {

  try {
print("APPROVE OPERATION START");
    final firestore =
        FirebaseFirestore.instance;

    final operationRef =
        firestore
            .collection("operations")
            .doc(docId);

    final paymentType =
        data["paymentType"]
            ?.toString() ?? "";
String paymentTypeArabic = "";

switch (paymentType) {
  case "monthly":
    paymentTypeArabic = "اشتراك شهري";
    break;

  case "panel":
    paymentTypeArabic = "اللوحة";
    break;

  case "donation":
    paymentTypeArabic = "تبرع";
    break;

  default:
    paymentTypeArabic = paymentType;
}
    final amount =
        double.tryParse(
          data["amount"]
              .toString(),
        ) ?? 0;

    final name =
        data["name"]
            ?.toString() ?? "";

    final phone =
        data["phone"]
            ?.toString() ?? "";

    final purpose =
        data["purpose"]
            ?.toString() ?? "";

    final personId =
        data["personId"]
            ?.toString() ?? "";
final createdByUid =
    data["createdByUid"]
            ?.toString() ??
        "";
        final collectorName =
    data["collectorName"]
            ?.toString() ??

    data["createdByName"]
            ?.toString() ??

    "غير محدد";
    // =========================
    // FIRESTORE TRANSACTION
    // =========================

    await firestore.runTransaction(

      (transaction) async {

        // =========================
        // GET OPERATION
        // =========================

        final operationSnap =
            await transaction.get(
          operationRef,
        );

        if (!operationSnap.exists) {

          throw Exception(
            "العملية غير موجودة",
          );
        }

        final operationData =
            operationSnap.data()
                as Map<String,
                    dynamic>? ??
                {};

        // =========================
        // CHECK STATUS
        // =========================

        final currentStatus =
            operationData["status"]
                    ?.toString() ??
                "";

        if (currentStatus !=
            "pending") {

          throw Exception(
            "تمت معالجة العملية مسبقاً",
          );
        }

        // =========================
        // CREATE TRANSACTION
        // =========================

       final transactionRef =
    firestore
        .collection(
          "transactions",
        )
        .doc(docId);
        final existingTransaction =
    await transaction.get(
      transactionRef,
    );

if (existingTransaction.exists) {
  throw Exception(
    "تمت معالجة هذه العملية مسبقاً",
  );
}

if (paymentType == "monthly") {

  final coveredMonths =
      List<int>.from(
    operationData["coveredMonths"] ?? [],
  );

  final year =
      operationData["year"] ??
      DateTime.now().year;

  for (final month in coveredMonths) {

    final monthLockRef =
        firestore
            .collection(
              "monthly_locks",
            )
            .doc(
              "${personId}_${year}_$month",
            );

    final monthLockSnap =
        await transaction.get(
      monthLockRef,
    );

    if (monthLockSnap.exists) {

      throw Exception(
        "الشهر $month مدفوع مسبقاً",
      );
    }

    transaction.set(
      monthLockRef,
      {
        "personId": personId,
        "year": year,
        "month": month,
        "operationId": docId,
        "createdAt":
            FieldValue.serverTimestamp(),
      },
    );
  }
}

        transaction.set(
          transactionRef,
          {

            "name":
                name,

            "phone":
                phone,

            "personId":
                personId,

            "collectorName":
                 collectorName,
                 
            "paymentType":
                paymentType,

            "type":
                "add",

            "amount":
                amount,

            "purpose":
                purpose,

            "operationId":
                docId,

            "coveredMonths":
                operationData[
                        "coveredMonths"] ??
                    [],

            "year":
                operationData[
                        "year"] ??
                    DateTime.now()
                        .year,

            "status":
                "approved",

            "isDeleted":
                false,

            "createdAt":
                FieldValue
                    .serverTimestamp(),
          },
        );

        // =========================
        // MONTHLY
        // =========================

        if (paymentType ==
            "monthly") {

          final category =
    int.tryParse(
      data["monthlyAmount"]
          ?.toString() ?? "500",
    ) ?? 500;

          // =========================
          // CREATE SUBSCRIPTION
          // IF NOT EXISTS
          // =========================

         final subRef =
    firestore
        .collection(
          "subscriptions",
        )
        .doc(personId);

final subSnap =
    await transaction.get(
  subRef,
);

if (!subSnap.exists) {

  transaction.set(
    subRef,
    {
      "fullName": name,
      "phone": phone,
      "personId": personId,
      "category": category,
      "monthlyAmount": category,
      "createdAt":
          FieldValue.serverTimestamp(),
      "isDeleted": false,
    },
  );
}
        }

        // =========================
        // DONATION
        // =========================

        if (paymentType ==
            "donation") {

          final donationRef =
              firestore
                  .collection(
                    "donations",
                  )
                  .doc();

          transaction.set(
            donationRef,
            {

              "fullName":
                  name,

              "phone":
                  phone,

              "amount":
                  amount,

              "purpose":
                  purpose,

              "operationId":
                  docId,

              "createdAt":
                  FieldValue
                      .serverTimestamp(),
            },
          );
        }

        // =========================
        // PANEL
        // =========================

        if (paymentType ==
            "panel") {

          final panelRef =
              firestore
                  .collection(
                    "lawha",
                  )
                  .doc();

          transaction.set(
            panelRef,
            {

              "fullName":
                  name,

              "phone":
                  phone,

              "amount":
                  amount,

              "purpose":
                  purpose,

              "operationId":
                  docId,

              "createdAt":
                  FieldValue
                      .serverTimestamp(),
            },
          );
        }

        // =========================
        // UPDATE OPERATION
        // =========================

        transaction.update(
          operationRef,
          {

            "status":
                "approved",

            "validatedAt":
                FieldValue
                    .serverTimestamp(),
          },
        );
      },
    );

    // =========================
    // UPDATE STATS CACHE
    // =========================

    if (paymentType ==
        "monthly") {

      final category =
    int.tryParse(
      data["monthlyAmount"]
          ?.toString() ?? "500",
    ) ?? 500;
      await SubscriptionStatsService
          .updateSubscriptionStats(

        personId,

        category,
      );
      final statsDoc =
    await firestore
        .collection(
          "subscription_stats",
        )
        .doc(personId)
        .get();

if (statsDoc.exists) {

  final stats =
      statsDoc.data()!;

  final missingMonths =
      List<int>.from(
    stats["missingMonths"] ?? [],
  );

 
final debt =
    (stats["debt"] ?? 0) as int;

await firestore
    .collection("transactions")
    .doc(docId)
    .update({

  "pending":
      missingMonths.length,

  "debt":
      debt,

  "missingMonths":
      missingMonths,
});

print("PERSON = $name");
print("MISSING MONTHS = $missingMonths");

print("DEBT = $debt");

print("CREATED BY = $createdByUid");

  if (missingMonths.isNotEmpty) {
print("CREATING LATE NOTIFICATION");
    await firestore
        .collection(
          "notifications",
        )
        .add({

      "userId":
          createdByUid,

      "title":
          "⚠️ منخرط متأخر",

      "body":
          "$name متأخر ${missingMonths.length} شهر\nالدين: $debt MRU",

      "type":
          "late_member",

      "personId":
          personId,

      "read":
          false,

      "createdAt":
          FieldValue
              .serverTimestamp(),
    });
  }
}
    }

    // =========================
    // NOTIFICATION COLLECTOR
    // =========================

    

    if (createdByUid
        .isNotEmpty) {

      await firestore
          .collection(
            "notifications",
          )
          .add({

        "userId":
            createdByUid,

        "title":
            "✅ تم قبول العملية",

        "body":
            "تمت الموافقة على الدخل بقيمة $amount MRU",

        "read":
            false,

        "createdAt":
            FieldValue
                .serverTimestamp(),
      });
    }

    // =========================
    // GLOBAL INFO
    // =========================

    await firestore
        .collection(
          "notifications",
        )
        .add({

      "title":
          "💰 تم تسديد حالة",

      "body":
          "إسم الزبون: $name\n"
          "الهاتف: $phone\n"
          "المبلغ: $amount MRU\n"
          "النوع: $paymentTypeArabic\n"
          "الغرض: $purpose",

      "type":
          "global_info",

      "forAll":
          true,

      "read":
          false,

      "createdAt":
          FieldValue
              .serverTimestamp(),
    });

    // =========================
    // PDF
    // =========================

    try {

      await PdfService
          .printReceipt(

        name:
            name,

        phone:
            phone,

        type:
            paymentType,

        amount:
            amount.toInt(),

        date:
            DateTime.now()
                .toString(),
      );

    } catch (e) {

      print(
        "PDF ERROR = $e",
      );
    }

    print(
      "✅ VALIDATION OK",
    );

  } catch (e) {

    print(
      "❌ ERROR = $e",
    );
  }
}