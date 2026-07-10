import 'package:dartz/dartz.dart';
import 'package:trackly/app/core/data/data_state.dart';
import 'package:trackly/app/core/error/failures.dart';

import '../entities/profile_user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, DataState<ProfileUser>>> getProfile();
}
