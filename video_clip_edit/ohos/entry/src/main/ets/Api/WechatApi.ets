/**
 * 微信 OpenSDK 能力：鸿蒙端拉起微信客服会话
 * 文档：https://developers.weixin.qq.com/doc/oplatform/Mobile_App/APP_launch_wechat_customer_service.html
 */
import { MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { LogUtil } from '../utils';
import * as wxopensdk from '@tencent/wechat_open_sdk';

const TAG = 'WechatApi';

/** 默认移动应用 AppID，与 Flutter WxLoginConfig 保持一致 */
const DEFAULT_WX_APP_ID = 'wx4f542866bf92ff70';

export class WechatApi {
  /**
   * 拉起微信客服会话（OpenCustomerServiceChat）
   * @param call 参数：corpId (string), url (string), appId? (string)
   */
  async openCustomerServiceChat(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      const corpId = (call.argument('corpId') as string | undefined)?.trim();
      const url = (call.argument('url') as string | undefined)?.trim();
      const appId = ((call.argument('appId') as string | undefined)?.trim()) || DEFAULT_WX_APP_ID;

      if (!corpId || !url) {
        result.success({ code: 400, msg: 'corpId and url are required', data: false });
        return;
      }

      const WXApi = wxopensdk.WXAPIFactory.createWXAPI(appId);
      const req = new wxopensdk.OpenCustomerServiceChatReq();
      req.corpId = corpId;
      req.url = url;
      const context = getContext() as common.UIAbilityContext;
      WXApi.sendReq(context, req);
      result.success({ code: 200, msg: 'success', data: true });
    } catch (err) {
      const msg = (err as Error)?.message ?? String(err);
      LogUtil.error(TAG, `openCustomerServiceChat failed: ${msg}`);
      result.success({ code: 500, msg: msg, data: false });
    }
  }
}
