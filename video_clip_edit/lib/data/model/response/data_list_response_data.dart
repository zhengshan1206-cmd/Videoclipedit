// ignore_for_file: overridden_fields

import 'base_response_entity.dart';

class ListEntity<T extends BaseData> extends APIEntity {
  @override
  int? status;
  @override
  String? message;
  List<T>? data;

  ListEntity({this.status, this.message});

  ListEntity.fromListJson(dynamic json, T Function(dynamic) construction) {
    if (json is Map) {
      status = json['status'];
      message = json['message'];
      final list = json['data'];
      if (isSuccess() && list is List) {
        data = list.map((element) => construction(element)).toList();
      }
    }
  }
}
