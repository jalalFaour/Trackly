import '../error/failures.dart';
import '../network_response/network_response.dart';

abstract class DataState<T> {
  final T data;
  final Paging? paging;
  final Failure? failure;
  final String key;
  final String? message;

  const DataState._({
    required this.data,
    this.paging,
    this.failure,
    required this.key,
    required this.message,
  });

  factory DataState.done({
    required T data,
    Paging? paging,
    Failure? failure,
    required String key,
    required String? message,
  }) = DoneState<T>;

  factory DataState.loading({
    required T data,
  }) = LoadingState<T>;
}

class DoneState<T> extends DataState<T> {
  const DoneState({
    required super.data,
    super.paging,
    super.failure,
    required super.key,
    required super.message,
  }) : super._();
}

class LoadingState<T> extends DataState<T> {
  const LoadingState({
    required super.data,
    super.key = '',
    super.message,
  }) : super._();
}
