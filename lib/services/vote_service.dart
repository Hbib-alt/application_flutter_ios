import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoteService {
  static Future<String> vote(String caseId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return "❌ غير مسجل";

    final phone = user.phoneNumber;
    if (phone == null) return "❌ لا يوجد رقم";

    final docRef =
        FirebaseFirestore.instance.collection("cases").doc(caseId);

    final snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;

    List votes = data["votes"] ?? [];

    if (votes.contains(phone)) {
      return "⚠️ صوتت مسبقاً";
    }

    await docRef.update({
      "votes": FieldValue.arrayUnion([phone])
    });

    final updated = await docRef.get();

    await docRef.update({
      "votesCount": (updated["votes"] ?? []).length
    });

    return "✅ تم التصويت";
  }
}