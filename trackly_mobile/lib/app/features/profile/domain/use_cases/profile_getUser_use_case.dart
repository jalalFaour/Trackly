import 'package:dartz/dartz.dart';
import 'package:trackly/app/core/data/data_state.dart';
import 'package:trackly/app/core/error/failures.dart';
import 'package:trackly/app/core/use_case/use_case.dart';

import '../entities/profile_user.dart';
import '../repositories/profile_repository.dart';

class ProfileGetuserUseCase extends UseCase<DataState<ProfileUser>, Params> {
  final ProfileRepository _repository;

  ProfileGetuserUseCase({
    required ProfileRepository repository,
  }) : _repository = repository;

  @override
  Future<Either<Failure, DataState<ProfileUser>>> call(Params params) {
    return _repository.getProfile();
  }
}

class Params {
  Params();
}
