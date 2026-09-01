class Consts {
  static const kSystemAndroid = "android";
  static const kSystemIOS = "ios";
  ///app安装时间，第一次启动时间
  static const kAppInstalledTime = "kAppInstalledTime";

  /// 启动时，用户协议是否已同意
  static const kAgreementChecked = "kAgreementChecked";
  static const kOralMuted = "kOralMuted";
  static const kUpgradeDialogShown = "kUpgradeDialogShown";

  /// 混剪引导页是否已弹出
  static const kGuidClipVoiceHasShown = "kGuidClipVoiceHasShown";

  /// 二创引导页是否已弹出
  static const kGuidRecreateVoiceHasShown = "kGuidRecreateVoiceHasShown";

  static const kVoiceoverSubtitlePage = "kVoiceoverSubtitlePage";
  static const kAddMaterialPage = "kAddMaterialPage";

  /// 添加作品纪录的type
  /// 1视频混剪 2短剧二创 3普通剪辑
  static const kUserWorkLogTypeClip = 1;
  static const kUserWorkLogTypeRecreate = 2;
  static const kUserWorkLogTypeClipNormal = 3;

  static const kConfigValueTypeText = 50;
  static const kConfigValueTypeAppPage = 51;
  static const kConfigValueTypeAppSecondPage = 52;
  static const kConfigValueTypeLink = 53;
  static const kConfigValueTypePicture = 100;

  static const ratiosMap = {
    "1:1": 1 / 1,
    "3:4": 3 / 4,
    "4:3": 4 / 3,
    "16:9": 16 / 9,
    "9:16": 9 / 16,
  };




  ///分功能分析-付费页面上报
  static const EVENT_PAID_PAGE = "event_paid_page";

  ///小说推文
  static const FUNCTION_NOVEL_TWEETS = 'function_novel_tweets';

  ///儿童绘本
  static const FUNCTION_PICTURE_BOOK = 'function_picture_book';

  ///民间故事
  static const FUNCTION_FOLK_STORY = 'function_folk_story';

  ///短剧解说
  static const FUNCTION_SKIT_COMMENTARY = 'function_skit_commentary';

  ///爆文创作
  static const FUNCTION_EXPLOSIVE_WRITING = 'function_explosive_writing';

  ///一键成片
  static const FUNCTION_ONE_CLICK_FILM = 'function_one_click_film';

  ///功能点击上报
  static const ACTION_FUNCTION_CLICK_REPORT = 'action_function_click';

  /// 打开付费页
  static const ACTION_OPEN_PAY_PAGE_REPORT = 'action_open_pay_page';

  ///打开中间页面
  static const ACTION_OPEN_MIDDLE_PAGE_REPORT = 'action_open_middle_page';

  /// 展示中间页面
  static const ACTION_SHOW_MIDDLE_PAGE_REPORT = 'action_show_middle_page';
  /// 创建订单
  static const ACTION_CREATE_ORDER_REPORT = 'action_create_order';

  ///订单付费成功
  static const ACTION_PAID_SUCCESS_REPORT = 'action_paid_success';


  ///大数据缓存
  ///首页热门同款数据
  static const CRUMBS_CATEGORY_LIST = 'crumbs_category_list';
  ///首页金刚位数据
  static const HOME_SHOW_CASE_LIST = 'home_show_case_list';
  ///首页banner位数据(顶部功能位)
  static const HOME_TOP_BANNER = 'home_top_banner';

}
