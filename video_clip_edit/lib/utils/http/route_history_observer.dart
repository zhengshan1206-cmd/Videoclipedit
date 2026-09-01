//  description: 路由历史观察者，用于监听路由变化并更新路由历史
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'route_history_manager.dart';

/// 路由历史观察者
/// 监听路由变化并自动更新路由历史记录
class RouteHistoryObserver extends RouteObserver<PageRoute<dynamic>> {
  final RouteHistoryManager _routeManager = RouteHistoryManager.instance;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    // 如果 previousRoute 存在且不在历史记录中，先添加它
    // 这样可以确保在 push 新页面时，上一个页面已经在历史记录中
    if (previousRoute != null) {
      final prevRouteName = _getRouteName(previousRoute);
      if (prevRouteName != null && prevRouteName.isNotEmpty) {
        final history = _routeManager.getRouteHistory();
        // 如果 previousRoute 不在历史记录中，先添加它
        if (!history.contains(prevRouteName)) {
          _routeManager.addRoute(prevRouteName);
        }
      }
    }

    // 然后添加当前路由
    // 使用延迟更新，确保 GetX 路由已经更新
    Future.microtask(() {
      _updateRouteHistory(route);
    });
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      _removeRouteFromHistory(oldRoute);
    }
    if (newRoute != null) {
      _updateRouteHistory(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    // 获取被 pop 的路由名称和 previousRoute 名称
    final poppedRouteName = _getRouteName(route);
    final previousRouteName =
        previousRoute != null ? _getRouteName(previousRoute) : null;

    final history = _routeManager.getRouteHistory();

    // pop 时的逻辑：
    // 1. 被 pop 的路由应该保留在历史记录中（作为 previousRoute），这样 getPreviousRoute() 才能正确返回
    // 2. previousRoute 应该成为新的当前路由（栈顶）
    //
    // 例如：从 /main push 到 /ai_tweets，历史：[/main, /ai_tweets]
    //      pop 后，历史应该是：[/ai_tweets, /main]，这样 getPreviousRoute() 返回 /ai_tweets

    if (previousRouteName != null && previousRouteName.isNotEmpty) {
      // 如果 previousRoute 已经在栈顶，不需要操作
      if (history.isEmpty || history.last != previousRouteName) {
        // previousRoute 不在栈顶，需要将它移到栈顶
        // 如果 previousRoute 在历史记录中，先移除它（避免重复）
        if (history.contains(previousRouteName)) {
          _routeManager.removeRoute(previousRouteName);
        }
        // 将 previousRoute 添加到栈顶（成为新的当前路由）
        _routeManager.addRoute(previousRouteName);
      }
      // 被 pop 的路由保留在历史记录中（如果它在栈顶，现在 previousRoute 在栈顶，所以它变成了 previousRoute）
    } else if (poppedRouteName != null && poppedRouteName.isNotEmpty) {
      // 如果没有 previousRoute，但被 pop 的路由在栈顶，移除它
      if (history.isNotEmpty && history.last == poppedRouteName) {
        _routeManager.removeTopRoute();
      }
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _removeRouteFromHistory(route);
  }

  /// 更新路由历史
  void _updateRouteHistory(Route<dynamic> route) {
    final routeName = _getRouteName(route);
    if (routeName != null && routeName.isNotEmpty) {
      _routeManager.addRoute(routeName);
    }
  }

  /// 获取路由名称
  String? _getRouteName(Route<dynamic> route) {
    // 优先从 RouteSettings 获取路由名称
    if (route.settings.name != null && route.settings.name!.isNotEmpty) {
      return route.settings.name;
    }

    // 如果没有设置名称，尝试从 GetX 获取当前路由
    try {
      final getXRoute = Get.currentRoute;
      if (getXRoute.isNotEmpty && getXRoute != '/') {
        return getXRoute;
      }
    } catch (e) {
      // GetX 未初始化或获取失败，忽略
    }

    // 如果还是没有，尝试从路由的 Widget 中获取（通过检查 Widget 的类型或属性）
    // 注意：这是一个备用方案，可能不够准确
    try {
      final builder = route.settings.arguments;
      // 某些情况下，arguments 可能包含路由信息
      if (builder is Map && builder.containsKey('routeName')) {
        return builder['routeName']?.toString();
      }
    } catch (e) {
      // 忽略错误
    }

    return null;
  }

  /// 从历史记录中移除路由
  void _removeRouteFromHistory(Route<dynamic> route) {
    final routeName = _getRouteName(route);
    if (routeName != null && routeName.isNotEmpty) {
      _routeManager.removeRoute(routeName);
    }
  }
}
