import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/step_view.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/narrator_cell.dart';
import 'package:video_clip_edit/modules/download/providers/download_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/voice_select_dailog.dart';
import 'package:video_clip_edit/modules/home/recreate/beans/commentary_item_bean.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/select_narrator_dailog.dart';
import 'package:video_clip_edit/modules/home/recreate/video_recreate_dubbing_generating_page.dart';
import 'package:video_clip_edit/modules/tool_box/videoExtraction/widgets/video_player_widget.dart';
import 'package:video_clip_edit/modules/home/recreate/provdier/video_recreate_dubbing_provider.dart';

class RecreateEditStepThreePage<T extends MaterialBaseProvider>
    extends StatefulWidget {
  const RecreateEditStepThreePage({super.key});

  @override
  State<RecreateEditStepThreePage<T>> createState() =>
      _RecreateEditStepThreePageState<T>();
}

class _RecreateEditStepThreePageState<T extends MaterialBaseProvider>
    extends State<RecreateEditStepThreePage<T>> {
  @override
  void initState() {
    super.initState();

    _loadCommentaryList();

    _loadSpeakers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: ByColorUtil.WhiteColor,
      body: Column(
        children: [
          /// 视频预览
          _buildVideoPreview(context),

          /// 进度
          _buildStepView(context),

          /// 当前解说人
          _buildNarrator(context),
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: ByWidgetsUtil.commonText(
                fontSize: 12.sp,
                text: "播放片段定位剧情，手动优化解说",
                textColor: ByColorUtil.TabTextColorSelected),
          ),
          Container(
            height: 5.h,
            color: const Color(0xFFECF1F3),
          ),

          /// 文案列表
          _buildNarratorList(context),
        ],
      ),
    );
  }

  /// App Bar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: ByWidgetsUtil.commonText(
        text: "解说文案",
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
      ),
      actions: [
        SizedBox(
          height: 30.h,
          child: ByWidgetsUtil.commonBtn(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            title: "下一步",
            onClick: () {
              ByNavRouterUtils.push(
                context,
                MultiProvider(
                  providers: [
                    ChangeNotifierProvider.value(value: context.read<T>()),
                    ChangeNotifierProvider(
                        create: (context) => VideoRecreateDubbingProvider()),
                    ChangeNotifierProvider(
                        create: (context) => DownloadProvider()),
                  ],
                  child: VideoRecreateDubbingGeneratingPage<T>(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 12.w),
      ],
    );
  }

  /// 视频预览
  _buildVideoPreview(BuildContext context) {
    final dynamic asset = context.read<T>().assetSpeedy!;
    final videoOffset =
        context.select<ShowRecreateProvider, int>((p) => p.videoOffset);
    return SizedBox(
      height: 210.h,
      child: ByWidgetsUtil.futuerBuilderWidget(
        future: _parseVideoUrl(asset),
        builder: (ctx, data) {
          if (data == null) {
            return Container();
          }
          return VideoPlayerWidget(
            url: data.path,
            offset: videoOffset,
          );
        },
      ),
    );
  }

  Future<File?> _parseVideoUrl(dynamic asset) async {
    if (asset is AssetEntity) {
      return asset.file;
    }
    return asset as File;
  }

  /// 进度
  _buildStepView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: StepView<T>(step: 2),
    );
  }

  /// 文案列表
  _buildNarratorList(BuildContext context) {
    final provider = context.watch<T>() as ShowRecreateProvider;
    final beans = provider.commentaryItemBeans;
    final len = beans.length;
    return Expanded(
        child: ListView.builder(
      itemCount: len,
      itemBuilder: (ctx, index) {
        final CommentaryItemBean bean = beans[index];
        return NarratorCell<T>(
          resultBean: bean,
          index: index,
        );
      },
    ));
  }

  /// 当前解说人
  _buildNarrator(BuildContext context) {
    final index = context.select<T, int>((p) => p.selectedDubbingIdx);
    final beans = context.read<T>().dubbingBeans ?? [];
    String name = "";
    if (index != -1 && index < beans.length) {
      name = beans[index].showName;
    }
    return Row(
      children: [
        Expanded(
          child: ByWidgetsUtil.commonContainer(
            borerRadius: 8.w,
            bgColor: ByColorUtil.LoginBtnBgColor,
            margin: EdgeInsets.only(left: 12.w, bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 16.h),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  useSafeArea: false,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: context.read<T>(),
                    child: SelectNarratorDailog(
                      callback: (changed) {
                        if (changed) {
                          _loadCommentaryList();
                        }
                      },
                    ),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  // Image.asset(
                  //   "assets/home/icon_role_white.png",
                  //   width: 16.w,
                  //   height: 18.h,
                  //   fit: BoxFit.contain,
                  //   color: ByColorUtil.WhiteColor,
                  // ),
                  // SizedBox(width: 8.w),
                  // ByWidgetsUtil.commonText(
                  //   text: "解说人",
                  //   fontSize: 16.sp,
                  //   fontWeight: FontWeight.w600,
                  //   textColor: ByColorUtil.WhiteColor,
                  // ),
                  ByWidgetsUtil.commonText(
                    text: context.select<ShowRecreateProvider, String>(
                        (p) => p.selectedRoleName),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    textColor: ByColorUtil.WhiteColor,
                  ),
                  const Spacer(),
                  Image.asset(
                    "assets/home/arrow_right.png",
                    width: 16.w,
                    height: 11.h,
                    fit: BoxFit.contain,
                    color: ByColorUtil.WhiteColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ByWidgetsUtil.commonContainer(
            borerRadius: 8.w,
            bgColor: const Color(0xFF1CCB71),
            margin: EdgeInsets.only(right: 12.w, bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 16.h),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  useSafeArea: false,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: context.read<T>(),
                    child: VoiceSelectDailog<T>(),
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  // Image.asset(
                  //   "assets/home/icon_dubbing_white.png",
                  //   width: 16.w,
                  //   height: 18.h,
                  //   fit: BoxFit.contain,
                  //   color: ByColorUtil.WhiteColor,
                  // ),
                  // const Spacer(),
                  ByWidgetsUtil.commonText(
                    text: name,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    textColor: ByColorUtil.WhiteColor,
                  ),
                  const Spacer(),
                  Image.asset(
                    "assets/home/arrow_right.png",
                    width: 16.w,
                    height: 11.h,
                    fit: BoxFit.contain,
                    color: ByColorUtil.WhiteColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 生成解说文案
  void _loadCommentaryList() {
    final provider = context.read<ShowRecreateProvider>();
    HttpUtils.post(
      APIs.getCommentaryList,
      {
        "narrator": provider.realNameFormSelectedRoleName(),
        "data": jsonEncode([
          ...provider.speakerQuotesBeans.map((e) => e.toJson()),
        ]),
      },
      success: (data) {
        final String taskId = data["data"]["task_id"] ?? "";
        if (taskId.isEmpty) {
          BotToast.showText(text: "解说文案获取失败，请稍后再试");
          return;
        }
        EasyLoading.show();
        _querryStatus(taskId);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 轮询查询解说生成状态
  void _querryStatus(String taskId) {
    final provider = context.read<ShowRecreateProvider>();
    provider.queryVoiceOptimizeState(
      taskId: taskId,
      onSuccess: (List<CommentaryItemBean> commentaryItemBeans) {
        if (commentaryItemBeans.isEmpty) {
          BotToast.showText(text: "解说文案生成失败， 请稍后再试");
          return;
        }
      },
    );
  }

  void _loadSpeakers() {
    Future.microtask(() {
      final provider = context.read<T>();
      if (provider.dubbingBeans?.isEmpty ?? true) {
        provider.loadDubbingList(
          onSuccess: (p0) {
            if (p0.isNotEmpty) {
              provider.updateSelectedDubbingIdx(0);
            }
          },
        );
      } else {
        provider.updateSelectedDubbingIdx(0);
      }
    });
  }
}
