///  description:  异常处理
library;

// ignore_for_file: constant_identifier_names
import 'dart:io';
import 'package:dio/dio.dart';

class ExceptionHandle {
  static const int success = 200; // 请求成功的状态码
  static const int success_not_content = 204;
  static const int not_modified = 304;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int not_found = 404;

  static const int net_error = 1000;
  static const int parse_error = 1001;
  static const int socket_error = 1002;
  static const int http_error = 1003;
  static const int connect_timeout_error = 1004;
  static const int send_timeout_error = 1005;
  static const int receive_timeout_error = 1006;
  static const int cancel_error = 1007;
  static const int unknown_error = 9999;

  static bool isSuccessStatus(dynamic status) {
    if (status == null) return false;
    if (status == success) return true;
    return status.toString() == '200';
  }

  static int? parseStatusCode(dynamic status) {
    if (status == null) return null;
    if (status is int) return status;
    return int.tryParse(status.toString());
  }

  static final Map<int, NetError> _errorMap = <int, NetError>{
    net_error: NetError(net_error, '网络异常，请检查你的网络！'),
    parse_error: NetError(parse_error, '数据解析错误！'),
    socket_error: NetError(socket_error, '网络异常，请检查你的网络！'),
    http_error: NetError(http_error, '服务器异常，请稍后重试！'),
    unauthorized: NetError(http_error, '服务器异常，请稍后重试！'),
    not_found: NetError(http_error, '服务器异常，请稍后重试！'),
    connect_timeout_error: NetError(connect_timeout_error, '连接超时！'),
    send_timeout_error: NetError(send_timeout_error, '请求超时！'),
    receive_timeout_error: NetError(receive_timeout_error, '响应超时！'),
    cancel_error: NetError(cancel_error, '取消请求'),
    unknown_error: NetError(unknown_error, '未知异常'),
  };

  static NetError handleException(dynamic error) {
    if (error is DioException) {
      if (!_errorMap.keys.contains(error.type.dioErrorCode)) {
        return _handleException(error.error);
      } else {
        return _errorMap[error.type.dioErrorCode]!;
      }
    } else {
      return _handleException(error);
    }
  }

  static NetError _handleException(dynamic error) {
    int errorCode = unknown_error;
    if (error is SocketException) {
      errorCode = socket_error;
    }
    if (error is HttpException) {
      errorCode = http_error;
    }
    if (error is FormatException) {
      errorCode = parse_error;
    }
    return _errorMap[errorCode]!;
  }
}

class NetError {
  int code;
  String msg;

  NetError(this.code, this.msg);
}

class DioErrorCode {
  String msg;
  int code;

  DioErrorCode(this.msg, this.code);
}

extension DioErrorCodeExtension on DioExceptionType {
  int get dioErrorCode {
    switch (this) {
      case DioExceptionType.connectionTimeout:
        return ExceptionHandle.connect_timeout_error;
      case DioExceptionType.sendTimeout:
        return ExceptionHandle.send_timeout_error;
      case DioExceptionType.receiveTimeout:
        return ExceptionHandle.receive_timeout_error;
      case DioExceptionType.badCertificate:
        return ExceptionHandle.unauthorized;
      case DioExceptionType.badResponse:
        return ExceptionHandle.parse_error;
      case DioExceptionType.cancel:
        return ExceptionHandle.cancel_error;
      case DioExceptionType.connectionError:
        return ExceptionHandle.net_error;
      case DioExceptionType.unknown:
        return ExceptionHandle.unknown_error;
    }
  }
}

extension DioErrorTypeExtension on DioExceptionType {
  int get errorCode => [
    ExceptionHandle.connect_timeout_error,
    ExceptionHandle.send_timeout_error,
    ExceptionHandle.receive_timeout_error,
    0,
    ExceptionHandle.cancel_error,
    0,
    0,
    0,
    0,
    0,
    0,
  ][index];
}
