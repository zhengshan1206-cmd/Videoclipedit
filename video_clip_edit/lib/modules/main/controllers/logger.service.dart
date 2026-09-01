/*
 * @Author: duncy
 * @Date: 2025-12-04 14:47:25
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-02 11:44:12
 * @FilePath: /video_clip_edit/lib/modules/main/controllers/logger.service.dart
 * @Description: 
 */

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../../utils/comon/by_device_info_utils.dart';


class LoggerService {

  static final Dio _dio = Dio()
    // ..options.baseUrl = BuildConfig.instance.environment.domain
    ..options.baseUrl = 'https://inchat.beiyinapp.com'
    ..options.connectTimeout = const Duration(seconds: 10)
    ..options.headers = {
      "Content-Type": "application/json; charset=utf-8",
    };

  static Future<Map<String, dynamic>> sendLog({
    required String tag,
    required String log,
    required String url,
  }) async {
    try {
      final imei = await ByDeviceInfoUtils.deviceInfo();
      // final Response response = await _dio.post(
      //   url,
      //   data: {"uuid": imei.item2, "tag": tag, "log": log},
      // );
      final requestHeaders = {
        'Content-Type': "application/json; charset=utf-8",
      };
      final response = await http.post(
        Uri.parse('https://inchat.beiyinapp.com$url'),
        headers: requestHeaders,
        body: jsonEncode({"uuid": imei.item2, "tag": tag, "log": log}),
      );
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      print("______上报 错误：${e},${e.runtimeType}");
      _sendDioLog(tag: tag, log: log, url: url);
      return {
        "status": -1,
        "message": "未知错误",
      };
    }
  }

  static Future<Map<String, dynamic>> _sendDioLog({
    required String tag,
    required String log,
    required String url,
  }) async {
    try {
      final imei = await ByDeviceInfoUtils.deviceInfo();
      await _dio.post(
        url,
        data: {"uuid": imei.item2, "tag": tag, "log": log},
      );
      return {};
    } catch (e) {
      print("______上报 Dio错误：${e}");
      return {
        "status": -1,
        "message": "未知错误",
      };
    }
  }
}