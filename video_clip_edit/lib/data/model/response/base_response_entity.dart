import 'package:video_clip_edit/core/network/result.dart';

abstract class APIEntity {
  int? status;
  String? message;

  String errorMsg() {
    return message ?? unknownErrorMsg;
  }

  bool isSuccess() {
    return status != null && status == 200;
  }

  bool isSpecialSuccessOne() {
    return status != null && status == 2001;
  }

  bool isSpecialSuccessTwo() {
    return status != null && status == 1002;
  }

  bool isSpecialSuccessThree() {
    return status != null && status == 1000001;
  }

  APIError? get error {
    if (!isSuccess()) {
      return APIError(
        errorMsg(),
        status ?? unknownErrorCode,
      );
    }
    return null;
  }

  static const unknownErrorMsg = '未知错误，请稍后再试';
  static const unknownErrorCode = -888;

  static const conncetErrorMsg = '连接错误，请检查网络设置';
  static const connectErrorCode = -999;

  static APIError get unknownError =>
      APIError(unknownErrorMsg, unknownErrorCode);
}

class BaseEntity<T> extends APIEntity {
  @override
  int? status;
  @override
  String? message;
  T? data;

  BaseEntity({this.status, this.message});

  BaseEntity.fromJson(dynamic json, T Function(dynamic) construction) {
    if (json is Map) {
      status = json['status'];
      message = json['message'];
      final dataMap = json['data'];
      if (isSuccess()) {
        data = construction(dataMap);
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    return data;
  }
}

abstract class BaseData {
  dynamic json;

  BaseData();

  BaseData.fromJson(dynamic json);

  dynamic toJson();
}

class VoidObject extends BaseData {
  VoidObject.fromJson(dynamic json);

  @override
  dynamic toJson() {
    return <String, dynamic>{};
  }
}

class StringDataEntity extends APIEntity {
  @override
  int? status;
  @override
  String? message;
  String? data;

  StringDataEntity({this.status, this.message, this.data});

  StringDataEntity.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    final dataString = json['data'];
    if (isSuccess() && dataString is String) {
      data = dataString;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    data['data'] = data;
    return data;
  }
}
