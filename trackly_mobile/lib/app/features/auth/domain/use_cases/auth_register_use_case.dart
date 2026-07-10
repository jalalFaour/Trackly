import 'package:dartz/dartz.dart';
import 'package:trackly/app/core/data/data_state.dart';
import 'package:trackly/app/core/error/failures.dart';
import 'package:trackly/app/core/use_case/use_case.dart';

import '../entities/auth_register_data.dart';
import '../repositories/auth_repository.dart';

class AuthRegisterUseCase extends UseCase<DataState<Unit>, Params> {
  final AuthRepository _repository;

  AuthRegisterUseCase({required AuthRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, DataState<Unit>>> call(Params params) {
    return _repository.register(data: params.data);
  }
}

class Params {
  final AuthRegisterData data;

  Params({required this.data});
}
