import { window, KeyboardAvoidMode } from "@kit.ArkUI"
import { deviceInfo } from "@kit.BasicServicesKit"
import { LogUtil } from "."
import { ChannelConstant } from "../constant"

const TAG = "utils"

export class ScreenManager {
  // 全屏
  async full(ctx?: Context) {
    // 2in1 电脑设备不处理
    if (deviceInfo.deviceType !== "2in1") {
      const win = await window.getLastWindow(ctx || getContext())
      await win.setWindowLayoutFullScreen(true)
      this.setAreaHeight(win) // 只要调用全屏就把安全区的高度存起来
    }
  }

  private setAreaHeight(win: window.Window) {
    // 顶部高度
    const safeTop = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height)
    // 底部高度
    const safeBottom = px2vp(win.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height)
    AppStorage.setOrCreate<number>(ChannelConstant.safeTop, safeTop)
    AppStorage.setOrCreate<number>(ChannelConstant.safeBottom, safeBottom)
    LogUtil.info(TAG, `safeTop:${safeTop} safeBottom:${safeBottom}`)
  }

  // 退出全屏
  async exitFull(ctx?: Context) {
    const win = await window.getLastWindow(ctx || getContext())
    win.setWindowLayoutFullScreen(false)
  }

  // 设置键盘压缩
  async setKeyBoardMode(ctx?: Context) {
    const win = await window.getLastWindow(ctx || getContext())
    win.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
  }
}


export const screenManager = new ScreenManager()