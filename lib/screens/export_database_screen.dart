import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

class ExportDatabaseScreen extends StatefulWidget {

  const ExportDatabaseScreen({
    super.key,
  });

  @override
  State<ExportDatabaseScreen> createState() =>
      _ExportDatabaseScreenState();
}

class _ExportDatabaseScreenState
    extends State<ExportDatabaseScreen> {

  bool loading = false;

  // ================= EXPORT EXCEL =================

  Future<void> exportDatabase() async {

    try {

      setState(() {
        loading = true;
      });

      // ================= FIREBASE =================

     
      final operationsSnapshot =
    await FirebaseFirestore
        .instance
        .collection("operations")
        .orderBy(
          "createdAt",
          descending: true,
        )
        .get();

      // ================= CREATE EXCEL =================

      final excel =
          Excel.createExcel();

      final sheet =
          excel['قاعدة البيانات'];

      // ================= STYLES =================

      final headerStyle =
    CellStyle(

  bold: true,

  fontSize: 14,

  fontColorHex:
      ExcelColor.white,

  backgroundColorHex:
      ExcelColor.teal,

  horizontalAlign:
      HorizontalAlign.Center,

  verticalAlign:
      VerticalAlign.Center,
);

      final allStyle =
          CellStyle(

        horizontalAlign:
            HorizontalAlign.Center,

        verticalAlign:
            VerticalAlign.Center,
      );

      // ================= HEADERS =================

      final headers = [

  "التاريخ",

  "الاسم الكامل",

  "رقم الهاتف",

  "المحصل",

  "نوع العملية",

  "المبلغ المدفوع",

  "عدد الأشهر",

  "السنة",

  "استفاد من الصندوق",

  "سبب الاستفادة",

  "المتأخرات",

  "التبرعات",

  "اللوحات",

  "ملاحظات",
];

      // ================= INSERT HEADERS =================

      for (int i = 0;
          i < headers.length;
          i++) {

        final cell =
            sheet.cell(

          CellIndex.indexByColumnRow(

            columnIndex: i,

            rowIndex: 0,
          ),
        );

        cell.value =
            CellValue(
          headers[i],
        );

        cell.cellStyle =
            headerStyle;
      }

      // ================= ROW INDEX =================

      int row = 1;

      // ================= OPERATIONS =================

for (var operation
    in operationsSnapshot.docs) {

  final data =
      operation.data();

  // ================= NAME =================

  final name =
      data["name"] ?? "";

  // ================= PHONE =================

  String phone =
      (data["phone"] ?? "")
          .toString();

  phone = phone.replaceAll(
    " ",
    "",
  );

  phone = phone.replaceAll(
    "+",
    "",
  );

  if (phone.startsWith(
      "222")) {

    phone =
        phone.substring(3);
  }

  if (phone.length > 8) {

    phone = phone.substring(
      phone.length - 8,
    );
  }

  // ================= COLLECTOR =================

  final collector =
      data["collectorName"] ??
          "";

  // ================= AMOUNT =================

  final amount =
      (data["amount"] ?? 0)
          .toInt();

  // ================= YEAR =================

  final year =
      (data["year"] ?? 0)
          .toInt();

  // ================= BENEFITED =================

  final benefited =
      data["benefitedFromCaisse"] == true
          ? "نعم"
          : "لا";

  // ================= REASON =================

  final reason =
      data["benefitReason"] ?? "";

  // ================= PENDING =================

  final pending =
      (data["pending"] ?? 0)
          .toInt();

  // ================= NOTE =================

  final note =
      data["note"] ?? "";

  // ================= PAYMENT TYPE =================

  final paymentType =
      data["paymentType"] ??
          "";

  int months = 0;

  if (paymentType ==
      "monthly") {

    months =
        (data["months"] ?? 0)
            .toInt();
  }

  // ================= DATE =================

  String createdAt = "";

  if (data["createdAt"] !=
      null) {

    final date =
        (data["createdAt"]
                as Timestamp)
            .toDate();

    createdAt =
        "${date.day}/${date.month}/${date.year}";
  }

  // ================= TYPE =================

  String typeArabic = "";

  if (paymentType ==
      "monthly") {

    typeArabic =
        "اشتراك";
  }

  else if (paymentType ==
      "donation") {

    typeArabic =
        "تبرع";
  }

  else if (paymentType ==
      "panel") {

    typeArabic =
        "لوحة";
  }

  else {

    typeArabic =
        paymentType;
  }

  // ================= DONATIONS =================

  final donations =
      paymentType == "donation"
          ? amount
          : 0;

  // ================= PANELS =================

  final panels =
      paymentType == "panel"
          ? amount
          : 0;

  // ================= INSERT ROW =================

  sheet.appendRow([

  createdAt,

  name,

  phone,

  collector,

  typeArabic,

  amount,

  paymentType == "monthly"
      ? months
      : "—",

  year,

  benefited,

  reason,

  pending,

  donations,

  panels,

  note,
]);

  // ================= STYLE =================

  for (int i = 0;
      i < headers.length;
      i++) {

    final cell =
        sheet.cell(

      CellIndex.indexByColumnRow(

        columnIndex: i,

        rowIndex: row,
      ),
    );

    cell.cellStyle =
        allStyle;
  }

  row++;
}

        
      // ================= COLUMN WIDTHS =================

      List<double> columnWidths = [

  20, // التاريخ

  40, // الاسم الكامل

  18, // الهاتف

  30, // المحصل

  22, // نوع العملية

  20, // المبلغ

  15, // الأشهر

  15, // السنة

  25, // استفاد

  35, // السبب

  20, // المتأخرات

  20, // التبرعات

  20, // اللوحات

  35, // ملاحظات
];

      // ================= APPLY WIDTH =================

      
      // ================= ENCODE =================

      final bytes =
          excel.encode();

      if (bytes == null) {

        throw Exception(
          "Erreur export Excel",
        );
      }

      // ================= SAVE EXCEL =================

final directory =
    await getApplicationDocumentsDirectory();

final path =
    "${directory.path}/قاعدة_بيانات_لجنة_كونكل_الخير.xlsx";

final file =
    File(path);

await file.writeAsBytes(bytes);

// ================= OPEN EXCEL =================

await OpenFilex.open(path);

      // ================= SUCCESS =================

      if (mounted) {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(

            content: Text(
              "✅ تم تصدير ملف Excel بنجاح",
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
          "تصدير قاعدة البيانات",
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

                Icons.table_view,

                size: 120,

                color: Colors.green,
              ),

              const SizedBox(
                height: 30,
              ),

              const Text(

                "تصدير قاعدة البيانات الكاملة",

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

                "الاشتراكات • التبرعات • اللوحات • المستفيدون • الأسباب",

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

              ElevatedButton.icon(

                onPressed:
                    loading
                        ? null
                        : exportDatabase,

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
                            "تصدير Excel",
                          ),

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.green,

                  foregroundColor:
                      Colors.white,

                  padding:
                      const EdgeInsets.symmetric(

                    horizontal: 30,

                    vertical: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}