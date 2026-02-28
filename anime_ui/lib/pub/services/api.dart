import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'realtime_ws.dart';

/// Base URL for the backend API.
/// Override at build time: `flutter run --dart-define=API_BASE_URL=https://example.com/api/v1`
const _kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3737/api/v1',
);

/// Server origin used for resolving relative file URLs.
/// Override at build time: `flutter run --dart-define=SERVER_ORIGIN=https://example.com`
const kServerOrigin = String.fromEnvironment(
  'SERVER_ORIGIN',
  defaultValue: 'http://localhost:3737',
);

/// If [url] is a relative path (starts with `/`), prepend the server origin.
String resolveFileUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return '$kServerOrigin$url';
}

String? _token;

String? get authToken => _token;

void setAuthToken(String? token) {
  _token = token;
  realtimeWS.setToken(token);
}

final dio = Dio(
  BaseOptions(
    baseUrl: _kBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 120),
    headers: {'Content-Type': 'application/json'},
  ),
)..interceptors.addAll([_AuthInterceptor(), if (kDebugMode) _LogInterceptor()]);

/// Extracts `data` field from the unified backend response `{"code":0,"message":"ok","data":...}`.
/// Throws [ApiException] when code != 0 or HTTP status indicates failure.
T extractData<T>(Response response) {
  final body = response.data;
  if (body is Map<String, dynamic>) {
    final code = body['code'] as int? ?? -1;
    if (code != 0) {
      throw ApiException(code, body['message'] as String? ?? 'Unknown error');
    }
    return body['data'] as T;
  }
  throw ApiException(-1, 'Unexpected response format');
}

/// Type-safe list extraction — eliminates `List<dynamic>` and `as Map` casts.
///
/// ```dart
/// final shots = extractDataList(resp, StoryboardShot.fromJson);
/// ```
List<T> extractDataList<T>(
  Response response,
  T Function(Map<String, dynamic>) fromJson,
) {
  final raw = extractData<List<dynamic>>(response);
  return raw.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}

/// Type-safe single object extraction.
///
/// ```dart
/// final project = extractDataObject(resp, Project.fromJson);
/// ```
T extractDataObject<T>(
  Response response,
  T Function(Map<String, dynamic>) fromJson,
) {
  final raw = extractData<Map<String, dynamic>>(response);
  return fromJson(raw);
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null && _token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    if (status == 401) {
      _token = null;
    }
    if (status == 423) {
      final body = err.response?.data;
      final msg = (body is Map<String, dynamic>)
          ? body['message'] as String? ?? '该阶段已锁定，无法执行此操作'
          : '该阶段已锁定，无法执行此操作';
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: err.type,
          error: PhaseLockedException(msg),
        ),
      );
      return;
    }
    handler.next(err);
  }
}

/// Thrown when the backend returns 423 (phase locked).
class PhaseLockedException implements Exception {
  PhaseLockedException(this.message);
  final String message;

  @override
  String toString() => 'PhaseLockedException: $message';
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '✖ ${err.response?.statusCode} ${err.requestOptions.uri} ${err.message}',
    );
    handler.next(err);
  }
}

class ApiException implements Exception {
  ApiException(this.code, this.message);
  final int code;
  final String message;

  @override
  String toString() => 'ApiException($code): $message';
}
