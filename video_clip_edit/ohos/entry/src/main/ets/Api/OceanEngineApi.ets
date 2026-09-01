import { MethodCall, MethodResult } from "@ohos/flutter_ohos";
import { LogUtil } from "../utils";
import { IChannelResponse } from "../models";
import { common, Permissions } from "@kit.AbilityKit";
import { abilityAccessCtrl } from "@kit.AbilityKit";
// 导入巨量引擎 SDK
import { BDConvert, BDConvertConfig, ConvertReportHelper } from '@bytedance_ads/app_convert';

const TAG = 'OceanEngineApi'

/**
 * 巨量引擎 SDK API 类
 * 用于处理归因相关的功能
 */
export class OceanEngineApi {
  private static isInitialized: boolean = false;
  private static appId: string = '';
  private static channel: string = '';

  /**
   * 初始化巨量引擎 SDK
   * @param result
   * @param call
   */
  async initAppConfig(result: MethodResult, call: MethodCall) {
    try {
      // 检查是否已经初始化（与 Android 逻辑一致）
      if (OceanEngineApi.isInitialized) {
        LogUtil.info(TAG, 'SDK 已初始化，跳过重复初始化');
        const successResponse: IChannelResponse<boolean> = {
          code: 200,
          msg: 'SDK 已初始化',
          data: true
        };
        result.success(successResponse);
        return;
      }

      const appid: string = call.argument('appid');
      const channel: string = call.argument('channel');

      if (!appid) {
        const errorResponse: IChannelResponse<null> = {
          code: 400,
          msg: 'appid is required',
          data: null
        };
        result.success(errorResponse);
        return;
      }
      
      OceanEngineApi.isInitialized = true;
      OceanEngineApi.appId = appid;
      OceanEngineApi.channel = channel;

      // 申请 APP_TRACKING_CONSENT 权限
      // 无论是否拥有权限，均可以接入，转化SDK内部会再做一次判断
      await this.requestPermission('ohos.permission.APP_TRACKING_CONSENT', getContext());
      
      try {
        // 初始化转化SDK（使用接入方式A，自动发送启动事件）
        // 注意：需要在用户同意隐私政策后调用
        const config = new BDConvertConfig();
        // config.autoSendLaunchEvent = true;//默认会自动发送启动事件
        // 可以根据需要配置其他参数
        // config.enableLog = false; // 是否开启debug日志
        config.enablePlaySessionEvent = true; // 是否启用心跳事件
        config.enableOAIDTrack = true; // SDK是否采集OAID
        
        BDConvert.getInstance().init(getContext(), config);

        LogUtil.info(TAG, `初始化巨量引擎 SDK 成功: appid=${appid}, channel=${channel}`);

        const successResponse: IChannelResponse<boolean> = {
          code: 200,
          msg: '初始化成功',
          data: true
        };
        result.success(successResponse);
      } catch (error) {
        LogUtil.error(TAG, `初始化失败: ${JSON.stringify(error)}`);
        const errorResponse: IChannelResponse<null> = {
          code: 500,
          msg: `初始化失败: ${error}`,
          data: null
        };
        result.success(errorResponse);
      }
    } catch (error) {
      LogUtil.error(TAG, `初始化失败: ${JSON.stringify(error)}`);
      const errorResponse: IChannelResponse<null> = {
        code: 500,
        msg: `初始化失败: ${error}`,
        data: null
      };
      result.success(errorResponse);
    }
  }

