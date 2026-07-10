import 'package:dartz/dartz.dart';
import 'package:trackly/app/core/data/data_state.dart';
import 'package:trackly/app/core/error/exception_mappers.dart';
import 'package:trackly/app/core/error/exceptions.dart';
import 'package:trackly/app/core/error/failures.dart';
import 'package:trackly/app/core/utils/app_log_utils.dart';
import 'package:trackly/app/core/utils/app_network_utils.dart';
import 'package:trackly/app/features/profile/domain/entities/mappers/profile_user_mappers.dart';
import 'package:trackly/app/features/profile/domain/entities/profile_user.dart';

import '../../domain/repositories/profile_repository.dart';
import '../data_sources/profile_local_data_source.dart';
import '../data_sources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, DataState<ProfileUser>>> getProfile() async {
    try {
      final isConnected = await AppNetworkUtilsImpl.instance.isConnected;
      if (!isConnected) {
        return Left(NoInternetConnectionFailure());
      }

      final remoteDataState = await remoteDataSource.getProfile();

      return Right(
        DataState.done(
          data: remoteDataState!.data.toDomain,
          paging: remoteDataState.pagedList,
          key: remoteDataState.key ?? '',
          message: remoteDataState.message,
        ),
      );
    } on LocalException catch (exception) {
      return Left(exception.toFailure);
    } on ServerException catch (exception) {
      return Left(exception.toFailure);
    } catch (exception) {
      AppLogUtils.errorLog(exception: exception);

      return Left(Failure(message: exception.toString()));
    }
  }
}
