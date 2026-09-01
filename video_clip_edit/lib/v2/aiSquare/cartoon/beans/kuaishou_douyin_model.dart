import 'package:get/get_core/src/get_main.dart';

///快手 抖音数据
class KShouDYinModel {
  final ItemModel? itemModel;
  final Compr? compr;
  KShouDYinModel({this.itemModel, this.compr});

  factory KShouDYinModel.fromJson({required dynamic json}) {
    if (json == null) {
      return KShouDYinModel();
    }
    return KShouDYinModel(
      itemModel: ItemModel.fromJson(json: json["items"]),
      compr: Compr.fromJson(json: json["com_pr"]),
    );
  }
}

class ItemModel {
  final int? jumpToPosition;
  final List<dynamic>? jumpTo;
  final int? isRead;
  final int? id;
  ItemModel({this.jumpToPosition, this.jumpTo, this.isRead, this.id});
  factory ItemModel.fromJson({required dynamic json}) {
    if (json == null) {
      return ItemModel();
    }
    return ItemModel(
      jumpToPosition: json["jump_to_position"],
      jumpTo: json["jump_to"],
      isRead: json["is_read"],
      id: json["id"],
    );
  }
}

class Compr {
  final int? type;
  final String? header;
  final List<Question>? questions;

  Compr({this.type, this.header, this.questions});

  factory Compr.fromJson({dynamic json}) {
    int? typeEx;
    if (json == null) {
      return Compr();
    }
    if (json is! Map) {
      // 接口偶发返回非对象（如空字符串/数组等），这里兜底避免解析崩溃
      return Compr();
    }

    if (json["type"] != null) {
      if (json["type"] is String) {
        typeEx = int.tryParse(json["type"]) ?? typeEx;
      }
      if (json["type"] is int) {
        typeEx = json["type"];
      }
    }

    Get.log("抖音快手的数据===> ${json["type"] is int}");

    return Compr(
      type: typeEx,
      header: json["header"]?.toString(),
      questions: Question.getList(json: json["questions"]),
    );
  }

  static List<Compr> getList({required dynamic json}) {
    List dataList = [];
    List<Compr> comprList = [];
    if (json != null) {
      dataList = json;
      if (dataList.isNotEmpty) {
        for (var e in dataList) {
          comprList.add(Compr.fromJson(json: e));
        }
      }
    }
    return comprList;
  }
}

class Question {
  final String? ask;
  final String? answer;

  Question({this.ask, this.answer});

  factory Question.fromJson({dynamic json}) {
    if (json == null || json is! Map) {
      return Question();
    }
    return Question(
      ask: json["ask"]?.toString(),
      answer: json["answer"]?.toString(),
    );
  }

  static List<Question> getList({required dynamic json}) {
    final List<Question> questionList = [];
    if (json == null) return questionList;

    // 兼容接口返回 List 或 Map（如 {"0": {...}, "1": {...}}）
    final List dataList =
        json is List ? json : (json is Map ? json.values.toList() : const []);

    for (final e in dataList) {
      if (e is Map) {
        questionList.add(Question.fromJson(json: e));
      }
    }
    return questionList;
  }
}
