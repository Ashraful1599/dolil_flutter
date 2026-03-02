class PhoneNormalizer {
  static String normalize(String input) {
    final trimmed = input.trim();
    if (trimmed.contains('@')) return trimmed; // It's an email, don't modify
    if (trimmed.startsWith('+')) return trimmed; // Already has country code
    return '+88$trimmed';
  }
}