  /**
   * 申请权限
   * @param permission 权限名称
   * @param context 上下文
   * @returns Promise<boolean> 权限申请结果
   */
  private async requestPermission(permission: Permissions, context: common.Context): Promise<boolean> {
    try {
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
      const data = await atManager.requestPermissionsFromUser(context, [permission]);
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === 0) {
          return true;
        } else {
          return false;
        }
      }
      return false;
    } catch (err) {
      LogUtil.error(TAG, `申请权限失败: ${JSON.stringify(err)}`);
      // 无论是否拥有权限，均可以接入，转化SDK内部会再做一次判断
      return false;
    }
  }

  /**
   * 上报事件到巨量引擎 SDK
   * @param result
   * @param call
   */
  async oceanengineEvent(result: MethodResult, call: MethodCall) {
    try {
      if (!OceanEngineApi.isInitialized) {
        LogUtil.warn(TAG, 'SDK 未初始化，无法上报事件');
        const errorResponse: IChannelResponse<null> = {
          code: 400,
          msg: 'SDK 未初始化',
          data: null
        };
        result.success(errorResponse);
        return;
      }

      const params: string = call.argument('params');
      if (!params) {
        const errorResponse: IChannelResponse<null> = {
          code: 400,
          msg: 'params is required',
          data: null
        };
        result.success(errorResponse);
        return;
      }

      LogUtil.info(TAG, `上报事件: ${params}`);

      // 解析事件参数
      let eventData: ESObject = {};
      try {
        eventData = JSON.parse(params) as ESObject;
      } catch (e) {
        LogUtil.error(TAG, `解析事件参数失败: ${e}`);
        const errorResponse: IChannelResponse<null> = {
          code: 400,
          msg: '事件参数格式错误',
          data: null
        };
        result.success(errorResponse);
        return;
      }

      // 根据事件类型处理
      const eventTypeValue: ESObject = eventData['event'] as ESObject;
      if (!eventTypeValue) {
        const errorResponse: IChannelResponse<null> = {
          code: 400,
          msg: '事件类型不能为空',
          data: null
        };
        result.success(errorResponse);
        return;
      }
      const eventType: string = String(eventTypeValue);
      LogUtil.info(TAG, `事件类型: ${eventType}`);
      
      try {
        // 根据事件类型调用相应的 SDK 方法
        if (eventType === 'register') {
          // 注册事件
          // ConvertReportHelper.onEventRegister(注册方式, 是否成功)
          const wayValue: ESObject = eventData['way'] as ESObject;
          const way: string = wayValue ? String(wayValue) : ''; // 登录方式(wechat 微信,phone 手机)
          
          ConvertReportHelper.onEventRegister(way, true);
          LogUtil.info(TAG, `注册事件上报: way=${way}`);
          
          const successResponse: IChannelResponse<boolean> = {
            code: 200,

            msg: '注册事件上报成功',
            data: true
          };
          result.success(successResponse);
        } else if (eventType === 'purchase') {
          // 付费事件
          // ConvertReportHelper.onEventPurchase(商品类型, 商品名称, 商品ID, 商品数量, 支付渠道, 币种, 是否成功, 金额)
          // 付费金额单位为元
          const goodType: string = String(eventData['good_type'] || '');
          const goodName: string = String(eventData['good_name'] || '');
          const goodId: string = String(eventData['good_id'] || '');
          const goodNum: number = Number(eventData['good_num'] || 1);
          const payType: string = String(eventData['pay_type'] || '');
          const currency: string = String(eventData['currency'] || '¥');
          const money: number = Number(eventData['money'] || 0);
          const intMoney: number = Math.floor(money); // 转换为整数（单位：元）
          
          ConvertReportHelper.onEventPurchase(goodType, goodName, goodId, goodNum, payType, currency, true, intMoney);
          LogUtil.info(TAG, `付费事件上报: money=${intMoney}`);
          
          const successResponse: IChannelResponse<boolean> = {
            code: 200,
            msg: '付费事件上报成功',
            data: true
          };
          result.success(successResponse);
        } else if (eventType === 'game_addiction') {
          // 关键行为
          const paramsObj: ESObject = {};
          try {
            const originEventValue: ESObject = eventData['origin_event'] as ESObject;
            if (originEventValue) {
              paramsObj['origin_event'] = originEventValue; // 添加原始事件名称参数
            }
          } catch (ex) {
            LogUtil.error(TAG, `解析 origin_event 失败: ${JSON.stringify(ex)}`);
          }
          
          ConvertReportHelper.onEventV3('game_addiction', paramsObj);
          LogUtil.info(TAG, `关键行为事件上报: game_addiction`);
          
          const successResponse: IChannelResponse<boolean> = {
            code: 200,
            msg: '关键行为事件上报成功',
            data: true
          };
          result.success(successResponse);
        } else {
          // 自定义事件
          // 移除 event 字段，将剩余参数作为事件属性
          // 由于 ArkTS 不支持 for...in，我们使用 Object.keys() 来遍历
          const eventParams: ESObject = {};
          const keys: string[] = Object.keys(eventData);
          for (let i = 0; i < keys.length; i++) {
            const key: string = keys[i];
            if (key !== 'event') {
              eventParams[key] = eventData[key];
            }
          }
          
          ConvertReportHelper.onEventV3(eventType, eventParams);
          LogUtil.info(TAG, `自定义事件上报: ${eventType}`);
          
          const successResponse: IChannelResponse<boolean> = {
            code: 200,
            msg: '自定义事件上报成功',
            data: true
          };
          result.success(successResponse);
        }
      } catch (error) {
        LogUtil.error(TAG, `事件上报失败: ${JSON.stringify(error)}`);
        const errorResponse: IChannelResponse<null> = {
          code: 500,
          msg: `事件上报失败: ${error}`,
          data: null
        };
        result.success(errorResponse);
      }
    } catch (error) {
      LogUtil.error(TAG, `事件上报失败: ${JSON.stringify(error)}`);
      const errorResponse: IChannelResponse<null> = {
        code: 500,
        msg: `事件上报失败: ${error}`,
        data: null
      };
      result.success(errorResponse);
    }
  }

  /**
   * 获取初始化状态
   */
  static isSDKInitialized(): boolean {
    return OceanEngineApi.isInitialized;
  }
}
