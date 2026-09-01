//  description:  api管理

class APIs {
  /// base url
  // static const String apiPrefix = "http://192.168.3.3:8000/api/"; // 本地环境
  // static const String apiPrefix =
  //     "http://mac.proxy.wujingfeng.xyz/api/"; // 本地环境

  static const String apiPrefix = "https://inchat.beiyinapp.com/api/"; // 线上环境
  static const String channel = "2ce49c9cee03d75a";

  //   static const String apiPrefix = "https://chatest.beiyinapp.com/api/"; // 测试环境

  // static const String channel = "3219edbe8ffb3112"; // 测试环境

  // static const String channel = "c59f7d0cdf0db084"; // 应用市场

  // static const String apiPrefix = "https://inchat.mianfeiread.com/api/"; // ios线上环境

  //1110  投放渠道                        3219edbe8ffb3112
  //101   知晓通 百度                     5b08e8a7d644c964
  // 1    默认                           4cf31ce4a26de857
  //237   知晓通-应用宝-默认包             c59f7d0cdf0db084
  // 245  广点通投放-知晓通-默认包          088b1b61fdf64983
  // 251  vivo应用市场-知晓通              73fe77b9e64fff15
  // 252  小米应用市场-知晓通               ac64204db72040ea
  //      知晓通 _oppo                    f185a4c609464bee
  //      知晓通 _ios                     a5946c0ea47914e2
  // 411  知晓通-荣耀应用市场               a1f15c30f8707997
  // 413  知晓通-魅族应用市场               9ee69b4a3d338396
  // 417  知晓通-VIVO-CPD                 324cd8fdb980715e
  // 422  知晓通-华为-应用市场-安卓          ed42f08a730dfd5a

  /// 启动接口（游客登陆）- 获取 token
  static const String launch = 'login/tourist';

  /// 注销账户
  static const String accountCancellations = 'user/accountCancellations';

  /// 启动接口（游客登陆）- 获取 token
  static const String deviceInfo = 'user/device';

  /// 微信登陆
  static const String loginByWX = 'login/wx';

  /// 一键登录
  static const String oneclickv2 = 'login/oneclickv2';

  /// 获取登陆验证码
  static const String sendVCode = "login/sendCode";

  /// 手机号登陆
  static const String loginByPhone = "login/phone";

  /// 退出登陆
  static const String logout = "user/logout";

  /// 自功能列表
  static const String showcaseList = "HomeConfig/showcaseList";

  /// 推小果列表
  static const String homeHotlist = "tuixiaoguo/hotlist";

  /// 推小果URL
  static const String tuixiaoguoUrl = "Navigation/getTuixiaoguoUrl";

  /// 检查DNS
  static const String dnsCheck = "dns/check";

  /// 首页广播
  static const String homeBroadcast = "tuixiaoguo/broadcast";

  /// 首页banner
  static const String homeBanner = "HomeConfig/bannerList";

  /// 个人信息
  static const String loadUserInfo = "user/info";

  /// 个人作品
  static const String getWorkList = "UserWorkLog/getWorkList";

  /// 删除个人作品
  static const String deleteWork = "UserWorkLog/deleteWorkLog";

  /// 个人作品详情
  static const String getWorkDetail = "UserWorkLog/getWorkDetail";

  /// 设置项目
  static const String loadSettingIems = "user/menus";

  ///
  static const String legalright = "user/legalright";

  /// 首页顶部的滚动列表配置
  static const String getHomeScrollListConfig =
      "HomeConfig/getHomeBannerConfig";

  ///====================== VIP ======================

  /// 获取VIP套餐列表
  static const String vipHappys = "vip/happys";

  /// 获取VIP权益列表
  static const String vipRights = "vip/rights";

  /// 获取文案提取列表
  static const String getExtractTextList = "ExtractText/getExtractTextList";

  /// 判断支付后是否展示客服引导弹窗
  static const checkVipGuidStaus = "vip/page";

  ///====================== 智能混剪 ======================
  static const String createUserWork = "UserWorkLog/addLog";
  static const String updateWorkLog = "UserWorkLog/updateWorkLog";
  static const String textRisk = "risk/textRisk";
  static const String getCommentarySimpleText =
      "Commentary/getCommentarySimpleText";

  ///====================== 文字提取 ======================
  static const String textExtract = "ExtractText/ocr";
  static const String imageUpladInfo = "image/imageUpladInfo";
  static const String extractTextBatchDelete = "ExtractText/batchDelete";
  static const String createAudioRecognitionTask =
      "ExtractText/createAudioRecognitionTask";
  static const String queryAudioRecognitionTask =
      "ExtractText/queryAudioRecognitionTask";

