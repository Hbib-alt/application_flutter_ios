import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addMonthlyTransaction({

  required String personId,

  required String collectorName,

  required String name,

  required String phone,

  required int amount,

  required String operationId,

  required String createdBy,
}) async {

  try {

    // ================= CREATE TRANSACTION =================

    await FirebaseFirestore.instance
        .collection("transactions")
        .add({

      "amount": amount,

      "collectorName": collectorName,

      "createdAt":
          Timestamp.now(),

      "createdBy":
          createdBy,

      "isDeleted": false,

      "name": name,

      "operationId":
          operationId,

      "paymentType":
          "monthly",

      "personId": personId,

      "phone": phone,

      "type": "add",
    });

    // ================= FIND SUBSCRIPTION =================

    final subscriptionQuery =
        await FirebaseFirestore
            .instance
            .collection(
              "subscriptions",
            )
            .where(
              "personId",
              isEqualTo:
                  personId,
            )
            .limit(1)
            .get();

    // ================= IF EXISTS =================

    if (subscriptionQuery
        .docs
        .isNotEmpty) {

      final subscriptionDoc =
          subscriptionQuery
              .docs
              .first;

      // ================= UPDATE TOTAL PAID =================

      await FirebaseFirestore
          .instance
          .collection(
            "subscriptions",
          )
          .doc(
            subscriptionDoc.id,
          )
          .update({

        "totalPaidAmount":
            FieldValue.increment(
          amount,
        ),
      });
    }

    // ================= CREATE IF NOT EXISTS =================

    else {

      await FirebaseFirestore
          .instance
          .collection(
            "subscriptions",
          )
          .add({

        "personId": personId,

        "fullName": name,

        "phone": phone,

        "monthlyAmount": 500,

        "totalPaidAmount":
            amount,

        "createdAt":
            Timestamp.now(),

        "isDeleted": false,
      });
    }
  }

  catch (e) {

    print(
      "ERROR MONTHLY TRANSACTION: $e",
    );
  }
}