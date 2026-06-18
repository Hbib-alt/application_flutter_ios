import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../utils/web_download.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExportDatabasePdfScreen
    extends StatefulWidget {

  const ExportDatabasePdfScreen({
    super.key,
  });

  @override
  State<ExportDatabasePdfScreen>
      createState() =>
          _ExportDatabasePdfScreenState();
}

class _ExportDatabasePdfScreenState
    extends State<
        ExportDatabasePdfScreen> {

  bool loading = false;

  // ================= EXPORT PDF =================

  Future<void> exportPdf() async {

    try {

      setState(() {
        loading = true;
      });

      // ================= FIREBASE =================

      
      final operationsSnapshot =
    await FirebaseFirestore
        .instance
        .collection("transactions")

        .where(
          "isDeleted",
          isEqualTo: false,
        )

        .orderBy(
          "createdAt",
          descending: true,
        )

        .get();

       
final healthCasesSnapshot =
    await FirebaseFirestore
        .instance
        .collection("health_cases")
        .where(
          "status",
          isEqualTo: "paid",
        )
        .orderBy(
          "createdAt",
          descending: true,
        )
        .get();
      // ================= FONTS =================

      final fontData =
    await rootBundle.load(
  "assets/fonts/cairo.ttf",
);

final font =
    pw.Font.ttf(
  fontData,
);

final boldFont =
    pw.Font.ttf(
  fontData,
);

      // ================= LOGO =================

      final logoBytes =

          (await rootBundle.load(
            "assets/images/logo.png",
          ))
              .buffer
              .asUint8List();
pw.TableRow specialSummaryRow(
  String title,
  double value,
  pw.Font font,
  pw.Font boldFont,
) {
  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      color: PdfColors.grey200,
    ),
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(16),
        child: pw.Text(
          "${value.toInt()} أوقية جديدة",
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 24,
          ),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(16),
        child: pw.Text(
          title,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 22,
          ),
        ),
      ),
    ],
  );
}
pw.TableRow summaryRow(
  String title,
  double value,
  pw.Font font,
  pw.Font boldFont,
) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(14),
        child: pw.Text(
          "${value.toInt()} أوقية جديدة",
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 20,
          ),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(14),
        child: pw.Text(
          title,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: font,
            fontSize: 18,
          ),
        ),
      ),
    ],
  );
}
pw.TableRow clientCountRow(
  int value,
  pw.Font font,
  pw.Font boldFont,
) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(14),
        child: pw.Text(
          "$value",
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 20,
          ),
        ),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(14),
        child: pw.Text(
          "عدد الزبناء حاليا",
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: font,
            fontSize: 18,
          ),
        ),
      ),
    ],
  );
}

pw.Widget definitionItem(
  String title,
  String description,
  pw.Font font,
  pw.Font boldFont,
) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 14),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 16,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          description,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
            font: font,
            fontSize: 14,
            color: PdfColors.grey800,
          ),
        ),
      ],
    ),
  );
}
      // ================= PDF =================

      final pdf =
          pw.Document(
        compress: true,
      );

      // ================= TABLE DATA =================

      List<List<String>>
          tableData = [];
List<List<String>> healthTable = [];
double totalSubscriptions = 0;
double totalDonations = 0;
double totalPanels = 0;
double totalExpenses = 0;
double totalPending = 0;


const monthlyFee = 200;

healthTable.add([
  "الاسم",
  "الهاتف",
  "نوع الحالة",
  "المستشفى",
  "(MRU) المبلغ المدفوع",
  "تاريخ الدفع",
]);
      // ================= HEADERS =================

    tableData.add([
  "الاسم الكامل",
  "رقم الهاتف",
  "المحصل",
  "فئة الاشتراك",
  "الأشهر المدفوعة",
  "إجمالي الاشتراكات المحصلة",
  "المتأخرات",
  "التبرعات",
  "اللوحات",
  "إجمالي الزبون(MRU)",
]);
final Set<String> caisseClients = {};
final Map<String, Map<String, dynamic>> clients = {};
// ================= OPERATIONS =================

final peopleSnapshot =
    await FirebaseFirestore.instance
        .collection("people")
        .get();

final Map<String, int> peopleCategories = {};

