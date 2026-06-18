import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/health_case_notification_service.dart';

class AddHealthCaseScreen extends StatefulWidget {
  const AddHealthCaseScreen({super.key});

  @override
  State<AddHealthCaseScreen> createState() =>
      _AddHealthCaseScreenState();
}

class _AddHealthCaseScreenState
    extends State<AddHealthCaseScreen> {

  // ================= FORM =================

  final _formKey = GlobalKey<FormState>();

  // ================= CONTROLLERS =================

  final fullNameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final hospitalController =
      TextEditingController();

  // ================= STATE =================

  String healthCaseType = "surgery";

  String treatmentPlace = "mauritania";

  bool hasInsurance = false;

  int suggestedAmount = 50000;

  String procedureType =
      "standard_procedure";

  bool isLoading = false;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _updateProcedure();
  }

  // ================= DISPOSE =================

  @override
  void dispose() {

    fullNameController.dispose();

    phoneController.dispose();

    descriptionController.dispose();

    hospitalController.dispose();

    super.dispose();
  }

  // ================= PHONE =================

  String _normalizePhone(String phone) {

    String cleanPhone =
        phone.trim().replaceAll(" ", "");

    if (!cleanPhone.startsWith("222")) {
      cleanPhone = "222$cleanPhone";
    }

    return cleanPhone;
  }

  // ================= PROCEDURE =================

  void _updateProcedure() {

    int amount = 0;

    String procedure =
        "standard_procedure";

    // 🔴 CAS ASSURÉ
    if (hasInsurance) {

      procedure = "exceptional_case";

      amount = 0;
    }

    // 🌍 CAS ÉTRANGER
    else if (treatmentPlace == "abroad") {

      procedure = "special_donation";

      amount = 0;
    }

    // 🇲🇷 CAS STANDARD
    else {

      switch (healthCaseType) {

        case "surgery":

          amount = 5000;
          break;

        case "hospitalization":

          amount = 3000;
          break;

        case "dialysis":

          amount = 2000;
          break;

        case "chronic":

          procedure =
              "committee_evaluation";

          amount = 0;

          break;

        case "weak_family":

          amount = 20000;

          break;

        default:

          procedure = "exceptional_case";

          amount = 0;
      }
    }

    setState(() {

      suggestedAmount = amount;

      procedureType = procedure;
    });
  }

  // ================= PROCEDURE LABEL =================

  String _procedureLabel() {

    switch (procedureType) {

      case "standard_procedure":
        return "داخل المسطرة";

      case "special_donation":
        return "فتح تبرع خاص / لوحة";

      case "committee_evaluation":
        return "تقييم اللجنة";

      case "exceptional_case":
        return "حالة استثنائية";

      default:
        return "غير محدد";
    }
  }

  // ================= SUBMIT =================

  Future<void> submitHealthCase() async {

    if (isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final user =
          FirebaseAuth.instance.currentUser;

      // 🔐 USER CHECK
      if (user == null) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "يرجى تسجيل الدخول أولاً",
            ),
          ),
        );

        setState(() {
          isLoading = false;
        });

        return;
      }

      // 📱 PHONE NORMALIZATION
      final phone =
          _normalizePhone(phoneController.text);

      // 💾 SAVE FIRESTORE
      final docRef =
    await FirebaseFirestore.instance
        .collection("health_cases")
        .add({

  "reportedBy": user.uid,

  "fullName":
      fullNameController.text.trim(),

  "phone": phone,

  "description":
      descriptionController.text.trim(),

  "healthCaseType":
      healthCaseType,

  "hospitalName":
      hospitalController.text.trim(),

  "treatmentPlace":
      treatmentPlace,

  "hasInsurance":
      hasInsurance,

  "procedureType":
      procedureType,

  "suggestedAmount":
      suggestedAmount,

  "votes": [],

  "votesCount": 0,

  "status": "submitted",

  "createdAt":
      FieldValue.serverTimestamp(),

  "isDeleted": false,
});

