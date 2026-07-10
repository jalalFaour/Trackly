import '../network_response/network_response.dart';

abstract class RemoteDataState<T> {
  final T data;
  final Paging? pagedList;
  final String key;
  final String? message;

  const RemoteDataState._({
    required this.data,
    this.pagedList,
    required this.key,
    required this.message,
  });

  factory RemoteDataState.done({
    required T data,
    required String key,
    Paging? pagedList,
    required String? message,
  }) = RemoteDoneState<T>;
}

class RemoteDoneState<T> extends RemoteDataState<T> {
  const RemoteDoneState({
    required super.data,
    super.pagedList,
    required super.key,
    required super.message,
  }) : super._();
}
