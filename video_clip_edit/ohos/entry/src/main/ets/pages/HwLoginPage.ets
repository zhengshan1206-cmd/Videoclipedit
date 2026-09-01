import { authentication, loginComponentManager, LoginWithHuaweiIDButton } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { connection, http } from '@kit.NetworkKit';
import { taskpool, util } from '@kit.ArkTS';
import FeaturePlugin from '../entryability/FeaturePlugin';


let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
// 当用户未登录华为账号时，是否强制拉起华为账号登录界面
loginRequest.forceLogin = true;
loginRequest.state = util.generateRandomUUID();

interface HuaweiAgreementConfig {
  appName: string;
  userServiceTitle: string;
  userServiceUrl: string;
  privacyTitle: string;
  privacyUrl: string;
}

const DEFAULT_APP_NAME: string = '妙笔工坊';
const DEFAULT_USER_SERVICE_TITLE: string = '用户服务协议';
const DEFAULT_PRIVACY_TITLE: string = '隐私政策';
const DEFAULT_USER_SERVICE_URL: string = 'https://inchat.beiyinapp.com/api/common3/protocol';
const DEFAULT_PRIVACY_URL: string = 'https://inchat.beiyinapp.com/api/common3/privacyHarmony';

const DEFAULT_AGREEMENT_CONFIG: HuaweiAgreementConfig = {
  appName: DEFAULT_APP_NAME,
  userServiceTitle: DEFAULT_USER_SERVICE_TITLE,
  userServiceUrl: DEFAULT_USER_SERVICE_URL,
  privacyTitle: DEFAULT_PRIVACY_TITLE,
  privacyUrl: DEFAULT_PRIVACY_URL
};

function cloneAgreementConfig(source: HuaweiAgreementConfig): HuaweiAgreementConfig {
  return {
    appName: source.appName,
    userServiceTitle: source.userServiceTitle,
    userServiceUrl: source.userServiceUrl,
    privacyTitle: source.privacyTitle,
    privacyUrl: source.privacyUrl
  };
}

const AGREEMENT_TAG_USER_SERVICE = 'USER_SERVICE';
const AGREEMENT_TAG_PRIVACY = 'PRIVACY';
const AGREEMENT_TAG_USER_AUTHENTICATION = 'USER_AUTHENTICATION';
const AGREEMENT_STORAGE_KEY = 'huaweiLoginAgreements';

function buildPrivacyTextConfig(config: HuaweiAgreementConfig): loginComponentManager.PrivacyText[] {
  const items: loginComponentManager.PrivacyText[] = [{
    text: '已阅读并同意',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: `《${config.userServiceTitle}》`,
    tag: AGREEMENT_TAG_USER_SERVICE,
    type: loginComponentManager.TextType.RICH_TEXT
  }];

  items.push({
    text: '、',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: `《${config.privacyTitle}》`,
    tag: AGREEMENT_TAG_PRIVACY,
    type: loginComponentManager.TextType.RICH_TEXT
  });

  items.push({
    text: '和',
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: '《华为账号用户认证协议》',
    tag: AGREEMENT_TAG_USER_AUTHENTICATION,
    type: loginComponentManager.TextType.RICH_TEXT
  }, {
    text: '。',
    type: loginComponentManager.TextType.PLAIN_TEXT
  });

  return items;
}

function buildAgreementConfigFromStorage(): HuaweiAgreementConfig {
  const nextConfig: HuaweiAgreementConfig = cloneAgreementConfig(DEFAULT_AGREEMENT_CONFIG);
  const stored = AppStorage.get<Record<string, string>>(AGREEMENT_STORAGE_KEY);
  if (!stored) {
    return nextConfig;
  }

  const hasValue = (value?: string): boolean => !!value && value.length > 0;

  if (hasValue(stored.appName)) {
    nextConfig.appName = stored.appName;
  }
  if (hasValue(stored.userServiceTitle)) {
    nextConfig.userServiceTitle = stored.userServiceTitle;
  }
  if (hasValue(stored.userServiceUrl)) {
    nextConfig.userServiceUrl = stored.userServiceUrl;
  }
  if (hasValue(stored.privacyTitle)) {
    nextConfig.privacyTitle = stored.privacyTitle;
  }
  if (hasValue(stored.privacyUrl)) {
    nextConfig.privacyUrl = stored.privacyUrl;
  }
  return nextConfig;
}