await HealthCaseNotificationService
    .notifyCommittee(
  title: "📢 حالة صحية جديدة",
  body:
      "تم الإعلان عن حالة جديدة باسم ${fullNameController.text.trim()}",
  caseId: docRef.id,
);

      // ✅ SUCCESS
      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "✅ تم إرسال الحالة بنجاح",
            ),
          ),
        );

        Navigator.pop(context);
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text("❌ خطأ: $e"),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("إضافة حالة"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [

              // 👤 NAME
              TextFormField(
                controller:
                    fullNameController,

                decoration:
                    const InputDecoration(
                  labelText:
                      "الاسم الكامل",

                  border:
                      OutlineInputBorder(),
                ),

                validator: (value) {

                  if (value == null ||
                      value.trim().isEmpty) {

                    return "أدخل الاسم الكامل";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // 📱 PHONE
              TextFormField(
                controller:
                    phoneController,

                keyboardType:
                    TextInputType.phone,

                decoration:
                    const InputDecoration(
                  labelText:
                      "رقم الهاتف بدون 222",

                  border:
                      OutlineInputBorder(),
                ),

                validator: (value) {

  if (value == null ||
      value.trim().isEmpty) {

    return "أدخل رقم الهاتف";
  }

  final phone =
      value.trim().replaceAll(" ", "");

  if (!RegExp(r'^[234]\d{7}$')
      .hasMatch(phone)) {

    return "رقم هاتف موريتاني غير صحيح";
  }

  return null;
},

               
              ),

              const SizedBox(height: 12),

              // 🏥 CASE TYPE
              DropdownButtonFormField<String>(
                value: healthCaseType,

                decoration:
                    const InputDecoration(
                  labelText:
                      "نوع الحالة",

                  border:
                      OutlineInputBorder(),
                ),

                items: const [

                  DropdownMenuItem(
                    value: "surgery",

                    child: Text(
                      "عملية جراحية داخل الوطن",
                    ),
                  ),

                  DropdownMenuItem(
                    value:
                        "hospitalization",

                    child: Text(
                      "حجز طبي 3 أيام",
                    ),
                  ),

                  DropdownMenuItem(
                    value: "dialysis",

                    child: Text(
                      "تصفية",
                    ),
                  ),

                  DropdownMenuItem(
                    value: "chronic",

                    child: Text(
                      "مرض مزمن / علاج مكلف",
                    ),
                  ),

                  DropdownMenuItem(
                    value: "weak_family",

                    child: Text(
                      "أسرة ضعيفة",
                    ),
                  ),

                  DropdownMenuItem(
                    value: "other",

                    child: Text(
                      "حالة أخرى",
                    ),
                  ),
                ],

                onChanged: (value) {

                  if (value == null) return;

                  healthCaseType = value;

                  _updateProcedure();
                },
              ),

              const SizedBox(height: 12),

              // 🌍 PLACE
              DropdownButtonFormField<String>(
                value: treatmentPlace,

                decoration:
                    const InputDecoration(
                  labelText:
                      "مكان العلاج",

                  border:
                      OutlineInputBorder(),
                ),

                items: const [

                  DropdownMenuItem(
                    value:
                        "mauritania",

                    child: Text(
                      "داخل موريتانيا",
                    ),
                  ),

                  DropdownMenuItem(
                    value: "abroad",

                    child: Text(
                      "مرفوع للخارج",
                    ),
                  ),
                ],

                onChanged: (value) {

                  if (value == null) return;

                  treatmentPlace = value;

                  _updateProcedure();
                },
              ),

              const SizedBox(height: 12),

              // 🛡 INSURANCE
              SwitchListTile(
                value: hasInsurance,

                title: const Text(
                  "هل لديه تأمين صحي؟",
                ),

                onChanged: (value) {

                  hasInsurance = value;

                  _updateProcedure();
                },
              ),

              const SizedBox(height: 12),

              // 🏥 HOSPITAL
              TextFormField(
  controller: hospitalController,

  decoration:
      const InputDecoration(
    labelText: "اسم المستشفى",
    border: OutlineInputBorder(),
  ),

  validator: (value) {

    if (value == null ||
        value.trim().isEmpty) {

      return "يجب إدخال اسم المستشفى";
    }

    return null;
  },
),

              const SizedBox(height: 12),

              // 📝 DESCRIPTION
              TextFormField(
                controller:
                    descriptionController,

                maxLines: 4,

                decoration:
                    const InputDecoration(
                  labelText:
                      "وصف الوضعية",

                  border:
                      OutlineInputBorder(),
                ),

                validator: (value) {

                  if (value == null ||
                      value.trim().isEmpty) {

                    return "أدخل وصف الحالة";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ⚙ PROCEDURE CARD
              Container(
                padding:
                    const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(14),

                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      "تصنيف الحالة: ${_procedureLabel()}",
                    ),

                    const SizedBox(height: 8),

                    Text(

                      suggestedAmount > 0

                          ? "المبلغ المقترح حسب المسطرة: $suggestedAmount أوقية جديدة"

                          : "المبلغ يحدد لاحقاً حسب قرار اللجنة",

                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🚀 SUBMIT
              ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : submitHealthCase,

                style:
                    ElevatedButton.styleFrom(
                  minimumSize:
                      const Size(
                    double.infinity,
                    50,
                  ),
                ),

                child: isLoading

                    ? const SizedBox(
                        width: 22,
                        height: 22,

                        child:
                            CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )

                    : const Text(
                        "إرسال الحالة",
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}