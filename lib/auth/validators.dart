final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address.';
  if (!_emailPattern.hasMatch(email)) return 'That email doesn\'t look right.';
  return null;
}

String? validateName(String? value) =>
    (value?.trim() ?? '').isEmpty ? 'Tell us what to call you.' : null;

String? validateSignInPassword(String? value) =>
    (value ?? '').isEmpty ? 'Enter your password.' : null;

String? validateNewPassword(String? value) =>
    (value ?? '').length < 8 ? 'Use at least 8 characters.' : null;

/// "kayeen.campana@mail.com" → "Kayeen".
String nameFromEmail(String email) {
  final first = email.trim().split('@').first.split(RegExp(r'[._\-+]')).first;
  if (first.isEmpty) return 'Wayfarer';
  return first[0].toUpperCase() + first.substring(1).toLowerCase();
}
