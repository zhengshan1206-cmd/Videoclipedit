// To parse this JSON data, do
//
//     final subtitlesBean = subtitlesBeanFromJson(jsonString);

import 'dart:convert';

SubtitlesBean subtitlesBeanFromJson(String str) =>
    SubtitlesBean.fromJson(json.decode(str));

String subtitlesBeanToJson(SubtitlesBean data) => json.encode(data.toJson());

class SubtitlesBean {
  /// 字幕的原内容
  String wordsOrigin;

  /// 将字幕转中的违禁词加上\$标记的的展示内容
  /// [prohitiedWods] 违禁词列表
  String wordsDisplay({
    List<String>? prohitiedWods,
  }) {
    return wordsOrigin;
    // if (prohitiedWods.isNullOrEmpty) {
    //   return wordsOrigin;
    // }
    // String res = wordsOrigin;
    // prohitiedWods!.sort((s1, s2) => s1.length <= s2.length ? 1 : 0);

    // for (var element in prohitiedWods) {
    //   if (!elementContainsOrInclude(prohitiedWods, element)) {
    //     RegExp regExp = RegExp(element);
    //     res = res.replaceAll(regExp,
    //         "${ForbiddenWordsText.flag}$element${ForbiddenWordsText.flag}");
    //   }
    // }
    // return res;
  }

  elementContainsOrInclude(List<String> soure, String target) {
    for (String element in soure) {
      if (element != target && element.contains(target)) {
        return true;
      }
    }
    return false;
  }

  SubtitlesBean({
    required this.wordsOrigin,
  });

  SubtitlesBean copyWith({
    String? wordsOrigin,
    // String? wordsDisplay,
  }) =>
      SubtitlesBean(
        wordsOrigin: wordsOrigin ?? this.wordsOrigin,
      );

  factory SubtitlesBean.fromJson(Map<String, dynamic> json) => SubtitlesBean(
        wordsOrigin: json["wordsOrigin"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "wordsOrigin": wordsOrigin,
      };
}
