import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;



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
              .collection("operations")
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

      // ================= PDF =================

      final pdf =
          pw.Document(
        compress: true,
      );

      // ================= TABLE DATA =================

      List<List<String>>
          tableData = [];

      // ================= HEADERS =================

      tableData.add([

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
      ]);

// ================= OPERATIONS =================

for (var operation
    in operationsSnapshot.docs) {

  final data =
      operation.data();

  final paymentType =
      data["paymentType"] ??
          "";

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

    data["collector"] ??

    data["collector_name"] ??

    "غير محدد";

  // ================= AMOUNT =================

  final amount =
      (data["amount"] ?? 0)
          .toString();

  // ================= YEAR =================

  final year =
      (data["year"] ?? "")
          .toString();

  // ================= MONTHS =================

  String months = "—";

  if (paymentType ==
      "monthly") {

    months =
        (data["months"] ?? 0)
            .toString();
  }

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
          .toString();

  // ================= DONATIONS =================

  final donations =
      paymentType == "donation"
          ? amount
          : "0";

  // ================= PANELS =================

  final panels =
      paymentType == "panel"
          ? amount
          : "0";

  // ================= ADD ROW =================

  tableData.add([

    name,

    phone,

    collector,

    typeArabic,

    amount,

    months,

    year,

    benefited,

    reason,

    pending,

    donations,

    panels,
  ]);
}

      // ================= DATE =================

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

                                "لجنة كونكل الخير الاجتماعية",

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

                                "قاعدة البيانات الكاملة",

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

                    // ================= TABLE =================

                    pw.Table(

  border:
      pw.TableBorder.all(

    color:
        PdfColors.grey400,
  ),

  defaultVerticalAlignment:
      pw.TableCellVerticalAlignment.middle,

  columnWidths: {

  0: const pw.FlexColumnWidth(3), // الاسم

  1: const pw.FlexColumnWidth(1.8), // الهاتف

  2: const pw.FlexColumnWidth(2.7), // المحصل

  3: const pw.FlexColumnWidth(1.7), // العملية

  4: const pw.FlexColumnWidth(1.4), // المبلغ

  5: const pw.FlexColumnWidth(1.1), // الأشهر

  6: const pw.FlexColumnWidth(1), // السنة

  7: const pw.FlexColumnWidth(1.5), // استفاد

  8: const pw.FlexColumnWidth(3), // السبب

  9: const pw.FlexColumnWidth(1.2), // المتأخرات

  10: const pw.FlexColumnWidth(1.2), // التبرعات

  11: const pw.FlexColumnWidth(1.2), // اللوحات
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

final directory =
    await getApplicationDocumentsDirectory();

final path =
    "${directory.path}/قاعدة_بيانات_لجنة_كونكل_الخير.pdf";

final file =
    File(path);

await file.writeAsBytes(bytes);

// ================= OPEN PDF =================

await launchUrl(path);



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

              ElevatedButton.icon(

                onPressed:
                    loading
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
            ],
          ),
        ),
      ),
    );
  }
}