import 'package:flutter/services.dart';

class BdaSignal {
  static const MethodChannel _channel = MethodChannel('bda_signal');


  /*
  * 自定义事件
  * eventName：自定义事件名称
  * param：自定义事件相关参数
  * */
  static Future<bool> trackEvent(String eventName, Map<String, dynamic>? param) async {
    try {
      Map<String, dynamic> methodP = {'eventName': eventName};
      if (param != null) {
        methodP['eventProperties'] = param;
      }
      final bool result = await _channel.invokeMethod('trackEvent', methodP);
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return false;
    }
  }

  /*
  * 注册事件
  * param： 事件参数
  * */
  static Future<bool> trackRegister(Map<String, dynamic>? param) async {
    try {
      Map<String, dynamic> methodP = {'eventName': 'register'};
      if (param != null) {
        methodP['eventProperties'] = param;
      }
      final bool result = await _channel.invokeMethod('register', methodP);
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return false;
    }
  }

  /*
  * 付费事件
  * param：事件参数
  * */
  static Future<bool> trackPay(Map<String, dynamic>? param) async {
    try {
      Map<String, dynamic> methodP = {'eventName': 'pay'};
      if (param != null) {
        methodP['eventProperties'] = param;
      }
      final bool result = await _channel.invokeMethod('pay', methodP);
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return false;
    }
  }

  /*
  * 停留事件
  * param：事件参数
  * */
  static Future<bool> trackStayTime(Map<String, dynamic>? param) async {
    try {
      Map<String, dynamic> methodP = {'eventName': 'stayTime'};
      if (param != null) {
        methodP['eventProperties'] = param;
      }
      final bool result = await _channel.invokeMethod('stayTime', methodP);
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return false;
    }
  }

  /*
  * 关键事件
  * param：事件参数
  * */
  static Future<bool> trackGameAddiction(Map<String, dynamic>? param) async {
    try {
      Map<String, dynamic> methodP = {'eventName': 'gameAddiction'};
      if (param != null) {
        methodP['eventProperties'] = param;
      }
      final bool result = await _channel.invokeMethod('gameAddiction', methodP);
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return false;
    }
  }

  /*
  * 获取IDFV
  * */
  static Future<String> idfv() async {
    try {
      Map<String, dynamic> methodP = {'eventName': 'idfv'};

      final String result = await _channel.invokeMethod('idfv', methodP);
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return '';
    }
  }

  /*
  * 获取手机系统启动时间
  * */
  static Future<int> systemBootTime() async {
    try {
      Map<String, dynamic> methodP = {'eventName': 'SystemBootTime'};

      final int result = await _channel.invokeMethod('SystemBootTime', methodP);
      print("手机启动时间=== $result");
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return 0;
    }
  }

  /*
  * 获取app安装时间
  * */
  static Future<String> appInstallTime() async {

    try {
      Map<String, dynamic> methodP = {'eventName': 'AppInstallTime'};

      final String result = await _channel.invokeMethod('AppInstallTime', methodP);

      print("app安装时间=== $result");


      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return "";
    }

  }

  /*
  * 广告token
  * */
  static Future<String> adToken() async {
    try {
      Map<String, dynamic> methodP = {'eventName': 'adToken'};

      final String result = await _channel.invokeMethod('adToken', methodP);
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return '';
    }
  }

  /*
  * 获取bda当前的额外信息
  * */
  static Future<Map<Object?, Object?>> bdaCurrentExtraInfo() async {
    try {
      Map<String, dynamic> methodP = {'eventName': 'getExtraInfo'};

      final Map<Object?, Object?> result = await _channel.invokeMethod('getExtraInfo', methodP);
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return {'': ''};
    }
  }

/*
* 设置bda的额外信息
* */
  static Future<bool> setExtraInfoToBDA(Map<String, dynamic> param) async {
    try {
      Map<String, dynamic> methodP = {'eventName': 'setExtraInfo'};
      methodP['eventProperties'] = param;
      final bool result = await _channel.invokeMethod('setExtraInfo', methodP);
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return false;
    }
  }

  /*
  * 获取设备初始化时间
  * */
  static Future<String> getDeviceInitialTime() async {
    try {
      final String result = await _channel.invokeMethod("deviceInitialTime");
      return result;
    } on PlatformException catch (e) {
      print('Error tracking event: ${e.message}');
      return '';
    }
  }

} 