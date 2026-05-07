class PhoneUtils {
  const PhoneUtils._();

  /// Sanitizes a phone number for use with the `tel:` scheme.
  ///
  /// Keeps digits plus `*` and `#`, and an optional leading `+`.
  static String sanitize(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return '';

    final hasPlus = raw.startsWith('+');
    final cleaned = raw.replaceAll(RegExp(r'[^0-9*#]'), '');
    if (cleaned.isEmpty) return '';
    return hasPlus ? '+$cleaned' : cleaned;
  }

  static bool isProbablyValid(String input) {
    final s = sanitize(input);
    // Very lightweight validation: at least 3 digits.
    final digits = s.startsWith('+') ? s.substring(1) : s;
    final onlyDigits = digits.replaceAll(RegExp(r'[^0-9]'), '');
    return onlyDigits.length >= 3;
  }
}
