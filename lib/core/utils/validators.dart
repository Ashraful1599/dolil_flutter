class Validators {
  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
    if (!re.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.length < min) return 'Minimum $min characters';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    final clean = value.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (clean.length < 10) return 'Enter a valid phone number';
    return null;
  }
}
