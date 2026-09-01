import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/profile/beans/mine_videos_select_all_notification.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/modules/common/widget/common_dialog.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_videos_downoad_dialog.dart';
import 'package:video_clip_edit/modules/profile/widgets/mine_videos_management_gride_view.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_management_provider.dart';
import 'package:video_clip_edit/modules/profile/providers/mine_videos_single_page_provider.dart';

/// 工具底部的PageView整体
class MineVideosManagmentPageView extends StatelessWidget {
  const MineVideosManagmentPageView({
    super.key,
    required this.pageController,
    required this.onPageChanged,
    required this.eventBus,
  });
  final EventBus eventBus;
  final PageController pageController;
  final void Function(int index) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final List<MineVideosCategoryBean> categoryBeans = context
        .select<MineVideosManagementProvider, List<MineVideosCategoryBean>>(
      (val) => val.mineVideos,
    );

    return PageView.builder(
      physics: context.select<MineVideosManagementProvider, bool>(
              (val) => val.videosEditing == false)
          ? const PageScrollPhysics()
          : const NeverScrollableScrollPhysics(), // 指定滚动物理行为
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: categoryBeans.length,
      itemBuilder: (context, index) {
        final bean = categoryBeans[index];
        return ChangeNotifierProvider(
          create: (BuildContext context) => MineVideosSinglePageProvider(),
          child: SingleGrideView(
            bean: bean,
            index: index,
            eventBus: eventBus,
          ),
        );
      },
    );
  }
}

/// 单个九宫格列表
class SingleGrideView extends StatefulWidget {
  const SingleGrideView({
    super.key,
    required this.bean,
    required this.index,
    required this.eventBus,
  });

  final int index;
  final EventBus eventBus;
  final MineVideosCategoryBean bean;

  @override
  State<SingleGrideView> createState() => _SingleGrideViewState();
}

