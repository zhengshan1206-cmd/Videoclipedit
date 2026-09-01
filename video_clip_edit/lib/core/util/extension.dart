extension MapExtension on Map<String, dynamic> {
  void setIfNotNull({required dynamic value, required String key}) {
    if (value != null) {
      this[key] = value;
    }
  }

  Map<String, String> convertMap(){
    return Map.fromEntries(
        entries
            .where((entry) => entry.value != null)
            .map((entry) => MapEntry(entry.key, entry.value.toString()))
    );
  }
}

extension OptionalEmptyExpression on String? {
  bool isEmptyString() {
    return isEmpty(this);
  }

  bool isNotEmptyString() {
    return isNotEmpty(this);
  }

  static bool isEmpty(String? text) {
    if (text == null) {
      return true;
    }
    return text.isEmpty;
  }

  static bool isNotEmpty(String? text) {
    if (text == null) {
      return false;
    }
    return text.isNotEmpty;
  }
}
