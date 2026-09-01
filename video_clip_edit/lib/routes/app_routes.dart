part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const LAUNCH = _Paths.launch;

  static const main = _Paths.main;
  static const userProfile = _Paths.userProfile;

  static const createFolkStoryPage = _Paths.createFolkStoryPage;

  /// 民间故事分步页面
  static const folkStorystepsPage = _Paths.stepsPage;
  static const folkStorystepTwoPage = _Paths.stepTwoPage;
  static const folkStorystepThreePage = _Paths.stepThreePage;
  static const aiCreateCaptionsSetting = _Paths.aiCreateCaptionsSetting;

  static const aiCreatePreviewTextFieldPage =
      _Paths.aiCreatePreviewTextFieldPage;
  static const launchFaild = _Paths.launchFaildPage;
  static const stepsPage = _Paths.stepsPage;
  static const storyManagementPage = _Paths.storyManagementPage;
  static const sliceGeneratePage = _Paths.slicingGeneratePage;

  ///新的短剧创作页面
  static const newShortPlayListPage = _Paths.newShortPlayListPage;

  ///积分页面
  static const integralPage = _Paths.integralPage;

  ///民间故事支付成功
  static const folkStorySuccessPayback = _Paths.folkStorySuccessPayback;

  ///ai动态视频页面
  static const String aiDynamicVideoPage = _Paths.aiDynamicVideoPage;

  ///图片裁剪页面
  static const String imageEditPageForVideo = _Paths.imageEditPageForVideo;

  ///新创作者福利页
  static const String benefitsForCreatorPage = _Paths.benefitsForCreatorPage;

  ///关于我们
  static const String aboutUsPage = _Paths.aboutUsPage;

  ///
  static const String singleShortPlayListPage = _Paths.singleShortPlayListPage;

  ///引导页
  static const String guidePage = _Paths.guidePage;

  ///漫剧
  static const String animePage = _Paths.animePage;

  ///短剧创作引导
  static const String shortDramaPage = _Paths.shortDramaPage;

  ///未成年人页面
  static const String minorPage = _Paths.minorPage;

  ///未成年创建页面
  static const String minorCreatePage = _Paths.minorCreatePage;
}

abstract class _Paths {
  _Paths._();

  static const launch = '/launch';

  static const main = '/main';

  static const userProfile = '/user_profile';

  static const createFolkStoryPage = '/create_fold_story';

  static const launchFaildPage = '/launch_faild';

  static const stepsPage = "/folk_story_steps_page";

  static const stepTwoPage = "/folk_story_step_two_page";

  static const stepThreePage = "/folk_story_step_three_page";

  static const aiCreateCaptionsSetting = '/ai_create_captions_setting';

  static const aiCreatePreviewTextFieldPage =
      '/ai_create_preview_text_field_page';

  static const storyManagementPage = '/folk_story_management_page';

  static const slicingGeneratePage = '/slicing_Generating_page';

  static const newShortPlayListPage = "/short_play_create";

  ///积分页面
  static const integralPage = '/integral';

  static const folkStorySuccessPayback = '/folk_story_success_payback_page';

  ///ai动态视频页面
  static const String aiDynamicVideoPage = "/ai_dynamic_video_page";

  ///图片裁剪页面
  static const String imageEditPageForVideo = "/image_edit_page";

  ///新创作者专属福利页
  static const String benefitsForCreatorPage = "/benefits_for_creator_page";

  ///关于我们
  static const String aboutUsPage = "/about_us_page";

  static const String singleShortPlayListPage = "/single_short_play_list_page";

  ///引导页
  static const String guidePage = "/guide_page";

  ///漫剧
  static const String animePage = '/anime';

  ///短剧创作引导
  static const String shortDramaPage = "/short_drama_page";

  ///未成年人页面
  static const String minorPage = "/minor_page";

  ///未成年创建页面
  static const String minorCreatePage = "/minor_create_page";
}
