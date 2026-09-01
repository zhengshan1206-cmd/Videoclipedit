class ByNativeBridge {
//   static const channelIdentifier = "com.by.ve.bridge";
//   static const channel = MethodChannel(channelIdentifier);
//   // //视频file参数
//   // static const String videoLocalFilePathRequest = "videoLocalFilePathParameter";
//   //音频mp3file返回值
//   // static const String audioLocalFilePathResult = "audioLocalFilePathResult";
//   //音频文案返回值
//   // static const String videoTextResult = "videoTextResult";
//   // 录音
//   // static const String recordingRequest = "recordingRequest";
//   // // 录音返回值
//   // static const String recordingResult = "recordingResult";
//
//   /// 调用原生方法获取数据
//   /// [method] 方法名
//   /// [params] 方法参数
//   static Future<dynamic> callNativeMethod({
//     required ByNativeMehod method,
//     dynamic params,
//   }) async {
//     if (method.rawValue.isEmpty) return null;
//     try {
//       final result = await channel.invokeMethod(
//         method.rawValue,
//         params,
//       );
//       return result;
//     } on PlatformException catch (e) {
//       byDebugPrint("调用原生方法${method.rawValue}时发生错误: '${e.message}'.");
//       return null;
//     }
//   }
//
//   dispose() {}
// }
//
// enum ByNativeMehod {
//   // ///初始化配置
//   // appInit,
//   //
//   // ///获取oid和androidid
//   // appDeviceInfo,
//
//   // /// 视频编辑
//   // videoEdit,
//
//   // /// 从视频中提取音频
//   // videoToAudio,
//
//   /// 批量获取视频截图
//   videoScreenshots,
//
//   // /// 录音
//   // record,
//
//   // /// 视频合成
//   // videoComposition,
//
//   /// 视频拆分
//   videoSplitting,
//
//   // ///视频去重
//   // comperssVideo,
//   ///擦除
//   // cleanWatermark,
//   // ///马赛克
//   // mosaic,
//   /// 退出应用
//   exitApp,
// }
//
// extension ByNativeMehodExt on ByNativeMehod {
//   String get rawValue {
//     switch (this) {
//       // /// 初始化配置
//       // case ByNativeMehod.appInit:
//       //   return "appInit";
//       //
//       // /// 获取oid和androidid
//       // case ByNativeMehod.appDeviceInfo:
//       //   return "appDeviceInfo";
//
//       /// 视频编辑
//       // case ByNativeMehod.videoEdit:
//       //   return "videoEdit";
//
//       // /// 从视频中提取音频
//       // case ByNativeMehod.videoToAudio:
//       //   return "videoToAudio";
//
//       // /// 批量获取视频截图
//       // case ByNativeMehod.videoScreenshots:
//       //   return "videoScreenshots";
//
//       // /// 录音
//       // case ByNativeMehod.record:
//       //   return "record";
//
//       // /// 视频合成
//       // case ByNativeMehod.videoComposition:
//       //   return "videoComposition";
//
//       /// 视频拆分
//       case ByNativeMehod.videoSplitting:
//         return "videoSplitting";
//
//       /// 视频拆分
//       case ByNativeMehod.exitApp:
//         return "exitApp";
//      // /// 视频去重
//      //  case ByNativeMehod.comperssVideo:
//      //    return "comperssVideo";
//     // /// 马赛克
//     //   case ByNativeMehod.mosaic:
//     //     return "mosaic";
//     ///擦除
//     //   case  ByNativeMehod.cleanWatermark:
//     return "cleanWatermark";
//       /// 其他
//       default:
//         return "";
//     }
//   }
}
