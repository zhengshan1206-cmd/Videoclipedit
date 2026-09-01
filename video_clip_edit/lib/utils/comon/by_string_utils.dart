class ByStringUtils {
  /// num类型转String类型整数
  static String toIntStr(num? value) {
    return (value ?? 0).toInt().toString();
  }

  static String subStringWithMaxLength(
    String origin,
    int maxLen,
    String seporator,
  ) {
    if (origin.length > 15) {
      String subStr = origin.substring(0, 15);
      if (subStr.endsWith(seporator)) {
        subStr = subStr.substring(0, subStr.length - 1);
      }
      return "${subStr}...";
    }
    return origin;
  }

  /// String类型转num类型，为空转成0
  static num toNum(String? value) {
    return num.tryParse(value ?? '') ?? 0;
    // if (value == null || value.length <= 0) {
    //   return 0;
    // } else {
    //   return num.parse(value);
    // }
  }

  static String trimWithPhoneNum(String contents) {
    RegExp phoneRegex = RegExp(r'\d+');
    Iterable<RegExpMatch> matches = phoneRegex.allMatches(contents);
    String res = "";
    for (final match in matches) {
      res += (match.group(0) ?? "");
    }
    return res;
  }

  static (String partIntegeral, String partFractional) componentsWithDouble(
      String doubleStr) {
    if (doubleStr.isEmpty) return ("", "");
    if (!doubleStr.contains(".")) {
      return (doubleStr, "");
    }
    List<String> results = doubleStr.split(".");
    return (results[0], results[1]);
  }

  static bool isPort(String source) {
    final comps = source.split(":");
    bool isProt = false;
    if (comps.length <= 1) {
      isProt = true;
    } else {
      isProt = int.parse(comps[0]) < int.parse(comps[1]);
    }
    return isProt;
  }
}
