import 'dart:async';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';

class BYRefresh {
  static EasyRefresh instance({
    Key? key,
    required Widget child,
    bool hasMore = true,
    bool hasBefore = true,
    Axis? triggerAxis = Axis.vertical,
    FutureOr Function()? onRefresh,
    FutureOr Function()? onLoad,
    EasyRefreshController? controller,
    ScrollController? scrollController,
  }) {
    return EasyRefresh(
      key: key,
      onRefresh: hasBefore ? onRefresh : null,
      onLoad: hasMore ? onLoad : null,
      triggerAxis: triggerAxis,
      controller: controller,
      scrollController: scrollController,
      child: child,
    );
  }
}
