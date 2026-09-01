import { MethodCall, MethodResult } from "@ohos/flutter_ohos"
import { IChannelResponse } from "../models"
import { avRecorderManager } from "../utils"


export class AudioApi {

  private responseReturn<T>(data: T): IChannelResponse<T> {
    return {
      code: 200,
      msg: 'response audio success',
      data: data
    }
  }

  /***************************** 录音相关 *************************************/
  async recorderInit(result: MethodResult) {
    await avRecorderManager.init()
    result.success(this.responseReturn(true))
  }

  async recorderStart(result: MethodResult) {
    await avRecorderManager.startRecorder()
    result.success(this.responseReturn(true))
  }

  async recorderEnd(result: MethodResult) {
    const path = await avRecorderManager.endRecorder()
    if (path) {
      result.success(this.responseReturn(path))
    }
    result.success(this.responseReturn(false))
  }

  async recorderRelease(result: MethodResult) {
    await avRecorderManager.release()
    result.success(this.responseReturn(true))
  }
}
