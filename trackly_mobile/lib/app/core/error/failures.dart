class Failure {
  final String? key;
  final String message; // Must be translated

  const Failure({
    this.key,
    this.message = 'failure',
  });
}

class ServerFailure extends Failure {
  ServerFailure({
    super.key,
    String? message,
  }) : super(
         message: message ?? 'serverFailure',
       );
}

class LocalFailure extends Failure {
  LocalFailure({
    super.key,
    String? message,
  }) : super(
         message: message ?? 'localFailure',
       );
}

class NoInternetConnectionFailure extends Failure {
  NoInternetConnectionFailure({
    String? message,
  }) : super(
         message: message ?? 'noInternetConnection',
       );
}

class SupportInformationFailure extends Failure {
  SupportInformationFailure({
    String? message,
  }) : super(
         message: message ?? 'supportInformation',
       );
}

class LocationFailure extends Failure {
  LocationFailure({
    String? message,
  }) : super(
         message: message ?? 'locationFailure',
       );
}
