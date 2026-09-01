import common from '@ohos.app.ability.common';
import { FlutterPage } from '@ohos/flutter_ohos';
import { wechatService } from '../components';
import { FileUtils, LogUtil, screenManager } from '../utils';

let storage = LocalStorage.getShared()
const EVENT_BACK_PRESS = 'EVENT_BACK_PRESS'

@Entry(storage)
@Component
struct Index {
  private context = getContext(this) as common.UIAbilityContext
  @LocalStorageLink('viewId') viewId: string = "";
  @StorageLink('isShowBindSheetService') isShowBindSheetService: boolean = false
  @StorageLink('navigateToHuaweiLogin') @Watch('onNavigateToHuaweiLoginChange') navigateToHuaweiLogin: boolean = false

  aboutToAppear(): void {
    screenManager.full(getContext(this))
  }

  aboutToDisappear(): void {
    FileUtils.clearCache(getContext(this))
  }

  build() {
    Column() {
      FlutterPage({ viewId: this.viewId })
    }
    .bindSheet($$this.isShowBindSheetService, this.bindSheetService, {
      height: 550,
      backgroundColor:Color.White
    })
  }

  onBackPress(): boolean {
    this.context.eventHub.emit(EVENT_BACK_PRESS)
    return true
  }

  @Builder
  bindSheetService() {
    wechatService()
  }

  onNavigateToHuaweiLoginChange() {
    if (!this.navigateToHuaweiLogin) {
      return;
    }
    this.navigateToHuaweiLogin = false;
    try {
      this.getUIContext().getRouter().pushUrl({ url: 'pages/HwLoginPage' });
    } catch (error) {
      LogUtil.error('Index', `navigateToHuaweiLogin push failed: ${JSON.stringify(error)}`);
    }
  }
}