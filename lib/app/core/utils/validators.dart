class Validators {
  static String? required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Required' : null;

  static String? minLength(String? value, int min) =>
      (value == null || value.length < min) ? 'Min $min characters' : null;
}
