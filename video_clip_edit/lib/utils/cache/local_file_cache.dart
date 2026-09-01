/*
 * @Author: cold-x
 * @Date: 2025-05-15 16:05:27
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-05-16 09:23:23
 * @FilePath: /video_clip_edit/lib/utils/cache/local_file_cache.dart
 * @Description: 数据本地化模块(shared_preferences)
 */



import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheKeys {
  CacheKeys._();
  
  //版本检查
  static const versionCheck = 'version_check'; 
}

class LocalCacheManager {
  // 保存数据
  static Future<void> saveJsonData(String cacheKey, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final value = json.encode(data);
    if (value.isNotEmpty) {
      bool result = await prefs.setString(cacheKey, value);
      if (result) {
        print('~~~~~$cacheKey数据保存成功');
      } else {
        print('~~~~~$cacheKey数据保存失败');
      }
    }
  }

  // 读取数据
  static Future<String> readJsonData(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();

    // 读取值，提供默认值以防止返回null
    final String jsonData = prefs.getString(cacheKey) ?? '';
    return jsonData;
  }

  // 删除数据
  static Future<void> removeJsonData(String cacheKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (cacheKey.isEmpty) {
      return;
    }
    // 删除指定的键
    await prefs.remove(cacheKey);
  }

  // 清除所有数据
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

