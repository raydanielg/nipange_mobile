/// Pure validation utils — testable without a backend.
abstract final class Validators {
  /// TZ phone → E.164. Accepts +255…, 255…, 0XXX → +255.
  static String? normalizePhone(String raw) {
    var p = raw.trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (p.startsWith('00')) p = '+${p.substring(2)}';
    if (p.startsWith('0')) p = '+255${p.substring(1)}';
    if (!p.startsWith('+')) p = '+$p';
    return RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(p) ? p : null;
  }

  /// Age in years with correct birthday boundary handling.
  static int age(DateTime dob, [DateTime? at]) {
    final now = at ?? DateTime.now();
    var a = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) a--;
    return a;
  }

  static bool isAdult(DateTime dob, [DateTime? at]) => age(dob, at) >= 18;

  /// Backend rule: min 12 chars.
  static String? passwordError(String p) => p.length < 12 ? 'min_12' : null;
}