  ///====================== 故事创作 ======================
  static const String generalPresets = "general/presets";
  static const String generalRichmessage = "general/richmessage";
  static const String generalMessage = "general/message";
  static const String richmessageconfig = "general/richmessageconfig";
  static const String parseDelete = "video/batchDeleteParseLog";

  /// AI 创作纪录
  static const String generalChats = "general/chatlist";
  static const String generalDelMsg = "general/delMsg";
  static const String generaIlnfo = "general/info";
  static const String batchDeleteMsg = "creator/batchDeleteMsg";
  static const String chatList = "general/chats";
  static const String cleanUpChat = "user/cleanupchat";

  /// AI 助手
  static const String creators = "creator/creators";
  static const String creatorPageInfo = "creator/info";
  static const String creatorMessage = "creator/message";
  static const String assistantRecord = "creator/chatlist";
  static const String assistantDelMsg = "creator/delMsg";
  static const String export = "creator/export";

  ///AIchat
  static const String getModelList = "role/getModelList";
  static const String getDefaultPrompt = "role/getDefaultPrompt";

  ///AI 音乐
  static const String musicAiGetConfig = "MusicAi/getConfig";
  // 根据music的id查询music详情
  static const String queryAiMusicTask = "MusicAi/queryAiMusicTask";

  ///AI 音乐创建任务
  static const String musicAiCreateTask = "MusicAi/createTask";
  static const String aiLyrics = "MusicAi/aiLyrics";
  static const String getTaskList = "MusicAi/getTaskList";
  static const String getDetailList = "MusicAi/getDetailList";
  static const String batchDeleteDetails = "MusicAi/batchDeleteDetails";
  static const String getRightsByType = "vip/getRightsByType";

  /// 获取云端素材库列表
  static const String cloudVideosList = "MultiMedia/getMaterialListWithDetail";

  /// 获取素材详情(分集)
  static const String getMaterialDetail = "MultiMedia/getMaterialDetail";

  /// 创建VIP支付订单
  static const String createVipOrder = "vip/order";
  static const String getConfig = "SuperConfigs/listByGroup";
  static const String queryOrderStatus = "vip/query";
  static const String imageErase = "FileErase/imageErase";
  static const String getEraseRecords = "FileErase/getEraseList";

  /// 视频提取
  static const String parseShareUrl = "video/parseShareUrl";
  static const String getParseList = "video/getParseList";

  // 更新视频提取的任务状态
  // static const String updateParseVideoAddress = "video/updateParseVideoAddress";

  static const String videoIntroList = "video/videoIntroList";
  // static const String dubbingList = "dubbing/initDubbing";
  static const String speakerList = "dubbing/speakerList";
  static const String vipPage = "vip/page";
  static const String voiceStyle = "Commentary/getOptimizeStyles";
  static const String optimizeText = "Commentary/optimizeText";

  /// 配乐分类列表
  static const String bgmCategoryList = "VideoMix/getBgmCateList";

  /// 配乐列表
  static const String bgmList = "VideoMix/bgmList";
  static const String getParseShareUrlConfig = "video/getParseShareUrlConfig";

  /// 生成解说文案
  static const String getCommentaryList = "Commentary/getCommentaryText";

  /// 查看解说文案生成进度
  static const String queryOptimizeTextState = "Commentary/queryState";

  /// 文字转语音
  static const String createDubbingTask = "dubbing/ttsV1";

  /// 批量创建任务
  static const String ttsV1Batch = "dubbing/ttsV1Batch";

  /// 转语音详情
  static const String getDubbingTaskDetails = "dubbing/getTtsByPid";

  /// 批量获取作品详情
  static const String getTtsByPids = "dubbing/getTtsByPids";

  /// 绑定手机号
  static const String bindPhone = "user/bindphonev2";

  /// ********************************** v2 **********************************
  /// AI绘图页面配置信息
  static const String drawConfig = "QiumiImage/config";

  /// 变现教学
  static const String aiCashTutor = "SuperConfigs/allV2";

  /// AI绘图同款案例信息 / ai广场
  static const String aiSquare = "QiumiImage/square";
  // AI音乐
  static const String getSquareList = "MusicAi/getSquareList";
  //AIbanner
  static const String getBannerList = "MusicAi/getBannerList";
  // AI绘图

  /// AI绘图
  static const String aiImageCreate = "QiumiImage/create";

