class AppText {
  static String title(String lang) {
    return lang == "fr" ? "Tableau de bord" : "لوحة التحكم";
  }

  static String addCase(String lang) {
    return lang == "fr" ? "Ajouter cas" : "إضافة حالة";
  }

  static String stats(String lang) {
    return lang == "fr" ? "Statistiques" : "إحصائيات";
  }

  static String pdf(String lang) {
    return lang == "fr" ? "Rapport PDF" : "تقرير PDF";
  }

  static String pending(String lang) {
    return lang == "fr" ? "En attente" : "قيد الانتظار";
  }

  static String approved(String lang) {
    return lang == "fr" ? "Accepté" : "تمت الموافقة";
  }

  static String rejected(String lang) {
    return lang == "fr" ? "Refusé" : "مرفوضة";
  }
}