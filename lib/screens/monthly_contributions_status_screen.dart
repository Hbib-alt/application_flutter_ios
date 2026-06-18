import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyContributionsStatusScreen extends StatelessWidget {
  const MonthlyContributionsStatusScreen({super.key});

  Future<Map<String, dynamic>> loadData() async {
  final peopleSnapshot =
      await FirebaseFirestore.instance.collection("people").get();

  final transactionsSnapshot = await FirebaseFirestore.instance
    .collection("transactions")
    .where("isDeleted", isEqualTo: false)
    .get();

  final now = DateTime.now();
  final currentYear = now.year;
  final elapsedMonths = now.month;

  int monthlyExpected = 0;
  int annualExpected = 0;
  int annualCollected = 0;

  final Map<String, int> monthlyAmounts = {};
  final Map<String, int> expectedByPerson = {};
  final Map<String, int> coveredElapsedByPerson = {};
  final Map<String, int> coveredMonthsByPerson = {};
  final Map<String, int> advanceByPerson = {};
  final Set<String> activePeopleIds = {};
  for (final doc in transactionsSnapshot.docs.take(20)) {
  print("STATUS = ${doc.data()["status"]}");
}
  for (final doc in transactionsSnapshot.docs) {
  final data = doc.data();

  final personId =
      (data["personId"] ?? "").toString();

  if (personId.isNotEmpty) {
    activePeopleIds.add(personId);
  }
}

print("ACTIVE PEOPLE = ${activePeopleIds.length}");
  
  for (final doc in transactionsSnapshot.docs) {
  final data = doc.data();

  final year =
      ((data["year"] ?? currentYear) as num).toInt();

  if (year != currentYear) continue;

  final personId =
      (data["personId"] ?? "").toString();

  if (personId.isNotEmpty) {
    activePeopleIds.add(personId);
  }
}
  // PEOPLE
  for (final person in peopleSnapshot.docs) {

  if (!activePeopleIds.contains(person.id)) {
    continue;
  }

  final data = person.data();

    int monthlyAmount =
    ((data["monthlyAmount"] ?? 0) as num).toInt();



if (monthlyAmount == 0) {
  monthlyAmount = 200;
}
if (monthlyAmount == 0) {
  print("NO MONTHLY AMOUNT => ${person.id}");
}
print(
  "NAME=${data["fullName"]} "
  "MONTHLY=$monthlyAmount"
);
    monthlyExpected += monthlyAmount;
    annualExpected += monthlyAmount * 12;

    monthlyAmounts[person.id] = monthlyAmount;
    print(
  "PERSON=${person.id} "
  "MONTHLY=$monthlyAmount"
);
    expectedByPerson[person.id] = monthlyAmount * elapsedMonths;

    coveredElapsedByPerson[person.id] = 0;
    advanceByPerson[person.id] = 0;
  }
print("TOTAL MONTHLY EXPECTED = $monthlyExpected");
print("PEOPLE COUNT = ${peopleSnapshot.docs.length}");
print("ACTIVE PEOPLE = ${activePeopleIds.length}");
print("TOTAL MONTHLY EXPECTED = $monthlyExpected");

int count200 = 0;
int count500 = 0;

for (final amount in monthlyAmounts.values) {
  if (amount == 200) count200++;
  if (amount == 500) count500++;
}

print("COUNT 200 = $count200");
print("COUNT 500 = $count500");
for (final entry in monthlyAmounts.entries) {
  print("CLIENT ${entry.key} => ${entry.value}");
}
for (final personId in activePeopleIds) {
  final exists = peopleSnapshot.docs.any(
    (p) => p.id == personId,
  );

  
}
for (final personId in activePeopleIds) {
  final exists =
      peopleSnapshot.docs.any(
        (p) => p.id == personId,
      );

  if (!exists) {
    print("MISSING PERSON = $personId");
  }
}
  // TRANSACTIONS
  for (final doc in transactionsSnapshot.docs) {
  final data = doc.data();
final paymentType =
    (data["paymentType"] ?? "").toString();

if (paymentType != "monthly") {
  continue;
}
  final year =
      ((data["year"] ?? currentYear) as num).toInt();

  if (year != currentYear) continue;

  final personId =
      (data["personId"] ?? "").toString();

  if (personId.isEmpty) continue;

  final amount =
      ((data["amount"] ?? 0) as num).toInt();

  final coveredMonths =
      List<int>.from(data["coveredMonths"] ?? []);
      coveredMonthsByPerson[personId] =
    (coveredMonthsByPerson[personId] ?? 0) +
    coveredMonths.length;

  if (coveredMonths.isEmpty) continue;

  annualCollected += amount;

  final amountPerMonth =
      monthlyAmounts[personId] ?? 200;

  for (final month in coveredMonths) {
    if (month <= elapsedMonths) {
      coveredElapsedByPerson[personId] =
          (coveredElapsedByPerson[personId] ?? 0) +
              amountPerMonth;
    } else {
      advanceByPerson[personId] =
          (advanceByPerson[personId] ?? 0) +
              amountPerMonth;
    }
  }
}

  final expectedUntilToday =
      monthlyExpected * elapsedMonths;

  int debt = 0;
int advance = 0;

for (final personId in expectedByPerson.keys) {
  final monthlyAmount =
      monthlyAmounts[personId] ?? 200;

  final paidMonths =
      (coveredMonthsByPerson[personId] ?? 0);

  final missingMonths =
      elapsedMonths - paidMonths;

  if (missingMonths > 0) {
    debt += missingMonths * monthlyAmount;
  }

  advance +=
      advanceByPerson[personId] ?? 0;
}

final collectedUntilToday =
    expectedUntilToday - debt;



  final annualRate = annualExpected == 0
      ? 0
      : ((annualCollected / annualExpected) * 100)
          .clamp(0, 100)
          .toInt();

  final currentRate = expectedUntilToday == 0
      ? 0
      : ((collectedUntilToday / expectedUntilToday) * 100)
          .clamp(0, 100)
          .toInt();
print("==============");
print("COUNT 200 = $count200");
print("COUNT 500 = $count500");
print("MONTHLY EXPECTED = $monthlyExpected");
print("ANNUAL EXPECTED = ${monthlyExpected * 12}");

print("EXPECTED UNTIL TODAY = $expectedUntilToday");
print("DEBT = $debt");
print("COLLECTED UNTIL TODAY = $collectedUntilToday");
print("ADVANCE = $advance");

return {
  "annualExpected": annualExpected,
  "annualCollected": annualCollected,
  "annualRate": annualRate,
  "expectedUntilToday": expectedUntilToday,
  "collectedUntilToday": collectedUntilToday,
  "currentRate": currentRate,
  "debt": debt,
  "advance": advance,
  "elapsedMonths": elapsedMonths,
};
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("وضعية الاشتراكات الشهرية"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _noteCard(),

                const SizedBox(height: 20),

                _sectionTitle("الوضعية السنوية"),

                Row(
                  children: [
                    _card(
                      title: "المبلغ المتوقع سنوياً",
                      value: "${data["annualExpected"]} MRU",
                      description:
                          "إجمالي الاشتراكات الشهرية المتوقع تحصيلها خلال السنة كاملة.",
                      icon: Icons.account_balance_wallet,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _card(
                      title: "المبلغ المحصل سنوياً",
                      value: "${data["annualCollected"]} MRU",
                      description:
                          "إجمالي الاشتراكات الشهرية المحصلة فعلياً منذ بداية السنة.",
                      icon: Icons.check_circle,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _card(
                      title: "نسبة الإنجاز السنوية",
                      value: "${data["annualRate"]}%",
                      description:
                          "نسبة ما تم تحصيله مقارنة بالهدف السنوي الكامل.",
                      icon: Icons.trending_up,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _sectionTitle("وضعية الأشهر المنقضية"),

                Row(
                  children: [
                    _card(
                      title: "المبلغ المتوقع حتى اليوم",
                      value: "${data["expectedUntilToday"]} MRU",
                      description:
                          "إجمالي الاشتراكات المستحقة خلال الأشهر المنقضية فقط.",
                      icon: Icons.calendar_month,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _card(
                      title: "المبلغ المحصل حتى اليوم",
                      value: "${data["collectedUntilToday"]} MRU",
                      description:
                          "إجمالي الاشتراكات الشهرية المحصلة فعلياً.",
                      icon: Icons.payments,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _card(
                      title: "نسبة الإنجاز حتى اليوم",
                      value: "${data["currentRate"]}%",
                      description:
                          "نسبة تغطية الاشتراكات المستحقة حتى تاريخ اليوم.",
                      icon: Icons.percent,
                      color: Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _card(
                      title: "إجمالي الديون",
                      value: "${data["debt"]} MRU",
                      description:
                          "الاشتراكات المستحقة وغير المحصلة حتى اليوم.",
                      icon: Icons.warning,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 12),
                    _card(
                      title: "الرصيد المسبق",
                      value: "${data["advance"]} MRU",
                      description:
                          "الاشتراكات المدفوعة مسبقاً عن أشهر مستقبلية.",
                      icon: Icons.trending_up,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _noteCard() {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        """ملاحظة:
تخص هذه المؤشرات الاشتراكات الشهرية فقط، ولا تشمل التبرعات أو مساهمات اللوحة.

تنبيه:
تعتمد هذه المؤشرات على المشتركين المسجلين حالياً في قاعدة البيانات فقط، ولا تشمل المنخرطين المحتملين غير المسجلين.""",
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

  static Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _card({
    required String title,
    required String value,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(
  minHeight: 210,
),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 14),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}