import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../utils/app_log_utils.dart';
import '../values/constants/app_constants.dart';
import 'api_caller.dart';

abstract class AppDioUtils {
  static Future<Response<dynamic>> downloadWithChunks({
    required Dio dio,
    required String url,
    required String pathToSave,
    required CancelToken cancelToken,
    required Options options,
    ProgressCallback? onReceiveProgress,
    int maxChunkCount = AppConstants.maxChunksCount,
    int maxConcurrentChunks = 3,
    int targetChunkSizeBytes = 2 * 1024 * 1024,
    int minChunkSizeBytes = 256 * 1024,
    bool useEtagGuards = true,
  }) async {
    final partDir = Directory(_partsDirPath(pathToSave: pathToSave));
    await partDir.create(recursive: true);

    final metaFile = File(_metaPath(pathToSave: pathToSave));

    final meta = await _readMeta(metaFile: metaFile);

    final head = await _safeHead(
      dio: dio,
      url: url,
      cancelToken: cancelToken,
      options: options,
    );

    final headTotal = _tryParseInt(
      head?.headers.value(Headers.contentLengthHeader),
    );

    final headEtag = head?.headers.value(HttpHeaders.etagHeader);
    final acceptRanges = head?.headers.value(HttpHeaders.acceptRangesHeader);

    final canRangeFromHead =
        acceptRanges != null && acceptRanges.toLowerCase().contains('bytes');

    final totalLength = headTotal;
    final effectiveEtag = headEtag ?? meta?.etag;

    final canRange = canRangeFromHead && totalLength != null && totalLength > 0;

    if (!canRange) {
      await _cleanupPartsDir(partDir: partDir);

      return dio.download(
        url,
        pathToSave,
        cancelToken: cancelToken,
        options: options,
        onReceiveProgress: onReceiveProgress,
        deleteOnError: false,
      );
    }

    if (useEtagGuards) {
      final isSameFile =
          meta == null || (effectiveEtag != null && meta.etag == effectiveEtag);

      if (!isSameFile) {
        await _cleanupPartsDir(partDir: partDir);

        await _writeMeta(
          metaFile: metaFile,
          meta: _DownloadMeta(
            url: url,
            etag: effectiveEtag,
            total: totalLength,
          ),
        );
      } else if (meta == null) {
        await _writeMeta(
          metaFile: metaFile,
          meta: _DownloadMeta(
            url: url,
            etag: effectiveEtag,
            total: totalLength,
          ),
        );
      }
    } else {
      if (meta == null) {
        await _writeMeta(
          metaFile: metaFile,
          meta: _DownloadMeta(
            url: url,
            etag: effectiveEtag,
            total: totalLength,
          ),
        );
      }
    }

    final chunkPlan = _buildChunkPlan(
      totalLength: totalLength,
      maxChunkCount: maxChunkCount,
      targetChunkSizeBytes: targetChunkSizeBytes,
      minChunkSizeBytes: minChunkSizeBytes,
    );

    AppLogUtils.infoLog(message: '📦 Total file size: $totalLength bytes');
    AppLogUtils.infoLog(message: '📦 Number of chunks: ${chunkPlan.length}');

    for (var i = 0; i < chunkPlan.length; i++) {
      AppLogUtils.infoLog(
        message:
            '📦 Chunk $i: '
            '${chunkPlan[i].start}-'
            '${chunkPlan[i].endInclusive} '
            '(${chunkPlan[i].length} bytes)',
      );
    }

    final semaphore = _AsyncSemaphore(maxConcurrentChunks);

    final progresses = List<int>.filled(chunkPlan.length, 0);

    for (var i = 0; i < chunkPlan.length; i++) {
      final partFile = File(_partPath(pathToSave: pathToSave, no: i));

      if (await partFile.exists()) {
        final len = await partFile.length();
        final expected = chunkPlan[i].length;

        progresses[i] = len.clamp(0, expected);

        AppLogUtils.infoLog(
          message:
              '📦 Chunk $i already has $len bytes '
              '(expected: $expected)',
        );
      }
    }

    void reportProgress() {
      if (onReceiveProgress == null) {
        return;
      }

      final sum = progresses.fold<int>(0, (a, b) => a + b);

      onReceiveProgress(sum, totalLength);
    }

    reportProgress();

    final futures = <Future<void>>[];

    for (var i = 0; i < chunkPlan.length; i++) {
      final chunkNo = i;
      final chunk = chunkPlan[chunkNo];

      futures.add(() async {
        await semaphore.acquire();

        try {
          final partFile = File(_partPath(pathToSave: pathToSave, no: chunkNo));

          final existing = await partFile.exists()
              ? await partFile.length()
              : 0;

          final expected = chunk.length;

          if (existing >= expected) {
            progresses[chunkNo] = expected;
            reportProgress();

            AppLogUtils.infoLog(message: '✅ Chunk $chunkNo already complete');
            return;
          }

          final start = chunk.start + existing;
          final endInclusive = chunk.endInclusive;

          final rangeHeader = 'bytes=$start-$endInclusive';

          AppLogUtils.infoLog(
            message: '🔽 Downloading chunk $chunkNo: $rangeHeader',
          );

          final headers = <String, dynamic>{
            ...?options.headers,
            HttpHeaders.rangeHeader: rangeHeader,
            if (useEtagGuards && effectiveEtag != null)
              HttpHeaders.ifRangeHeader: effectiveEtag,
          };

          final response = await dio.get<ResponseBody>(
            url,
            options: options.copyWith(
              headers: headers,
              responseType: options.responseType ?? ResponseType.stream,
              receiveTimeout:
                  options.receiveTimeout ?? apiCallerFilesReceiveTimeout,
            ),
            cancelToken: cancelToken,
            onReceiveProgress: (count, _) {
              progresses[chunkNo] = (existing + count).clamp(0, expected);
              reportProgress();
            },
          );

          AppLogUtils.infoLog(
            message: '📥 Chunk $chunkNo response: ${response.statusCode}',
          );

          final ok = response.statusCode == 206 || response.statusCode == 200;

          if (!ok || response.data == null) {
            throw DioException.badResponse(
              statusCode: response.statusCode ?? -1,
              requestOptions: response.requestOptions,
              response: response,
            );
          }

          final shouldAppend = response.statusCode == 206 && existing > 0;

          if (!shouldAppend && existing > 0) {
            AppLogUtils.infoLog(
              message:
                  '⚠️ Server sent full content for chunk '
                  '$chunkNo, restarting',
            );

            if (await partFile.exists()) {
              await partFile.delete();
            }

            progresses[chunkNo] = 0;
          }

          await partFile.create(recursive: true);

          final raf = await partFile.open(
            mode: shouldAppend ? FileMode.append : FileMode.writeOnly,
          );

          try {
            await for (final dataChunk in response.data!.stream) {
              await raf.writeFrom(dataChunk);
            }

            await raf.flush();
          } catch (e) {
            AppLogUtils.infoLog(message: '❌ Error writing chunk $chunkNo: $e');
            rethrow;
          } finally {
            await raf.close();
          }

          final finalLen = await partFile.length();

          progresses[chunkNo] = finalLen.clamp(0, expected);

          reportProgress();

          AppLogUtils.infoLog(
            message:
                '✅ Chunk $chunkNo complete: '
                '$finalLen bytes (expected: $expected)',
          );

          if (chunkNo == chunkPlan.length - 1) {
            if (finalLen > expected) {
              throw StateError(
                'Last chunk $chunkNo is larger than expected: '
                'expected $expected bytes, got $finalLen bytes',
              );
            }
          } else {
            if (finalLen != expected) {
              throw StateError(
                'Chunk $chunkNo has incorrect size: '
                'expected $expected bytes, got $finalLen bytes',
              );
            }
          }
        } finally {
          semaphore.release();
        }
      }());
    }

    await Future.wait(futures);

    AppLogUtils.infoLog(message: '🔗 Merging ${chunkPlan.length} chunks...');

    var totalDownloaded = 0;

    for (var i = 0; i < chunkPlan.length; i++) {
      final partFile = File(_partPath(pathToSave: pathToSave, no: i));

      if (!await partFile.exists()) {
        throw StateError('Missing part file $i before merge');
      }

      final partSize = await partFile.length();

      totalDownloaded += partSize;

      AppLogUtils.infoLog(message: '📦 Part $i: $partSize bytes');
    }

    AppLogUtils.infoLog(
      message:
          '📦 Total downloaded: $totalDownloaded bytes '
          '(expected: $totalLength)',
    );

    if (totalDownloaded != totalLength) {
      throw StateError(
        'Total downloaded size mismatch: '
        'expected $totalLength bytes, got $totalDownloaded bytes',
      );
    }

    await _mergePartsSafelyWithRAF(
      pathToSave: pathToSave,
      partsCount: chunkPlan.length,
    );

    final finalFile = File(pathToSave);

    if (!await finalFile.exists()) {
      throw StateError('Final file was not created');
    }

    final finalSize = await finalFile.length();

    AppLogUtils.infoLog(message: '✅ Final file size: $finalSize bytes');

    if (finalSize != totalLength) {
      throw StateError(
        'Final file size mismatch: '
        'expected $totalLength bytes, got $finalSize bytes',
      );
    }

    await _cleanupPartsDir(partDir: partDir);

    if (await metaFile.exists()) {
      await metaFile.delete();
    }

    AppLogUtils.infoLog(message: '🎉 Download complete: $pathToSave');

    return Response<dynamic>(
      requestOptions: RequestOptions(path: url),
      statusCode: 200,
      data: pathToSave,
    );
  }

