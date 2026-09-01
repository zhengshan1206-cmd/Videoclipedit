import { MethodCall, MethodResult } from "@ohos/flutter_ohos";
import { LogUtil, permissionManager, FileUtils } from "../utils";
import { AAID } from "@kit.PushKit";
import { identifier } from "@kit.AdsKit";
import { IChannelResponse, IDevice } from "../models";
import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { camera, cameraPicker } from "@kit.CameraKit";
import { common, Permissions } from "@kit.AbilityKit";
import { picker } from "@kit.CoreFileKit";
import { unifiedDataChannel } from "@kit.ArkData";
import { deviceInfo } from "@kit.BasicServicesKit";


const TAG = 'entryability'
const HAID_TYPE = "bytedance_haid"

interface HAIDModel {
  type: string
  id: string | undefined
  insert_time: number
}

export class DeviceApi {
  /**
   * 从统一数据通路获取 HAID（完全按照官方实现）
   * @returns Promise<HAIDModel | undefined>
   */
  private getHAIDFromUnifiedDataChannel(): Promise<HAIDModel | undefined> {
    return new Promise<HAIDModel | undefined>((resolve) => {
      try {
        unifiedDataChannel.queryData({
          intention: unifiedDataChannel.Intention.DATA_HUB
        }, (err, data) => {
          if (err === undefined) {
            let result: HAIDModel | undefined
            let time: number = 0
            data.forEach((unifiedDataItem: unifiedDataChannel.UnifiedData) => {
              unifiedDataItem.getRecords().forEach((record) => {
                if (record instanceof unifiedDataChannel.PlainText) {
                  // 只处理string
                  const haidOrNot = this.getHAIDData(record)
                  if (haidOrNot) {
                    LogUtil.info(TAG, "获取数据通路数据候选：" + JSON.stringify(haidOrNot))
                    if (haidOrNot.insert_time > time) {
                      LogUtil.info(TAG, "候选采纳：" + JSON.stringify(haidOrNot))
                      result = haidOrNot
                      time = haidOrNot.insert_time
                    }
                  }
                }
              })
            })
            LogUtil.info(TAG, "数据通路最终返回的HAID：" + JSON.stringify(result))
            resolve(result)
          } else {
            LogUtil.info(TAG, "获取数据通路数据失败，error：" + err.message)
            resolve(undefined)
          }
        })
      } catch (err) {
        const errorMsg = (err as Error)?.message || String(err)
        LogUtil.info(TAG, "获取数据通路数据失败，error：" + errorMsg)
        resolve(undefined)
      }
    })
  }

  /**
   * 解析 HAID 数据（完全按照官方实现）
   * @param value PlainText 数据
   * @returns HAIDModel | undefined
   */
  private getHAIDData(value: unifiedDataChannel.PlainText): HAIDModel | undefined {
    if (value.textContent.includes(HAID_TYPE)) {
      try {
        const haid = JSON.parse(value.textContent) as HAIDModel | undefined
        return haid
      } catch (e) {
        // ignore
      }
    }
    return undefined
  }

  /**
   * 获取设备ID：AAID，OAID，HAID，ODID
   * @param result
   */
  async getDeviceChannelId(result: MethodResult) {
    await permissionManager.getPermissionOnce(["ohos.permission.APP_TRACKING_CONSENT"])
    const aaid: string = await AAID.getAAID();
    const oaid = await identifier.getOAID();
    
    // 获取 HAID
    let haid: string | undefined = undefined
    try {
      const haidModel = await this.getHAIDFromUnifiedDataChannel()
      haid = haidModel?.id
    } catch (e) {
      const errorMsg = (e as Error)?.message || String(e)
      LogUtil.info(TAG, "获取HAID失败：" + errorMsg)
    }
    // 获取 ODID
    let odid: string | undefined = undefined
    try {
      odid = await deviceInfo.ODID
      LogUtil.info(TAG, "获取ODID成功：" + odid)
    } catch (e) {
      const errorMsg = (e as Error)?.message || String(e)
      LogUtil.info(TAG, "获取ODID失败：" + errorMsg)
    }
    
    // 获取设备品牌、型号、系统版本
    let brand: string | undefined = undefined
    let model: string | undefined = undefined
    let sysVersion: string | undefined = undefined
    try {
      brand = deviceInfo.brand
      model = deviceInfo.productModel
      sysVersion = deviceInfo.osFullName
      LogUtil.info(TAG, `获取设备信息成功: brand=${brand}, model=${model}, sysVersion=${sysVersion}`)
    } catch (e) {
      const errorMsg = (e as Error)?.message || String(e)
      LogUtil.info(TAG, "获取设备信息失败：" + errorMsg)
    }
    
    const device: IChannelResponse<IDevice> = {
      code: 200,
      msg: 'get deviceId success',
      data: {
        androidId: aaid,
        oId: oaid,
        haid: haid,
        odid: odid,
        brand: brand,
        model: model,
        sysVersion: sysVersion
      }
    }
    result.success(device)
  }

