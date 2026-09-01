import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/guid/add_material_guid_page.dart';
import 'package:video_clip_edit/modules/guid/clip/cloud_materials_guid_page.dart';
import 'package:video_clip_edit/modules/home/clipped/clipped_page.dart';
import 'package:video_clip_edit/modules/home/deduplication/video_dedupliaction_page.dart';
import 'package:video_clip_edit/modules/home/erase/video_erase_page.dart';
import 'package:video_clip_edit/modules/home/forbidden_words_detect_page.dart';
import 'package:video_clip_edit/modules/home/providers/by_audio_player.dart';
import 'package:video_clip_edit/modules/home/providers/clipped_provider.dart';
import 'package:video_clip_edit/modules/home/providers/forbidden_words_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/providers/video_deduplication_provider.dart';
import 'package:video_clip_edit/modules/home/providers/video_erase_provider.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/short_show_recreate_page.dart';
import 'package:video_clip_edit/modules/home/story/assistant/assistant_info_page.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/creator_bean.dart';
import 'package:video_clip_edit/modules/home/story/beans/story_argument_bean.dart';
import 'package:video_clip_edit/modules/home/words/words_extraction_page.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/modules/profile/mine_video_materials_management_page.dart';
import 'package:video_clip_edit/modules/profile/mine_words_management_page.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_video_materials_management_provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_words_management_provider.dart';
import 'package:video_clip_edit/modules/purchase/ios_purchase_page.dart';
import 'package:video_clip_edit/modules/purchase/new_page/new_purchase_blue.dart';
import 'package:video_clip_edit/modules/purchase/new_page/new_purchase_red.dart';
import 'package:video_clip_edit/modules/purchase/new_page/purchase_page_five.dart';
import 'package:video_clip_edit/modules/purchase/new_page/purchase_page_four.dart';
import 'package:video_clip_edit/modules/purchase/new_purchase/ios_purchase/new_ios_purchase_page.dart';
import 'package:video_clip_edit/modules/purchase/purchase_page.dart';
import 'package:video_clip_edit/modules/purchase/purchase_page_dark.dart';
import 'package:video_clip_edit/modules/purchase/purchase_page_new.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/extraction_recent_tasks_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/guide_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/video_extraction_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoSplit/video_split_page.dart';
import 'package:video_clip_edit/v2/AiNovel/providers/ai_novel_provider.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/minorMode/minor_mode_navigation_guard.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_page.dart';
import 'package:video_clip_edit/routes/route_page_const.dart';
import 'package:video_clip_edit/providers/home_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_my_dubbing_list_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/ai_oral_video_management_page.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiOralVideos/providers/ai_oral_videos_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_video_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/chat/ai_chat_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_management_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_work_management_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_settings_mixin.dart';
import 'package:video_clip_edit/v2/aiSquare/song/ai_song_page.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/song/ai_song_tasks_page.dart';
import 'package:video_clip_edit/v2/aiSquare/song/ai_song_view_page.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/ai_song_task_detail_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/song/provider/ai_song_tasks_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/song/provider/ai_song_view_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/writing/ai_writing_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_square_model.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_dynamic_video_page.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_video_management_page.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_videos_same_case_page.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/new_ai_video_page.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_provider.dart';
import 'package:video_clip_edit/v2/anime/beans/anime_bean.dart';
import 'package:video_clip_edit/v2/hotCreate/hot_novel_create_page.dart';
import 'package:video_clip_edit/v2/hotCreate/providers/novel_create_provider.dart';
import 'package:video_clip_edit/v2/hotReplica/hot_case_replica_page.dart';
import 'package:video_clip_edit/v2/hotReplica/providers/hot_case_replica_provider.dart';
import 'package:video_clip_edit/v2/materialsLib/ai_my_materials_lib_page.dart';
import 'package:video_clip_edit/modules/home/story/story_create_home_page.dart';
import 'package:video_clip_edit/v2/aiSquare/novelwriting/ai_novel_writing.dart';
import 'package:video_clip_edit/v2/aiSquare/writing/ai_writing_record_page.dart';
import 'package:video_clip_edit/v2/aiSquare/song/provider/ai_song_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/writing/ai_writing_setting_page.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/writing/provider/ai_writing_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_mine_materials_provider.dart';
import 'package:video_clip_edit/v2/materialsLib/providers/ai_my_material_lib_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/novelwriting/providers/ai_novel_writing_providers.dart';
import 'package:video_clip_edit/v2/toolBox/new_same_case_square_page.dart';
import 'package:video_clip_edit/v2/toolBox/new_tool_box_page.dart';
import 'package:video_clip_edit/v2/toolBox/providers/new_tool_box_provider.dart';

import '../modules/home/beans/cloud_video_bean.dart';
import '../modules/home/clipped/video_clip_hyber_page.dart';
import '../modules/purchase/new_purchase/ios_purchase/ui_type_enum.dart';
import '../providers/ai_chat_providers.dart';
import '../providers/ios_purchase_provider.dart';
import '../v2/AiNovel/pages/new_ai_novel_page.dart';
import 'package:video_clip_edit/modules/home/clipped/video_clip_hyber_preview.dart';
import '../v2/aiOralVideos/ai_oral_videos_create_page.dart';
import '../v2/aiOralVideos/providers/ai_oral_dubbing_anchor_provider.dart';
import '../v2/aiOralVideos/providers/ai_oral_dubbing_provider.dart';
import '../v2/aiPhotoFix/pages/new_hd_photo_fix_page.dart';
import '../v2/aiPhotoFix/pages/new_old_photo_fix_page.dart';
import '../v2/aiPhotoFix/provider/ai_photo_fix_provider.dart';
import '../v2/aiSquare/draw/ai_draw_details_page.dart';
import '../v2/aiSquare/draw/ai_draw_work_details_page.dart';
import '../v2/folkStory/widget/folk_story_list_page.dart';
import '../v2/hotCreate/providers/short_show_details_provider.dart';
import '../v2/hotCreate/short_play_list_page.dart';
import '../widgets/toast_util.dart';
import 'app_pages.dart';

