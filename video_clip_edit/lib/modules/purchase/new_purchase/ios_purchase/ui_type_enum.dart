import 'package:flutter/material.dart';

enum PurchaseUiType {
  Blue(value: 1, color: Color(0xff5B4BF7)),
  Red(value: 2, color: Color(0xffFF387A));

  final int value;
  final Color color;

  const PurchaseUiType({required this.value, required this.color});
}
