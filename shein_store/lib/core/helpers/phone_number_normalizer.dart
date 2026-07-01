class PhoneNumberNormalizer {
  const PhoneNumberNormalizer._();

  static String normalize(String value) {
    var text = _englishDigits(value.trim());
    text = text.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (text.startsWith('00')) {
      text = '+${text.substring(2)}';
    }
    if (text.startsWith('09') && text.length == 10) {
      return '+218${text.substring(1)}';
    }
    if (text.startsWith('2189') && text.length == 12) {
      return '+$text';
    }
    if (text.startsWith('+2189') && text.length == 13) {
      return text;
    }
    if (text.startsWith('+') && text.length >= 8) {
      return text;
    }
    return text;
  }

  static bool isValid(String value) {
    final normalized = normalize(value);
    return RegExp(r'^\+\d{8,15}$').hasMatch(normalized);
  }

  static String mask(String value) {
    final normalized = normalize(value);
    if (normalized.length <= 8) {
      return normalized;
    }
    final prefix = normalized.substring(0, normalized.length - 7);
    final suffix = normalized.substring(normalized.length - 3);
    return '$prefix****$suffix';
  }

  static String _englishDigits(String value) {
    var output = value;
    for (var index = 0; index < 10; index++) {
      output = output
          .replaceAll(String.fromCharCode(0x0660 + index), '$index')
          .replaceAll(String.fromCharCode(0x06F0 + index), '$index');
    }
    return output;
  }
}
