// ignore_for_file: overridden_fields

import 'base_response_entity.dart';

class ListDataEntity<T extends BaseData> extends APIEntity {
  @override
  int? status;
  @override
  String? message;
  ListData<T>? data;

  ListDataEntity({this.status, this.message});

  ListDataEntity.fromJson(dynamic json, T Function(dynamic) construction) {
    if (json is Map) {
      status = json['status'];
      message = json['message'];
      final dataMap = json['data'];
      if (isSuccess() && dataMap is Map<String, dynamic>) {
        data = ListData.fromJson(dataMap, construction);
      }
    }
  }
}

class ListData<T extends BaseData> extends BaseData {
  int? total;
  List<T> items = const [];
  int? size;
  int? page;
  int? cpage;

  ListData({
    this.total,
    this.items = const [],
    this.size,
    this.page,
    this.cpage,
  });

  @override
  ListData.fromJson(
      Map<String, dynamic> json, T Function(dynamic) construction) {
    total = json['total'];
    final elements = json['items'];
    if (elements is List) {
      items = elements.map((element) => construction(element)).toList();
    }
    size = json['size'];
    page = json['page'];
    cpage = json['cpage'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['items'] = items.map((element) => element.toJson()).toList();
    data['size'] = size;
    data['page'] = page;
    data['cpage'] = cpage;
    return data;
  }
}
