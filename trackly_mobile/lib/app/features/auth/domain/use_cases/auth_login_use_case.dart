import 'package:dartz/dartz.dart';
import 'package:trackly/app/core/data/data_state.dart';
import 'package:trackly/app/core/error/failures.dart';
import 'package:trackly/app/core/use_case/use_case.dart';

import '../entities/auth_login.dart';
import '../entities/auth_login_data.dart';
import '../repositories/auth_repository.dart';

class AuthLoginUseCase extends UseCase<DataState<AuthLogin>, Params> {
  final AuthRepository _repository;

  AuthLoginUseCase({required AuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, DataState<AuthLogin>>> call(Params params) {
    return _repository.login(data: params.data);
  }
}

class Params {
  final AuthLoginData data;

  Params({required this.data});
}
