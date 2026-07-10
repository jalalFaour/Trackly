extension StringExtensions on String {}

extension StringNullableExtensions on String? {
  bool get isNullOrEmpty => this == null || this?.isEmpty == true;
}
