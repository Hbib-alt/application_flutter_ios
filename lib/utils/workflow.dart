class Workflow {
  static const submitted = "submitted";
  static const underReview = "under_review";
  static const committeeApproved = "committee_approved";
  static const approved = "approved";
  static const specialDonation = "special_donation";
  static const discretionarySupport = "discretionary_support";
  static const waitingPayment = "waiting_payment";
  static const paid = "paid";
  static const rejected = "rejected";

  static String label(String status) {
    switch (status) {
      case submitted:
        return "قيد الدراسة";
      case underReview:
        return "تحت المراجعة";
      case committeeApproved:
        return "موافقة اللجنة";
      case approved:
        return "مقبولة";
      case specialDonation:
        return "تبرع خاص";
      case discretionarySupport:
        return "دعم استثنائي";
      case waitingPayment:
        return "في انتظار الدفع";
      case paid:
        return "تم الدفع";
      case rejected:
        return "مرفوضة";
      default:
        return status;
    }
  }

  static bool needsPayment(String status) {
    return status == approved || status == discretionarySupport;
  }
}