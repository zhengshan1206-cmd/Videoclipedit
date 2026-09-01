class Result<T, E extends Error> {
  T? responseData;
  E? error;

  Result._(this.responseData, this.error);

  factory Result.succss(T data) {
    return Result._(data, null);
  }

  factory Result.failure(
    E error, {
    T? responseData,
  }) {
    return Result._(responseData, error);
  }

  bool get isSuccess => error == null;
  bool get isFailure => !isSuccess;
  //暂时这么判断
  bool get isTimeout => responseData == null && error != null;
}

class APIError implements Error {
  final String message;

  /// The status code of the request that failed, if any.
  final int code;

  /// {@macro request_failure}
  APIError(this.message, this.code);

  @override
  String toString() {
    return 'RequestError{message: $message, statusCode: $code}';
  }

  @override
  StackTrace? get stackTrace => null;
}
