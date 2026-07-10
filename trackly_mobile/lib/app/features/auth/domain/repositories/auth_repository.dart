import 'package:dartz/dartz.dart';
import 'package:trackly/app/core/data/data_state.dart';
import 'package:trackly/app/core/error/failures.dart';

import '../entities/auth_login.dart';
import '../entities/auth_login_data.dart';
import '../entities/auth_register_data.dart';

abstract class AuthRepository {
  Future<Either<Failure, DataState<Unit>>> register({
    required AuthRegisterData data,
  });

  Future<Either<Failure, DataState<AuthLogin>>> login({
    required AuthLoginData data,
  });
}