  /// AI绘图进度查询
  static const String aiImageCreateProgress = "QiumiImage/query";

  /// AI绘图详情
  static const String aiImageDetails = "QiumiImage/picinfo";

  /// 我的所有图片
  static const String allAiPictures = "QiumiImage/allpictures";

  /// 图片详情
  static const String picInfo = "QiumiImage/picinfo";

  /// 我的图片带状态参数
  static const String aiPictures = "QiumiImage/pictures";

  /// ai广场
  // static const String aiSquare = "QiumiImage/square";

  /// 推文画面风格
  static const String screenStyleList = "VideoV2/screenStyleList";

  /// 视频比例列表
  static const String videoRatioList = "VideoBy/videoScaleList";

  /// 视频字体列表
  static const String videoFontList = "VideoBy/typeFaceListV2";

  /// ai配音列表
  static const String viVoiceList = "VideoV2/ttsList";

  /// ai本地bgm列表
  static const String customBgmList = "Material/getSelfMaterial";

  /// ai本地bgm上传
  /// 类型:文本 text 图片img 背景音乐bgm 视频video
  static const String uploadBgm = "Material/saveSelfMaterial";

  /// ai本地bgm上传
  /// 类型:文本 text 图片img 背景音乐bgm 视频video
  static const String aiSpeakerList = "DubbingLow/speakerList";

  /// 图文生视频第一步(保存基本参数)
  static const String saveVideoStep1 = "videoBy/videoStep1";

  /// 获取推文随机
  static const String getRandText = "video/getRandText";

  /// 获取文本分段
  static const String articleSplit = "videoV2/articleSplit";

  /// 获取文本分段
  static const String videoStep2 = "videoBy/videoStep2";

  /// 获取文本分段
  static const String imgsList = "videoV2/getById";

  /// 删除分段图片
  static const String cleanItemImg = "videoV2/cleanItemImg";

  /// 生成(或上传或者重绘)单张图片
  static const String regenerateImg = "videoBy/submitItemImg";

  /// 换一张图库
  static const String searchSplitImg = "videoBy/searchSplitImg";

  /// 视频管理列表
  static const String videoList = "video/getMyVideoParamsV2";

  /// 视频生成
  static const String videoSubmit = "videoBy/submitTaskById";

  /// 删除视频
  static const String batchDeleteMyWork = "video/batchDeleteMyWork";

  /// 获取首页变现案例tab配置
  static const String getTabsConfig = "HomeConfig/getExampleTabsConfig";

  /// 鉴黄
  static const String contentsRisk = "risk/risk";

  /// 删除图片
  static const String batchDeletePictures = "QiumiImage/deleteOrders";

  /// 获取作品数量
  static const String getWorksCount = "user/getWorksCount";

  /// 获取用户作品
  static const String getUserWorks = 'user/getWorksCountArr';

  /// 推文广场
  static const String videoSquareList = "HomeConfig/videoSquareList";

  /// ***************************************** 智能混剪 *****************************************
  /// 获取云端素材库列表
  static const aiCloudMaterialList = "MultiMedia/getMaterialCateWithPackList";

  /// 按分类获取明细列表
  static const aiGetDetailList = "MultiMedia/getDetailList";

  /// 云端素材库样片列表
  static const aiMaterialDemoList = "MultiMedia/getMaterialDemoList";

  /// 图文生视频第一步(保存基本参数)
  static const aiClipSave = "videoMix/videoStep1";

  /// 视频比例列表
  static const aiVideoScaleList = "VideoMix/videoScaleList";

  /// 字体列表
  static const aiTypeFaceList = "VideoMix/typeFaceList";

  /// 获取云端素材库列表
  static const aiBgmCateList = "VideoMix/getBgmCateList";

  /// 获取云端素材库列表
  static const aiBgmList = "VideoMix/bgmList";

  /// 获取云端素材库列表
  static const aiMaterialsList = "MultiMedia/getMaterialCateWithPackList";

  /// 获取片头
  static const aiMaterialsOpeningList = "MultiMedia/getMaterialTitlesList";

  /// 创建配音
  static const aiTtsVideo = "DubbingLow/ttsVideo";

  /// ***************************************** AI 视频 *****************************************

  /// 广场视频列表
  static const aiVideoCategoryDetail = "VideoAi/getAiVideoCategoryDetail";

  /// 视屏详情
  static const queryAiVideoTask = "VideoAi/queryAiVideoTask";

  /// ***************************************** 智能混剪 *****************************************
  /// ***************************************** 积分权益 *****************************************

