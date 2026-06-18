import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/finance_service.dart';
import '../services/user_service.dart';

class PaymentScreen extends StatefulWidget {

  final Map data;

  final double balance;

  const PaymentScreen({
    super.key,
    required this.data,
    required this.balance,
  });

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {
bool _isSubmitting = false;
  // =========================
  // SELECTED MONTHS
  // =========================

  final Set<int> selectedMonths = {};

  // =========================
  // ALREADY PAID MONTHS
  // =========================

  List<int> alreadyPaidMonths = [];

  // =========================
  // MONTHS
  // =========================

  final List<String> monthsNames = [

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

  // =========================
  // INIT
  // =========================

  @override
  void initState() {

    super.initState();

    loadAlreadyPaidMonths();
  }

  // =========================
  // LOAD PAID MONTHS
  // =========================

  Future<void> loadAlreadyPaidMonths() async {

    final personId =
        widget.data["personId"]
                ?.toString() ??
            widget.data["phone"]
                ?.toString() ??
            "";

    final months =
        await getAlreadyPaidMonths(
      personId,
    );

    if (!mounted) {
      return;
    }

    setState(() {

      alreadyPaidMonths =
          months;
    });
  }

  // =========================
  // GET ALREADY PAID MONTHS
  // =========================

  Future<List<int>> getAlreadyPaidMonths(
    String personId,
  ) async {

    try {

      final currentYear =
          DateTime.now().year;

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
              print("PERSON ID SEARCH = $personId");
print("TRANSACTIONS FOUND = ${snapshot.docs.length}");

for (final doc in snapshot.docs) {
  print("TRANSACTION DATA = ${doc.data()}");
}
              print("TRANSACTIONS FOUND = ${snapshot.docs.length}");
              print("PERSON ID SEARCH = $personId");

for (final doc in snapshot.docs) {
  print("TRANSACTION DATA = ${doc.data()}");
}
final pendingSnapshot =
    await FirebaseFirestore.instance
        .collection("operations")
        .where(
          "personId",
          isEqualTo: personId,
        )
        .where(
          "paymentType",
          isEqualTo: "monthly",
        )
        .where(
          "status",
          isEqualTo: "pending",
        )
        // .where("year", isEqualTo: currentYear)
        .get();
      final Set<int> paidMonths =
          {};

      for (final doc
          in snapshot.docs) {

        final data =
            doc.data();

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

          if (month > 0 &&
              month <= 12) {

            paidMonths.add(
              month,
            );
          }
        }
      }
for (final doc
    in pendingSnapshot.docs) {

  final data = doc.data();

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

    if (month > 0 &&
        month <= 12) {

      paidMonths.add(month);
    }
  }
}
print("PAID MONTHS FROM TRANSACTIONS = $paidMonths");
      final result =
          paidMonths.toList();

      result.sort();

      return result;

    } catch (e) {

      return [];
    }
  }

  // =========================
  // CHECK CONTINUOUS MONTHS
  // =========================

  bool isContinuousSelection(
    List<int> months,
  ) {

    if (months.length <= 1) {
      return true;
    }

    final sorted =
        [...months]..sort();

    for (int i = 0;
        i < sorted.length - 1;
        i++) {

      if (sorted[i + 1] !=
          sorted[i] + 1) {

        return false;
      }
    }

    return true;
  }

  // =========================
  // PROCESS PAYMENT
  // =========================

  Future<void> processPayment(
  BuildContext context,
) async {

  if (_isSubmitting) return;

  setState(() {
    _isSubmitting = true;
  });

  try {
final paymentType =
    widget.data["paymentType"]
            ?.toString() ??
        "monthly";
        
     

final isMonthly =
    paymentType == "monthly";
      // ================= CHECK BALANCE =================

      final canPayNow =
          FinanceService.canPay(

        widget.balance,

        widget.data,
      );

      if (!canPayNow) {

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(

            content: Text(
              "❌ لا يمكن تسديد المستحق",
            ),
          ),
        );

        return;
      }

      // ================= CHECK MONTHS =================
if (

    isMonthly &&

    alreadyPaidMonths.length == 12

) {

  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(

    const SnackBar(

      content: Text(
        "❌ لقد دفع المعني كل اشتراكه السنوي",
      ),
    ),
  );

  return;
}
      if (

    isMonthly &&

    selectedMonths.isEmpty

){

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(

            content: Text(
              "❌ اختر الأشهر المطلوبة",
            ),
          ),
        );

        return;
      }

