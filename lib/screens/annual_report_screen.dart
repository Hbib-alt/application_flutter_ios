import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:typed_data';
import '../utils/web_download.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';

class AnnualReportScreen extends StatefulWidget {

  const AnnualReportScreen({
    super.key,
  });

  @override
  State<AnnualReportScreen>
      createState() =>
          _AnnualReportScreenState();
}

class _AnnualReportScreenState
    extends State<AnnualReportScreen> {

  bool loading = false;

  int selectedYear =
      DateTime.now().year;

  // ================= GENERATE REPORT =================

  Future<void> generateAnnualReport() async {

    try {

      setState(() {
        loading = true;
      });

      // ================= DATE RANGE =================

      final startDate =
          DateTime(
        selectedYear,
        1,
        1,
      );

      final endDate =
          DateTime(
        selectedYear + 1,
        1,
        1,
      );

      // ================= FIRESTORE =================

      final snapshot =
          await FirebaseFirestore
              .instance
              .collection("transactions")
.where(
  "type",
  isEqualTo: "add",
)
.where(
  "isDeleted",
  isEqualTo: false,
)
.where(
  "createdAt",
  isGreaterThanOrEqualTo:
      Timestamp.fromDate(startDate),
)
.where(
  "createdAt",
  isLessThan:
      Timestamp.fromDate(endDate),
)
             
              .get();

      // ================= VARIABLES =================

      double totalMonthly = 0;

      double totalDonations = 0;

      double totalPanels = 0;

      double totalGlobal = 0;

      int operationsCount = 0;

      

      final Map<int, double>
          monthlyStats = {};

      final Map<String, double>
          collectorStats = {};

      // ================= PROCESS DATA =================

      for (var doc
          in snapshot.docs) {

        final data =
            doc.data();

        final amount =
    double.tryParse(
      data["amount"].toString(),
    ) ?? 0;
        final paymentType =
            data["paymentType"] ??
                "";

        final collector =
            data["collectorName"] ??
                "غير معروف";

       if (data["createdAt"] == null) {
  continue;
}

final createdAt =
    (data["createdAt"] as Timestamp)
        .toDate();

        operationsCount++;

        totalGlobal += amount;

        // ================= TYPES =================

        if (paymentType ==
            "monthly") {

          totalMonthly += amount;
        }

        else if (paymentType ==
            "donation") {

          totalDonations += amount;
        }

        else if (paymentType ==
            "panel") {

          totalPanels += amount;
        }

        // ================= BENEFITED =================

        

        // ================= MONTHLY STATS =================

        final month =
            createdAt.month;

        monthlyStats[month] =

            (monthlyStats[month] ??
                    0) +
                amount;

        // ================= COLLECTOR STATS =================

        collectorStats[collector] =

            (collectorStats[
                        collector] ??
                    0) +
                amount;
      }

      // ================= TOP COLLECTORS =================

      final sortedCollectors =
          collectorStats.entries
              .toList()

            ..sort(

              (a, b) =>
                  b.value.compareTo(
                a.value,
              ),
            );
final bestMonth =
    monthlyStats.isNotEmpty
        ? monthlyStats.entries.reduce(
            (a, b) =>
                a.value > b.value
                    ? a
                    : b,
          )
        : null;

final weakestMonth =
    monthlyStats.isNotEmpty
        ? monthlyStats.entries.reduce(
            (a, b) =>
                a.value < b.value
                    ? a
                    : b,
          )
        : null;
   const monthNames = [
  "",
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
      // ================= RECOMMENDATIONS =================

      List<String>
          recommendations = [];

      if (totalDonations <
          totalGlobal * 0.15) {

        recommendations.add(

          "يوصى بتكثيف حملات التبرعات لزيادة الإيرادات السنوية.",
        );
      }

       

      if (sortedCollectors
          .isNotEmpty) {

        recommendations.add(

          "أفضل المحصلين هذه السنة: ${sortedCollectors.take(3).map((e) => e.key).join(" ، ")}",
        );
      }

      
        
      // ================= LOAD FONT =================

      final fontData =
          await rootBundle.load(
        "assets/fonts/cairo.ttf",
      );

      final font =
          pw.Font.ttf(
        fontData,
      );

      // ================= LOAD LOGO =================

      final logoBytes =
          (await rootBundle.load(
        "assets/images/logo.png",
      ))
              .buffer
              .asUint8List();

      // ================= PDF =================

      final pdf =
          pw.Document();

      // ================= PAGE =================

      pdf.addPage(

        pw.MultiPage(

          pageFormat:
              PdfPageFormat.a4,

          textDirection:
              pw.TextDirection.rtl,

          build: (context) {

            return [

              // ================= HEADER =================

              pw.Center(

                child: pw.Column(

                  children: [

                    pw.Image(

                      pw.MemoryImage(
                        logoBytes,
                      ),

                      width: 100,

                      height: 100,
                    ),

                    pw.SizedBox(
                      height: 10,
                    ),

                    pw.Text(

                      "لجنة كونكل الخير",

                      style:
                          pw.TextStyle(

                        font: font,

                        fontSize: 24,

                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),

                    pw.SizedBox(
                      height: 10,
                    ),

                    pw.Text(

                      "التقرير السنوي لسنة $selectedYear",

                      style:
                          pw.TextStyle(

                        font: font,

                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(
                height: 30,
              ),

              // ================= GENERAL STATS =================

              pw.Text(

                "الإحصائيات العامة",

                style:
                    pw.TextStyle(

                  font: font,

                  fontSize: 20,

                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(
                height: 10,
              ),

              pw.Bullet(
                text:
                    "إجمالي العمليات: $operationsCount",
                style:
                    pw.TextStyle(
                  font: font,
                ),
              ),

              pw.Bullet(
                text:
                    "إجمالي الاشتراكات: ${totalMonthly.toStringAsFixed(2)}",
                style:
                    pw.TextStyle(
                  font: font,
                ),
              ),

              pw.Bullet(
                text:
                    "إجمالي التبرعات: ${totalDonations.toStringAsFixed(2)}",
                style:
                    pw.TextStyle(
                  font: font,
                ),
              ),

              pw.Bullet(
                text:
                    "إجمالي اللوحات: ${totalPanels.toStringAsFixed(2)}",
                style:
                    pw.TextStyle(
                  font: font,
                ),
              ),

              pw.Bullet(
                text:
                    "الإجمالي العام: ${totalGlobal.toStringAsFixed(2)}",
                style:
                    pw.TextStyle(
                  font: font,
                ),
              ),

             
              pw.SizedBox(
                height: 25,
              ),

              // ================= TOP COLLECTORS =================

              pw.Text(

                "أفضل المحصلين",

                style:
                    pw.TextStyle(

                  font: font,

                  fontSize: 20,

                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(
                height: 10,
              ),

              ...sortedCollectors
                  .take(5)
                  .map(

                (e) {

                  return pw.Bullet(

                    text:
                        "${e.key} : ${e.value.toStringAsFixed(2)}",

                    style:
                        pw.TextStyle(
                      font: font,
                    ),
                  );
                },
              ),

              pw.SizedBox(
                height: 25,
              ),
pw.Text(
  "التحليل السنوي",
  style: pw.TextStyle(
    font: font,
    fontSize: 20,
    fontWeight: pw.FontWeight.bold,
  ),
),

pw.SizedBox(height: 10),

pw.Text(
  bestMonth == null
      ? "لا توجد بيانات مالية متاحة لهذه السنة."
      : "بلغ إجمالي الموارد خلال سنة $selectedYear مبلغ ${totalGlobal.toStringAsFixed(2)} أوقية جديدة. "
          "وكان أفضل شهر هو ${monthNames[bestMonth.key]} "
          "بمبلغ ${bestMonth.value.toStringAsFixed(2)} أوقية جديدة، "
          "بينما كان أضعف شهر هو ${monthNames[weakestMonth!.key]}.",
  style: pw.TextStyle(
    font: font,
  ),
),

pw.SizedBox(height: 25),

              // ================= RECOMMENDATIONS =================

              pw.Text(

                "التوصيات للسنة القادمة",

                style:
                    pw.TextStyle(

                  font: font,

                  fontSize: 20,

                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(
                height: 10,
              ),

              ...recommendations.map(
  (r) {
    return pw.Bullet(
      text: r,
      style: pw.TextStyle(
        font: font,
      ),
    );
  },
),

pw.SizedBox(height: 25),

pw.Text(
  "الخاتمة",
  style: pw.TextStyle(
    font: font,
    fontSize: 20,
    fontWeight: pw.FontWeight.bold,
  ),
),

pw.SizedBox(height: 10),

pw.Text(
  "تتقدم لجنة كونكل الخير بجزيل الشكر لجميع المحصلين والمتبرعين والداعمين الذين ساهموا في إنجاح أنشطة اللجنة خلال هذه السنة.",
  style: pw.TextStyle(
    font: font,
  ),
),

pw.SizedBox(height: 20),

pw.Text(
  "حرر بتاريخ: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
  style: pw.TextStyle(
    font: font,
  ),
),

];
            
          },
        ),
      );

      // ================= SAVE PDF =================

      Uint8List bytes =
          await pdf.save();

   if (kIsWeb) {

  await downloadFile(

    bytes,

    "annual_report_$selectedYear.pdf",

    "application/pdf",
  );
}

else {

  await Permission.storage.request();

  final directory =

      Directory(
        '/storage/emulated/0/Download',
      );

  final path =

      "${directory.path}/annual_report_$selectedYear.pdf";

  final file = File(path);

  await file.writeAsBytes(bytes);

  await OpenFilex.open(path);
}

      // ================= SUCCESS =================

      if (mounted) {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(

            content: Text(
              "✅ تم إنشاء التقرير السنوي بنجاح",
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
              Text(
            "Erreur : $e",
          ),
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
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "التقرير السنوي",
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

                Icons.analytics,

                size: 120,

                color: Colors.blue,
              ),

              const SizedBox(
                height: 30,
              ),

              const Text(

                "التقرير السنوي الذكي",

                style: TextStyle(

                  fontSize: 28,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              DropdownButton<int>(

                value: selectedYear,

                items: List.generate(

                  5,

                  (index) {

                    final year =

                        DateTime.now()
                                .year -
                            index;

                    return DropdownMenuItem(

                      value: year,

                      child: Text(
                        year.toString(),
                      ),
                    );
                  },
                ),

                onChanged: (value) {

                  if (value == null) {
                    return;
                  }

                  setState(() {

                    selectedYear =
                        value;
                  });
                },
              ),

              const SizedBox(
                height: 40,
              ),

              ElevatedButton.icon(

                onPressed:
                    loading
                        ? null
                        : generateAnnualReport,

                icon: const Icon(
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
                            "تحميل التقرير السنوي",
                          ),

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.blue,

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