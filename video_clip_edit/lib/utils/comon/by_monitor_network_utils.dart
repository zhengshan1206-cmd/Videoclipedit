///  description:  网络监测
library;

// ignore_for_file: body_might_complete_normally_nullable, avoid_print

import 'package:connectivity_plus/connectivity_plus.dart';

class ByMonitorNetworkUtils {
  /// 是否有网
  static Future<bool> isNetwork() async {
    var result = await Connectivity().checkConnectivity();
    final list = result is List<ConnectivityResult>
        ? result as List<ConnectivityResult>
        : <ConnectivityResult>[result as ConnectivityResult];
    if (list.isEmpty) return false;
    return list.first != ConnectivityResult.none;
  }

  /// 获取网络状态：0 无网络，1 手机，2 wifi
  static Future<int> getNetworkStatus() async {
    var result = await Connectivity().checkConnectivity();
    final list = result is List<ConnectivityResult>
        ? result as List<ConnectivityResult>
        : <ConnectivityResult>[result as ConnectivityResult];
    if (list.isEmpty) return 0;
    final connectivityResult = list.first;
    if (connectivityResult == ConnectivityResult.mobile) {
      // 网络类型为移动网络
      return 1;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // 网络类型为WIFI
      return 2;
    } else {
      return 0;
    }
  }

  static String? monitorNetwork() {
    Connectivity().onConnectivityChanged.listen((event) {
      print(event);
    });
  }

  /// 定义一个异步生成器
  static Stream<ConnectivityResult> connectChangeListener() async* {
    final Connectivity connectivity = Connectivity();
    await for (final list in connectivity.onConnectivityChanged) {
      final iterable = list is Iterable<ConnectivityResult>
          ? list
          : <ConnectivityResult>[list as ConnectivityResult];
      for (final result in iterable) {
        yield result;
      }
    }
  }
}
