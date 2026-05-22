import 'dart:io';

import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'package:pdf/pdf.dart';

import 'package:pdf/widgets.dart' as pw;

import 'package:share_plus/share_plus.dart';

class PdfService {

  static Future<void> printReceipt({

    required String name,

    required String phone,

    required String type,

    required int amount,

    required String date,

  }) async {

    final pdf = pw.Document();

    // ✅ Arabic font

    final fontData =
        await rootBundle.load(
      "assets/fonts/cairo.ttf",
    );

    final ttf =
        pw.Font.ttf(fontData);

    // ✅ Logo

    final logoData =
        await rootBundle.load(
      "assets/images/logo.png",
    );

    final logo = pw.MemoryImage(
      logoData.buffer.asUint8List(),
    );

    pdf.addPage(

      pw.Page(

        pageFormat:
            PdfPageFormat.a4,

        build: (context) {

          return pw.Directionality(

            textDirection:
                pw.TextDirection.rtl,

            child: pw.Padding(

              padding:
                  const pw.EdgeInsets.all(
                24,
              ),

              child: pw.Column(

                crossAxisAlignment:
                    pw.CrossAxisAlignment
                        .start,

                children: [

                  // ✅ LOGO

                  pw.Center(

                    child: pw.Image(

                      logo,

                      width: 120,

                      height: 120,
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // ✅ TITLE

                  pw.Center(

                    child: pw.Text(

                      "وصل دفع",

                      style: pw.TextStyle(

                        font: ttf,

                        fontSize: 28,

                        fontWeight:
                            pw.FontWeight.bold,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 40),

                  // ✅ NAME

                  pw.Text(

                    "الاسم: $name",

                    style: pw.TextStyle(

                      font: ttf,

                      fontSize: 18,
                    ),
                  ),

                  pw.SizedBox(height: 15),

                  // ✅ PHONE

                  pw.Text(

                    "الهاتف: $phone",

                    style: pw.TextStyle(

                      font: ttf,

                      fontSize: 18,
                    ),
                  ),

                  pw.SizedBox(height: 15),

                  // ✅ TYPE

                  pw.Text(

                    "النوع: $type",

                    style: pw.TextStyle(

                      font: ttf,

                      fontSize: 18,
                    ),
                  ),

                  pw.SizedBox(height: 15),

                  // ✅ AMOUNT

                  pw.Text(

                    "المبلغ: $amount MRU",

                    style: pw.TextStyle(

                      font: ttf,

                      fontSize: 18,
                    ),
                  ),

                  pw.SizedBox(height: 15),

                  // ✅ DATE

                  pw.Text(

                    "التاريخ: $date",

                    style: pw.TextStyle(

                      font: ttf,

                      fontSize: 18,
                    ),
                  ),

                  pw.SizedBox(height: 50),

                  // ✅ SIGNATURE

                  pw.Text(

                    "التوقيع: __________________",

                    style: pw.TextStyle(

                      font: ttf,

                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    // ✅ SAVE PDF

    final bytes =
        await pdf.save();

    final dir =
        await getTemporaryDirectory();

    final file = File(
      "${dir.path}/receipt.pdf",
    );

    await file.writeAsBytes(bytes);

    // ✅ SHARE PDF

    await Share.shareXFiles(

      [XFile(file.path)],

      text: "وصل الدفع",
    );
  }
}