  /**
   * 从相册中获取资源
   * @param result
   * @param call：获取参数
   * @param type：资源类型
   */
  async getFromAlbum(result: MethodResult, call: MethodCall, type: 'image' | 'video' | 'image_video' | 'gif') {
    const count: number = call.argument('count')
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
    switch (type) {
      case "video":
        photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.VIDEO_TYPE
        break;
      case "image_video":
        photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE
        break;
      case "gif":
        photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.MOVING_PHOTO_IMAGE_TYPE
        break;
      default:
        photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
    }
    photoSelectOptions.maxSelectNumber = count

    const photoPicker = new photoAccessHelper.PhotoViewPicker()
    const photoResult = await photoPicker.select(photoSelectOptions)

    if (photoResult.photoUris.length === 0) {
      result.success(null)
      return
    }
    const context = getContext()
    const urls: string[] = photoResult.photoUris.map((uri) => {
      return FileUtils.getPathFromUri(context, uri) || '';
    })
    console.log('xxxx return urls', JSON.stringify(urls))
    if (urls.length) {
      const res: IChannelResponse<string[]> = {
        code: 200,
        msg: 'photo is success',
        data: urls
      }
      result.success(res)
    } else {
      result.success(null)
    }
  }

  /**
   * 从相机中获取资源
   * @param result
   * @param type：资源类型
   */
  async getFromCamera(result: MethodResult, type: 'photo' | 'video') {
    const typeArray: cameraPicker.PickerMediaType[] = []
    if (type === "photo") {
      typeArray.push(cameraPicker.PickerMediaType.PHOTO)
    } else {
      typeArray.push(cameraPicker.PickerMediaType.VIDEO)
    }
    const CameraFiles = await cameraPicker.pick(getContext(), typeArray, {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
      videoDuration: 120
    })
    const uri = CameraFiles.resultUri
    if (!uri) {
      result.success(null)
      return
    }
    const newUri = FileUtils.getPathFromUri(getContext(), uri);
    if (newUri) {
      const res: IChannelResponse<string> = {
        code: 200,
        msg: 'camera is success',
        data: newUri
      }
      result.success(res)
    } else {
      result.success(null)
    }
  }

  /**
   * 获取音频资源
   * @param result
   * @param call
   */
  async getAudio(result: MethodResult, call: MethodCall) {
    const count: number = call.argument('count')
    let context = getContext(this) as common.Context;
    let audioPicker = new picker.AudioViewPicker(context);
    const audioResult = await audioPicker.select({ maxSelectNumber: count });
    if (audioResult.length == 0) {
      result.success(null)
      return
    }
    const audioUrls = audioResult.map((audio) => {
      return FileUtils.getPathFromUri(context, audio) || '';
    })

    if (audioUrls.length) {
      const res: IChannelResponse<string[]> = {
        code: 200,
        msg: 'audio is success',
        data: audioUrls
      }
      result.success(res)
    } else {
      result.success(null)
    }
  }

  /**
   * 获取权限（目前只用于申请麦克风权限）
   * @param result
   * @param call
   */
  async getPermission(result: MethodResult, call: MethodCall) {

    const permissionKey: string = call.argument("permission")

    const permissions: Permissions[] = []

    switch (permissionKey) {
      case "WRITE_IMAGEVIDEO":
        permissions.push("ohos.permission.WRITE_IMAGEVIDEO")
        break
      case "CAMERA":
        permissions.push("ohos.permission.CAMERA")
        break
      case "READ_AUDIO":
        permissions.push("ohos.permission.READ_AUDIO")
        break
      case "READ_IMAGEVIDEO":
        permissions.push("ohos.permission.READ_IMAGEVIDEO")
        break
      case "MICROPHONE":
        permissions.push("ohos.permission.MICROPHONE")
        break
      default:
    }

    const isSetting: boolean = call.argument("isSetting")

    let isAgree: boolean = false

    isAgree = await permissionManager.getPermission(permissions)

    // if (isSetting) {
    //   isAgree = await permissionManager.getPermissionBySetting(permissions)
    // } else {
    //   isAgree = await permissionManager.getPermissionOnce(permissions)
    // }


    const response: IChannelResponse<boolean> = {
      code: 200,
      msg: 'response permission fail',
      data: isAgree
    }
    if (isAgree) {
      response.msg = "response permission success"
    }
    result.success(response)
  }

  /**
   * 保存资源到相册
   * @param result
   * @param call
   */
  async saveToAlbum(result: MethodResult, call: MethodCall) {
    const path: string = call.argument('path')
    const type: string = call.argument('type')
    const isSave = await FileUtils.saveToAlbum(path, type == 'image' ? 'image' : 'video')
    const response: IChannelResponse<boolean> = {
      code: 200,
      msg: type + ' save fail',
      data: isSave
    }
    if (isSave) {
      response.msg = type + ' save success'
    }
    result.success(response)

  }


  async getAudioDuration(result: MethodResult, call: MethodCall) {
    const path: string = call.argument('path')
    const duration = await FileUtils.getAudioDuration(path)
    const response: IChannelResponse<number> = {
      code: 200,
      msg: 'get duration success',
      data: duration
    }
    result.success(response)
  }
}