      // ================= CHECK CONTINUOUS =================

     if (

    isMonthly &&

    !isContinuousSelection(
      selectedMonths.toList(),
    )

) {

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(

            content: Text(
              "❌ يجب اختيار أشهر متتالية",
            ),
          ),
        );

        return;
      }

      // ================= MONTHLY AMOUNT =================

      final monthlyAmount =

    isMonthly

        ? int.tryParse(
            widget.data["monthlyAmount"]
                .toString(),
          ) ?? 500

        : int.tryParse(
            widget.data["amount"]
                .toString(),
          ) ?? 0;

      // ================= TOTAL AMOUNT =================

      final safeAmount =

   isMonthly

        ? monthlyAmount *
            selectedMonths.length

        : monthlyAmount;

      if (safeAmount <= 0) {

        if (!context.mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(

            content: Text(
              "❌ مبلغ غير صالح",
            ),
          ),
        );

        return;
      }

      // ================= USER DATA =================

      final userName =
          await UserService
              .getUserName();

      final createdByUid =
          UserService.currentUid ??
              "";

      final fullName =
          widget.data["fullName"]
                  ?.toString() ??
              "";

      final phone =
          widget.data["phone"]
                  ?.toString() ??
              "";

      final purpose =
          widget.data["purpose"]
                  ?.toString() ??
              "";
final now = DateTime.now();

final formattedDate =

    "${now.year}/"
    "${now.month.toString().padLeft(2, '0')}/"
    "${now.day.toString().padLeft(2, '0')}"

    " - "

    "${now.hour.toString().padLeft(2, '0')}:"
    "${now.minute.toString().padLeft(2, '0')}";

      // ================= PERSON ID =================

      final personId =
          widget.data["personId"]
                  ?.toString() ??
              phone;

      // ================= CHECK DUPLICATES =================

      if (isMonthly) {
      final duplicatedMonths =
          selectedMonths
              .where(

                (m) =>
                    alreadyPaidMonths
                        .contains(m),
              )
              .toList();

      if (duplicatedMonths
          .isNotEmpty) {

        if (!context.mounted) {
          return;
        }

        final monthsNamesArabic =

            duplicatedMonths.map((m) {

          return monthsNames[
              m - 1];

        }).join(" - ");

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          SnackBar(

            content: Text(

              "❌ الأشهر مدفوعة مسبقاً:\n$monthsNamesArabic",
            ),
          ),
        );

        return;
      }
}
      // ================= CREATE OPERATION =================

      final opRef =
          await FirebaseFirestore
              .instance
              .collection(
                "operations",
              )
              .add({

        "name":
            fullName,

        "phone":
            phone,

        "personId":
            personId,

        "amount":
            safeAmount,

        "monthlyAmount":
            monthlyAmount,

       "paymentType":
    paymentType,

        "purpose":
            purpose,

        "coveredMonths":

    isMonthly

        ? selectedMonths.toList()

        : [],

        "year":
            DateTime.now().year,

        "status":
            "pending",

        "createdByUid":
            createdByUid,

        "createdByName":
            userName,

        "collectorName":
            userName,

        "createdAt":
            FieldValue
                .serverTimestamp(),

        "isDeleted":
            false,
      });

// ================= SEND TO TREASURERS =================

final treasurerSnapshot =
    await FirebaseFirestore
        .instance
        .collection(
          "users",
        )
        .where(
          "role",
          isEqualTo:
              "treasurer",
        )
        .get();

