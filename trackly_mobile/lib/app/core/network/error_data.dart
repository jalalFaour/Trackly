class AppError {
  final String propertyName;
  final List<String> errorMessages;

  AppError({
    required this.propertyName,
    required this.errorMessages,
  });

  factory AppError.fromJson(
    Map<String, dynamic> json,
  ) =>
      AppError(
        propertyName: json['propertyName'],
        errorMessages: List<String>.from(
          json['errorMessages'],
        ),
      );
}
