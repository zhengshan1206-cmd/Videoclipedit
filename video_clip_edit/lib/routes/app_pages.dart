import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/guide/guide_binding.dart';
import 'package:video_clip_edit/modules/guide/guide_page.dart';
import 'package:video_clip_edit/modules/guide/short_drama_page.dart';
import 'package:video_clip_edit/modules/main/bindings/launch_error_binding.dart';
import 'package:video_clip_edit/modules/main/bindings/main_binding.dart';
import 'package:video_clip_edit/modules/main/launch_error_page.dart';
import 'package:video_clip_edit/modules/main/launch_page.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/v2/Me/AboutUs/pages/about_us_page.dart';
import 'package:video_clip_edit/v2/aiCreate/bindings/create_folk_story_steps_binding.dart';
import 'package:video_clip_edit/v2/aiCreate/bindings/ai_create_captions_setting_binding.dart';
import 'package:video_clip_edit/v2/aiCreate/bindings/folk_story_management_binding.dart';
import 'package:video_clip_edit/v2/aiCreate/views/ai_create_captions_setting.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_story_step_three_page.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_story_step_two_page.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_story_steps_page.dart';
import 'package:video_clip_edit/v2/aiCreate/views/ai_create_preview_text_field_page.dart';
import 'package:video_clip_edit/v2/aiCreate/views/folk_stoy_video_management_page.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_dynamic_video_page.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/image_edit_page.dart';
import 'package:video_clip_edit/v2/business/benefits_for_creator_page.dart';
import 'package:video_clip_edit/v2/folkStory/widget/folk_story_success_create.dart';
import 'package:video_clip_edit/v2/hotCreate/new_short_play_list_page.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/new_short_play_list_binding.dart';
import 'package:video_clip_edit/v2/profile/bindings/home_mine_binding.dart';
import 'package:video_clip_edit/v2/profile/bindings/user_profile_binding.dart';
import 'package:video_clip_edit/v2/profile/views/user_profile_page.dart';
import 'package:video_clip_edit/v2/promote/bindings/home_promote_binding.dart';
import 'package:video_clip_edit/v2/aiCreate/bindings/create_folk_story_binding.dart';
import 'package:video_clip_edit/v2/aiCreate/views/create_folk_story_page.dart';
import 'package:video_clip_edit/v2/slicing/binding/content_generating_binding.dart';
import 'package:video_clip_edit/v2/slicing/contents_generating_page.dart';
import 'package:video_clip_edit/v2/integral/integral_page.dart';
import 'package:video_clip_edit/v2/integral/integral_controller.dart';
import 'package:video_clip_edit/v2/integral/bindings/integral_vip_binding.dart';

import '../modules/home/providers/stroy_create_provider.dart';
import '../v2/Me/AboutUs/bindings/abount_us_binding.dart';
import '../v2/aiClip/provider/ai_clip_mine_materials_provider.dart';
import '../v2/aiClip/provider/ai_clip_opening_provider.dart';
import '../v2/aiClip/provider/ai_clip_provider.dart';
import '../v2/aiClip/provider/ai_material_provider.dart';
import '../v2/anime/pages/anime_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(name: _Paths.launch, page: () => const LaunchPage()),
    GetPage(
      name: _Paths.main,
      page: () => const MainPage(),
      bindings: [
        MainBinding(),
        HomePromoteBinding(),
        HomeMineBinding(),
        IntegralVipBinding(),
      ],
      transition: Transition.noTransition,
    ),
    GetPage(
      name: _Paths.userProfile,
      page: () => const UserProfilePage(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: _Paths.createFolkStoryPage,
      page: () => const CreateFolkStoryPage(),
      binding: CreateFolkStoryBinding(),
    ),
    GetPage(
      name: _Paths.launchFaildPage,
      page: () => const LaunchErrorPage(),
      binding: LaunchErrorBinding(),
    ),
    GetPage(
      name: _Paths.stepsPage,
      page: () => const FolkStoryStepsPage(),
      binding: CreateFolkStoryStepsBinding(),
    ),
    GetPage(name: _Paths.stepTwoPage, page: () => const FolkStoryStepTwoPage()),
    GetPage(
      name: _Paths.stepThreePage,
      page: () => const FolkStoryStepThreePage(),
    ),
    GetPage(
      name: _Paths.aiCreateCaptionsSetting,
      page: () => const AiCreateCaptionsSetting(),
      binding: AiCreateCaptionsSettingBinding(),
    ),
    GetPage(
      name: _Paths.aiCreatePreviewTextFieldPage,
      page: () => const AiCreatePreviewTextFieldPage(),
    ),
    GetPage(
      name: _Paths.storyManagementPage,
      page: () => const FolkStoyVideoManagementPage(),
      binding: FolkStoryManagementBinding(),
    ),
    GetPage(
      name: _Paths.slicingGeneratePage,
      page: () => const ContentsGeneratingPage(),
      binding: ContentGeneratingBinding(),
    ),

    ///积分页面
    GetPage(
      name: _Paths.integralPage,
      page: () => const IntegralPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<IntegralController>(() => IntegralController());
      }),
    ),

    //民间故事支付成功
    GetPage(
      name: _Paths.folkStorySuccessPayback,
      page: () => const FolkStorySuccessCreateVIPAwailable(),
    ),

    //关于我们
    GetPage(
      name: _Paths.aboutUsPage,
      page: () => const AboutUsPage(),
      binding: AboutUsBinding(),
    ),

    ///新的短剧创作页面
    // GetPage(name: _Paths.newShortPlayListPage, page: ()=> const NewShortPlayListPage(),
    //   binding: NewShortPlayListBinding()
    // )
    GetPage(
      name: _Paths.newShortPlayListPage,
      page: () => ChangeNotifierProvider(
        create: (context) => StroyCreateProvider(),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AiClipProvider()),
            ChangeNotifierProvider(
              create: (BuildContext context) => AiMaterialProvider(),
            ),
            ChangeNotifierProvider(
              create: (BuildContext context) => AiClipOpeningProvider(),
            ),
            ChangeNotifierProvider(
              create: (BuildContext context) => AiClipMineMaterialsProvider(),
            ),
          ],
          child: const NewShortPlayListPage(),
        ),
      ),
      binding: NewShortPlayListBinding(),
    ),
    GetPage(
      name: _Paths.aiDynamicVideoPage,
      page: () => const AIDynamicVideoPage(),
    ),
    GetPage(
      name: _Paths.imageEditPageForVideo,
      page: () {
        return const ImageEditPage();
      },
    ),
    GetPage(
      name: _Paths.benefitsForCreatorPage,
      page: () {
        return const BenefitsForCreatorPage();
      },
    ),

    GetPage(
      name: _Paths.guidePage,
      page: () {
        return const GuidePage();
      },
      binding: GuideBinding(),
    ),

    GetPage(
      name: _Paths.animePage,
      page: () {
        return AnimePage();
      },
    ),

    GetPage(
      name: _Paths.shortDramaPage,
      page: () {
        return const ShortDramaPage();
      },
    ),
  ];
}

class RouterUtil {
  static String initialRoute() => nextRoute();

  static String nextRoute() {
    return Routes.LAUNCH;
  }
}
