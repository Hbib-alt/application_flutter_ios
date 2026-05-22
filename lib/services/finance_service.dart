import '../utils/constants.dart';

class FinanceService {

  static bool canPay(double balance, Map data) {

    // ❤️ الأسر المتعففة
    if (data["caseType"] == "social_monthly") {
      return balance > 0;
    }

    // 🟢 الحالة العادية
    if (balance > MIN_BALANCE) return true;

    // 🗳 استثناء 5 أصوات
    if ((data["exceptionVotesCount"] ?? 0) >= 5) return true;

    return false;
  }

  static double getPayableAmount(double balance, Map data) {

    // ❤️ الأسر المتعففة
    if (data["caseType"] == "social_monthly") {
      return balance >= SOCIAL_MONTHLY_AMOUNT
          ? SOCIAL_MONTHLY_AMOUNT
          : balance;
    }

    return data["amountEligible"] ?? 0;
  }
}