class _SingleGrideViewState extends State<SingleGrideView>
    with AutomaticKeepAliveClientMixin {
  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _refresh(context: context);

        widget.eventBus.on<MineVideosSelectAllNotification>().listen((event) {
          context
              .read<MineVideosSinglePageProvider>()
              .updateSelectAllStatus(event.selectAll);
        });
      });
    }
    super.initState();
  }

  // 上拉加载更多
  void _loadMore({
    required BuildContext context,
  }) {
    final provider = context.read<MineVideosSinglePageProvider>();
    final vmProvider = context.read<MineVideosManagementProvider>();
    final categoryId = vmProvider.mineVideos[widget.index].id;
    final MineVideoType type = MineVideoType.fromRawValue(categoryId);
    provider.loadVideoList(
      type: type,
      isRefresh: false,
      onSuccess: (hasMore) {
        _easyRefreshController.finishLoad(
          hasMore ? IndicatorResult.success : IndicatorResult.noMore,
          true,
        );
      },
      onFailed: () {
        _easyRefreshController.finishLoad(
          IndicatorResult.fail,
          false,
        );
      },
    );
  }

  // 下拉刷新
  void _refresh({
    required BuildContext context,
  }) {
    final provider = context.read<MineVideosSinglePageProvider>();
    final vmProvider = context.read<MineVideosManagementProvider>();
    final categoryId = vmProvider.mineVideos[widget.index].id;
    final MineVideoType type = MineVideoType.fromRawValue(categoryId);

    provider.loadVideoList(
      type: type,
      isRefresh: true,
      onSuccess: (hasMore) {
        _easyRefreshController.finishRefresh(IndicatorResult.success, true);
        _easyRefreshController.resetFooter();
      },
      onFailed: () {
        _easyRefreshController.finishRefresh(
          IndicatorResult.fail,
          false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vmProvider = context.read<MineVideosManagementProvider>();
    final categoryId = vmProvider.mineVideos[widget.index].id;
    final MineVideoType type = MineVideoType.fromRawValue(categoryId);

    final showEditBottomBar = context
        .select<MineVideosManagementProvider, bool>(
      (p) => p.videosEditing && p.selectedCategory == widget.index,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: EasyRefresh(
            triggerAxis: Axis.vertical,
            controller: _easyRefreshController,
            canLoadAfterNoMore: false,
            canRefreshAfterNoMore: true,
            onLoad: () => _loadMore(context: context),
            onRefresh: () => _refresh(context: context),
            child: MineVideosManagementGrideView(
              index: widget.index,
              type: type,
            ),
          ),
        ),
        if (showEditBottomBar) _buildBottmBar(context),
      ],
    );
  }

  Widget _buildBottmBar(BuildContext context) {
    final provider = context.read<MineVideosSinglePageProvider>();
    final providerM = context.read<MineVideosManagementProvider>();
    final rowH = ByScreenUtils.managementBottomActionRowHeight(44.h);
    final barH = ByScreenUtils.managementBottomBarSurfaceHeight(
      scaledBarH: 66.h,
      actionRowHeight: rowH,
    );
    final bottomInset = ByScreenUtils.bottomInsetForScrollable(context);
    return ColoredBox(
      color: ByColorUtil.WhiteColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: ByColorUtil.WhiteColor,
            elevation: 0,
            shadowColor: Colors.transparent,
            child: SizedBox(
              width: double.infinity,
              height: barH,
              child: Center(
                child: SizedBox(
                  height: rowH,
                  child: Row(
                  children: [
                    SizedBox(
                      width: 12.w,
                    ),
                    Expanded(
                      child: ByWidgetsUtil.commonBtn(
                        title: "取消",
                        fontSize: 16.sp,
                        borderRadius: 12.w,
                        fontWeight: FontWeight.w600,
                        bgColor: ByColorUtil.CommonTextColor.withOpacity(0.2),
                        textColor: ByColorUtil.WhiteColor,
                        onClick: () {
                          if (providerM.videosEditing) {
                            providerM.updateWorksEditingState(false);
                            provider.updateSelectAllStatus(false);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 12.w,
                    ),
                    Expanded(
                      child: ByWidgetsUtil.commonBtn(
                        title: "删除",
                        fontSize: 16.sp,
                        borderRadius: 12.w,
                        fontWeight: FontWeight.w600,
                        bgColor: const Color(0xFFFF5373),
                        textColor: ByColorUtil.WhiteColor,
                        onClick: () {
                          final ids = provider.selectedVideoIdxs;
                          if (ids.isEmpty) {
                            BotToast.showText(text: "请选择要删除的视频");
                            return;
                          }
                          final categoryId =
                              providerM.mineVideos[widget.index].id;
                          final MineVideoType type =
                              MineVideoType.fromRawValue(categoryId);
                          List<int> idsDetete = [];
                          switch (type) {
                            case MineVideoType.aiClip:
                            case MineVideoType.aiTweets:
                            case MineVideoType.playPromote:
                            case MineVideoType.novelPromote:
                              idsDetete = provider.selectedVideoIdxs
                                  .map((idx) =>
                                      provider.videoRecordBeans[idx].id)
                                  .toList();
                              break;
                            case MineVideoType.oral:
                              idsDetete = provider.selectedVideoIdxs
                                  .map((idx) =>
                                      provider.oralVideoRecordBeans[idx].id)
                                  .toList();
                              break;
                            case MineVideoType.textToVideo:
                            case MineVideoType.imgToVideo:
                            case MineVideoType.embraceVideo:
                              idsDetete = provider.selectedVideoIdxs
                                  .map((idx) =>
                                      provider.dynamicRecordBeans[idx].id)
                                  .toList();
                              break;
                            case MineVideoType.hot:
                              idsDetete = provider.selectedVideoIdxs
                                  .map((idx) => provider.hotRecordBeans[idx].id)
                                  .toList();
                              break;
                            // case MineVideoType.playPromote:
                            //   idsDetete = provider.selectedVideoIdxs
                            //       .map(
                            //           (idx) => provider.videoExtractBeans[idx].id)
                            //       .toList();
                            //   break;
                            default:
                              break;
                          }
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return CommonDialog(
                                reverse: false,
                                maxLine: 10,
                                contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
                                confirmBtnTitle: "删除",
                                confirmCallback: () {
                                  final vmProvider = context
                                      .read<MineVideosManagementProvider>();
                                  final categoryId =
                                      vmProvider.mineVideos[widget.index].id;
                                  final MineVideoType type =
                                      MineVideoType.fromRawValue(categoryId);
                                  provider.deleteVideos(
                                    idsDetete,
                                    type: type,
                                    onSuccess: () {
                                      provider.updateSelectAllStatus(false);
                                      // _easyRefreshController.callRefresh();
                                      _refresh(context: context);
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 12.w,
                    ),
                    Expanded(
                      child: ByWidgetsUtil.commonBtn(
                        title: " 下载",
                        fontSize: 16.sp,
                        borderRadius: 12.w,
                        fontWeight: FontWeight.w600,
                        textColor: ByColorUtil.WhiteColor,
                        bgColor: ByColorUtil.LoginBtnBgColor,
                        onClick: () async {
                          if (await ByPermissionUtils.storage() == false)
                            return;
                          final categoryId =
                              providerM.mineVideos[widget.index].id;
                          final MineVideoType type =
                              MineVideoType.fromRawValue(categoryId);
                          List<String> urls = [];
                          switch (type) {
                            case MineVideoType.aiClip:
                            case MineVideoType.aiTweets:
                            case MineVideoType.playPromote:
                            case MineVideoType.novelPromote:
                              urls = provider.selectedVideoIdxs
                                  .map((idx) =>
                                      provider.videoRecordBeans[idx].videoUrl)
                                  .toList();
                              break;
                            case MineVideoType.hot:
                              urls = provider.selectedVideoIdxs
                                  .map((idx) =>
                                      provider.hotRecordBeans[idx].videoUrl)
                                  .toList();
                              break;
                            case MineVideoType.oral:
                              urls = provider.selectedVideoIdxs
                                  .map((idx) => provider
                                      .oralVideoRecordBeans[idx].videoUrl)
                                  .toList();
                              break;
                            case MineVideoType.textToVideo:
                            case MineVideoType.imgToVideo:
                            case MineVideoType.embraceVideo:
                              urls = provider.selectedVideoIdxs
                                  .map((idx) =>
                                      provider
                                          .dynamicRecordBeans[idx].videoUrl ??
                                      "")
                                  .toList();
                              break;
                            // case MineVideoType.playPromote:
                            //   urls = provider.selectedVideoIdxs
                            //       .map((idx) =>
                            //           provider.videoExtractBeans[idx].shareUrl)
                            //       .toList();
                            //   break;
                            default:
                              break;
                          }
                          showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (c) {
                              return AiVideosDownoadDialog(
                                contents: "",
                                maxLine: 10,
                                cancelBtnTitle: "取消",
                                confirmBtnTitle: "确定",
                                confirmCallback: () {},
                                videoUrls: urls,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 12.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
          ColoredBox(
            color: ByColorUtil.WhiteColor,
            child: SizedBox(
              width: double.infinity,
              height: bottomInset,
            ),
          ),
        ],
      ),
    );
  }
}
