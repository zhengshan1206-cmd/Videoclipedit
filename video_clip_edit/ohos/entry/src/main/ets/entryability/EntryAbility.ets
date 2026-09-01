import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import window from '@ohos.window';
import { UIContext } from '@kit.ArkUI';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import AlipayKitPlugin from './AlipayKitPlugin';
import FeaturePlugin from './FeaturePlugin';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    try {
      super.configureFlutterEngine(flutterEngine)
      GeneratedPluginRegistrant.registerWith(flutterEngine)
      this.addPlugin(new FeaturePlugin())
      this.addPlugin(new AlipayKitPlugin())
    } catch (e) {
      // 捕获初始化错误，避免启动崩溃
    }
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    super.onWindowStageCreate(windowStage);
    windowStage.getMainWindow().then((mainWindow) => {
      const uiContext: UIContext = mainWindow.getUIContext();
      AppStorage.setOrCreate<UIContext>('uiContext', uiContext);
    }).catch(() => {
      // 忽略错误，避免启动崩溃
    })
  }
}
