import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodChannel,
  MethodResult
} from '@ohos/flutter_ohos';
import { AudioApi, DeviceApi, OceanEngineApi, WechatApi } from '../Api';
import { ChannelConstant } from '../constant';
import { LogUtil } from '../utils';

const TAG = "FeaturePluginTag";

export default class FeaturePlugin implements FlutterPlugin {
  private deviceChannel?: MethodChannel;
  private deviceApi = new DeviceApi();
  private audioApi = new AudioApi();
  private oceanEngineApi = new OceanEngineApi();
  private wechatApi = new WechatApi();
  private static instance?: FeaturePlugin;

  static getInstance(): FeaturePlugin | undefined {
    return FeaturePlugin.instance;
  }

  getDeviceChannel(): MethodChannel | undefined {
    return this.deviceChannel;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    FeaturePlugin.instance = this;
    this.setDeviceMethodChannel(binding)
  }

  setDeviceMethodChannel(binding: FlutterPluginBinding) {
    this.deviceChannel = new MethodChannel(binding.getBinaryMessenger(), ChannelConstant.channelIdentifier);
    let that = this;
    this.deviceChannel.setMethodCallHandler({
      onMethodCall(call: MethodCall, result: MethodResult) {
        switch (call.method) {
          case "appDeviceInfo":
            that.deviceApi.getDeviceChannelId(result)
            break;
          case "exitApp":
            try {
              getContext().getApplicationContext().killAllProcesses()
            } catch (e) {
              // 如果getContext不可用，忽略错误
            }
            break;
          case "getPhotoPathFromAlbum":
            that.deviceApi.getFromAlbum(result, call, 'image')
            break;
          case "getPhotoPathFromCamera":
            that.deviceApi.getFromCamera(result, 'photo')
            break;
          case "getVideoPathFromAlbum":
            that.deviceApi.getFromAlbum(result, call, 'video')
            break;
          case "getVideoPathFromCamera":
            that.deviceApi.getFromCamera(result, 'video')
            break;
          case "getAudioPath":
            that.deviceApi.getAudio(result, call)
            break;
          case "saveToAlbum":
            that.deviceApi.saveToAlbum(result, call)
            break;
          case "getPermission":
            that.deviceApi.getPermission(result, call)
            break;
          case "recorderInit":
            that.audioApi.recorderInit(result)
            break;
          case "recorderStart":
            that.audioApi.recorderStart(result)
            break;
          case "recorderEnd":
            that.audioApi.recorderEnd(result)
            break;
          case "recorderRelease":
            that.audioApi.recorderRelease(result)
            break;
          case "bindSheetService":
            AppStorage.setOrCreate('isShowBindSheetService', true)
            break;
          case "getAudioDuration":
            that.deviceApi.getAudioDuration(result, call)
            break;
          case "navigateToHuaweiLogin":
            that.navigateToHuaweiLogin(call, result);
            break;
          case "appInit":
            that.oceanEngineApi.initAppConfig(result, call);
            break;
          case "oceanengineEvent":
            that.oceanEngineApi.oceanengineEvent(result, call);
            break;
          case "openWechatCustomerService":
            that.wechatApi.openCustomerServiceChat(call, result);
            break;
          default:
            LogUtil.info(TAG, "method is not found");
            result.notImplemented();
            break;
        }
      }
    })
  }


  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    LogUtil.info(TAG, "onDetachedFromEngine")
    this.deviceChannel?.setMethodCallHandler(null);
    FeaturePlugin.instance = undefined;
  }

  getUniqueClassName(): string {
    return "FeaturePlugin";
  }

  private navigateToHuaweiLogin(call: MethodCall, result: MethodResult): void {
    try {
      AppStorage.setOrCreate('navigateToHuaweiLogin', false);
      AppStorage.setOrCreate('navigateToHuaweiLogin', true);
      LogUtil.info(TAG, 'navigateToHuaweiLogin flag set true');
      result.success({ code: 200, msg: 'success', data: true });
    } catch (error) {
      LogUtil.error(TAG, `navigateToHuaweiLogin failed: ${JSON.stringify(error)}`);
      result.success({ code: 500, msg: 'navigateToHuaweiLogin failed', data: false });
    }
    }
}

