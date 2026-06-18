import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
class SubscriptionStatsService {

  // =========================
  // UPDATE STATS
  // =========================

  static Future<void>
      updateSubscriptionStats(

    String personId,

    int monthlyAmount,
  ) async {

    try {

      final currentYear =
          DateTime.now().year;

      final currentMonth =
          DateTime.now().month;

      // ================= TRANSACTIONS =================

      final snapshot =
          await FirebaseFirestore
              .instance
              .collection(
                "transactions",
              )
              .where(
                "personId",
                isEqualTo: personId,
              )
              .where(
                "paymentType",
                isEqualTo: "monthly",
              )
              .where(
                "type",
                isEqualTo: "add",
              )
              .where(
                "year",
                isEqualTo:
                    currentYear,
              )
              .where(
                "isDeleted",
                isEqualTo: false,
              )
              .get();

      final Set<int> paidMonths =
          {};

      int totalPaid = 0;

      for (final doc
          in snapshot.docs) {

        final data =
            doc.data();

        totalPaid +=
            (data["amount"] ?? 0)
                as int;

        final months =
            (data["coveredMonths"]
                    as List?) ??
                [];

        for (final m in months) {

          final month =
              int.tryParse(
                    m.toString(),
                  ) ??
                  0;

          if (month >= 1 &&
              month <= 12) {

            paidMonths.add(
              month,
            );
          }
        }
      }

      // ================= MISSING =================

      final List<int>
          missingMonths = [];

      for (
        int i = 1;
        i <= currentMonth;
        i++
      ) {

        if (!paidMonths
            .contains(i)) {

          missingMonths.add(
            i,
          );
        }
      }

      // ================= FUTURE =================

      final List<int>
          futureMonths = [];

      for (final m
          in paidMonths) {

        if (m > currentMonth) {

          futureMonths.add(
            m,
          );
        }
      }

      // ================= CALCULATIONS =================

      final expectedAmount =
          currentMonth *
              monthlyAmount;

      final debt =
          missingMonths.length *
              monthlyAmount;

      final advance =
          futureMonths.length *
              monthlyAmount;

      // ================= SAVE CACHE =================

      await FirebaseFirestore
          .instance
          .collection(
            "subscription_stats",
          )
          .doc(personId)
          .set({

        "personId":
            personId,

        "year":
            currentYear,

        "expectedAmount":
            expectedAmount,

        "totalPaid":
            totalPaid,

        "debt":
            debt,

        "advance":
            advance,

        "lateMonths":
            missingMonths.length,

        "paidMonths":
            paidMonths.length,

        "paidMonthsList":
            paidMonths.toList(),

        "missingMonths":
            missingMonths,

        "futureMonths":
            futureMonths,

        "updatedAt":
            FieldValue
                .serverTimestamp(),
      });

    } catch (e) {


debugPrint(
  "SUBSCRIPTION STATS ERROR = $e",

      );
    }
  }
}