  static List<_Chunk> _buildChunkPlan({
    required int totalLength,
    required int maxChunkCount,
    required int targetChunkSizeBytes,
    required int minChunkSizeBytes,
  }) {
    if (totalLength <= 0) {
      return <_Chunk>[];
    }

    final safeMinChunkSize = minChunkSizeBytes <= 0
        ? 1
        : minChunkSizeBytes > totalLength
        ? totalLength
        : minChunkSizeBytes;

    final safeTargetChunkSize = targetChunkSizeBytes <= 0
        ? safeMinChunkSize
        : targetChunkSizeBytes < safeMinChunkSize
        ? safeMinChunkSize
        : targetChunkSizeBytes;

    final suggestedCount = (totalLength / safeTargetChunkSize).ceil();

    final chunksCount = suggestedCount.clamp(1, maxChunkCount);

    final computedChunkSize = (totalLength / chunksCount).ceil();

    final chunkSize = computedChunkSize < safeMinChunkSize
        ? safeMinChunkSize
        : computedChunkSize;

    final chunks = <_Chunk>[];

    var start = 0;

    while (start < totalLength) {
      final endExclusive = (start + chunkSize) > totalLength
          ? totalLength
          : (start + chunkSize);

      chunks.add(_Chunk(start: start, endInclusive: endExclusive - 1));

      start = endExclusive;
    }

    return chunks;
  }

