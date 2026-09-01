package com.yinxiaozhi.fastscreen.common;

//全局常量
public class GlobalConstant {
   public final  static  int  SUCCESS=200;
   public final  static  int  FAIL=-1;

    public final static String FLUTTER_CHANNEL_NAME = "com.by.ve.bridge";
    // 自定义根目录，如果为空则默认为/sdcard/Android/data/***/files/rdve
    public final  static  String VIDEO_DEFULT_LOCAL_PATH="ve";
    //录音页面请求码
    public final static  int  RECORDING_ACTIVITY_REQUEST_CODE= 8456;
    //跳转视频编辑页面requestCode
    public final static int EDITVIEO_ACTIVITY_REQUEST_CODE = 8455;
 //视频去重requestCodeCOMPRESS_VIDEO
 public final static  int  COMPRESS_VIDEO_ACTIVITY_REQUEST_CODE= 8153;
 //视频擦除requestCode
 public final static int    VIDEO_CLEAN_WATERMARK_ACTIVITY_REQUEST_CODE = 8455;

    /**
     * request
     * */
    //头条SDK回传事件
    public final  static  String OCEANENGINE_EVENT ="oceanengineEvent";
    //App初始化
    public final  static  String APP_INIT="appInit";
    //获取App信息
    public final  static  String APP_DEVICE_INFO="appDeviceInfo";
    // 视频编辑
    public final static String VIDEO_EDIT = "videoEdit";
    // 从视频中提取音频和文案
    public final static String VIDEO_TO_AUDIO = "videoToAudio";
    // 压缩视频
    public final static String COMPRESS_VIDEO= "comperssVideo";
    //擦除
    public final static String VIDEO_CLEAN_WATERMARK = "cleanWatermark";
//    //马赛克
//    public final static String MOSAIC = "mosaic";
    //视频帧图
    public final  static  String  VIDEO_TO_IMG= "videoToImg";
    // 录音
    public final static String RECORDING = "record";
    /**
     * parameter
     * */
    //本地视频地址
    public final static String VIDEO_FILE_PATH = "videoLocalFilePathParameter";
    //音频mp3file返回值
    public final  static  String  AUDIO_LOCAL_FILE_PATH_RESULT= "audioLocalFilePathResult";
    //音频文案返回值
    public final  static  String  VIDEO_TEXT_RESULT= "videoTextResult";



    /**
     * result
     * */
    //录音页面返回值
    public final  static  String RECORDING_ACTIVITY_RESULT_DATA = "recordingActivityResultData";




}

