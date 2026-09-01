// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/routes/route_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/routes/route_page_const.dart';
import 'package:video_clip_edit/providers/home_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/clipped/clipped_page.dart';
import 'package:video_clip_edit/modules/guid/add_material_guid_page.dart';
import 'package:video_clip_edit/modules/home/erase/picture_erase_page.dart';
import 'package:video_clip_edit/modules/home/providers/clipped_provider.dart';
import 'package:video_clip_edit/modules/home/words/words_extraction_page.dart';
import 'package:video_clip_edit/modules/home/forbidden_words_detect_page.dart';
import 'package:video_clip_edit/modules/home/story/story_create_home_page.dart';
import 'package:video_clip_edit/modules/home/words/short_play_authorization.dart';
import 'package:video_clip_edit/modules/home/providers/video_erase_provider.dart';
import 'package:video_clip_edit/modules/guid/clip/cloud_materials_guid_page.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/video_clip_hyber_preview.dart';
import 'package:video_clip_edit/modules/home/recreate/short_show_recreate_page.dart';
import 'package:video_clip_edit/modules/home/providers/forbidden_words_provider.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/video_extraction_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';

enum CellType {
  blue,
  green,
}

class ToolboxCell extends StatelessWidget {
  //推文变现专区
  static const String aiBoxCmicTweets = "AI漫画推文";
  static const String aiBoxCmicClip = "智能混剪";
  static const String aiBoxSmart = "智能混剪";
  static const String aiBoxFolkTales = "民间故事";
  static const String aiBoxHildrenPictureBooks = "儿童绘本";
  static const String aiBoxHorrorStories = "恐怖故事";
  static const String aiBoxaiCmicTweets = "故事创作";
  static const String aiOralVideos = "口播视频";
  static const String aiNovel = "AI小说";
//AI成片变现专区
  static const String aiTextToVideo = "文生视频";
  static const String aiImageToVideo = "图生视频";
  static const String aiBoxTimeEmbrace = "时空拥抱";
  static const String aiBoxWorkingCatSeries = "打工猫系列";
  static const String aiBoxDynamicScenery = "动态风景";
  static const String aiBoxAISongwriting = "AI写歌";
  static const String aiBoxImageErase = "AI绘图";
//变现辅助工具
  static const String aiBoxImgWatermark = "图片去水印";
  static const String aiBoxVideoWatermark = "视频去字幕";
  static const String aiBoxVideoExtraction = "一键提取";
  static const String aiBoxBannedWordFiltering = "违禁词筛选";
  static const String aiBoxMd5Modification = "MD5修改";
  static const String aiBoxTxtExtraction = "文案提取";
  static const String aiBoxOldPhotoFix = "老照片修复";
  static const String aiBoxHdPhotoFix = "画质高清修复";

  final ToolboxCellBean cellBean;

