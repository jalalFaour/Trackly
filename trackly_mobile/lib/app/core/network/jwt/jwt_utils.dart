import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

abstract class JwtUtils {
  static DateTime? tryExtractExpirationDate({
    required String token,
  }) {
    try {
      final jwt = JWT.decode(
        token,
      );

      final exp = jwt.payload['exp'] as int?;

      if (exp == null) {
        return null;
        throw Exception(
          'Token does not contain expiration claim',
        );
      }

      return DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
        isUtc: true,
      );
    } catch (exception) {
      return null;
      throw Exception(
        'Failed to extract expiration date: $exception',
      );
    }
  }

  static bool isTokenExpired({
    required String token,
  }) {
    try {
      final expirationDate = tryExtractExpirationDate(
        token: token,
      );

      if (expirationDate == null) {
        return true;
      }

      final nowWithSkew = DateTime.now().toUtc().add(
            _getSkewBuffer(),
          );

      return nowWithSkew.isAfter(
        expirationDate,
      );
    } catch (exception) {
      return true;
    }
  }

  static Duration _getSkewBuffer() => const Duration(
        seconds: 30,
      );
}