for (final treasurer
    in treasurerSnapshot.docs) {

  await FirebaseFirestore
      .instance
      .collection(
        "notifications",
      )
      .add({

    "userId":
        treasurer.id,

    "title":
        "طلب إدخال مبلغ للصندوق",

    "body":

isMonthly

? """المحصل: $userName

الزبون: $fullName

نوع العملية: اشتراك شهري

عدد الأشهر: ${selectedMonths.length}

الأشهر:
${([...selectedMonths]..sort()).map((m) => monthsNames[m - 1]).join(" - ")}

المبلغ: $safeAmount MRU

التاريخ: $formattedDate
"""

: """المحصل: $userName

الزبون: $fullName

نوع العملية: ${paymentType == "donation" ? "تبرع" : "لوحة"}

المبلغ: $safeAmount MRU

الغرض: $purpose

التاريخ: $formattedDate
""",

    "type":
        "operation",

    "operationId":
        opRef.id,

    "read":
        false,

    "status":
        "pending",

    "createdAt":
        FieldValue
            .serverTimestamp(),
  });
}


      // ================= SUCCESS =================

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content: Text(
            "✅ تم إرسال العملية بنجاح",
          ),
        ),
      );

      Navigator.pop(context);

   } catch (e) {

  print(
    "PAYMENT ERROR = $e",
  );

  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(

    const SnackBar(
      content: Text(
        "❌ حدث خطأ أثناء إرسال العملية",
      ),
    ),
  );

} finally {

  if (mounted) {
    setState(() {
      _isSubmitting = false;
    });
  }

}
}
    

  // =========================
