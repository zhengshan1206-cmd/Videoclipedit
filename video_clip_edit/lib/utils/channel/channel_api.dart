class ChannelApi {
  static const channelIdentifier = "com.by.ve.bridge";
  static const int channelSuccess = 200;
  //头条SDK回传
  static const String oceanengineEvent = "oceanengineEvent";
  //init
  static const String init = "appInit";
  //appDeviceInfo
  static const String appDeviceInfo = "appDeviceInfo";
  //从视频中提取音频
  static const String videoToAudio = "videoToAudio";
  //去重
  static const String comperssVideo = "comperssVideo";
  //视频编辑
  static const String videoEdit = "videoEdit";
  //录音
  static const String recordingRequest = "record";
  //擦除
  static const String cleanWatermark = "cleanWatermark";

  // 退出应用
  static const String exitApp = "exitApp";
  //视频帧图
  static String videoToImg = "videoToImg";
  // 获取音频文件的时长
  static const String multimediaFilesDuration = "multimediaFilesDuration";
  //编辑视频返回的参数名
  static const String editResult = "edit_result";
  //视频file参数
  static const String videoLocalFilePathRequest = "videoLocalFilePathParameter";

  /// 视频文案提取失败重试次数
  static const String audioAndTxtRetryTimes = "kAudioAndTxtRetryTimes";
  //音频mp3file返回值
  static const String audioLocalFilePathResult = "audioLocalFilePathResult";
  //音频文案返回值
  static const String videoTextResult = "videoTextResult";
  //录音返回值
  static const String recordingResult = "recordingActivityResultData";

  //获取相机图片路径返回值
  static const String getPhotoPathFromCamera = "getPhotoPathFromCamera";
  //获取相册路径返回值
  static const String getPhotoPathFromAlbum = "getPhotoPathFromAlbum";
  //获取相机视频路径返回值
  static const String getVideoPathFromCamera = "getVideoPathFromCamera";
  //获取相机视频路径返回值
  static const String getVideoPathFromAlbum = "getVideoPathFromAlbum";
  //获取音频路径返回值
  static const String getAudioPath = "getAudioPath";
  //保存资源到相册
  static const String saveToAlbum = "saveToAlbum";
  //获取音频时长
  static const String getAudioDuration = "getAudioDuration";

  //相册写入权限
  static const String getPermission = "getPermission";
  //初始化录音
  static const String recorderInit = "recorderInit";
  //开始录音
  static const String recorderStart = "recorderStart";
  //停止录音
  static const String recorderEnd = "recorderEnd";
  //释放录音器
  static const String recorderRelease = "recorderRelease";

  //拉起微信跳转二维码
  static const String bindSheetService = "bindSheetService";

  /// 鸿蒙：拉起微信客服会话（OpenCustomerServiceChat，需 corpId + url）
  static const String openWechatCustomerService = "openWechatCustomerService";
  //华为登录code回调
  static const String onHuaweiLoginCode = "onHuaweiLoginCode";
  //跳转到华为登录页面
  static const String navigateToHuaweiLogin = "navigateToHuaweiLogin";
}