for (final person in peopleSnapshot.docs) {

  final data = person.data();

  peopleCategories[person.id] =
      (data["monthlyAmount"] ?? 200) as int;
}
for (var operation in operationsSnapshot.docs) {
 final data = operation.data();
 final personId =
      (data["personId"] ?? "").toString();
  print("PERSON ID = $personId");
print("CATEGORY FOUND = ${peopleCategories[personId]}");
  final monthlyAmount =
     peopleCategories[personId] ?? 200;
 

  

  if (personId.isEmpty) continue;

  caisseClients.add(personId);

  final paymentType =
      (data["paymentType"] ?? "").toString();

  final amountValue =
      ((data["amount"] ?? 0) as num)
          .toDouble();

  String phone =
      (data["phone"] ?? "")
          .toString();

  phone = phone.replaceAll(" ", "");
  phone = phone.replaceAll("+", "");

 

if (phone.startsWith("222")) {
  phone = phone.substring(3);
}

if (phone.length > 8) {
  phone = phone.substring(phone.length - 8);
}

phone = "(222) $phone";

  final collector =
      data["collectorName"] ??
      data["collector"] ??
      data["collector_name"] ??
      "غير محدد";

  final name =
      (data["name"] ?? "").toString();

  final year =
      (data["year"] ?? "").toString();

  
  int paidMonths = 0;

  if (paymentType == "monthly") {

  totalSubscriptions += amountValue;

  final coveredMonths =
      List.from(
    data["coveredMonths"] ?? [],
  );

  paidMonths =
      coveredMonths.length;
}

  if (paymentType == "donation") {
    totalDonations += amountValue;
  }

  if (paymentType == "panel") {
    totalPanels += amountValue;
  }

  if (!clients.containsKey(personId)) {

    clients[personId] = {
  "name": name,
  "phone": phone,
  "collector": collector,
  "year": year,
  "months": 0,

  "monthsSet": <int>{},

  "pending": 0.0,
  "donations": 0.0,
  "panels": 0.0,
  "subscriptions": 0.0,
  "monthlyCategory": monthlyAmount,
};
  }

  if (paymentType == "monthly") {

  clients[personId]!["subscriptions"] +=
      amountValue;

  final coveredMonths =
    List<int>.from(
      data["coveredMonths"] ?? [],
    );

(clients[personId]!["monthsSet"]
        as Set<int>)
    .addAll(coveredMonths);
}

  if (paymentType == "donation") {

    clients[personId]!["donations"] +=
        amountValue;
  }

  if (paymentType == "panel") {

    clients[personId]!["panels"] +=
        amountValue;
  }
}

for (final client in clients.values) {
  final monthlyCategory =
    (client["monthlyCategory"] ?? 200) as int;

final paidMonths =
    (client["monthsSet"] as Set<int>)
        .length;

final expectedMonths =
    DateTime.now().month;

final missingMonths =
    expectedMonths - paidMonths;

final pending =
    missingMonths > 0
        ? missingMonths * monthlyCategory
        : 0;

totalPending += pending;


  final totalPaid =

      client["subscriptions"] +

      client["donations"] +

      client["panels"];

  tableData.add([
  client["name"],
  client["phone"],
  client["collector"],

  "${client["monthlyCategory"]} MRU",

  paidMonths.toString(),

  (client["subscriptions"] as double)
      .toInt()
      .toString(),

  pending.toString(),

  (client["donations"] as double)
      .toInt()
      .toString(),

  (client["panels"] as double)
      .toInt()
      .toString(),

  totalPaid.toInt().toString(),
]);
}
 
final totalClients =
    caisseClients.length;
for (final doc in healthCasesSnapshot.docs) {

  final data = doc.data();
  String healthPhone =

    (data["phone"] ?? "").toString();

healthPhone =

    healthPhone.replaceAll(" ", "");


healthPhone =

    healthPhone.replaceAll("+", "");


if (healthPhone.startsWith("222")) {

  healthPhone =

      healthPhone.substring(3);

}


if (healthPhone.length > 8) {

  healthPhone =

      healthPhone.substring(

        healthPhone.length - 8,

      );

}


healthPhone =

    "(222) $healthPhone";
  final expense =
    ((data["approvedAmount"] ??
      data["suggestedAmount"] ??
      0) as num)
        .toDouble();

totalExpenses += expense;


  String paidDate = "";

if (data["paidAt"] != null) {

  final date =
      (data["paidAt"] as Timestamp)
          .toDate();

  paidDate =
    "${date.day.toString().padLeft(2, '0')}/"
    "${date.month.toString().padLeft(2, '0')}/"
    "${date.year}";
}
healthTable.add([
  data["fullName"] ?? "",
 healthPhone,
  data["description"] ?? "",
  data["hospitalName"] ?? "",
  "${data["paidAmount"] ?? data["approvedAmount"] ?? data["suggestedAmount"] ?? 0}",
  paidDate,
]);
}
      // ================= DATE =================
