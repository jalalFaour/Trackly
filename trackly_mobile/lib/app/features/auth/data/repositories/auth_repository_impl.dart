import 'package:dartz/dartz.dart';
import 'package:trackly/app/core/data/data_state.dart';
import 'package:trackly/app/core/error/exception_mappers.dart';
import 'package:trackly/app/core/error/exceptions.dart';
import 'package:trackly/app/core/error/failures.dart';
import 'package:trackly/app/core/utils/app_log_utils.dart';
import 'package:trackly/app/core/utils/app_network_utils.dart';
import 'package:trackly/app/features/auth/domain/entities/mappers/auth_login_mappers.dart';

import '../../domain/entities/auth_login.dart';
import '../../domain/entities/auth_login_data.dart';
import '../../domain/entities/auth_register_data.dart';
import '../../domain/entities/mappers/auth_login_data_mappers.dart';
import '../../domain/entities/mappers/auth_register_data_mappers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_local_data_source.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, DataState<Unit>>> register({
    required AuthRegisterData data,
  }) async {
    try {
      final isConnected = await AppNetworkUtilsImpl.instance.isConnected;
      if (!isConnected) {
        return Left(NoInternetConnectionFailure());
      }

      final remoteDataState = await remoteDataSource.register(data: data.toDto);

      return Right(
        DataState.done(
          data: unit,
          paging: remoteDataState?.pagedList,
          key: remoteDataState?.key ?? '',
          message: remoteDataState?.message,
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

  @override
  Future<Either<Failure, DataState<AuthLogin>>> login({
    required AuthLoginData data,
  }) async {
    String? serverMessage;

    try {
      final isConnected = await AppNetworkUtilsImpl.instance.isConnected;
      if (!isConnected) {
        return Left(NoInternetConnectionFailure());
      }

      final remoteDataState = await remoteDataSource.login(data: data.toDto);
      serverMessage = remoteDataState?.message;

      return Right(
        DataState.done(
          data: remoteDataState!.data.toDomain,
          paging: remoteDataState.pagedList,
          key: remoteDataState.key,
          message: remoteDataState.message,
        ),
      );
    } on LocalException catch (exception) {
      return Left(
        exception.toFailure,
      );
    } on ServerException catch (exception) {
      return Left(
        exception.toFailure,
      );
    } catch (exception) {
      AppLogUtils.errorLog(
        exception: exception,
      );

      return Left(
        Failure(
          message: exception.toString(),
        ),
      );
    }
  }
}
