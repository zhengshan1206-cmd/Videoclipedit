//  description: 路由历史管理器，用于记录和管理路由历史
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/main.dart' show navigatorKey;

/// 路由历史管理器
/// 用于跟踪当前路由和上一个路由，兼容 GetX 和原生 Navigator
class RouteHistoryManager {
  RouteHistoryManager._();

  static final RouteHistoryManager _instance = RouteHistoryManager._();
  static RouteHistoryManager get instance => _instance;

  /// 路由历史栈（最多保留最近10个路由）
  final List<String> _routeHistory = [];
  static const int _maxHistorySize = 10;

  /// 添加路由到历史记录
  /// [forceAdd] 是否强制添加，即使和最后一个路由相同也添加（用于 pop 后的场景）
  void addRoute(String? routeName, {bool forceAdd = false}) {
    if (routeName == null || routeName.isEmpty) {
      return;
    }

    // 如果当前路由和最后一个路由相同，且不是强制添加，则不重复添加
    if (!forceAdd &&
        _routeHistory.isNotEmpty &&
        _routeHistory.last == routeName) {
      return;
    }

    // 如果路由已存在且不是最后一个，先移除它（避免重复）
    if (_routeHistory.contains(routeName) &&
        (_routeHistory.isEmpty || _routeHistory.last != routeName)) {
      _routeHistory.remove(routeName);
    }

    _routeHistory.add(routeName);

    // 限制历史记录大小
    if (_routeHistory.length > _maxHistorySize) {
      _routeHistory.removeAt(0);
    }
  }

  /// 移除路由（当路由被 pop 时）
  /// 从栈顶移除匹配的路由（通常是最后一个）
  void removeRoute(String? routeName) {
    if (routeName == null || routeName.isEmpty) {
      return;
    }

    // 从栈顶开始查找并移除（通常被 pop 的路由在栈顶）
    for (int i = _routeHistory.length - 1; i >= 0; i--) {
      if (_routeHistory[i] == routeName) {
        _routeHistory.removeAt(i);
        break; // 只移除第一个匹配的（从栈顶开始）
      }
    }
  }

  /// 移除栈顶的路由（用于 pop 操作）
  void removeTopRoute() {
    if (_routeHistory.isNotEmpty) {
      _routeHistory.removeLast();
    }
  }

  /// 获取当前路由
  String getCurrentRoute() {
    String? currentRoute;

    // 优先使用 GetX 的路由（最准确）
    try {
      final getXRoute = Get.currentRoute;
      if (getXRoute.isNotEmpty && getXRoute != '/') {
        currentRoute = getXRoute;
        // 如果获取到了路由但不在历史记录中，添加到历史记录
        if (_routeHistory.isEmpty || _routeHistory.last != currentRoute) {
          addRoute(currentRoute);
        }
        return currentRoute;
      }
    } catch (e) {
      // GetX 未初始化或获取失败，继续尝试其他方式
    }

    // 如果 GetX 没有获取到，尝试从 Navigator 获取（实时获取）
    try {
      final navigatorState = navigatorKey.currentState;
      if (navigatorState != null) {
        final route = ModalRoute.of(navigatorState.context);
        if (route != null &&
            route.settings.name != null &&
            route.settings.name!.isNotEmpty) {
          currentRoute = route.settings.name!;
          // 如果获取到了路由但不在历史记录中，添加到历史记录
          if (_routeHistory.isEmpty || _routeHistory.last != currentRoute) {
            addRoute(currentRoute);
          }
          return currentRoute;
        }
      }
    } catch (e) {
      // 获取失败
    }

    // 最后尝试从历史记录中获取（作为备用）
    if (_routeHistory.isNotEmpty) {
      currentRoute = _routeHistory.last;
    }

    return currentRoute ?? '';
  }

  /// 获取上一个路由
  String getPreviousRoute() {
    // 从历史记录中获取
    if (_routeHistory.length >= 2) {
      return _routeHistory[_routeHistory.length - 2];
    }

    // 尝试从 Navigator 获取路由栈（主要依赖历史记录）
    // 注意：Navigator 无法直接获取上一个路由，所以主要依赖历史记录

    return '';
  }

  /// 清空历史记录
  void clear() {
    _routeHistory.clear();
  }

  /// 获取路由历史（用于调试）
  List<String> getRouteHistory() {
    return List.unmodifiable(_routeHistory);
  }
}
