// ignore_for_file: camel_case_extensions

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/forbidden_words_text.dart';

const List<String> specialCharacters = ["null", "NULL", "Null"];

extension ByMediaQueryExtension on BuildContext {
  MediaQueryData get byMediaQuery => MediaQuery.of(this);

  Size get bySize => byMediaQuery.size;

  double get byScreenWidth => bySize.width;

  double get byScreenHeight => bySize.height;

  double get byScale => byMediaQuery.devicePixelRatio;

  // double get byTextScaleFactor => byMediaQuery.textScaleFactor;

  double get byNavigationBarHeight => byMediaQuery.padding.top + kToolbarHeight;

  double get byTopSafeHeight => byMediaQuery.padding.top;

  double get byBottomSafeHeight => byMediaQuery.padding.bottom;
}

extension byStringExtension on String? {
  /// String 空安全处理
  String get byNullSafe => this ?? '';

  /// String类型转num类型，为空转成0
  num get byToNum => num.tryParse(this ?? '') ?? 0;
}

extension byDecodeExt on String {
  dynamic prettyDecode() {
    // 去除转义字符
    String unescapedJsonString =
        replaceAll(r'\"', '"').replaceAll(r"\'", "").replaceAll(r'\\', "\\");
    // 将字符串转换为 JSON
    return json.decode(unescapedJsonString);
  }

  String withoutSpecialCharacter() {
    String res = this;
    for (var e in specialCharacters) {
      res = res.replaceAll(e, "");
    }
    return res;
  }
}

extension ByProhibitedExt on String {
  String get withoutProhibitedTag {
    return replaceAll(ForbiddenWordsText.flag, "");
  }

  String getFirstLetters() {
    return PinyinHelper.getShortPinyin(this);
  }
}

extension byNumExtension on num? {
  /// num 空安全处理
  String get byNullSafe => this?.toString() ?? '';

  /// num类型转String类型整数
  String get byToIntStr => (this ?? 0).toInt().toString();

  /// num类型转int类型
  int get byToInt => (this ?? 0).toInt();
}

extension byIntExtension on int? {
  /// int 空安全处理
  String get byNullSafe => this?.toString() ?? '';

  /// int类型转String类型整数
  String get byToIntStr => (this ?? 0).toString();
}

extension byNullListExtension<T> on List<T>? {
  /// List 空安全处理
  List<T> get byNullSafe => this ?? [];

  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

extension byNullMapExtension<K, V> on Map<K, V>? {
  /// Map 空安全处理
  Map<K, V> get byNullSafe => this ?? {};

  bool get byIsNullOrEmpty => this == null || this!.isEmpty;
}

extension byNullBoolExtension on bool? {
  /// bool 空安全处理
  bool get byNullSafe => this ?? false;
}
