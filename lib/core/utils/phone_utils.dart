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

  /// Normalizes a phone number for duplicate detection.
  ///
  /// Rules:
  /// - removes spaces/dashes/extra symbols (keeps digits only)
  /// - removes common country code prefix like +91 (India) when present
  /// - if number is longer than 10 digits, uses the last 10 digits
  static String normalizeForDuplicate(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return '';

    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';

    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.startsWith('91') && digits.length >= 12) {
      digits = digits.substring(2);
    }
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }

    return digits;
  }
}
