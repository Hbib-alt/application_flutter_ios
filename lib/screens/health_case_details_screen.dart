import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';
import '../utils/workflow.dart';
import '../services/health_case_notification_service.dart';

class HealthCaseDetailsScreen
    extends StatelessWidget {

  final String caseId;

  const HealthCaseDetailsScreen({
    super.key,
    required this.caseId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "تفاصيل الحالة الصحية",
        ),
      ),

     body: StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection("health_cases")
      .doc(caseId)
      .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (!snapshot.data!.exists) {

            return const Center(
              child: Text(
                "الحالة غير موجودة",
              ),
            );
          }

          final data =
              snapshot.data!.data()
                  as Map<String, dynamic>;
String treatmentPlaceArabic = "";

switch (data["treatmentPlace"]) {

  case "mauritania":
    treatmentPlaceArabic = "موريتانيا";
    break;

  case "abroad":
    treatmentPlaceArabic = "الخارج";
    break;

  default:
    treatmentPlaceArabic =
        data["treatmentPlace"] ?? "";
}

String procedureArabic = "";

switch (data["procedureType"]) {

  case "standard_procedure":
    procedureArabic = "المسطرة العادية";
    break;

  case "committee_evaluation":
    procedureArabic = "تقييم اللجنة";
    break;
case "exceptional_case":
  procedureArabic = "حالة تحتاج السلطة التقديرية للجنة";
  break;
  default:
    procedureArabic =
        data["procedureType"] ?? "";
}

String statusArabic = "";

switch (data["status"]) {

  case "submitted":
    statusArabic = "تم التصريح";
    break;

  case "approved":
    statusArabic = "تمت الموافقة";
    break;

  case "paid":
    statusArabic = "تم الدفع";
    break;

  case "rejected":
    statusArabic = "مرفوض";
    break;

  default:
    statusArabic =
        data["status"] ?? "";
}
          return ListView(

            padding:
                const EdgeInsets.all(16),

            children: [

Card(
  elevation: 3,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Text(
          data["fullName"] ?? "",
          style: const TextStyle(
            fontSize: 22,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          "📞 ${data["phone"] ?? ""}",
        ),

        const SizedBox(height: 4),

        Text(
          "🏥 ${data["hospitalName"] ?? "-"}",
        ),
        const SizedBox(height: 4),

Text(
  "📍 مكان العلاج: $treatmentPlaceArabic",
),

const SizedBox(height: 4),

Text(
  "🛡️ التأمين: ${data["hasInsurance"] == true ? "نعم" : "لا"}",
),

const SizedBox(height: 4),

Text(
  "🩺 الوضعية الصحية: ${data["description"] ?? "-"}",
),
      ],
    ),
  ),
),
             
             

              _item(
  "الإجراء المطبق",
  procedureArabic,
),

              Card(
  elevation: 4,
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [

        const Text(
          " المبلغ المقترح",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Text(
  data["paidAmount"] != null
      ? "${data["paidAmount"]} MRU"
      : data["approvedAmount"] != null
          ? "${data["approvedAmount"]} MRU"
          : data["procedureType"] == "exceptional_case"
              ? "يحدد من طرف اللجنة"
              : "${data["suggestedAmount"] ?? 0} MRU",
  style: const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  ),
),
      ],
    ),
  ),
),

Card(
  elevation: 2,
  child: ListTile(
    leading: const Icon(
      Icons.how_to_vote,
      color: Colors.indigo,
    ),
    title: const Text(
      "عدد الآراء",
    ),
    trailing: Text(
      "${data["votesCount"] ?? 0}",
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
FutureBuilder<String>(
  future: UserService.getUserRole(),
  builder: (context, roleSnapshot) {

   

    final opinions =
        data["votes"] as List? ?? [];

    final currentUid =
        UserService.currentUid;

    final alreadyVoted =
        opinions.contains(currentUid);

   
    if (alreadyVoted ||
    data["status"] != "submitted") {
  return const SizedBox();
}

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0057FF),
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(
      vertical: 14,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  icon: const Icon(
    Icons.how_to_vote,
    color: Colors.white,
  ),

  label: const Text(
    "إبداء الرأي",
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),

  onPressed: () async {

    final newOpinions = [
      ...opinions,
      currentUid,
    ];

    final newCount =
        newOpinions.length;

    await FirebaseFirestore.instance
        .collection("health_cases")
        .doc(caseId)
        .update({

      "votes": newOpinions,
      "votesCount": newCount,

      "status": newCount >= 5
          ? Workflow.committeeApproved
          : "submitted",
    });
if (newCount >= 5) {

  await HealthCaseNotificationService
      .notifyPresident(

    title: "📋 حالة جاهزة للبت النهائي",

    body:
        "حصلت الحالة على 5 آراء وتنتظر قرار الرئيس",

    caseId: caseId,
  );
}
    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "✅ تم تسجيل الرأي",
        ),
      ),
    );
  },
),
          
              
      ),
    );
  },
),
Card(
  elevation: 3,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        const Text(
          "الحالة",
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),

          decoration: BoxDecoration(

            color: data["status"] ==
                    "paid"
                ? Colors.green.shade100
                : data["status"] ==
                        "approved"
                    ? Colors.blue.shade100
                    : data["status"] ==
                            "rejected"
                        ? Colors.red.shade100
                        : Colors.orange.shade100,

            borderRadius:
                BorderRadius.circular(20),
          ),

          child: Text(
            statusArabic,

            style: TextStyle(
              fontWeight:
                  FontWeight.bold,

              color: data["status"] ==
                      "paid"
                  ? Colors.green
                  : data["status"] ==
                          "approved"
                      ? Colors.blue
                      : data["status"] ==
                              "rejected"
                          ? Colors.red
                          : Colors.orange,
            ),
          ),
        ),
      ],
    ),
  ),
),


      
             
            ],
          );
        },
      ),
    );
  }

  Widget _item(
    String title,
    dynamic value,
  ) {

    return Card(

      child: ListTile(

        title: Text(title),

        subtitle: Text(
          value?.toString() ?? "",
        ),
      ),
    );
  }
}