  const ToolboxCell({
    super.key,
    required this.cellBean,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _handleTap(context);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: cellBean.type == CellType.blue
                ? [const Color(0xFFF8FDFD), const Color(0xFFEBF9FF)]
                : [const Color(0xFFF8FDFD), const Color(0xFFEBFFFA)],
          ),
          boxShadow: [
            BoxShadow(
              color: ByColorUtil.BlackColor.withOpacity(0.08),
              blurRadius: 2.w,
            )
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              cellBean.icon,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                cellBean.title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: ByColorUtils.hexColor("#0B1843"),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void exportVideoPage(BuildContext context, String path) {
    try {
      ByNavRouterUtils.push(
        context,
        VideoClipHyberPrevicew(
          path,
          title: "完成去重",
        ),
      );
    } catch (e) {
      byDebugPrint(e);
    }
  }

  void _handleTap(BuildContext context) async {
    final title = cellBean.title;
    LaunchProvider provider = context.read<LaunchProvider>();
    final bool showCreateGuid = provider.shouldShowCreateGuid();
    final bool showClipGuid = provider.shouldShowClipGuid();
    switch (title) {
      case ToolboxCell.aiOralVideos:
        RouteUtils.gotoPage(context, "/ai_oral_videos");
        break;
      case ToolboxCell.aiBoxCmicTweets:
        RouteUtils.gotoPage(context, "/ai_tweets");
        break;
      case ToolboxCell.aiBoxCmicClip:
        RouteUtils.gotoPage(context, "/ai_clip");
        break;
      case ToolboxCell.aiBoxFolkTales:
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (context) => StroyCreateProvider(),
            child: const StoryCreateHomePage(
              select: 0,
            ),
          ),
        );
        break;
      case ToolboxCell.aiBoxHildrenPictureBooks:
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (context) => StroyCreateProvider(),
            child: const StoryCreateHomePage(
              select: 0,
            ),
          ),
        );
        break;
      case ToolboxCell.aiBoxHorrorStories:
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (context) => StroyCreateProvider(),
            child: const StoryCreateHomePage(
              select: 0,
            ),
          ),
        );
        break;
      case ToolboxCell.aiBoxaiCmicTweets:
        RouteUtils.gotoPage(context, RoutePageConst.aiWritingPageName);
        break;
      case aiBoxAISongwriting:
        RouteUtils.gotoPage(context, RoutePageConst.aiSongPageName);
        break;
      case aiBoxImageErase:
        RouteUtils.gotoPage(context, "/ai_draw");
        break;
      case aiNovel:
        RouteUtils.gotoPage(context, "/ai_novel");
        break;
      case aiTextToVideo:
        RouteUtils.gotoPage(context, "/ai_text_to_video");
        break;
      case aiImageToVideo:
        RouteUtils.gotoPage(context, "/ai_image_to_video");
        break;
      case aiBoxTimeEmbrace:
        RouteUtils.gotoPage(context, "/ai_embrace_video");
        break;
      case aiBoxOldPhotoFix:
        RouteUtils.gotoPage(context, "/old_photo_fix");
        break;
      case aiBoxHdPhotoFix:
        RouteUtils.gotoPage(context, "/hd_photo_fix");
        break;
      case aiBoxImgWatermark:
        // ByCommonUtils.pickAssets(context, maxCount: 1, type: RequestType.image,
        //     onSelectedCallback: (asstes) async {
        //   /// 未选择则不处理
        //   if (asstes.isEmpty) return;
        //   final file = await asstes[0].file;
        //   if (file != null) {
        //     await ChannelOperate.toVideoEdit(true,
        //             isSavePhoto: true,
        //             videoLocalFilePathParameter: [file.path],
        //             mosaic: true)
        //         .then((data) {
        //       if (data != null) {
        //         BotToast.showText(text: "作品已保存到相册中!");
        //       }
        //     });
        //   }
        // });
        break;
      case aiBoxVideoWatermark:
        // ByCommonUtils.pickAssets(context, maxCount: 1, type: RequestType.video,
        //     onSelectedCallback: (asstes) async {
        //   /// 未选择则不处理
        //   if (asstes.isEmpty) return;
        //   final file = await asstes[0].file;
        //   if (file != null) {
        //     await ChannelOperate.toVideoEdit(true,
        //             isSavePhoto: true,
        //             videoLocalFilePathParameter: [file.path],
        //             mosaic: true)
        //         .then((data) {
        //       if (data != null) {
        //         BotToast.showText(text: "作品已保存到相册中!");
        //       }
        //     });
        //   }
        // });
        break;
      case aiBoxVideoExtraction:
        ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (ctx) => VideoExtractionProvider(),
              child: const VideoExtractionPage(),
            ));
        break;
      case aiBoxBannedWordFiltering:
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider(
            create: (BuildContext context) => ForbiddenWordsProvider(),
            child: const ForbiddenWordsDetectPage(),
          ),
        );
        break;
      // case aiBoxMd5Modification:
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
      case aiBoxTxtExtraction:
        ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
                create: (context) => WordsExtractProvider(),
                child: const WordsExtractionPage()));
        break;
      case "视频合成":
        // await ChannelOperate.toVideoEdit(false).then((data) {
        //   if (data != null) {
        //     final String pathResult = data["edit_result"] ?? "";
        //     if (pathResult.isNotEmpty) {
        //       ByNavRouterUtils.push(
        //           context, VideoClipHyberPrevicew(pathResult));
        //     } else {
        //       BotToast.showText(text: "视频合成失败");
        //     }
        //   }
        // });
        break;
      case "视频剪辑":
        // await ChannelOperate.toVideoEdit(false).then((data) {
        //   if (data != null) {
        //     final String pathResult = data["edit_result"] ?? "";
        //     if (pathResult.isNotEmpty) {
        //       ByNavRouterUtils.push(
        //           context, VideoClipHyberPrevicew(pathResult));
        //     } else {
        //       BotToast.showText(text: "视频剪辑失败");
        //     }
        //   }
        // });
        break;
      case "一键提取":
        ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (ctx) => VideoExtractionProvider(),
              child: const VideoExtractionPage(),
            ));
        break;
      case "视频混剪":
        ByNavRouterUtils.push(
          context,
          showClipGuid == false
              ? ChangeNotifierProvider<ClippedProvider>(
                  create: (ctx) => ClippedProvider(),
                  child: const ClippedPage<ClippedProvider>(),
                )
              : const CloudMaterialsGuidPage(),
        );
        if (showClipGuid) {
          provider.checkClipGuid();
        }
        break;
      case "影视二创":
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider<ShowRecreateProvider>(
            create: (context) => ShowRecreateProvider(),
            child: showCreateGuid == false
                ? const ShortShowRecreatePage<ShowRecreateProvider>()
                : const AddMaterialGuidPage(),
          ),
        );

        if (showCreateGuid) {
          provider.checkCreateGuid();
        }
        break;
      case "短剧授权":
        ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => HomePageProvider(),
              child: const ShortPlayAuthorizationPage(),
            ));
        break;
      case "文案提取":
        ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
                create: (context) => WordsExtractProvider(),
                child: const WordsExtractionPage()));
        break;
      case "智能去重":
      // case "视频去重":
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
      case "图片去水印":
        // ByCommonUtils.pickAssets(context, maxCount: 1, type: RequestType.image,
        //     onSelectedCallback: (asstes) async {
        //   /// 未选择则不处理
        //   if (asstes.isEmpty) return;
        //   final file = await asstes[0].file;
        //   if (file != null) {
        //     await ChannelOperate.toVideoEdit(true,
        //             isSavePhoto: true,
        //             videoLocalFilePathParameter: [file.path],
        //             mosaic: true)
        //         .then((data) {
        //       if (data != null) {
        //         BotToast.showText(text: "作品已保存到相册中!");
        //       }
        //     });
        //   }
        // });
        break;
      case "视频去水印":
        // ByCommonUtils.pickAssets(context, maxCount: 1, type: RequestType.video,
        //     onSelectedCallback: (asstes) async {
        //   /// 未选择则不处理
        //   if (asstes.isEmpty) return;
        //   final file = await asstes[0].file;
        //   if (file != null) {
        //     await ChannelOperate.toVideoEdit(true,
        //             isSavePhoto: true,
        //             videoLocalFilePathParameter: [file.path],
        //             mosaic: true)
        //         .then((data) {
        //       if (data != null) {
        //         BotToast.showText(text: "作品已保存到相册中!");
        //       }
        //     });
        //   }
        // });
        break;
      case "视频擦除":
        // ByCommonUtils.pickAssetsOnTypeVideo(context, maxCount: 1,
        //     onSelectedCallback: (asstes) async {
        //   /// 未选择则不处理
        //   if (asstes.isEmpty) return;
        //   final file = await asstes[0].file;
        //   if (file != null) {
        //     await ChannelOperate.toCleanWatermark(file.path).then((data) {
        //       if (data != null) {
        //         final String pathResult = data["edit_result"] ?? "";
        //         if (pathResult.isNotEmpty) {
        //           ByNavRouterUtils.push(
        //               context, VideoClipHyberPrevicew(pathResult));
        //         } else {
        //           BotToast.showText(text: "视频擦除失败");
        //         }
        //       }
        //     });
        //   }
        // });
        break;
      case "图片擦除":
        ByCommonUtils.pickAssetsOnType(context, maxCount: 1,
            onSelectedCallback: (assets) async {
          if (assets.isEmpty) return;
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (context) => VideoEraseProvider(),
              child: PictureErasePage(assets: assets),
            ),
          );
        });
        break;
      // case "违禁词检测":
      //   ByNavRouterUtils.push(
      //     context,
      //     ChangeNotifierProvider(
      //       create: (BuildContext context) => ForbiddenWordsProvider(),
      //       child: const ForbiddenWordsDetectPage(),
      //     ),
      //   );
      //   break;

      // case "图片去水印":
      // case "视频去水印":
      //   ByNavRouterUtils.push(context, const WatermarkErasePage());
      //   break;
      default:
    }
  }
}

class ToolboxCellBean {
  String icon;
  String title;
  String desc;
  CellType type;

  ToolboxCellBean({
    required this.icon,
    required this.title,
    required this.desc,
    this.type = CellType.blue,
  });
}