  /// 积分套餐列表
  static const scoreHappys = "IntegralVip/happys";

  /// 积分页面数据
  static const scoresInfo = "IntegralVip/page";

  /// 积分日志
  static const scoreRecords = "IntegralVip/logs";

  /// 创建订单
  static const createOrder = "IntegralVip/order";

  /// 积分创建订单
  static const createOrderv2 = "IntegralVip/orderv2";

  /// 查询订单状态
  static const queryOrder = "IntegralVip/query";

  /// ***************************************** 积分权益 *****************************************

  /// ***************************************** 数字人 *****************************************
  /// 声音克隆 --------
  /// 获取克隆列表
  static const getUserAudioCloneList = "UserAudioClone/getUserAudioCloneList";

  /// 删除声音克隆
  static const deleteUserAudioClone = "UserAudioClone/deleteUserAudioClone";

  /// 修改声音克隆标题
  static const renameUserAudioClone = "UserAudioClone/renameUserAudioClone";

  /// 创建声音克隆
  static const createUserAudioClone = "UserAudioClone/createUserAudioClone";

  /// 获取默认的朗读文本
  static const getDefaultTxt = "UserAudioClone/getDefaultTxt";

  /// 删除上传的视频
  static const deleteUserVideo = "Material/deleteSelfMatrial";

  /// 上传视频
  static const uploadUserVideo = "Material/saveSelfMaterial";

  /// 获取配音详情
  static const queryUserAudioClone = "UserAudioClone/queryUserAudioClone";

  /// 保存音色
  static const saveUserAudioClone = "UserAudioClone/saveUserAudioClone";

  /// 创建配音任务
  static const createUserAudioTTS = "UserAudioTTS/createUserAudioTTS";

  /// 获取配音详情
  static const getUserAudioTTS = "UserAudioTTS/getUserAudioTTS";

  /// 删除任务
  static const deleteUserAudioTTS = "UserAudioTTS/deleteUserAudioTTS";

  /// 获取任务列表
  static const getUserAudioTTSList = "UserAudioTTS/getUserAudioTTSList";

  /// 重命名配音
  static const renameUserAudioTTS = "UserAudioTTS/renameUserAudioTTS";

  /// 口播 --------
  /// 创建口播(数字人)任务
  static const createDigitalHuman = "DigitalHuman/createDigitalHuman";

  /// 获取口播任务详情
  static const getDigitalHuman = "DigitalHuman/getDigitalHuman";

  /// 口播任务列表
  static const getDigitalHumanList = "DigitalHuman/getDigitalHumanList";

  /// 删除任务
  static const deleteDigitalHuman = "DigitalHuman/deleteDigitalHuman";

  /// 转换视频比特率
  static const convertVideoRatio = "video/changeScale";

  /// ***************************************** 数字人 *****************************************

  /// ***************************************** 新工具箱 *****************************************

  /// 工具箱列表类别
  static const crumbsCategoryList = "/HomeConfig/crumbsCategoryList";

  /// 工具箱列表数据
  static const crumbsList = "/HomeConfig/crumbsList";

  /// 获取推文视频详情
  static const videoSquareInfo = "HomeConfig/videoSquareInfo";

  /// ***************************************** 新工具箱 *****************************************
  /// ***************************************** 爆款复刻 *****************************************
  /// 创建爆款复刻任务
  static const createHotCopy = "videoMix/createHotCopy";

  /// ***************************************** 爆款复刻 *****************************************

  /// ***************************************** 爆文创作 *****************************************
  /// 获取分类配置
  static const categoryConfig = "Tuixiaobei/getConfig";

  /// 获取小说列表
  static const getNovelList = "Tuixiaobei/getNovelList";

  /// 获取小说章节列表
  static const getNovelDetailList = "Tuixiaobei/getNovelDetailList";

  /// 推广页菜单配置
  static const getPromotionMenu = "Navigation/getPromotionMenu";

  /// 混剪啊文案 - AI改写
  static const explanationDramaText = "VideoMix/explanationDramaText";

  /// ***************************************** 爆文创作 *****************************************

  ///首页智能绘图
  static const aiTips = "ImageChats/tips";

  ///首页智能回答
  static const aiPresets = "general/presets";

  ///首页ai动态视频
  static const aiVideoBanner = "VideoAi/getBannerList";

  ///首页ai写歌
  static const aiMusic = "/MusicAi/getBannerList";

  ///批量导出ai创作
  static const exportAiNovelBatch = "AiNovel/exportAiNovelBatch";

