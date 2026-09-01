import 'package:flutter/material.dart';

class MineVideosSelectAllNotification extends Notification {
  final bool selectAll;

  MineVideosSelectAllNotification(this.selectAll);

  @override
  String toString() {
    return 'MineVideosSelectAllNotification{isSelectAll: $selectAll}';
  }
}
