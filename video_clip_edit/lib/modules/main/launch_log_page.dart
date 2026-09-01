import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_clip_edit/modules/main/controllers/launch_error_controller.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_device_info_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class LaunchLogPage extends StatefulWidget {
  const LaunchLogPage({super.key});

  @override
  State<LaunchLogPage> createState() => _LaunchLogPageState();
}

class _LaunchLogPageState extends State<LaunchLogPage> {
  @override
  void initState() {
    super.initState();
    _loadErrorInfo();
  }

  /// 加载错误信息
  Future<void> _loadErrorInfo() async {
    final controller = Get.find<LaunchErrorController>();
    // 如果 errorInfo 为空，自动加载
    final c = controller as dynamic;
    if (c.errorInfo.value.isEmpty) {
      try {
        // 获取设备信息
        final Map deviceInfo = await ByDeviceInfoUtils.getUserDiviceInfo();

        // 从 LaunchProvider 获取启动接口的请求结果
        final provider = Provider.of<LaunchProvider>(context, listen: false);
        final launchResult = provider.lastLaunchResult;
        final errorCode = provider.lastLaunchErrorCode;
        final errorMsg = provider.lastLaunchErrorMsg;

        // 组合信息
        Map<String, dynamic> combinedInfo = {
          "deviceInfo": deviceInfo,
          "launchRequest": {
            "result": launchResult ?? "",
            "error":
                (errorCode != null || (errorMsg != null && errorMsg.isNotEmpty))
                    ? {
                        "code": errorCode ?? "",
                        "msg": errorMsg ?? "",
                      }
                    : "",
          },
        };

        c.errorInfo.value = combinedInfo;
      } catch (e) {
        // 加载失败，保持空状态
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LaunchErrorController>();
    final c = controller as dynamic;

    return Scaffold(
      backgroundColor: ByColorUtil.WhiteColor,
      body: Stack(
        children: [
          // 顶部背景图片
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Image.asset(
              "assets/v2/launch/launch_error_top_bg.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          // 关闭按钮
          Positioned(
            left: 0,
            top: 0,
            child: SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.back();
                },
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  padding: EdgeInsets.all(16.w),
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/home/icon_back.png",
                    width: 16.w,
                    height: 16.w,
                  ),
                ),
              ),
            ),
          ),
          // 内容区域
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 240.h),
                  // 中间内容区域 - 显示 errorInfo
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      child: Obx(() {
                        if (c.errorInfo.value.isEmpty) {
                          return Center(
                            child: ByWidgetsUtil.commonText(
                              text: "暂无错误信息",
                              fontSize: 14.sp,
                              textColor:
                                  ByColorUtil.CommonTextColor.withOpacity(0.5),
                            ),
                          );
                        }

                        try {
                          // 格式化 JSON 显示
                          final formattedJson =
                              const JsonEncoder.withIndent('  ')
                                  .convert(c.errorInfo.value);

                          return SingleChildScrollView(
                            padding: EdgeInsets.all(8.w),
                            child: SelectableText(
                              formattedJson,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: ByColorUtil.CommonTextColor,
                                fontFamily: 'monospace',
                                height: 1.5,
                              ),
                            ),
                          );
                        } catch (e) {
                          return Center(
                            child: ByWidgetsUtil.commonText(
                              text: "错误信息格式异常: $e",
                              fontSize: 14.sp,
                              textColor:
                                  ByColorUtil.CommonTextColor.withOpacity(0.5),
                            ),
                          );
                        }
                      }),
                    ),
                  ),

                  // 底部按钮区域
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    child: Row(
                      children: [
                        // 下载按钮
                        Expanded(
                          child: ByWidgetsUtil.commonBtn(
                            title: "下载",
                            textColor:
                                ByColorUtil.CommonTextColor.withOpacity(0.6),
                            bgColor: ByColorUtil.CommonPageBgColor,
                            borderRadius: 8.w,
                            fontSize: 16.sp,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            onClick: () async {
                              await _downloadErrorInfo(controller);
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // 复制信息按钮
                        Expanded(
                          child: ByWidgetsUtil.commonBtn(
                            title: "复制信息",
                            textColor: ByColorUtil.WhiteColor,
                            bgColor: ByColorUtil.LoginBtnBgColor,
                            borderRadius: 8.w,
                            fontSize: 16.sp,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            onClick: () async {
                              await _copyErrorInfo(controller);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 下载错误信息为 txt 文件
  Future<void> _downloadErrorInfo(LaunchErrorController controller) async {
    final c = controller as dynamic;
    try {
      if (c.errorInfo.value.isEmpty) {
        BotToast.showText(text: "暂无错误信息可下载");
        return;
      }

      // 格式化 JSON
      final formattedJson =
          const JsonEncoder.withIndent('  ').convert(c.errorInfo.value);

      // 获取临时目录
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = "error_log_$timestamp.txt";
      final filePath = "${directory.path}/$fileName";

      // 写入文件
      final file = File(filePath);
      await file.writeAsString(formattedJson);

      // 验证文件是否存在
      if (!await file.exists()) {
        BotToast.showText(text: "文件创建失败");
        return;
      }

      // 分享文件（不传 text 参数，避免在某些平台上覆盖文件分享）
      final xFile = XFile(filePath, mimeType: 'text/plain');
      await Share.shareXFiles([xFile], subject: "错误日志");

      BotToast.showText(text: "文件已保存");
    } catch (e) {
      BotToast.showText(text: "下载失败: $e");
    }
  }

  /// 复制错误信息到剪贴板
  Future<void> _copyErrorInfo(LaunchErrorController controller) async {
    final c = controller as dynamic;
    try {
      if (c.errorInfo.value.isEmpty) {
        BotToast.showText(text: "暂无错误信息可复制");
        return;
      }

      // 格式化 JSON
      final formattedJson =
          const JsonEncoder.withIndent('  ').convert(c.errorInfo.value);

      // 复制到剪贴板
      await Clipboard.setData(ClipboardData(text: formattedJson));
      BotToast.showText(text: "复制成功");
    } catch (e) {
      BotToast.showText(text: "复制失败: $e");
    }
  }
}