// BUILD
// =========================
Widget buildSummaryRow(
  String title,
  String value,
) {

  return Row(

    mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

    children: [

      Text(

        title,

        style: const TextStyle(

          fontSize: 16,

          color: Colors.black87,
        ),
      ),

      Text(

        value,

        style: const TextStyle(

          fontSize: 17,

          fontWeight:
              FontWeight.bold,
        ),
      ),
    ],
  );
}
@override
Widget build(BuildContext context) {

  final fullName =
      widget.data["fullName"]
              ?.toString() ??
          "بدون اسم";

  final phone =
      widget.data["phone"]
              ?.toString() ??
          "";

 final paymentType =
    widget.data["paymentType"]
            ?.toString() ??
        "monthly";

final isMonthly =
    paymentType == "monthly";

final monthlyAmount =

    isMonthly

        ? int.tryParse(
            widget.data["monthlyAmount"]
                .toString(),
          ) ?? 500

        : int.tryParse(
            widget.data["amount"]
                .toString(),
          ) ?? 0;

  final totalAmount =

    isMonthly

        ? monthlyAmount *
            selectedMonths.length

        : monthlyAmount;

  return Scaffold(

    backgroundColor:
        const Color(
      0xFFF5F6FA,
    ),

    appBar: AppBar(

  title: Text(

    isMonthly

        ? "تسديد الإشتراك"

        : paymentType == "donation"

            ? "إرسال تبرع"

            : "إرسال لوحة",
  ),

  centerTitle: true,
),

    body: SingleChildScrollView(

      padding:
          const EdgeInsets.all(
        20,
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .stretch,

        children: [

          // ================= PERSON CARD =================

          Card(

            shape:
                RoundedRectangleBorder(

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            child: Padding(

              padding:
                  const EdgeInsets.all(
                18,
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(

                    fullName,

                    style:
                        const TextStyle(

                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  if (phone
                      .isNotEmpty)

                    Text(
                      "📱 $phone",
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // ================= BALANCE =================

          // ================= OPERATION SUMMARY =================

Container(

  padding: const EdgeInsets.all(20),

  decoration: BoxDecoration(

    color: Colors.white,

    borderRadius:
        BorderRadius.circular(22),

    boxShadow: [

      BoxShadow(

        color:
            Colors.black.withOpacity(
          0.05,
        ),

        blurRadius: 10,

        offset: const Offset(
          0,
          4,
        ),
      ),
    ],
  ),

  child: Column(

    children: [

      Row(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: const [

          Icon(
            Icons.receipt_long,
            color: Colors.green,
          ),

          SizedBox(width: 8),

          Text(

            "ملخص العملية",

            style: TextStyle(

              fontSize: 22,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),

      const SizedBox(height: 20),

      buildSummaryRow(

  isMonthly
      ? "الفئة الشهرية"
      : "المبلغ",

  "$monthlyAmount MRU",
),

 if (isMonthly) ...[

  const SizedBox(height: 12),

  buildSummaryRow(
    "عدد الأشهر المختارة",
    "${selectedMonths.length}",
  ),

  if (selectedMonths.isNotEmpty) ...[

    const SizedBox(height: 10),

    Text(
      "الأشهر:\n${([...selectedMonths]..sort()).map((m) => monthsNames[m - 1]).join(" - ")}",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey.shade700,
        height: 1.5,
      ),
    ),
  ],
],

const Divider(
  height: 30,
),

      Text(

        "${totalAmount.toInt()} MRU",

        style: const TextStyle(

          fontSize: 34,

          fontWeight:
              FontWeight.bold,

          color: Colors.green,
        ),
      ),

      const SizedBox(height: 6),

     Text(

  isMonthly
      ? "المبلغ الإجمالي"
      : "المبلغ",

  style: const TextStyle(

    color: Colors.grey,

    fontSize: 15,
  ),
),

       
    ],
  ),
),
if (isMonthly) ...[

          // ================= TITLE =================

          const Text(

            "اختر الأشهر المطلوب دفعها",

            style: TextStyle(

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          // ================= GRID =================

          GridView.builder(

            shrinkWrap: true,

            physics:
                const NeverScrollableScrollPhysics(),

            itemCount:
                monthsNames.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(

              crossAxisCount: 3,

              mainAxisSpacing: 12,

              crossAxisSpacing: 12,

              childAspectRatio: 2.2,
            ),

            itemBuilder:
                (context, index) {

              final month =
                  index + 1;

              final isSelected =
                  selectedMonths
                      .contains(
                month,
              );

              final isAlreadyPaid =
                  alreadyPaidMonths
                      .contains(
                month,
              );

              return InkWell(

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),

                onTap:
                    isAlreadyPaid

                        ? null

                        : () {

                            setState(() {

                              if (isSelected) {

                                selectedMonths
                                    .remove(
                                  month,
                                );

                              } else {

                                selectedMonths
                                    .add(
                                  month,
                                );
                              }
                            });
                          },

                child: Container(

                  decoration:
                      BoxDecoration(

                    color:

                        isAlreadyPaid

                            ? Colors.grey
                                .shade400

                            : isSelected

                               ? const Color(
                0xFF2E7D32,
              )

                                : Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),

                    border: Border.all(

                      color:

                          isAlreadyPaid

                              ? Colors.grey
                                  .shade500

                              : isSelected

                                  ? Colors.green

                                  : Colors.grey
                                      .shade300,
                    ),
                  ),

                  child: Center(

                    child: Text(

                      monthsNames[
                          index],

                      style:
                          TextStyle(

                        color:

                            isAlreadyPaid

                                ? Colors.white

                                : isSelected

                                    ? Colors.white

                                    : Colors.black,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(
            height: 20,
          ),

          ],

          // ================= BUTTON =================

        SizedBox(

  height: 58,

  child: ElevatedButton.icon(

    onPressed: _isSubmitting
    ? null
    : () {
        processPayment(context);
      },

    icon: _isSubmitting
    ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
    : const Icon(
        Icons.send_rounded,
        size: 22,
        color: Colors.white,
      ),

    label: Text(

  _isSubmitting
      ? "جاري الإرسال..."
      : "إرسال العملية للصندوق",

  style: const TextStyle(

    fontSize: 17,

    fontWeight: FontWeight.bold,

    color: Colors.white,
  ),
),

    style:
        ElevatedButton.styleFrom(

      backgroundColor:
          const Color(
        0xFF2E7D32,
      ),

      elevation: 4,

      shadowColor:
          Colors.green
              .withOpacity(0.35),

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(
          18,
        ),
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