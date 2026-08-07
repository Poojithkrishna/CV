/// Shared form-field validators, kept as pure functions so they're usable
/// both from [TextFormField.validator] callbacks and from domain-layer
/// use cases (which validate again before hitting the database, since a
/// form is not the only caller of a use case).
class Validators {
  Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String field = 'This field'}) {
    if (value != null && value.length > max) {
      return '$field must be $max characters or fewer';
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return null;
    final num? parsed = num.tryParse(value);
    if (parsed == null) return '$field must be a valid number';
    if (parsed < 0) return '$field cannot be negative';
    return null;
  }

  static String? optionalPercentage(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return null;
    final num? parsed = num.tryParse(value);
    if (parsed == null) return '$field must be a valid number';
    if (parsed < 0 || parsed > 100) return '$field must be between 0 and 100';
    return null;
  }

  /// Combines multiple validators, returning the first non-null error.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final String? error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