export interface iLogin {
  isFromDialog: boolean,
  url: string
}

@Concurrent
async function longTask() {
  //写发出的请求任务
  try { // 构造RCP请求
    let url = 'https://account.cloud.huawei.com/rest.php?nsp_svc=GOpen.User.getInfo'; // 替换为有效URL
    let response = await http.createHttp().request(url, {
      method: http.RequestMethod.GET,
      connectTimeout: 60000 // 设置超时时间（单位：ms）
    });
    console.info("TeenagerModeInfo66666 " + JSON.stringify(response));
  } catch (error) {
    console.error('TeenagerModeInfo66666' + JSON.stringify((error as BusinessError).message))
  }
}

@Entry
@Component
export struct QuickLoginButtonComponent {
  @StorageProp('topHeight') topHeight: number = 0;
  @StorageProp('bottomHeight') bottomHeight: number = 0;
  logTag: string = 'QuickLoginButtonComponent';
  domainId: number = 0x0000;
  // 第二步获取的匿名化手机号传到此处
  @State quickLoginAnonymousPhone: string = '';
  // 是否勾选协议
  @State isSelected: boolean = false;
  @State code: string = ''
  @State unionID: string | undefined = ''
  @State openID: string | undefined = ''
  @State userInstructions: Partial<UserInstructions> = {}
  @State agreementConfig: HuaweiAgreementConfig = cloneAgreementConfig(DEFAULT_AGREEMENT_CONFIG);
  @State privacyText: loginComponentManager.PrivacyText[] = buildPrivacyTextConfig(DEFAULT_AGREEMENT_CONFIG);
  // 华为账号用户认证协议链接，此处仅为示例，实际开发过程中，出于可维护性、安全性等方面考虑，域名不建议硬编码在本地
  private static USER_AUTHENTICATION_PROTOCOL: string =
    'https://privacy.consumer.huawei.com/legal/id/authentication-terms.htm?code=CN&language=zh-CN';
  private static USER_SERVICE_TAG = AGREEMENT_TAG_USER_SERVICE;
  private static PRIVACY_TAG = AGREEMENT_TAG_PRIVACY;
  private static USER_AUTHENTICATION_TAG = AGREEMENT_TAG_USER_AUTHENTICATION;

  async initUserInstructions() {
    this.updateAgreementConfigFromStorage();
  }

  private updateAgreementConfigFromStorage() {
    const nextConfig: HuaweiAgreementConfig = buildAgreementConfigFromStorage();
    this.agreementConfig = nextConfig;
    this.privacyText = buildPrivacyTextConfig(nextConfig);
  }

  //登陆方法
  async hwLogo(code: string) {
    try {
      // 通过MethodChannel将code发送给Flutter端处理
      const featurePlugin = FeaturePlugin.getInstance();
      const deviceChannel = featurePlugin?.getDeviceChannel();
      if (deviceChannel && code) {
        deviceChannel.invokeMethod("onHuaweiLoginCode", {
          code: code,
          unionID: this.unionID,
          openID: this.openID,
          isCancelled: false
        });
        hilog.info(this.domainId, this.logTag, 'Succeeded in sending login code to Flutter.');
        // 发送成功后关闭登录页面
        this.getUIContext().getRouter().back();
      } else {
        hilog.error(this.domainId, this.logTag, 'DeviceChannel is not available or code is empty.');
        // 通知Flutter端登录失败
        this.notifyLoginCancelled();
        this.showToast('登录失败，请重试');
      }
    } catch (error) {
      hilog.error(this.domainId, this.logTag, 'huaweiLoginError: ' + JSON.stringify(error));
      // 通知Flutter端登录失败
      this.notifyLoginCancelled();
      this.showToast('登录失败，请重试');
    }
  }

