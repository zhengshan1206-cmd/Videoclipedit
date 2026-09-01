import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  NewWantListener
} from '@ohos/flutter_ohos';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import { bundleManager } from '@kit.AbilityKit';
import { Pay } from '@cashier_alipay/cashiersdk';
import { BusinessError } from '@kit.BasicServicesKit';

/** AlipayKitPlugin **/
export default class AlipayKitPlugin implements FlutterPlugin, AbilityAware, NewWantListener, MethodCallHandler {
  private channel: MethodChannel | null = null
  private abilityBinding: AbilityPluginBinding | null = null

  getUniqueClassName(): string {
    return "AlipayKitPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "v7lin.github.io/alipay_kit");
    this.channel.setMethodCallHandler(this)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.abilityBinding = binding
    this.abilityBinding.addOnNewWantListener(this)
  }

  onDetachedFromAbility(): void {
    if (this.abilityBinding != null) {
      this.abilityBinding.removeOnNewWantListener(this)
    }
    this.abilityBinding = null
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {

  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "setEnv":
      case "isInstalled":
        const installed = bundleManager.canOpenLink("alipays://")
        result.success(installed)
        break
      case "pay":
        this.handlePayCall(call, result);
        break
      case "auth":
        this.handleAuthCall(call, result);
        break
    }
  }

  handlePayCall(call: MethodCall, result: MethodResult): void {
    console.log(call.argument("orderInfo"))
    new Pay().pay(call.argument("orderInfo"), true).then((request) => {
      let message =
        `resultStatus: ${request.get('resultStatus')} memo: ${request.get('memo')} result: ${request.get('result')}`;
      console.log(message);
      this.channel?.invokeMethod("onPayResp", request)
    }).catch((error: BusinessError) => {
      console.log(error.message);
      this.channel?.invokeMethod("onPayResp", { 'resultStatus': 6001, 'result': '拉起失败' })
    });
    result.success(null)
  }

  handleAuthCall(call: MethodCall, result: MethodResult): void {

    result.success(null)
  }
}