  ///根据id 获取短剧详情
  static const getMaterialInfo = "MultiMedia/getMaterilInfo";

  ///头条回传
  static const oceanengineSuccess = "Oceanengine/success";
  static const oceanengineFail = "Oceanengine/fail";

  /// 新民间故事
  /// 获取民间故事详情
  static const storyInfo = "folkStory/getFolkStoryInfo";

  /// 获取民间故事列表
  static const folkStoryList = "folkStory/getFolkStoryList";

  /// 获取民间故事列表
  static const storyList = "folkStory/getFolkStoryList";

  /// 获取民间故事角色列表
  static const roleList = "folkStory/getRoleList";

  /// 获取角色详情
  static const roleInfo = "folkStory/getRoleInfo";

  /// 修改角色信息
  static const updateRoleInfo = "folkStory/updateRoleInfo";

  /// 角色重绘
  static const roleRepaint = "folkStory/roleRepaint";

  /// 手动开始分镜
  static const manualDrawScene = "folkStory/manualDrawScene";

  /// 获取分镜列表
  static const sceneList = "folkStory/getSceneList";

  /// 获取分镜信息
  static const sceneInfo = "folkStory/getSceneInfo";

  /// 修改分镜信息
  static const updateSceneInfo = "folkStory/updateSceneInfo";

  /// 分镜重绘
  static const sceneRepaint = "folkStory/sceneRepaint";

  /// 开始生成视频
  static const createVideoTask = "folkStory/createVideoTask";

  ///新的配乐列表
  static const String bgmListNew = "VideoMix/bgmListNew";

  ///公告
  static const String noticeData = "common/notice";

  /// 删除民间故事
  static const deleteFolkStory = "folkStory/delFolkStory";

  /// 一键成片
  /// 获取一键成片的分类
  static const String filmCategory = "common/OneClickFilmCategory";

  /// 根据分类id获取一键成片提示词列表
  static const String filmPrompt = "common/getOneClickFilmPrompt";

  /// 获取随机的故事灵感
  static const String randomPrompt = "common/getRandomPrompt";

  ///ios-支付相关
  static const iosOrder = "vip/orderv2";
  static const iosRepair = "vip/iosRepair";

  ///攻略列表
  static const String strategyGuideList = "ComConfig/strategyGuideList";

  ///图生视频（仅用于首尾帧与多图参考两种模式）
  static const String createFunnyVideoTask = "videoAi/createFunnyVideoTask";

  ///接口上报
  static const apiPost = "event/report";

  /// 获取平台
  static const String getMaterialConfig = "MultiMedia/getMaterialConfig";

  /// 获取归因付费页样式
  static const String payStyle = 'PayPage/getPayPageConfig';

  /*
    AI漫剧
  */
  ///漫剧列表
  static const String animeList = 'AiVideoDaram/getTemplateList';

  ///漫剧配置
  static const String animeConfig = 'AiVideoDaram/getConfig';

  ///创建任务
  static const String animeCreate = 'AiVideoDaram/createTask';

  ///创建任务
  static const String animeRecord = 'AiVideoDaram/getTaskList';

  ///删除记录
  static const String animeDelete = 'AiVideoDaram/deleteTask';

  ///获取漫剧详情
  static const String animeDetail = 'AiVideoDaram/getTemplateById';

  ///获取付费页面顶部素材
  static const String getPayPageTopMaterial =
      'api/PayPage/getPayPageTopMaterial';

  ///根据id获取支付挽留套餐信息
  static const String getOrderInfoById = 'vip/getOrderInfoById';

  ///获取拦截弹窗配置
  static const String getPopConfig = 'BlockPopUp/getPopConfig';

  ///根据id获取拦截弹窗配置
  static const String getPopUpConfigById = 'BlockPopUp/getPopUpConfigById';

  /*********未成年人模式 *********/

  ///首次开启未成年人模式
  static const String enableMinorMode = 'user/enableMinorMode';

  /// 关闭未成年人模式
  static const String setMinorModeStatus = 'user/setMinorModeStatus';

  ///编辑使用时段
  static const String updateMinorModeTimeLimit =
      'user/updateMinorModeTimeLimit';

  ///获取配置详情
  static const String minorModeInfo = 'user/minorModeInfo';

  ///忘记密码
  static const String forgotMinorModePassword = 'user/forgotMinorModePassword';

  ///未成年人使用协议
  static const String minorAgreementUrl =
      'https://inchat.beiyinapp.com/api/common3/minorAgreement';
}