class RouteUtils {
  static Map<String, WidgetBuilder> routeList = {
    "/home": (context) => const MainPage(),
    "/toolBox": (context) => const MainPage(),
    "/mine": (context) => const MainPage(),
    // 文案创作
    "/storyCreation": (BuildContext context) => ChangeNotifierProvider(
      create: (context) => StroyCreateProvider(),
      child: const StoryCreateHomePage(select: 0),
    ),
    // 文案创作/助手
    "/storyAssistant": (BuildContext context) => ChangeNotifierProvider(
      create: (context) => StroyCreateProvider(),
      child: const StoryCreateHomePage(select: 1),
    ),
    // 使用攻略
    "/guide": (BuildContext context) => ChangeNotifierProvider(
      create: (context) => VideoExtractionProvider(),
      child: const GuidePage(),
    ),
    // 去水印
    "/removeWatermark": (BuildContext context) => ChangeNotifierProvider(
      create: (context) => VideoEraseProvider(),
      child: const VideoErasePage(),
    ),
    // 去除字幕
    "/removeSubtitles": (BuildContext context) => ChangeNotifierProvider(
      create: (context) => VideoEraseProvider(),
      child: const VideoErasePage(),
    ),
    // 违禁词
    "/wordDetection": (BuildContext context) => ChangeNotifierProvider(
      create: (BuildContext context) => ForbiddenWordsProvider(),
      child: const ForbiddenWordsDetectPage(),
    ),
    // 视频擦除
    "/videoErase": (BuildContext context) => ChangeNotifierProvider(
      create: (context) => VideoEraseProvider(),
      child: const VideoErasePage(),
    ),
    // 文案提取
    "/copywritingExtraction": (BuildContext context) => ChangeNotifierProvider(
      create: (context) => WordsExtractProvider(),
      child: const WordsExtractionPage(),
    ),
    // 智能去重
    "/videoDeduplication": (BuildContext context) => ChangeNotifierProvider(
      create: (BuildContext context) => VideoDeduplicationProvider(),
      child: const VideoDedupliactionPage(),
    ),
    // 视频提取
    "/videoExtraction": (BuildContext context) => ChangeNotifierProvider(
      create: (ctx) => VideoExtractionProvider(),
      child: const VideoExtractionPage(),
    ),
    // 视频拆分/视频分割
    "/videoSplit": (BuildContext context) => ChangeNotifierProvider(
      create: (ctx) => VideoExtractionProvider(),
      child: const VideoSplitPage(),
    ),
    // 视频混剪
    "/videoMix": (BuildContext context) =>
        ChangeNotifierProvider<ClippedProvider>(
          create: (ctx) => ClippedProvider(),
          child: const ClippedPage<ClippedProvider>(),
        ),
    // 短剧二创
    "/voideCreate": (BuildContext context) =>
        ChangeNotifierProvider<ShowRecreateProvider>(
          create: (context) => ShowRecreateProvider(),
          child: const ShortShowRecreatePage<ShowRecreateProvider>(),
        ),
    //编辑视频预设参数
    "/hyberClipContent": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => ShowRecreateProvider(),
        child: VideoClipHyberPage(),
      );
    },
    "/rechargeOld": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => PurchaseProvider(),
        child: const PurchasePage(),
      );
    },
    "/rechargeNew": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => PurchaseProvider(),
        child: const PurchasePageDark(),
      );
    },
    "/rechargeMbgf": (BuildContext context) {
      if (Platform.isIOS) {
        return ChangeNotifierProvider(
          create: (context) => IosPurchaseProvider(),
          child: const IosPurchasePage(),
        );
      } else {
        return ChangeNotifierProvider(
          create: (context) => PurchaseProvider(),
          child: const PurchasePageNew(),
        );
      }
    },
    "/rechargeMbgf2": (BuildContext context) {
      if (Platform.isIOS) {
        return ChangeNotifierProvider(
          create: (context) => IosPurchaseProvider(),
          child: const NewIosPurchasePage(),
        );
      } else {
        return ChangeNotifierProvider(
          create: (context) => PurchaseProvider(),
          child: const NewPurchasePageBlue(),
          // child: const NewPurchasePageRed()  ,
        );
      }
    },

    "/rechargeMbgf3": (BuildContext context) {
      if (Platform.isIOS) {
        return ChangeNotifierProvider(
          create: (context) => IosPurchaseProvider(),
          child: const NewIosPurchasePage(type: PurchaseUiType.Red),
        );
      } else {
        return ChangeNotifierProvider(
          create: (context) => PurchaseProvider(),
          child: const NewPurchasePageRed(),
        );
      }
    },
    "/rechargeMbgf4": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => PurchaseProvider(),
        child: const PurchasePageFour(),
      );
    },

    "/rechargeMbgf5": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => PurchaseProvider(),
        child: const PurchasePageFive(),
      );
    },

    "/ai_tweets": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiCartoonProvider(),
        child: const AiCartoonPage(pagePath: "/ai_tweets"),
      );
    },
    "/ai_draw": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiDrawProvider(),
        child: const AiDrawPage(),
      );
    },
    RoutePageConst.aiSongPageName: (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiSongProvider(),
        child: AiSongPage(),
      );
    },
    "/ai_material_lib": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiMyMaterialLibProvider(),
        child: const AiMyMaterialsLibPage(),
      );
    },
    RoutePageConst.aiWritingPageName: (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiWritingProvider(),
        child: const AiWritingPage(),
      );
    },

    RoutePageConst.aiWritingRecord: (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiWritingProvider(),
        child: const AiWritingRecordPage(),
      );
    },
    RoutePageConst.aiWritingSetting: (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiWritingProvider(),
        child: const AiWritingSettingPage(),
      );
    },
    RoutePageConst.aiNovelWriting: (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiNovelWritingProviders(),
        child: const AiNovelWriting(),
      );
    },
    "/ai_oral_videos": (BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AiOralVideosProvider()),
          ChangeNotifierProvider.value(
            value: ByAudioPlayer.sharedInstance.statusProvider,
          ),
          ChangeNotifierProvider(create: (context) => AiOralDubbingProvider()),
          ChangeNotifierProvider(
            create: (context) => AiOralDubbingAnchorProvider(),
          ),
        ],
        child: const AiOralVideosCreatePage(),
      );

      // return const AiOralVideosPage();
    },
    "/ai_novel": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiNovelProvider(),
        child: const NewAiNovelPage(),
      );
    },
    "/ai_text_to_video": (BuildContext context) {
      // queryAiVideoTask
      return ChangeNotifierProvider(
        create: (context) => AiVideoProvider(),
        child: const NewAiVideoPage(
          initType: AiVideoGenerationType.textToVideo,
          pagePath: "/ai_text_to_video",
        ),
      );
    },
    "/ai_image_to_video": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiVideoProvider(),
        child: const NewAiVideoPage(
          initType: AiVideoGenerationType.imageToVideo,
          pagePath: "/ai_image_to_video",
        ),
      );
    },

    "/ai_text_to_video_v2": (BuildContext context) {
      return const AIDynamicVideoPage(
        initType: AiVideoGenerationType.textToVideo,
      );
    },
    "/ai_image_to_video_v2": (BuildContext context) {
      return const AIDynamicVideoPage(
        initType: AiVideoGenerationType.imageToVideo,
      );
    },

    "/ai_embrace_video": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiVideoProvider(),
        child: const NewAiVideoPage(
          initType: AiVideoGenerationType.embraceVideo,
          pagePath: "/ai_embrace_video",
        ),
      );
    },
    "/tool_box_new": (BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => NewToolBoxProvider()),
        ],
        child: const NewToolBoxPage(),
      );
    },
    "/old_photo_fix": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiPhotoFixProvider(),
        child: const NewOldPhotoFixPage(),
      );
    },
    "/hd_photo_fix": (BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => AiPhotoFixProvider(),
        child: const NewHdPhotoFixPage(),
      );
    },
  };

  static gotoPage(BuildContext context, String name, {dynamic params}) {
    if (MinorModeNavigationGuard.interceptIfNeeded()) return;

    LaunchProvider provider = context.read<LaunchProvider>();
    final bool showClipGuid = provider.shouldShowClipGuid();
    final bool showCreateGuid = provider.shouldShowCreateGuid();
    byDebugPrint('route_utils.gotoPage => name: $name');
    switch (name) {
      ///小说推文视频记录
      case '/novel_tweets_video_works':

      ///智能混剪视频记录
      case '/intelligent_hybrid_cutting_video_works':

      ///短剧视频记录
      case '/short_drama_video_works':

      ///爆文视频记录
      case '/explosive_video_works':
        ByNavRouterUtils.push(
          context,
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => AiCartoonVideoManagementProvider(),
              ),
            ],
            child: AiCartoonVideoManagementPage(
              type: name == '/novel_tweets_video_works'
                  ? AiCartoonVideoManagementPageType.normal
                  : AiCartoonVideoManagementPageType.clip,
              source: name == '/explosive_video_works'
                  ? EntranceSource.explosive
                  : name == '/short_drama_video_works'
                  ? EntranceSource.shortPlay
                  : EntranceSource.normal,
            ),
          ),
          name: name,
        );
        break;

      ///漫剧  ----3.10.35版本
      case '/anime':
        // 解析参数：可能是字符串（id）或 Map（包含 id 和 listData）
        String? animeId;
        Map<String, dynamic>? listData;

        if (params is Map) {
          animeId = params["id"]?.toString();
          if (params["listData"] != null) {
            try {
              listData = jsonDecode(params["listData"]);
            } catch (e) {
              log("解析 listData 失败: $e");
            }
          }
        } else if (params != null && params != "") {
          animeId = params.toString();
        }

        if (animeId != null && animeId.isNotEmpty) {
          ///跳中间视频播放页面
          HttpUtils.get(
            APIs.animeDetail,
            showLoading: true,
            {"id": animeId},
            success: (data) {
              final json = data["data"] as Map<String, dynamic>?;
              if (json == null) {
                return;
              }
              final AnimeBean animeBean = AnimeBean.fromJson(json: json);
              // 构造 AiVideoSquareModel 用于视频播放页面
              // 只使用实际存在的字段，不存在的字段使用默认值
              AiVideoSquareModel bean = AiVideoSquareModel(
                userId: 0,
                type: AiVideoGenerationType.textToVideo,
                userName: "",
                // 使用详情数据或列表数据中的标题
                prompt: animeBean.title ?? listData?["title"] ?? "",
                negativePrompt: "",
                // 从列表数据中获取变现相关字段（如果存在）
                useTime: listData?["use_time"]?.toString() ?? "0",
                withdrawMoney: listData?["withdraw_money"]?.toString() ?? "",
                withdrawMoneyTip:
                    listData?["withdraw_money_tip"]?.toString() ?? "",
                categoryIds: json["category_id"]?.toString() ?? "",
                labels: [],
                multiImage: [],
                cfgScale: 0.0,
                mode: "",
                aspectRatio: "",
                // 视频地址使用详情数据
                videoUrl: animeBean.videoUrl ?? "",
                coverUrl: animeBean.coverUrl ?? "",
                shareVideoUrl: animeBean.videoUrl ?? "",
                shareCoverUrl: animeBean.coverUrl ?? "",
                activeUserName: "",
                activeUserAvatar: "",
                activeUserCreateDays: 0,
              );

              log("构造的视频数据=====> ${bean.toJson()}");
              ByNavRouterUtils.push(
                context,
                AiVideosSameCasePage(
                  caseBean: bean,
                  preview: false,
                  type: "anime",
                  jumpParam: jsonEncode(animeBean.toJson()),
                  prePagePath: "/anime",
                ),
                name: "/anime",
              );

              // 第二种方式 animeDetailSettingPage 调转
            },
            fail: (code, msg) {
              ToastUtil().showToast(msg);
            },
          );
        } else {
          ByNavRouterUtils.pushNamed(context, name);
        }
        break;

      ///AI漫剧记录
      case '/anime_works':

      ///数字人记录
      case '/digital_human_works':
        final recordType =
            name == '/anime_works' ||
                params == ManagementRecord.aiAnime ||
                params == "anime_works"
            ? ManagementRecord.aiAnime
            : ManagementRecord.aiOral;
        ByNavRouterUtils.push(
          context,
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => AiOralVideoManagementProvider(),
              ),
            ],
            child: AiOralVideoManagementPage(recordType: recordType),
          ),
          name: name,
        );
        break;

      ///智能绘图记录
      case '/intelligent_draw_works':
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (context) => AiDrawWorkManagementProvider(),
            child: const AiDrawManagementPage(),
          ),
          name: name,
        );
        break;

      ///动态视频记录
      case '/motion_video_works':
        ByNavRouterUtils.push(
          context,
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => AiVideoManagementProvider(),
              ),
            ],
            child: const AiVideoManagementPage(),
          ),
          name: name,
        );
        break;

      ///ai写歌记录
      case '/ai_music_works':
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (context) => AiSongTasksProvider(),
            child: const AiSongTasksPage(),
          ),
          name: name,
        );
        break;

      ///配音记录
      case '/dub_works':
        ByNavRouterUtils.push(
          context,
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => AiOralVideosProvider(),
              ),
              ChangeNotifierProvider.value(
                value: ByAudioPlayer.sharedInstance.statusProvider,
              ),
            ],
            child: const AiOralMyDubbingListPage(showSelect: false),
          ),
          name: name,
        );
        break;

      ///素材记录
      case '/source_material_works':
        ByNavRouterUtils.push(
          context,
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => MineVideoMaterialsManagementProvider(),
              ),
            ],
            child: const MineVideoMaterialsManagementPage(),
          ),
          name: name,
        );
        break;

      ///一键提取视频记录
      case '/video_extraction_works':
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (ctx) => VideoExtractionProvider(),
            child: const ExtractionRecentTasksPage(),
          ),
          name: name,
        );
        break;

      ///文案提取记录
      case '/txt_extraction_works':
        ByNavRouterUtils.push(
          context,
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => MineWordsManagementProvider(),
              ),
              ChangeNotifierProvider(create: (context) => AiWritingProvider()),
              ChangeNotifierProvider(
                create: (context) => WordsExtractProvider(),
              ),
            ],
            child: const MineWordsManagementPage(),
          ),
          name: name,
        );
        break;

      /// 充值
      case "/topup":
        context.read<LaunchProvider>().gotoPay(
          context,
          closePay: true,
          replace: false,
        );
        break;

      /// 爆款复刻
      case "/hot_case_replica":
        ByNavRouterUtils.push(
          context,
          MultiProvider(
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
              ChangeNotifierProvider<HotCaseReplicaProvider>(
                create: (context) => HotCaseReplicaProvider(),
              ),
            ],
            child: const HotCaseReplicaPage(),
          ),
          name: name,
        );
        break;

      /// 视频二创
      case "/video_recreate":
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider<ShowRecreateProvider>(
            create: (context) => ShowRecreateProvider(),
            child: showCreateGuid == false
                ? const ShortShowRecreatePage<ShowRecreateProvider>()
                : const AddMaterialGuidPage(),
          ),
          name: name,
        );

        if (showCreateGuid) {
          provider.checkCreateGuid();
        }
        break;

      /// 智能混剪（SDK）已废弃
      case "/video_clip":
        break;
      case "/home":
        Get.find<MainController>().backToMain();
        Get.find<MainController>().tabChanged(0);
        break;

      /// 口播视频
      case "/ai_oral_videos":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 文生视频
      case "/ai_text_to_video":
        if (params != null && params != "") {
          HttpUtils.get(
            APIs.queryAiVideoTask,
            showLoading: true,
            {"id": params},
            success: (data) {
              byDebugPrint(data);
              final bean = AiVideoSquareModel.fromJson(data["data"]);
              ByNavRouterUtils.push(
                context,
                AiVideosSameCasePage(
                  caseBean: bean,
                  preview: false,
                  prePagePath: "/ai_text_to_video",
                ),
                name: "/ai_text_to_video",
              );
            },
            fail: (code, msg) {
              // BotToast.showText(text: msg);
              ToastUtil().showToast(msg);
            },
          );
        } else {
          // log("执行跳转了");
          ByNavRouterUtils.pushNamed(context, name);
        }
        break;

      /// 图生视频
      case "/ai_image_to_video":
        if (params != null && params != "") {
          HttpUtils.get(
            APIs.queryAiVideoTask,
            showLoading: true,
            {"id": params},
            success: (data) {
              byDebugPrint(data);
              final bean = AiVideoSquareModel.fromJson(data["data"]);
              ByNavRouterUtils.push(
                context,
                AiVideosSameCasePage(
                  caseBean: bean,
                  preview: false,
                  prePagePath: "/ai_image_to_video",
                ),
                name: "/ai_image_to_video",
              );
            },
            fail: (code, msg) {
              // BotToast.showText(text: msg);
              ToastUtil().showToast(msg);
            },
          );
        } else {
          ByNavRouterUtils.pushNamed(context, name);
        }
        break;

      case "/ai_text_to_video_v2":
        if (params != null && params != "") {
          HttpUtils.get(
            APIs.queryAiVideoTask,
            showLoading: true,
            {"id": params},
            success: (data) {
              byDebugPrint(data);
              final bean = AiVideoSquareModel.fromJson(data["data"]);
              ByNavRouterUtils.push(
                context,
                AiVideosSameCasePage(
                  caseBean: bean,
                  preview: false,
                  prePagePath: "/ai_text_to_video_v2",
                ),
                name: "/ai_text_to_video_v2",
              );
            },
            fail: (code, msg) {
              // BotToast.showText(text: msg);
              ToastUtil().showToast(msg);
            },
          );
        } else {
          // log("执行跳转了");
          ByNavRouterUtils.pushNamed(context, name);
        }
        break;

      case "/ai_image_to_video_v2":
        if (params != null && params != "") {
          HttpUtils.get(
            APIs.queryAiVideoTask,
            showLoading: true,
            {"id": params},
            success: (data) {
              byDebugPrint(data);
              final bean = AiVideoSquareModel.fromJson(data["data"]);
              ByNavRouterUtils.push(
                context,
                AiVideosSameCasePage(
                  caseBean: bean,
                  preview: false,
                  prePagePath: "/ai_image_to_video_v2",
                ),
                name: "/ai_image_to_video_v2",
              );
            },
            fail: (code, msg) {
              // BotToast.showText(text: msg);
              ToastUtil().showToast(msg);
            },
          );
        } else {
          ByNavRouterUtils.pushNamed(context, name);
        }
        break;

      /// 拥抱视频
      case "/ai_embrace_video":
        if (params != null && params != "") {
          HttpUtils.get(
            APIs.queryAiVideoTask,
            showLoading: true,
            {"id": params},
            success: (data) {
              byDebugPrint(data);
              final bean = AiVideoSquareModel.fromJson(data["data"]);
              ByNavRouterUtils.push(
                context,
                AiVideosSameCasePage(
                  caseBean: bean,
                  preview: false,
                  prePagePath: "/ai_embrace_video",
                ),
                name: "/ai_embrace_video",
              );
            },
            fail: (code, msg) {
              // BotToast.showText(text: msg);
              ToastUtil().showToast(msg);
            },
          );
        } else {
          ByNavRouterUtils.pushNamed(context, '/ai_embrace_video');
        }
        break;

      /// AI推文视频
      case "/ai_tweets":
        final provider = AiCartoonProvider();
        if (params != null && params != "") {
          ///跳中间视频播放页面
          HttpUtils.get(
            APIs.videoSquareInfo,
            showLoading: true,
            {"id": params},
            success: (data) {
              Map json = data["data"];
              log("获取到的数据=====> $json");
              byDebugPrint(data);
              late AiVideoSquareModel bean;
              bean = AiVideoSquareModel(
                userId: json["active_user_id"],
                type: $enumDecode(_$AiVideoGenerationTypeEnumMap, json['type']),
                userName: json["active_user_name"],
                prompt: json["prompt"],
                negativePrompt: "",
                useTime: json["use_time"].toString(),
                withdrawMoney: json["withdraw_money"],
                categoryIds: "",
                labels: [],
                multiImage: [],
                cfgScale: json["cfgScale"] ?? 0,
                mode: json["mode"] ?? "",
                aspectRatio: json["aspectRatio"] ?? "",
                videoUrl: json["video_url"] ?? "",
                coverUrl: json["cover_url"] ?? "",
                shareVideoUrl: json["share_url"] ?? "",
                shareCoverUrl: json["share_cover_url"] ?? "",
                withdrawMoneyTip: json["withdraw_money_tip"] ?? "",
                activeUserName: json["active_user_name"] ?? "",
                activeUserAvatar: json["active_user_avatar"] ?? "",
                activeUserCreateDays: json["active_user_create_days"] ?? 0,
              );
              log("获取到的数据2=====> $data");
              ByNavRouterUtils.push(
                context,
                AiVideosSameCasePage(
                  caseBean: bean,
                  preview: false,
                  type: "ai_tweets",
                  prePagePath: "/ai_tweets",
                ),
                name: "/ai_tweets",
              );
            },
            fail: (code, msg) {
              // BotToast.showText(text: msg);
              ToastUtil().showToast(msg);
            },
          );
        } else {
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => provider,
              child: const AiCartoonPage(pagePath: "/ai_tweets"),
            ),
            name: "/ai_tweets",
          );
        }

        break;

      // case "/ai_novel":
      //   ByNavRouterUtils.push(
      //       context,
      //       ChangeNotifierProvider(
      //         create: (context) => AiNovelProvider(),
      //         child: const NewAiNovelPage(),
      //       ));

      //   break;

      /// AI绘图
      case "/ai_draw":
        final provider = AiDrawProvider();
        if (params != null && params != "") {
          ByNavRouterUtils.push(
            context,
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (context) => AiDrawProvider()),
              ],
              child: AiDrawWorkDetailsPage(
                workId: int.parse(params),
                type: "ai_draw",
              ),
            ),
            name: "/ai_draw",
          );

          // ByNavRouterUtils.push(
          //   context,
          //   ChangeNotifierProvider(
          //     create: (context) => provider,
          //     child: const AiDrawPage(),
          //   ),
          // );
        } else {
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => provider,
              child: const AiDrawPage(),
            ),
            name: name,
          );
        }

        break;

      /// AI音乐
      case RoutePageConst.aiMusic:
        if (params != null && params != "") {
          HttpUtils.get(
            APIs.queryAiMusicTask,
            {"id": params},
            showLoading: true,
            success: (data) {
              byDebugPrint("data: $data");
              final bean = AiSongTaskDetailBean.fromJson(data["data"]);
              ByNavRouterUtils.pushNamedResult(
                context,
                ChangeNotifierProvider(
                  create: (context) => AiSongViewProvder(),
                  child: AiSongViewPage([bean], 0, false),
                ),
                (data) {},
              );
            },
            fail: (code, msg) {
              // BotToast.showText(text: msg);
              ToastUtil().showToast(msg);
            },
          );
        } else {
          RouteUtils.gotoPage(context, RoutePageConst.aiSongPageName);
        }
        break;

      /// AI音乐写歌的页面
      case RoutePageConst.aiSongPageName:
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (context) => AiSongProvider(),
            child: AiSongPage(aiSongTaskDetailBean: params),
          ),
          name: RoutePageConst.aiSongPageName,
        );
        break;
      case "/toolBox":
        Get.find<MainController>().backToMain();
        Get.find<MainController>().tabChanged(1);
        break;
      case "/mine":
        Get.find<MainController>().backToMain();
        Get.find<MainController>().tabChanged(2);
        break;

      /// 教程
      case "/guide":
        ByNavRouterUtils.pushNamed(context, name);
        break;
      case "/removeWatermark":
        // 去水印
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 故事创作/AI写作
      case "/storyCreation":
        // ByNavRouterUtils.pushNamed(context, name);
        RouteUtils.gotoPage(context, RoutePageConst.aiWritingPageName);
        break;

      /// 故事创作助手
      case "/storyAssistant":
        if (params != null && params.isNotEmpty) {
          HomePageProvider provider = context.read<HomePageProvider>();

          provider.loadCreators(
            call: () {
              var data = provider.assistantItemBeans.where(
                (e) => e.id == params,
              );
              if (data.isNotEmpty) {
                CreatorBean bean = data.first;
                ByNavRouterUtils.push(
                  context,
                  ChangeNotifierProvider(
                    create: (context) => StroyCreateProvider(),
                    child: AssistantInfoPage(bean: bean),
                  ),
                );
              }
            },
          );
          return;
        }

        ByNavRouterUtils.pushNamed(
          context,
          name,
          arguments: params != null && params.isNotEmpty
              ? StoryArgumentBean(typeId: params)
              : null,
        );
        break;

      /// 去除字幕
      case "/removeSubtitles":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 违禁词检测
      case "/wordDetection":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 视频擦除
      case "/videoErase":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 文案提取
      case "/copywritingExtraction":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 智能去重
      case "/videoDeduplication":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 视频提取
      case "/videoExtraction":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 视频拆分/视频分割
      case "/videoSplit":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 视频混剪（SDK）
      case "/videoMix":
        showClipGuid == false
            ? ByNavRouterUtils.pushNamed(context, name)
            : ByNavRouterUtils.push(
                context,
                const CloudMaterialsGuidPage(),
                name: name,
              );
        if (showClipGuid) {
          provider.checkClipGuid();
        }
        // ByNavRouterUtils.pushNamed(context, name);
        break;

      // case "/image_water_mark":
      //   ByCommonUtils.pickAssets(
      //     context,
      //     maxCount: 1,
      //     type: RequestType.image,
      //     onSelectedCallback: (asstes) async {
      //       /// 未选择则不处理
      //       if (asstes.isEmpty) return;
      //       final file = await asstes[0].file;
      //       if (file != null) {
      //         await ChannelOperate.toVideoEdit(true,
      //                 isSavePhoto: true,
      //                 videoLocalFilePathParameter: [file.path],
      //                 mosaic: true)
      //             .then((data) {
      //           if (data != null) {
      //             BotToast.showText(text: "作品已保存到相册中!");
      //           }
      //         });
      //       }
      //     },
      //   );
      //   break;
      // case "/video_water_mark":
      //   ByCommonUtils.pickAssets(context, maxCount: 1, type: RequestType.video,
      //       onSelectedCallback: (asstes) async {
      //     /// 未选择则不处理
      //     if (asstes.isEmpty) return;
      //     final file = await asstes[0].file;
      //     if (file != null) {
      //       await ChannelOperate.toVideoEdit(true,
      //               isSavePhoto: true,
      //               videoLocalFilePathParameter: [file.path],
      //               mosaic: true)
      //           .then((data) {
      //         if (data != null) {
      //           BotToast.showText(text: "作品已保存到相册中!");
      //         }
      //       });
      //     }
      //   });
      //   break;

      /// 视频提取
      case "/video_extraction":
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (ctx) => VideoExtractionProvider(),
            child: const VideoExtractionPage(),
          ),
          name: name,
        );
        break;

      /// 违禁词检测
      case "/banned_words":
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (BuildContext context) => ForbiddenWordsProvider(),
            child: const ForbiddenWordsDetectPage(),
          ),
          name: name,
        );
        break;
      // case "/md5_modification":
      //   ByCommonUtils.pickAssetsOnTypeVideo(context, maxCount: 1,
      //       onSelectedCallback: (asstes) async {
      //     /// 未选择则不处理
      //     if (asstes.isEmpty) return;
      //     final file = await asstes[0].file;

      //     if (file != null) {
      //       ChannelOperate.toComperssVideo(file.path).then((data) {
      //         if (data != null) {
      //           exportVideoPage(context, data[ChannelApi.editResult]);
      //         }
      //       });
      //     }
      //   });
      //   break;
      /// 文案提取
      case "/txt_extraction":
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (context) => WordsExtractProvider(),
            child: const WordsExtractionPage(),
          ),
          name: name,
        );
        break;

      /// 短剧二创
      case "/voideCreate":
        // showCreateGuid == false
        //     ? ByNavRouterUtils.pushNamed(context, name)
        //     : ByNavRouterUtils.push(context, const AddMaterialGuidPage());
        ByNavRouterUtils.pushNamed(context, name);
        if (showCreateGuid) {
          provider.checkCreateGuid();
        }
        // ByNavRouterUtils.pushNamed(context, name);
        break;
      // case "/video_sdk_clip":
      //   //编辑视频预设参数
      //   ChannelOperate.toVideoEdit(false).then((data) {
      //     if (data != null) {
      //       final String pathResult = data["edit_result"] ?? "";
      //       if (pathResult.isNotEmpty) {
      //         ByNavRouterUtils.push(
      //             context, VideoClipHyberPrevicew(pathResult));
      //       } else {
      //         BotToast.showText(text: "视频剪辑失败");
      //       }
      //     }
      //   });
      //   break;
      case "/hyberClipContent":
        //编辑视频预设参数
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 旧版充值
      case "/rechargeOld":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 新版充值
      case "/rechargeNew":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 一键提取
      case "/one-clickExtraction":
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (ctx) => VideoExtractionProvider(),
            child: const VideoExtractionPage(),
          ),
          name: name,
        );
        break;

      /// AI智能混剪
      case "/ai_clip":
        final providerClip = AiClipProvider();
        log("传递过去的参数===> $params");
        if (params != null && params != "") {
          ///跳中间视频播放页面
          HttpUtils.get(
            APIs.videoSquareInfo,
            showLoading: true,
            {"id": params},
            success: (data) {
              Map json = data["data"];
              log("获取到的数据=====> $json");
              byDebugPrint(data);
              late AiVideoSquareModel bean;
              bean = AiVideoSquareModel(
                userId: json["active_user_id"],
                type: $enumDecode(_$AiVideoGenerationTypeEnumMap, json['type']),
                userName: json["active_user_name"],
                prompt: json["prompt"],
                negativePrompt: "",
                useTime: json["use_time"].toString(),
                withdrawMoney: json["withdraw_money"],
                categoryIds: "",
                labels: [],
                multiImage: [],
                cfgScale: json["cfgScale"] ?? 0,
                mode: json["mode"] ?? "",
                aspectRatio: json["aspectRatio"] ?? "",
                videoUrl: json["video_url"] ?? "",
                coverUrl: json["cover_url"] ?? "",
                shareVideoUrl: json["share_url"] ?? "",
                shareCoverUrl: json["share_cover_url"] ?? "",
                withdrawMoneyTip: json["withdraw_money_tip"] ?? "",
                activeUserName: json["active_user_name"] ?? "",
                activeUserAvatar: json["active_user_avatar"] ?? "",
                activeUserCreateDays: json["active_user_create_days"] ?? 0,
              );
              log("获取到的数据2=====> $data");
              ByNavRouterUtils.push(
                context,
                AiVideosSameCasePage(
                  caseBean: bean,
                  preview: false,
                  type: "ai_clip",
                  prePagePath: "/ai_clip",
                ),
                name: "/ai_clip",
              );
            },
            fail: (code, msg) {
              // BotToast.showText(text: msg);
              ToastUtil().showToast(msg);
            },
          );
        } else {
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => StroyCreateProvider(),
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (context) => providerClip),
                  ChangeNotifierProvider(
                    create: (BuildContext context) => AiMaterialProvider(),
                  ),
                  ChangeNotifierProvider(
                    create: (BuildContext context) => AiClipOpeningProvider(),
                  ),
                  ChangeNotifierProvider(
                    create: (BuildContext context) =>
                        AiClipMineMaterialsProvider(),
                  ),
                ],
                child: const AiClipPage(pagePath: "/ai_clip"),
              ),
            ),
            name: name,
          );
        }
        break;

      /// AI素材库
      case "/ai_material_lib":
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 创作助手
      case "/create_assistant":
        ByNavRouterUtils.pushNamed(context, RoutePageConst.aiWritingPageName);
        break;

      /// 创作详情
      case "/create_assistant_detail":
        if (params != null && params.isNotEmpty) {
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => StroyCreateProvider(),
              child: AssistantInfoPage(
                bean: CreatorBean.fromIdAndTitle(id: params),
              ),
            ),
            name: "/create_assistant_detail",
          );
          return;
        }
        ByNavRouterUtils.pushNamed(
          context,
          "/storyAssistant",
          arguments: params != null && params.isNotEmpty
              ? StoryArgumentBean(typeId: params)
              : null,
        );
        break;

      /// 同款广场
      case "/same_case_square":
        if (params != null && params is String && params.isNotEmpty) {
          final String sqid = params;
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => AiSquareProvider(),
              child: NewSameCaseSquarePage(sqid: sqid),
            ),
            name: "/same_case_square",
          );
        }
        break;

      /// AI写作
      case RoutePageConst.aiWritingPageName:
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// AI写作记录
      case RoutePageConst.aiWritingRecord:
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// AI写作设置
      case RoutePageConst.aiWritingSetting:
        ByNavRouterUtils.pushNamed(context, name, arguments: params);
        break;

      /// AI小说创作
      case RoutePageConst.aiNovelWriting:
        ByNavRouterUtils.pushNamed(context, name, arguments: params);
        break;
      // case RoutePageConst.aiImageToVideo:
      //   ByNavRouterUtils.pushNamed(context, name, arguments: params);
      //   break;
      // case RoutePageConst.aiBoxTimeEmbrace:
      //   ByNavRouterUtils.pushNamed(context, name, arguments: params);
      //   break;
      // case RoutePageConst.aiTextToVideo:
      //   ByNavRouterUtils.pushNamed(context, name, arguments: params);

      /// 新版工具箱
      case "/tool_box_new":
        // 去水印
        ByNavRouterUtils.pushNamed(context, name);
        break;

      /// 新版的AI小说创作
      case RoutePageConst.aiNovel:
        ByNavRouterUtils.pushNamed(context, name, arguments: params);
        break;

      /// 老照片修复
      case RoutePageConst.oldPhotoFix:
        ByNavRouterUtils.pushNamed(context, name, arguments: params);
        break;

      /// 老照片高清修复
      case RoutePageConst.hdPhotoFix:
        ByNavRouterUtils.pushNamed(context, name, arguments: params);
        break;

      ///民间故事记录
      case Routes.storyManagementPage:
        Get.toNamed(Routes.storyManagementPage);
        break;

      /// 爆文创作
      case "/novel_create":
        print('~~~~_____QQQQQ,$params');
        //兼容老版
        if (params == 'mjgs' || params == "bwcz") {
          bool folkTales = false;
          bool isPromote = false;
          folkTales = "mjgs" == params;
          isPromote = ["mjgs", "bwcz"].contains(params);
          final provider = NovelCreateProvider();
          provider.isFolkTales = folkTales;
          provider.isPromote = isPromote;
          if (folkTales) {
            provider.themeId = 'folk_tales_novel';
          } else {
            provider.themeId = 'hot_copy_novel';
          }
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => provider,
              child: const HotNovelCreatePage(),
            ),
            name: "/novel_create",
          );
        } else if (params != null && params != "") {
          final provider = NovelCreateProvider();
          provider.themeId = params;
          // provider.themeId = 'folk_tales_novel';
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => provider,
              child: const FolkStoryListPage(),
            ),
            name: "/novel_create",
          );
        }
        break;

      /// 民间故事创作页
      case "/create_fold_story":
        if (params != null && params != "") {
          final themeId = params;
          Get.toNamed(
            Routes.createFolkStoryPage,
            arguments: {'theme_id': themeId},
          );
        }
        break;

      ///todo 这里需要替换成新的页面
      /// 短剧创作
      case "/short_play_create":
        // ByNavRouterUtils.push(
        //   context,
        //   ChangeNotifierProvider(
        //     create: (context) => ShortPlayCreateProvider(),
        //     child: const HotShortPlayCreatePage(),
        //   ),
        // );
        Get.toNamed(Routes.newShortPlayListPage);
        break;

      /// AI对话
      case "/ai_chat":
        ByNavRouterUtils.push(
          context,
          // ChangeNotifierProvider(
          //   create: (context) => ShortPlayCreateProvider(),
          //   child: const HotShortPlayCreatePage(),
          // ),
          ChangeNotifierProvider<AiChatProviders>(
            create: (context) => AiChatProviders(),
            child: const AiChatPage(),
          ),
          name: name,
        );
        break;

      ///民间故事
      case '/storyCreationDetail':
        if (params != null && params.isNotEmpty) {
          HomePageProvider provider = HomePageProvider();
          provider.loadCreators(
            call: () {
              var data = provider.assistantItemBeans.where(
                (e) => e.id == params,
              );
              if (data.isNotEmpty) {
                CreatorBean bean = data.first;
                ByNavRouterUtils.push(
                  context,
                  ChangeNotifierProvider(
                    create: (context) => StroyCreateProvider(),
                    child: AssistantInfoPage(bean: bean),
                  ),
                  name: "/storyCreationDetail",
                );
              }
            },
          );
          return;
        } else {
          final provider = NovelCreateProvider();
          provider.isFolkTales = true;
          provider.isPromote = false;
          if (provider.isFolkTales) {
            provider.themeId = 'folk_tales_novel';
          } else {
            provider.themeId = 'hot_copy_novel';
          }
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => provider,
              child: const HotNovelCreatePage(),
            ),
            name: "/storyCreationDetail",
          );
        }
        break;

      ///短剧创作详情跳转
      case "/short_play_create_detail":
        if (params != null && params.isNotEmpty) {
          ///todo 中间播放视频页面
          HttpUtils.get(
            APIs.videoSquareInfo,
            showLoading: true,
            {"id": params},
            success: (data) {
              Map json = data["data"];
              log("获取到的数据=====> $json");
              String jumpParam = json["jump_param"] ?? "";
              byDebugPrint(data);
              late AiVideoSquareModel bean;
              bean = AiVideoSquareModel(
                userId: json["active_user_id"],
                type: $enumDecode(_$AiVideoGenerationTypeEnumMap, json['type']),
                userName: json["active_user_name"],
                prompt: json["prompt"],
                negativePrompt: "",
                useTime: json["use_time"].toString(),
                withdrawMoney: json["withdraw_money"],
                categoryIds: "",
                labels: [],
                multiImage: [],
                cfgScale: json["cfgScale"] ?? 0,
                mode: json["mode"] ?? "",
                aspectRatio: json["aspectRatio"] ?? "",
                videoUrl: json["video_url"] ?? "",
                coverUrl: json["cover_url"] ?? "",
                shareVideoUrl: json["share_url"] ?? "",
                shareCoverUrl: json["share_cover_url"] ?? "",
                withdrawMoneyTip: json["withdraw_money_tip"] ?? "",
                activeUserName: json["active_user_name"] ?? "",
                activeUserAvatar: json["active_user_avatar"] ?? "",
                activeUserCreateDays: json["active_user_create_days"] ?? 0,
              );
              log("获取到的数据2=====> $data");

              if (jumpParam != "") {
                ByNavRouterUtils.push(
                  context,
                  AiVideosSameCasePage(
                    caseBean: bean,
                    preview: false,
                    type: "short_play_create_detail",
                    jumpParam: jumpParam,
                    prePagePath: "/short_play_create_detail",
                  ),
                  name: "/short_play_create_detail",
                );
              } else {
                HttpUtils.get(
                  APIs.getMaterialInfo,
                  {"id": int.parse(params), "detailNum": 1},
                  success: (data) {
                    final CloudVideoListBean shortPlayBean =
                        CloudVideoListBean.fromJson(data["data"]);
                    ByNavRouterUtils.push(
                      context,
                      ChangeNotifierProvider(
                        create: (BuildContext context) =>
                            ShortShowDetailsProvider(),
                        child: ShortPlayListPage(
                          videoListBean: shortPlayBean,
                          fromPrompt: true,
                        ),
                      ),
                      name: "/short_play_create_detail",
                    );
                  },
                  fail: (code, msg) {
                    // BotToast.showText(text: msg);
                    ToastUtil().showToast(msg);
                  },
                );
              }
            },
            fail: (code, msg) {
              BotToast.showText(text: msg);
            },
          );
        } else {
          HttpUtils.get(
            APIs.getMaterialInfo,
            {"id": int.parse(params), "detailNum": 1},
            success: (data) {
              final CloudVideoListBean shortPlayBean =
                  CloudVideoListBean.fromJson(data["data"]);
              ByNavRouterUtils.push(
                context,
                ChangeNotifierProvider(
                  create: (BuildContext context) => ShortShowDetailsProvider(),
                  child: ShortPlayListPage(
                    videoListBean: shortPlayBean,
                    fromPrompt: true,
                  ),
                ),
                name: "/short_play_create_detail",
              );
            },
            fail: (code, msg) {
              BotToast.showText(text: msg);
            },
          );
        }
        break;

      ///短剧创作引导
      case "/short_drama_guide":
        Get.toNamed(Routes.shortDramaPage);
        break;

      ///未成年人页面
      case "/minor_page":
        Get.toNamed(Routes.minorPage);
        break;

      ///未成年创建页面
      case "/minor_create_page":
        Get.toNamed(Routes.minorCreatePage);
        break;
    }
  }

  static void exportVideoPage(BuildContext context, String path) {
    try {
      ByNavRouterUtils.push(
        context,
        VideoClipHyberPrevicew(path, title: "完成去重"),
        name: "/video_export_preview",
      );
    } catch (e) {
      byDebugPrint(e);
    }
  }
}

const _$AiVideoGenerationTypeEnumMap = {
  AiVideoGenerationType.textToVideo: 1,
  AiVideoGenerationType.imageToVideo: 2,
  AiVideoGenerationType.embraceVideo: 3,
};
