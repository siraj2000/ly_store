class Validators {
  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? emailOrPhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email or phone is required';
    if (text.contains('@') && text.contains('.')) return null;
    if (text.length >= 8) return null;
    return 'Enter a valid email or phone';
  }

  static String? password(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 6) return 'Use at least 6 characters';
    return null;
  }
}
