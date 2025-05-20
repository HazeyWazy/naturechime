// Validates an email address
String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return 'Email cannot be empty';
  }
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(email)) {
    return 'Enter a valid email address';
  }
  return null;
}

// Validates a password
String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return 'Password cannot be empty';
  }
  if (password.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}

// Validates a non-empty input
String? validateNonEmpty(String? value, String fieldName) {
  if (value == null || value.isEmpty) {
    return '$fieldName cannot be empty';
  }
  return null;
}
