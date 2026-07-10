import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

const networkResponseRequiredKeys = [
  'data',
  'key',
  'message',
];

class NetworkResponse<T> {
  final bool isSuccess;
  final String key;
  final String message;
  final Paging? paging;
  final T? data;
  final List<T>? dataList;

  NetworkResponse({
    required this.isSuccess,
    required this.key,
    required this.message,
    required this.paging,
    required this.data,
    required this.dataList,
  });

  static NetworkResponse<T> fromJson<T>(
    Map<String, dynamic> json, [
    T Function(Map<String, dynamic> json)? fromJsonT,
  ]) => NetworkResponse(
    isSuccess: json['isSuccess'],
    key: json['key'] ?? '',
    message: json['message'] ?? '',
    paging: json['paging'] == null
        ? null
        : Paging.fromJson(
            json['paging'],
          ),
    data: _getData<T>(
      json,
      fromJsonT,
    ),
    dataList: _getDataList<T>(
      json,
      fromJsonT,
    ),
  );

  static T? _getData<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json)? fromJsonT,
  ) {
    if (json['data'] == null) {
      return null;
    }

    if (fromJsonT == null) {
      return json['data'] as T;
    }

    if (json['data'] is Map) {
      return fromJsonT(
        json['data'],
      );
    }

    if (json['data'] is String) {
      return json['data'];
    }

    return null;
  }

  static List<T>? _getDataList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json)? fromJsonT,
  ) {
    if (fromJsonT == null) {
      return null;
    }

    if (json['dataList'] == null) {
      return null;
    }

    if (json['dataList'] is List) {
      return (json['dataList'] as List)
          .map(
            (element) => fromJsonT(
              element,
            ),
          )
          .toList();
    }

    return null;
  }
}

class Paging {
  final int totalRecords;
  final int pageSize;
  final int pageNumber;
  final int firstPage;
  final int lastPage;
  final int previousPage;
  final int nextPage;
  final int totalPages;
  final int firstItem;
  final int lastItem;
  final bool withPaging;

  Paging({
    required this.totalRecords,
    required this.pageSize,
    required this.pageNumber,
    required this.firstPage,
    required this.lastPage,
    required this.previousPage,
    required this.nextPage,
    required this.totalPages,
    required this.firstItem,
    required this.lastItem,
    required this.withPaging,
  });

  factory Paging.defaultObj() => Paging(
    totalRecords: 0,
    pageSize:
        kIsWeb ||
            Platform.isWindows ||
            Platform.isMacOS ||
            Platform.isLinux ||
            Platform.isFuchsia
        ? 16
        : 12,
    pageNumber: 1,
    firstPage: -1,
    lastPage: -1,
    previousPage: -1,
    nextPage: -1,
    totalPages: -1,
    firstItem: -1,
    lastItem: -1,
    withPaging: true,
  );

  Paging copyWith({
    int? pageSize,
    int? pageNumber,
    int? nextPage,
    int? totalRecords,
    bool? withPaging,
  }) => Paging(
    totalRecords: totalRecords ?? this.totalRecords,
    pageSize: pageSize ?? this.pageSize,
    pageNumber: pageNumber ?? this.pageNumber,
    firstPage: firstPage,
    lastPage: lastPage,
    previousPage: previousPage,
    nextPage: nextPage ?? this.nextPage,
    totalPages: totalPages,
    firstItem: firstItem,
    lastItem: lastItem,
    withPaging: withPaging ?? this.withPaging,
  );

  factory Paging.fromJson(
    Map<String, dynamic> json,
  ) => Paging(
    totalRecords: json['totalRecords'],
    pageSize: json['pageSize'],
    pageNumber: json['pageNumber'],
    firstPage: json['firstPage'],
    lastPage: json['lastPage'],
    previousPage: json['previousPage'],
    nextPage: json['nextPage'],
    totalPages: json['totalPages'],
    firstItem: json['firstItem'],
    lastItem: json['lastItem'],
    withPaging: json['withPaging'],
  );

  Map<String, dynamic> toJson() => {
    'totalRecords': totalRecords,
    'pageSize': pageSize,
    'pageNumber': pageNumber,
    'firstPage': firstPage,
    'lastPage': lastPage,
    'previousPage': previousPage,
    'nextPage': nextPage,
    'totalPages': totalPages,
    'firstItem': firstItem,
    'lastItem': lastItem,
    'withPaging': withPaging,
  };

  @override
  String toString() => jsonEncode(
    toJson(),
  );

  int get defaultPageSizeBasedOnPlatform {
    if (kIsWeb) {
      return 16;
    } else if (Platform.isAndroid) {
      return 8;
    } else if (Platform.isIOS) {
      return 8;
    } else if (Platform.isWindows) {
      return 16;
    } else if (Platform.isMacOS) {
      return 16;
    } else if (Platform.isLinux) {
      return 16;
    } else if (Platform.isFuchsia) {
      return 16;
    } else {
      return 16;
    }
  }
}
