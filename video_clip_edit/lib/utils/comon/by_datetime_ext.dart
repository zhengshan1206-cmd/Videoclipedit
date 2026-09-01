import 'package:intl/intl.dart';

extension ByDatetimeExt on DateTime {
  formattedTime({
    String? format,
  }) {
    return DateFormat(format ?? "yyyy-MM-dd hh:mm:ss").format(this);
  }
}

extension ByDoubleExt on String {
  amountConversion() {
    return (double.parse(this) / 100).toStringAsFixed(2);
  }
}
