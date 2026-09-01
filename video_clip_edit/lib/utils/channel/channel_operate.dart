import 'dart:developer';

import 'base_channel.dart';
import 'package:video_clip_edit/utils/channel/channel_api.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';

class ChannelOperate {
  //初始化原生
  static Future<dynamic> initAppConfig(String appid, String channel) async {
    return await BaseChannel.instance.callNativeMethod(ChannelApi.init,
        params: {"appid": appid, "channel": channel});
  }

  //头条SDK回传
  static Future<dynamic> oceanengineEvent(String params) async {
    return await BaseChannel.instance.callNativeMethod(
        ChannelApi.oceanengineEvent,
        params: {"params": params});
  }

  //获取app设备信息
  static Future<dynamic> getAppDeviceInfo() async {
    return await BaseChannel.instance
        .callNativeMethod(ChannelApi.appDeviceInfo);
  }

  /// 视频编辑
  /// [commentaryDubbingList] 为解说文案生成的配音列表
  /// 格式为 [
  /// 	      {
  /// 		      “audioPath”: “/xxxxx/xxxxx/dd.mp3”,
  /// 		      "start_time": 54.48,
  ///         	"end_time": 58.1
  /// 	      }
  ///       ]
  /// [srtFilePaths] 视频的字幕文件列表
  // static Future<dynamic> toVideoEdit(
  //   bool isPresets, {
  //   List<String>? videoLocalFilePathParameter,
  //   List<String>? srtFilePaths,
  //   String? srtFilePathsSing,
  //   String? videoRatio = "原始",
  //   List<Map<String, dynamic>> commentaryDubbingListSing = const [],
  //   List<Map<String, dynamic>> commentaryDubbingList = const [],
  //   List<Map<String, dynamic>> removeList = const [],
  //   Map<String, dynamic> removeListSing = const {},
  //   String? subtitles,
  //   List<String>? selectionMode,
  //   List<String>? selectionEffect,
  //   String? selectMusic,
  //   bool? isOriginalSoundtrack,
  //   bool? isExportVideo,
  //   bool? isSelectEditModel,
  //   bool? hindMenu,
  //   bool? isSplictShowDialog = false,
  //   bool? mosaic,
  //   String? exportTitle,
  //   bool? srtFilePathsAll = false,
  //   bool? isShowLoadDialog,
  //   String? exportTxt,
  //   bool? isSavePhoto = false,
  //   String? dialogTitle,
  // }) async {
  //   byDebugPrint(commentaryDubbingList, tag: "-----------为解说文案生成的配音列表: ");
  //   byDebugPrint(removeList, tag: "-----------要删除的视频剧情列表: ");

  //   final status = await ByPermissionUtils.videos();
  //   if (!status) return;
  //   return await BaseChannel.instance
  //       .callNativeMethod(ChannelApi.videoEdit, params: {
  //     'data': {
  //       'removeListSing': removeListSing,
  //       'isPresets': isPresets,
  //       'isSplictShowDialog': isSplictShowDialog,
  //       'isExportVideo': isExportVideo,
  //       'srtFilePathsSing': srtFilePathsSing,
  //       'commentaryDubbingListSing': commentaryDubbingListSing,
  //       'isSelectEditModel': isSelectEditModel,
  //       ChannelApi.videoLocalFilePathRequest: videoLocalFilePathParameter,
  //       'videoRatio': videoRatio,
  //       'srtFilePaths': srtFilePaths,
  //       'srtFilePathsAll': srtFilePathsAll,
  //       'subtitles': subtitles,
  //       'isSavePhoto': isSavePhoto,
  //       'commentaryDubbingList': commentaryDubbingList,
  //       'removeList': removeList,
  //       'isShowLoadDialog': isShowLoadDialog,
  //       'selectionMode': selectionMode,
  //       'selectionEffect': selectionEffect,
  //       'selectMusic': selectMusic,
  //       'isOriginalSoundtrack': isOriginalSoundtrack,
  //       'hindMenu': hindMenu,
  //       'exportTxt': exportTxt,
  //       'exportTitle': exportTitle,
  //       'dialogTitle': dialogTitle,
  //       'mosaic': mosaic,
  //     }
  //   });
  // }

  //去重
  // static Future<dynamic> toComperssVideo(String path) async {
  //   final status = await ByPermissionUtils.videos();
  //   if (!status) return;
  //   return await BaseChannel.instance.callNativeMethod(ChannelApi.comperssVideo,
  //       params: {ChannelApi.videoLocalFilePathRequest: path});
  // }

  //擦除
  // static Future<dynamic> toCleanWatermark(String path) async {
  //   final status = await ByPermissionUtils.videos();
  //   if (!status) return;
  //   return await BaseChannel.instance.callNativeMethod(
  //       ChannelApi.cleanWatermark,
  //       params: {ChannelApi.videoLocalFilePathRequest: path});
  // }

  /// mainDloag
  // static Future<dynamic> showDialog() async {
  //   return await BaseChannel.instance.callNativeMethod("showDialog");
  // }

  // static Future<dynamic> hidDialog() async {
  //   return await BaseChannel.instance.callNativeMethod("hd");
  // }

  //提取音频和文案
  static Future<dynamic> getVideoToAudioAndTxt(String path,
      {bool isOnlyAudio = false}) async {
    final status = await ByPermissionUtils.videos();
    if (!status) return;
    return await BaseChannel.instance
        .callNativeMethod(ChannelApi.videoToAudio, params: {
      ChannelApi.videoLocalFilePathRequest: path,
      // TODO: 测试提取失败重试，临时设置为2次,从0开始
      ChannelApi.audioAndTxtRetryTimes: 1,
      "isOnlyAudio": isOnlyAudio,
    });
  }

  //录音
  // static Future<dynamic> toRecordingRequest() async {
  //   final status = await ByPermissionUtils.videos();
  //   if (!status) return;
  //   return await BaseChannel.instance
  //       .callNativeMethod(ChannelApi.recordingRequest);
  // }

  //获取视频帧图
  // static Future<dynamic> getVideoImage(String time, String path) async {
  //   final status = await ByPermissionUtils.videos();
  //   if (!status) return;
  //   return await BaseChannel.instance.callNativeMethod(ChannelApi.videoToImg,
  //       params: {ChannelApi.videoLocalFilePathRequest: path, "time": time});
  // }

  //退出应用
  static Future<dynamic> exitApp() async {
    return await BaseChannel.instance.callNativeMethod(ChannelApi.exitApp);
  }

  //获取音频文件的时长
  // static Future<double> getMultimediaFilesDuration(String path) async {
  //   final status = await ByPermissionUtils.videos();
  //   if (!status) return 0;
  //   var duration = await BaseChannel.instance.callNativeMethod(
  //       ChannelApi.multimediaFilesDuration,
  //       params: {ChannelApi.videoLocalFilePathRequest: path});
  //   return duration;
  // }

  //退出应用
  // static Future<dynamic> myEdit(List<String> path) async {
  //   return await BaseChannel.instance.callNativeMethod("myEdit",
  //       params: {ChannelApi.videoLocalFilePathRequest: path});
  // }
}
