import 'exceptions.dart';
import 'failures.dart';

extension ServerExceptionMappers on ServerException {
  ServerFailure get toFailure => ServerFailure(
        key: key,
        message: message,
      );
}

extension LocalExceptionMappers on LocalException {
  LocalFailure get toFailure => LocalFailure(
        key: key,
        message: message,
      );
}
