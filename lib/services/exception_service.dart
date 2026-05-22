import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExceptionService {
  static Future<String> voteException(String caseId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return "❌ غير مسجل";

    final phone = user.phoneNumber;
    if (phone == null) return "❌ لا يوجد رقم";

    final docRef =
        FirebaseFirestore.instance.collection("cases").doc(caseId);

    final snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;

    List votes = data["exceptionVotes"] ?? [];

    if (votes.contains(phone)) {
      return "⚠️ صوتت مسبقاً";
    }

    await docRef.update({
      "exceptionVotes": FieldValue.arrayUnion([phone])
    });

    final updated = await docRef.get();

    await docRef.update({
      "exceptionVotesCount": (updated["exceptionVotes"] ?? []).length
    });

    return "✅ تم التصويت للاستثناء";
  }
}