  // 通知Flutter端用户取消登录
  notifyLoginCancelled(reason: string = 'CANCELLED') {
    try {
      const featurePlugin = FeaturePlugin.getInstance();
      const deviceChannel = featurePlugin?.getDeviceChannel();
      if (deviceChannel) {
        deviceChannel.invokeMethod("onHuaweiLoginCode", {
          code: "",
          unionID: "",
          openID: "",
          isCancelled: true,
          reason: reason
        });
        hilog.info(this.domainId, this.logTag, 'Notified Flutter that login was cancelled.');
      }
    } catch (error) {
      hilog.error(this.domainId, this.logTag, 'Failed to notify Flutter: ' + JSON.stringify(error));
    }
  }

  // 构造LoginWithHuaweiIDButton组件的控制器
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
    /**
     * 当应用使用自定义的登录页时，如果用户未同意协议，需要设置协议状态为NOT_ACCEPTED，当用户同意协议后再设置
     * 协议状态为ACCEPTED，才可以使用华为账号一键登录功能
     */
      .setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED)
      .onClickLoginWithHuaweiIDButton((error: BusinessError | undefined,
        response: loginComponentManager.HuaweiIDCredential) => {
        this.handleLoginWithHuaweiIDButton(error, response);
      })
      .onClickEvent((error: BusinessError, clickEvent: loginComponentManager.ClickEvent) => {
        if (error) {
          this.dealAllError(error);
          return;
        }
        hilog.info(this.domainId, this.logTag, `onClickEvent clickEvent: ${clickEvent}`);
      });
  agreementDialog: CustomDialogController = new CustomDialogController({
    builder: AgreementDialog({
      privacyText: this.privacyText,
      agreementConfig: this.agreementConfig,
      cancel: () => {
        this.agreementDialog.close();
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
        // 用户取消协议，通知Flutter端（但不关闭页面，让用户可以选择其他登录方式）
      },
      confirm: () => {
        this.agreementDialog.close();
        this.isSelected = true;
        this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
        // 调用此方法，同意协议与登录一并完成，无需再次点击登录按钮
        try {
          let controller = new authentication.AuthenticationController(getContext(this));
          controller.executeRequest(loginRequest, async (err, data) => {
            if (err) {
              hilog.error(0x0000, 'testTag', `Failed to login. Code: ${err.code}, message: ${err.message}`);
              return;
            }
            let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
            let state = loginWithHuaweiIDResponse.state;
            if (state != undefined && loginRequest.state != state) {
              hilog.error(0x0000, 'testTag', `Failed to login. State is different.`);
              return;
            }
            hilog.info(0x0000, 'testTag', `Succeeded in logining.`);

          });
        } catch (error) {
          let err = error as BusinessError;
          hilog.error(0x0000, 'testTag', `Failed to login. Code: ${err.code}, message: ${err.message}`);
        }
        this.controller.continueLogin((error: BusinessError) => {
          if (error) {
            hilog.error(this.domainId, this.logTag,
              `Failed to login with agreementDialog. errCode is ${error.code}, errMessage is ${error.message}`);
          } else {
            hilog.info(this.domainId, this.logTag,
              'Succeeded in clicking agreementDialog continueLogin.');
          }
        });
      },
      clickHyperlinkText: () => {
        this.agreementDialog.close();
        this.jumpToPrivacyWebView();
      }
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
  });

  // 传递页面渲染所需的数据，如匿名手机号等
  aboutToAppear() {
    let task: taskpool.LongTask = new taskpool.LongTask(longTask);
    taskpool.execute(task).then((res: Object) => {
      taskpool.terminateTask(task);
      console.info("taskpool longTask result: " + res);
    });
    this.getQuickLoginAnonymousPhone()
    this.initUserInstructions()
  }

  getQuickLoginAnonymousPhone() {
    // 创建授权请求，并设置参数
    const authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取匿名手机号需传quickLoginAnonymousPhone这个scope，传参之前需要先申请“华为账号一键登录”权限
    authRequest.scopes = ['quickLoginAnonymousPhone'];
    // 用于防跨站点请求伪造
    authRequest.state = util.generateRandomUUID();
    // 一键登录场景该参数必须设置为false
    authRequest.forceAuthorization = false;
    const controller = new authentication.AuthenticationController();
    try {
      controller.executeRequest(authRequest).then((response: authentication.AuthorizationWithHuaweiIDResponse) => {
        // 获取到UnionID、OpenID、匿名手机号
        const unionID = response.data?.unionID;
        const openID = response.data?.openID;
        const anonymousPhone = response.data?.extraInfo?.quickLoginAnonymousPhone as string;

        console.log('extraInfo666' + JSON.stringify(response.data?.extraInfo))
        if (anonymousPhone) {
          hilog.info(0x0000, 'testTag', 'Succeeded in authentication.');
          this.quickLoginAnonymousPhone = anonymousPhone;
          this.unionID = unionID;
          this.openID = openID;
          return;
        }
        hilog.info(0x0000, 'testTag', 'Succeeded in authentication. AnonymousPhone is empty.');
        // 未获取到匿名手机号，但不通知Flutter端，让用户可以选择其他登录方式
        promptAction.showToast({
          message: "未登录"
        })

      }).catch((error: BusinessError) => {
        hilog.error(this.domainId, this.logTag, 'Failed to get anonymous phone: ' + JSON.stringify(error));
        // 获取匿名手机号失败，但不通知Flutter端，让用户可以选择其他登录方式
        this.dealAllError(error);
      })
    } catch (error) {
      hilog.error(this.domainId, this.logTag, 'Failed to get anonymous phone: ' + JSON.stringify(error));
      // 获取匿名手机号失败，但不通知Flutter端，让用户可以选择其他登录方式
      this.dealAllError(error);
    }
  }

  // Toast提示
  showToast(resource: string) {
    try {
      promptAction.showToast({
        message: resource,
        duration: 2000
      });
    } catch (error) {
      const message = (error as BusinessError).message
      const code = (error as BusinessError).code
      hilog.error(this.domainId, this.logTag, `showToast args  errCode is ${code}, errMessage is ${message}`);
    }
  }

  // 跳转华为账号用户认证协议页,该页面需在工程main_pages.json文件配置
  jumpToPrivacyWebView(name?: string) {
    try {
      // 需在module.json5中配置“ohos.permission.GET_NETWORK_INFO”权限
      const checkNetConn = connection.hasDefaultNetSync();
      if (!checkNetConn) {
        this.showToast('服务或网络异常，请稍后重试');
        return;
      }
    } catch (error) {
      const message = error.message as string;
      const code = error.code as string;
      hilog.error(0x0000, 'testTag', `Failed to hasDefaultNetSync, errCode is ${code}, errMessage is ${message}`);
    }
    let targetUrl = '';
    if (name === QuickLoginButtonComponent.USER_SERVICE_TAG) {
      targetUrl = this.agreementConfig.userServiceUrl;
    } else if (name === QuickLoginButtonComponent.PRIVACY_TAG || !name) {
      targetUrl = this.agreementConfig.privacyUrl;
    } else if (name === QuickLoginButtonComponent.USER_AUTHENTICATION_TAG) {
      targetUrl = QuickLoginButtonComponent.USER_AUTHENTICATION_PROTOCOL;
    }
    if (!targetUrl || targetUrl.length === 0) {
      this.showToast('暂未配置协议链接，请稍后重试');
      return;
    }
    this.getUIContext()
      .getRouter()
      .pushUrl({ url: "pages/WebPage", params: { url: targetUrl } })
      .catch((err: BusinessError) => {
        hilog.error(this.domainId, this.logTag, 'Failed to open agreement page: ' + JSON.stringify(err));
        this.showToast('页面打开失败，请稍后重试');
      });
  }

  async handleLoginWithHuaweiIDButton(error: BusinessError | undefined,
    response: loginComponentManager.HuaweiIDCredential) {
    if (error) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton. errCode is ${error.code}, errMessage is ${error.message}`);
      if (error.code === ErrorCode.ERROR_CODE_NETWORK_ERROR) {
        AlertDialog.show(
          {
            message: "网络未连接，请检查网络设置。",
            offset: { dx: 0, dy: -12 },
            alignment: DialogAlignment.Bottom,
            autoCancel: false,
            confirm: {
              value: "知道了",
              action: () => {
              }
            }
          }
        );
      } else if (error.code === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
        // 未同意协议，弹出协议弹框，推荐使用该回调方式
        this.agreementDialog.open();
      } else if (error.code === ErrorCode.ERROR_CODE_LOGIN_OUT) {
        // 华为账号未登录提示
        this.showToast("华为账号未登录，请重试");
        // 通知Flutter端登录失败，回退到普通登录
        this.notifyLoginCancelled('HW_ACCOUNT_NOT_LOGGED_IN');
      } else if (error.code === ErrorCode.ERROR_CODE_NOT_SUPPORTED) {
        // 不支持该scopes或permissions提示
        this.showToast("该scopes或permissions不支持");
        // 通知Flutter端登录失败，回退到普通登录
        this.notifyLoginCancelled('SCOPE_NOT_SUPPORTED');
      } else if (error.code === ErrorCode.ERROR_CODE_PARAMETER_ERROR) {
        // 参数错误提示
        this.showToast("参数错误");
        // 通知Flutter端登录失败，回退到普通登录
        this.notifyLoginCancelled('PARAMETER_ERROR');
      } else {
        // 其他提示系统或服务异常
        this.showToast('服务或网络异常，请稍后重试');
        // 通知Flutter端登录失败，回退到普通登录
        this.notifyLoginCancelled('UNKNOWN_ERROR');
      }
      return;
    }
    try {
      if (this.isSelected) {
        if (response) {
          hilog.info(this.domainId, this.logTag, 'Succeeded in clicking LoginWithHuaweiIDButton.');
          console.log('response1111' + JSON.stringify(response))
          // 开发者根据实际业务情况使用以下信息
          const authCode = response.authorizationCode;
          const openID = response.openID;
          const unionID = response.unionID;
          const idToken = response.idToken;
          console.log('authorizationCode' + authCode)
          this.hwLogo(authCode)

        }
      } else {
        this.agreementDialog.open();
      }
    } catch (err) {
      hilog.error(this.domainId, this.logTag,
        `Failed to login with LoginWithHuaweiIDButton, errCode: ${err.code}, errMessage: ${err.message}`);
      AlertDialog.show(
        {
          message: '服务或网络异常，请稍后重试',
          offset: { dx: 0, dy: -12 },
          alignment: DialogAlignment.Bottom,
          autoCancel: false,
          confirm: {
            value: '知道了',
            action: () => {
            }
          }
        }
      );
    }
  }

  // 错误处理
  dealAllError(error: BusinessError): void {
    hilog.error(this.domainId, this.logTag,
      `Failed to login, errorCode is ${error.code}, errorMessage is ${error.message}`);
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Column() {
            Column() {
              Image($r('app.media.starground'))
                .width(80)
                .height(80)
                .borderRadius(10)
                .draggable(false)
                .copyOption(CopyOptions.None)
                .onComplete(() => {
                  hilog.info(this.domainId, this.logTag, 'appIcon loading success.');
                })
                .onError(() => {
                  hilog.error(this.domainId, this.logTag, 'appIcon loading fail.');
                })
            }.margin({
              top: 100
            })


            if (this.quickLoginAnonymousPhone || this.unionID || this.openID) {
              Column() {
                Text(this.quickLoginAnonymousPhone)
                  .fontSize(28)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Bold)
                  .lineHeight(48)
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
                  .constraintSize({ maxWidth: '100%', minHeight: 48 })

                Text('华为账号绑定号码')
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                  .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(19)
                  .textAlign(TextAlign.Center)
                  .maxLines(1)
                  .constraintSize({ maxWidth: '100%' })
                  .margin({
                    top: 8
                  })
              }.margin({
                top: 64
              })

              Column() {
                LoginWithHuaweiIDButton({
                  params: {
                    // LoginWithHuaweiIDButton支持的样式
                    style: loginComponentManager.Style.BUTTON_CUSTOM,
                    // 账号登录按钮在登录过程中展示加载态
                    extraStyle: {
                      buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                        show: true
                      })
                    },
                    // LoginWithHuaweiIDButton的边框圆角半径
                    borderRadius: 24,
                    // LoginWithHuaweiIDButton支持的登录类型
                    loginType: loginComponentManager.LoginType.QUICK_LOGIN,
                    // LoginWithHuaweiIDButton支持按钮的样式跟随系统深浅色模式切换
                    supportDarkMode: true,
                    // verifyPhoneNumber：如果华为账号用户在过去90天内未进行短信验证，是否拉起Account Kit提供的短信验证码页面
                    verifyPhoneNumber: true,
                    customButtonParams: {
                      backgroundColor: "#FF2B3D"
                    }
                  },
                  controller: this.controller
                })

              }
              .height(40)
              .margin({
                top: 56
              })
            } else {
              Button({
                type: ButtonType.Capsule,
                stateEffect: true
              }) {
                Text('华为账号登录')
                  .fontColor('#fff')
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.ohos_id_text_size_button1'))
                  .focusable(true)
                  .focusOnTouch(true)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .padding({ left: 8, right: 8 })
              }
              .fontColor('#fff')
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor("#FF2B3D")
              .focusable(true)
              .focusOnTouch(true)
              .constraintSize({ minHeight: 40 })
              .width('100%')
              .margin({
                top: 200
              })
              .onClick(() => {
                // 点击兜底登录按钮，同样遵循协议校验并拉起华为账号登录
                if (this.isSelected) {
                  try {
                    let controller = new authentication.AuthenticationController(getContext(this));
                    controller.executeRequest(loginRequest, async (err, data) => {
                      if (err) {
                        hilog.error(0x0000, 'testTag', `Failed to login. Code: ${err.code}, message: ${err.message}`);
                        return;
                      }
                      let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
                      let state = loginWithHuaweiIDResponse.state;
                      if (state != undefined && loginRequest.state != state) {
                        hilog.error(0x0000, 'testTag', `Failed to login. State is different.`);
                        return;
                      }
                      hilog.info(0x0000, 'testTag', `Succeeded in logining.`);
                      let loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
                      let authorizationCode = loginWithHuaweiIDCredential.authorizationCode;
                      console.log('authorizationCode' + authorizationCode)
                    });
                  } catch (error) {
                    let err = error as BusinessError;
                    hilog.error(0x0000, 'testTag', `Failed to login. Code: ${err.code}, message: ${err.message}`);
                  }
                } else {
                  this.agreementDialog.open()
                }

              })
            }

            Column() {
              Button({
                type: ButtonType.Capsule,
                stateEffect: true
              }) {
                Text('其他登录方式')
                  .fontColor('#4B525F')
                  .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize($r('sys.float.ohos_id_text_size_button1'))
                  .focusable(true)
                  .focusOnTouch(true)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .padding({ left: 8, right: 8 })
              }
              .fontColor('#4B525F')
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#F5F5F5')
              .focusable(true)
              .focusOnTouch(true)
              .constraintSize({ minHeight: 40 })
              .width('100%')
              .onClick(() => {
                hilog.info(this.domainId, this.logTag, 'click optionalLoginButton.');
                // 用户选择其他登录方式，通知Flutter端回退到普通登录
                this.notifyLoginCancelled('OTHER_LOGIN_METHOD');
                // 关闭当前页面，返回Flutter页面
                this.getUIContext().getRouter().back();
              })
            }.margin({ top: 16 })
          }.width('100%')

          Row() {
            Row() {
              Checkbox({ name: 'privacyCheckbox', group: 'privacyCheckboxGroup' })
                .width(16)
                .height(16)
                .focusable(true)
                .focusOnTouch(true)
                .selectedColor("#FF2B3D")
                .margin({ top: 0 })
                .select(this.isSelected)
                .onChange((value: boolean) => {
                  if (value) {
                    this.isSelected = true;
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.ACCEPTED);
                  } else {
                    this.isSelected = false;
                    this.controller.setAgreementStatus(loginComponentManager.AgreementStatus.NOT_ACCEPTED);
                  }
                  hilog.info(this.domainId, this.logTag, `agreementChecked: ${value}`);
                })
            }

            Row() {
              Text() {
                ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
                  if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
                    Span(item?.text)
                    // .fontColor(privacyText)
                      .fontColor($r('sys.color.ohos_id_color_text_primary'))
                      .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                      .fontWeight(FontWeight.Regular)
                      .fontSize($r('sys.float.ohos_id_text_size_body3'))
                  } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
                    Span(item?.text)
                      .fontColor("#5480B1")
                      .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                      .fontWeight(FontWeight.Medium)
                      .fontSize($r('sys.float.ohos_id_text_size_body3'))
                      .focusable(true)
                      .focusOnTouch(true)
                      .onClick(() => {
                        // 应用需要根据item.tag实现协议页面的跳转逻辑
                        hilog.info(this.domainId, this.logTag, `click privacy text tag: ${item.tag}`);
                  this.jumpToPrivacyWebView(item.tag as string);
                      })
                  }
                }, (item: loginComponentManager.PrivacyText) => item.text?.toString())
              }
              .width('100%')
            }
            .margin({ left: 12 })
            .layoutWeight(1)
            .constraintSize({ minHeight: 24 })
          }
          .alignItems(VerticalAlign.Top)
          .margin({
            top: 16,
            bottom: 16
          })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .constraintSize({ minHeight: '100%' })
        .margin({
          left: 16,
          right: 16
        })

      }
      .width('100%')
      .height('100%')
      .padding({
        top: this.topHeight,
        bottom: this.bottomHeight
      })
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      // 用户按返回键，通知Flutter端取消登录
      this.notifyLoginCancelled('USER_BACK_PRESS');
      // 返回false允许页面关闭
      return false;
    })

  }
}

@CustomDialog
export struct AgreementDialog {
  logTag: string = 'AgreementDialog';
  domainId: number = 0x0000;
  dialogController?: CustomDialogController;
  cancel: () => void = () => {
  };
  confirm: () => void = () => {
  };
  clickHyperlinkText: () => void = () => {
  };
  privacyText: loginComponentManager.PrivacyText[] = [];
  agreementConfig: HuaweiAgreementConfig = cloneAgreementConfig(DEFAULT_AGREEMENT_CONFIG);
  private static USER_AUTHENTICATION_TAG = AGREEMENT_TAG_USER_AUTHENTICATION;
  @State userInstructions: Partial<UserInstructions> = {}
  private static USER_AUTHENTICATION_PROTOCOL: string =
    'https://privacy.consumer.huawei.com/legal/id/authentication-terms.htm?code=CN&language=zh-CN';
  private static USER_SERVICE_TAG = AGREEMENT_TAG_USER_SERVICE;
  private static PRIVACY_TAG = AGREEMENT_TAG_PRIVACY;

  async initUserInstructions() {
    // const res = await HomeAPI.getCachedData()
    // console.log('666666', JSON.stringify(res?.user_instructions))
    // this.userInstructions = res?.user_instructions || {}
  }

  private refreshAgreementConfig() {
    const nextConfig: HuaweiAgreementConfig = buildAgreementConfigFromStorage();
    this.agreementConfig = nextConfig;
    this.privacyText = buildPrivacyTextConfig(nextConfig);
  }

  private navigateToAgreement(tag?: string) {
    let targetUrl = '';
    if (tag === AgreementDialog.USER_SERVICE_TAG) {
      targetUrl = this.agreementConfig.userServiceUrl;
    } else if (tag === AgreementDialog.PRIVACY_TAG || !tag) {
      targetUrl = this.agreementConfig.privacyUrl;
    } else if (tag === AgreementDialog.USER_AUTHENTICATION_TAG) {
      targetUrl = AgreementDialog.USER_AUTHENTICATION_PROTOCOL;
    }
    if (!targetUrl || targetUrl.length === 0) {
      hilog.warn(this.domainId, this.logTag, 'agreement url is empty, skip navigation.');
      return;
    }
    this.getUIContext()
      .getRouter()
      .pushUrl({ url: "pages/WebPage", params: { url: targetUrl } })
      .catch((error: BusinessError) => {
        hilog.error(this.domainId, this.logTag, 'Failed to open agreement page: ' + JSON.stringify(error));
      });
  }

  aboutToAppear(): void {
    this.initUserInstructions()
    this.refreshAgreementConfig()
  }

  build() {
    Column() {
      Row() {
        Text('用户协议与隐私条款')
          .id('loginPanel_agreement_dialog_privacy_title')
          .maxFontSize($r('sys.float.ohos_id_text_size_headline8'))
          .minFontSize($r('sys.float.ohos_id_text_size_body1'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
      }
      .alignItems(VerticalAlign.Center)
      .constraintSize({ minHeight: 56, maxWidth: 400 })
      .margin({
        left: $r('sys.float.ohos_id_max_padding_start'),
        right: $r('sys.float.ohos_id_max_padding_start')
      })

      Row() {
        Text() {
          ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
            if (item?.type == loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
              Span(item?.text)
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor($r('sys.color.ohos_id_color_text_primary'))
                .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
                .fontWeight(FontWeight.Regular)
            } else if (item?.type == loginComponentManager.TextType.RICH_TEXT && item?.text) {
              Span(item?.text)
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .fontColor("#5480B1")
                .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
                .fontWeight(FontWeight.Medium)
                .focusable(true)
                .focusOnTouch(true)
                .onClick(() => {
                  // 应用需要根据item.tag实现协议页面的跳转逻辑
                  hilog.info(this.domainId, this.logTag, `click privacy text tag: ${item.tag}`);
                  this.navigateToAgreement(item.tag as string);
                  this.dialogController?.close();
                })
            }
          }, (item: loginComponentManager.PrivacyText) => item.text?.toString())
        }
        .width('100%')
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(10)
        .textAlign(TextAlign.Start)
        .focusable(true)
        .focusOnTouch(true)
        .padding({ left: 24, right: 24 })
      }.width('100%')

      Flex({
        direction: FlexDirection.Row
      }) {
        Button('取消',
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_cancel_btn')
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .backgroundColor(Color.Transparent)
          .fontWeight(FontWeight.Medium)
          .focusable(true)
          .focusOnTouch(true)
          .constraintSize({ minHeight: 40, maxWidth: 400 })
          .width('50%')
          .onClick(() => {
            hilog.info(this.domainId, this.logTag, 'AgreementDialog cancel.');
            this.cancel();
          })

        Button('同意并登录',
          { type: ButtonType.Capsule, stateEffect: true })
          .id('loginPanel_agreement_dialog_huawei_id_login_btn')
          .fontColor(Color.White)
          .backgroundColor("#FF2B3D")
          .fontSize($r('sys.float.ohos_id_text_size_button1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontWeight(FontWeight.Medium)
          .focusable(true)
          .focusOnTouch(true)
          .constraintSize({ minHeight: 40, maxWidth: 400 })
          .width('50%')
          .onClick(() => {
            hilog.info(this.domainId, this.logTag, 'AgreementDialog confirm.');
            this.confirm();
          })
      }
      .margin({
        top: 8,
        left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        right: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        bottom: 16
      })
    }.backgroundColor($r('sys.color.ohos_id_color_dialog_default_bg'))
    .padding({
      left: 16,
      right: 16
    })
  }
}

export enum ErrorCode {
  // 账号未登录
  ERROR_CODE_LOGIN_OUT = 1001502001,
  // 该账号不支持一键登录，如海外账号
  ERROR_CODE_NOT_SUPPORTED = 1001500003,
  // 网络错误
  ERROR_CODE_NETWORK_ERROR = 1001502005,
  // 用户未同意用户协议
  ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = 1005300001,
  // 参数错误
  ERROR_CODE_PARAMETER_ERROR = 401
}


export interface UserInstructions {
  user_service: UserInstructionsInfo
  privacy_protected: UserInstructionsInfo
  publish_promise: UserInstructionsInfo
  juveniles_protected: UserInstructionsInfo
}

interface UserInstructionsInfo {
  name: string
  version: number
  link: string
}