  static Future<Response<dynamic>?> _safeHead({
    required Dio dio,
    required String url,
    required CancelToken cancelToken,
    Options? options,
  }) async {
    try {
      return await dio.head<dynamic>(
        url,
        cancelToken: cancelToken,
        options: options,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> _mergePartsSafelyWithRAF({
    required String pathToSave,
    required int partsCount,
  }) async {
    final mergePath = _mergePath(pathToSave: pathToSave);

    final mergeFile = await File(mergePath).create(recursive: true);

    final raf = await mergeFile.open(mode: FileMode.writeOnly);

    try {
      for (var i = 0; i < partsCount; i++) {
        final partFile = File(_partPath(pathToSave: pathToSave, no: i));

        if (!await partFile.exists()) {
          throw StateError('Missing part $i during merge');
        }

        final bytes = await partFile.readAsBytes();

        await raf.writeFrom(bytes);

        AppLogUtils.infoLog(
          message: '✅ Merged part $i (${bytes.length} bytes)',
        );
      }

      await raf.flush();
    } catch (e) {
      AppLogUtils.infoLog(message: '❌ Error merging parts: $e');

      if (await mergeFile.exists()) {
        await mergeFile.delete();
      }

      rethrow;
    } finally {
      await raf.close();
    }

    final finalFile = File(pathToSave);

    if (await finalFile.exists()) {
      await finalFile.delete();
    }

    await mergeFile.rename(pathToSave);
  }

  static Future<void> _cleanupPartsDir({required Directory partDir}) async {
    if (!await partDir.exists()) {
      return;
    }

    await partDir.delete(recursive: true);
  }

  static int? _tryParseInt(String? v) {
    if (v == null) {
      return null;
    }

    return int.tryParse(v);
  }

  static String _partsDirPath({required String pathToSave}) {
    return '$pathToSave.parts';
  }

  static String _partPath({required String pathToSave, required int no}) {
    return '${_partsDirPath(pathToSave: pathToSave)}/part_$no';
  }

  static String _mergePath({required String pathToSave}) {
    return '$pathToSave.merge';
  }

  static String _metaPath({required String pathToSave}) {
    return '${_partsDirPath(pathToSave: pathToSave)}/meta.json';
  }

  static Future<_DownloadMeta?> _readMeta({required File metaFile}) async {
    if (!await metaFile.exists()) {
      return null;
    }

    try {
      final raw = await metaFile.readAsString();
      final map = jsonDecode(raw) as Map<String, dynamic>;

      return _DownloadMeta.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeMeta({
    required File metaFile,
    required _DownloadMeta meta,
  }) async {
    await metaFile.create(recursive: true);

    await metaFile.writeAsString(jsonEncode(meta.toJson()), flush: true);
  }
}

final class _Chunk {
  const _Chunk({required this.start, required this.endInclusive});

  final int start;
  final int endInclusive;

  int get length => (endInclusive - start) + 1;
}

final class _DownloadMeta {
  const _DownloadMeta({
    required this.url,
    required this.etag,
    required this.total,
  });

  factory _DownloadMeta.fromJson(Map<String, dynamic> json) {
    return _DownloadMeta(
      url: json['url'] as String,
      etag: json['etag'] as String?,
      total: json['total'] as int,
    );
  }

  final String url;
  final String? etag;
  final int total;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'url': url, 'etag': etag, 'total': total};
  }
}

final class _AsyncSemaphore {
  _AsyncSemaphore(int max) : _available = max;

  int _available;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  Future<void> acquire() {
    if (_available > 0) {
      _available--;
      return Future.value();
    }

    final c = Completer<void>();
    _waiters.addLast(c);
    return c.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
      return;
    }

    _available++;
  }
}