final totalRevenue =
    totalSubscriptions +
    totalDonations +
    totalPanels;

final balance =
    totalRevenue -
    totalExpenses;



final now =
    DateTime.now();

      final dateText =

          "${now.day}/${now.month}/${now.year}"
          " - "
          "${now.hour}:${now.minute}";

      // ================= PAGE =================

      pdf.addPage(

        pw.MultiPage(

  maxPages: 5000,

  pageFormat:
      PdfPageFormat.a3.landscape,

  margin:
      const pw.EdgeInsets.all(8),

  build: (context) {


            return [

              pw.Directionality(

                textDirection:
                    pw.TextDirection.rtl,

                child: pw.Column(

                  children: [

                    // ================= HEADER =================

                    pw.Container(

                      padding:
                          const pw.EdgeInsets.all(
                        12,
                      ),

                      decoration:
                          pw.BoxDecoration(

                        color:
                            PdfColors.white,

                        border: pw.Border.all(

                          color:
                              PdfColors.grey700,

                          width: 1.2,
                        ),

                        borderRadius:
                            pw.BorderRadius.circular(
                          6,
                        ),
                      ),

                      child: pw.Row(

                        mainAxisAlignment:
                            pw.MainAxisAlignment
                                .spaceBetween,

                        children: [

                          // ================= LOGO =================

                          pw.Container(

                            width: 60,

                            height: 60,

                            decoration:
                                pw.BoxDecoration(

                              color:
                                  PdfColors.white,

                              border: pw.Border.all(

                                color:
                                    PdfColors.grey600,
                              ),

                              borderRadius:
                                  pw.BorderRadius.circular(
                                6,
                              ),
                            ),

                            padding:
                                const pw.EdgeInsets.all(
                              4,
                            ),

                            child: pw.Image(

                              pw.MemoryImage(
                                logoBytes,
                              ),

                              fit:
                                  pw.BoxFit.contain,
                            ),
                          ),

                          // ================= TITLES =================

                          pw.Column(

                            crossAxisAlignment:
                                pw.CrossAxisAlignment.end,

                            children: [

                              pw.Text(

                                "لجنة كونكل الخير ",

                                style:
                                    pw.TextStyle(

                                  font:
                                      boldFont,

                                  fontSize: 18,

                                  color:
                                      PdfColors.black,
                                ),
                              ),

                              pw.SizedBox(
                                height: 4,
                              ),

                              pw.Text(

                                "قاعدة البيانات ، بتاريخ:",

                                style:
                                    pw.TextStyle(

                                  font:
                                      font,

                                  fontSize: 12,

                                  color:
                                      PdfColors.black,
                                ),
                              ),

                              pw.SizedBox(
                                height: 4,
                              ),

                              pw.Text(

                                dateText,

                                style:
                                    pw.TextStyle(

                                  font:
                                      font,

                                  fontSize: 10,

                                  color:
                                      PdfColors.grey800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(
                      height: 15,
                    ),
pw.Text(
  "ملخص الصندوق",
  style: pw.TextStyle(
    font: boldFont,
    fontSize: 28,
  ),
),

pw.SizedBox(height: 20),

pw.Container(
  height: 600,
  width: double.infinity,

  padding: const pw.EdgeInsets.all(15),

  decoration: pw.BoxDecoration(
    border: pw.Border.all(
      color: PdfColors.black,
      width: 1,
    ),
  ),

  child: pw.Row(

    crossAxisAlignment:
        pw.CrossAxisAlignment.start,

    children: [

      // ================= CHIFFRES =================

      pw.Expanded(
        flex: 45,

        child: pw.Table(

          border: pw.TableBorder.all(
            color: PdfColors.grey500,
          ),

          children: [

  clientCountRow(
  totalClients,
  font,
  boldFont,
),

  summaryRow(
    "إجمالي الاشتراكات",
    totalSubscriptions,
    font,
    boldFont,
  ),

            summaryRow(
              "إجمالي التبرعات",
              totalDonations,
              font,
              boldFont,
            ),

            summaryRow(
              "إجمالي اللوحات",
              totalPanels,
              font,
              boldFont,
            ),

            summaryRow(
              "إجمالي الإيرادات",
              totalRevenue,
              font,
              boldFont,
            ),

            summaryRow(
              "إجمالي المصروفات",
              totalExpenses,
              font,
              boldFont,
            ),

            specialSummaryRow(
  "الرصيد الحالي",
  balance,
  font,
  boldFont,
),

            summaryRow(
              "إجمالي المتأخرات",
              totalPending,
              font,
              boldFont,
            ),
          ],
        ),
      ),

      pw.SizedBox(width: 20),

      // ================= DEFINITIONS =================

      pw.Expanded(
        flex: 55,

        child: pw.Column(

          crossAxisAlignment:
              pw.CrossAxisAlignment.end,

          children: [

            pw.Text(
              "شرح المؤشرات",
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 18,
              ),
            ),

            pw.SizedBox(height: 15),

            definitionItem(
              "إجمالي الاشتراكات",
              "مجموع الاشتراكات الشهرية المحصلة من جميع الأعضاء.",
              font,
              boldFont,
            ),

            definitionItem(
              "إجمالي التبرعات",
              "مجموع التبرعات المالية المستلمة لصالح الصندوق.",
              font,
              boldFont,
            ),

            definitionItem(
              "إجمالي اللوحات",
              "مجموع مساهمات اللوحات المدفوعة.",
              font,
              boldFont,
            ),

            definitionItem(
              "إجمالي الإيرادات",
              "مجموع الاشتراكات والتبرعات واللوحات.",
              font,
              boldFont,
            ),

            definitionItem(
              "إجمالي المصروفات",
              "المبالغ المصروفة للمستفيدين من الصندوق.",
              font,
              boldFont,
            ),

            definitionItem(
              "الرصيد الحالي",
              "الرصيد المتبقي في الصندوق بعد خصم جميع المصروفات.",
              font,
              boldFont,
            ),

            definitionItem(
              "إجمالي المتأخرات",
              "الاشتراكات المستحقة وغير المدفوعة حتى تاريخ التقرير.",
              font,
              boldFont,
            ),
          ],
        ),
      ),
    ],
  ),
),

pw.SizedBox(height: 25),

pw.NewPage(),

pw.Text(
  "موارد الصندوق",
  style: pw.TextStyle(
    font: boldFont,
    fontSize: 16,
  ),
),


pw.SizedBox(height: 15),

/// ================= TABLE =================

pw.Table(
  border: pw.TableBorder.all(
    color: PdfColors.grey400,
  ),

  

  defaultVerticalAlignment:
      pw.TableCellVerticalAlignment.middle,

 columnWidths: {
  0: const pw.FlexColumnWidth(3.2), // الاسم الكامل
  1: const pw.FlexColumnWidth(1.8), // الهاتف
  2: const pw.FlexColumnWidth(2.4), // المحصل
  3: const pw.FlexColumnWidth(1.3), // فئة الاشتراك
  4: const pw.FlexColumnWidth(1.2), // الأشهر المدفوعة
  5: const pw.FlexColumnWidth(2.0), // إجمالي الاشتراكات المحصلة
  6: const pw.FlexColumnWidth(1.3), // المتأخرات
  7: const pw.FlexColumnWidth(1.3), // التبرعات
  8: const pw.FlexColumnWidth(1.3), // اللوحات
  9: const pw.FlexColumnWidth(1.8), // إجمالي الزبون
},
  children: [

                        // ================= HEADER =================

                        pw.TableRow(

                          decoration:
                              pw.BoxDecoration(

                            color:
                                PdfColors.white,

                            border: pw.Border.all(

                              color:
                                  PdfColors.grey700,

                              width: 1,
                            ),
                          ),

                          children:
                              tableData.first.map(

                            (header) {

                              return pw.Padding(

                                padding:
                                    const pw.EdgeInsets.all(
                                  4,
                                ),

                                child:
                                    pw.Directionality(

                                  textDirection:
                                      pw.TextDirection.rtl,

                                  child: pw.Text(

  header.toString(),

  textAlign:
      pw.TextAlign.center,

  softWrap: true,

  style: pw.TextStyle(

    font: boldFont,

    color: PdfColors.black,

    fontSize: 10,
  ),
),
                                ),
                              );
                            },
                          ).toList(),
                        ),

                        // ================= DATA =================

...tableData
    .sublist(1)
    .map(

  (row) {

    return pw.TableRow(

      children:
          row.map(

        (cell) {

          return pw.Padding(

            padding:
                const pw.EdgeInsets.symmetric(

              vertical: 5,
              horizontal: 3,
            ),

            child: pw.Directionality(

              textDirection:
                  pw.TextDirection.rtl,

              child: pw.Text(

                cell.toString(),

                textAlign:
                    pw.TextAlign.center,

                softWrap: true,

                style: pw.TextStyle(

                  font: font,

                  fontSize: 9.5,
                ),
              ),
            ),
          );
        },
      ).toList(),
    );
  },
).toList(),

                      ],
                    ),
pw.SizedBox(height: 20),

pw.Text(
  "الحالات الصحية المعوضة",
  style: pw.TextStyle(
    font: boldFont,
    fontSize: 16,
  ),
),

pw.SizedBox(height: 10),

pw.Table(
  border: pw.TableBorder.all(
    color: PdfColors.grey400,
  ),

  children: [

    // En-têtes

    pw.TableRow(
      children: healthTable.first.map((header) {

        return pw.Padding(
          padding: const pw.EdgeInsets.all(4),

          child: pw.Text(
            header,
            textAlign: pw.TextAlign.center,

            style: pw.TextStyle(
              font: boldFont,
              fontSize: 10,
            ),
          ),
        );

      }).toList(),
    ),

    // Lignes

    ...healthTable
        .sublist(1)
        .map((row) {

      return pw.TableRow(

        children: row.map((cell) {

          return pw.Padding(

            padding:
                const pw.EdgeInsets.all(4),

            child: pw.Text(

              cell.toString(),

              textAlign:
                  pw.TextAlign.center,

              style: pw.TextStyle(
                font: font,
                fontSize: 9,
              ),
            ),
          );
        }).toList(),
      );
    }).toList(),
  ],
),
                  ],
                ),
              ),
            ];
          },
        ),
      );

// ================= SAVE PDF =================

Uint8List bytes =
    await pdf.save();

// ================= WEB DOWNLOAD =================

if (kIsWeb) {

  await downloadFile(

    bytes,

    "قاعدة_بيانات_لجنة_كونكل_الخير.pdf",

    "application/pdf",
  );
}

// ================= MOBILE / WINDOWS =================

else {

  await Permission.storage.request();

  final directory =

      Directory(
        '/storage/emulated/0/Download',
      );

  final path =

      "${directory.path}/قاعدة_بيانات_لجنة_كونكل_الخير.pdf";

  final file = File(path);

  await file.writeAsBytes(
    bytes,
  );

  await OpenFilex.open(path);
}

// ================= OPEN PDF =================

// await launchUrl(path);



      // ================= SUCCESS =================

      if (mounted) {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(

            content: Text(
              "✅ تم تصدير PDF بنجاح",
            ),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        SnackBar(

          content:
              Text("Erreur : $e"),
        ),
      );

    } finally {

      setState(() {
        loading = false;
      });
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "تصدير PDF",
        ),
      ),

      body: Center(

        child: Padding(

          padding:
              const EdgeInsets.all(
            24,
          ),

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const Icon(

                Icons.picture_as_pdf,

                size: 120,

                color: Colors.red,
              ),

              const SizedBox(
                height: 30,
              ),

              const Text(

                "تصدير قاعدة البيانات PDF",

                textAlign:
                    TextAlign.center,

                style: TextStyle(

                  fontSize: 24,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              const Text(

                "ملف PDF احترافي",

                textAlign:
                    TextAlign.center,

                style: TextStyle(

                  fontSize: 16,

                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 40,
              ),

              FutureBuilder<DocumentSnapshot>(

  future:
      FirebaseFirestore.instance
          .collection("users")
          .doc(

            FirebaseAuth
                .instance
                .currentUser
                ?.uid,
          )
          .get(),

  builder: (
    context,
    snapshot,
  ) {

    if (!snapshot.hasData) {

      return const CircularProgressIndicator();
    }

    final userData =
        snapshot.data!.data()
            as Map<String, dynamic>?;

    final isAdmin =

        userData?["role"] ==
            "admin";

    return Column(

      children: [

        ElevatedButton.icon(

          onPressed:

              !isAdmin
                  ? null
                  : loading
                      ? null
                      : exportPdf,

          icon:
              const Icon(
            Icons.download,
          ),

          label:
              loading

                  ? const Padding(

                      padding:
                          EdgeInsets.all(
                        8,
                      ),

                      child:
                          CircularProgressIndicator(
                        color:
                            Colors.white,
                      ),
                    )

                  : const Text(
                      "تصدير PDF",
                    ),

          style:
              ElevatedButton.styleFrom(

            backgroundColor:
                Colors.red,

            foregroundColor:
                Colors.white,

            padding:
                const EdgeInsets.symmetric(

              horizontal: 30,

              vertical: 18,
            ),
          ),
        ),

        if (!isAdmin)

          const Padding(

            padding:
                EdgeInsets.only(
              top: 12,
            ),

            child: Text(

              "التحميل متاح للإدارة فقط",

              style: TextStyle(

                color: Colors.red,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  },
),

               
            ],
          ),
        ),
      ),
    );
  }
}