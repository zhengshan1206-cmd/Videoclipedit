import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/download/providers/download_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/clipped/video_clip_hyber_page.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/video_edit_cell.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/clipped/widgets/add_material_dailog.dart';
import 'package:video_clip_edit/utils/consts/const.dart';

class VideoMaterialEdit<T extends MaterialBaseProvider> extends StatefulWidget {
  const VideoMaterialEdit({
    super.key,
  });

  @override
  State<VideoMaterialEdit<T>> createState() => _VideoMaterialEditState<T>();
}

class _VideoMaterialEditState<T extends MaterialBaseProvider>
    extends State<VideoMaterialEdit<T>> {
  bool _showGuide = false;
  Size _captureSize = Size.zero;
  Offset _captureOffset = Offset.zero;
  ui.Image? _snapshot;
  final _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _loadGuideInfo();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<T>();
    final selectedMaterials = provider.selectedMaterials;
    final selectedMaterialSrts = provider.selectedMaterialSrts;
    final workId = provider.workId;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF4F7F8),
          appBar: ByWidgetsUtil.appBar(context: context, title: "视频编辑"),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: selectedMaterials.length + 1,
                  itemBuilder: (ctx, index) {
                    if (index == selectedMaterials.length) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (selectedMaterials.length >= 9) {
                            BotToast.showText(text: "最多添加9个视频");
                            return;
                          }
                          showDialog(
                            context: context,
                            useSafeArea: false,
                            builder: (ctx) {
                              return ChangeNotifierProvider<T>.value(
                                value: context.read<T>(),
                                child: AddMaterialDialog<T>(),
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24.w,
                                height: 24.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: ByColorUtil.WhiteColor,
                                  borderRadius: BorderRadius.circular(12.w),
                                ),
                                child: Image.asset(
                                  "assets/home/icon_clip_add.png",
                                  width: 10.w,
                                  height: 10.w,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              ByWidgetsUtil.commonText(
                                text: "新增视频片段",
                                textColor: ByColorUtil.BlackColor,
                                fontSize: 12.sp,
                              )
                            ],
                          ),
                        ),
                      );
                    }
                    return _buildListCell(
                      context: context,
                      index: index,
                    );
                  },
                ),
              ),
              _buildBottomBar(
                  workId, selectedMaterials, selectedMaterialSrts, context)
            ],
          ),
        ),
        if (_showGuide)
          Positioned.fill(
            child: Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _showGuide = false;
                    });
                  },
                  child: Container(
                    color: ByColorUtil.BlackColor.withOpacity(0.5),
                  ),
                ),
                if (_showGuide)
                  Positioned(
                    left: _captureOffset.dx,
                    top: _captureOffset.dy,
                    child: SizedBox(
                      width: _captureSize.width,
                      height: _captureSize.height,
                      child: _snapshot != null
                          ? RawImage(image: _snapshot)
                          : Container(),
                    ),
                  ),
                if (_showGuide)
                  Positioned(
                    left: _captureOffset.dx + 32.w,
                    top: _captureOffset.dy + 85.h,
                    child: Image.asset(
                      "assets/guide/guide_clip_voice.png",
                      width: 225,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildListCell({
    required BuildContext context,
    required int index,
  }) {
    return VideoEditCell<T>(
      index: index,
      captureKey: index == 0 ? _repaintBoundaryKey : null,
    );
  }

// Future<bool>  _checkMultimediaFilesDuration( BuildContext context)async{
  Container _buildBottomBar(String workId, List<dynamic> selectedMaterials,
      List<dynamic> selectedMaterialSrts, BuildContext context) {
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: 8.h + ByScreenUtils.bottomSafeHeight,
      ),
      child: SizedBox(
        height: 50.h,
        child: ByWidgetsUtil.commonBtn(
          title: "下一步",
          fontSize: 16.sp,
          onClick: () async {
            // if(workId.isEmpty&&selectedMaterialSrts.isEmpty){
            //   ByProgressHUD.showText("请配置视频文案!");
            // }

            ByNavRouterUtils.push(
              context,
              MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(value: context.read<T>()),
                  ChangeNotifierProvider(
                      create: (context) => DownloadProvider())
                ],
                child: VideoClipHyberPage<T>(
                  showCommentary: false,
                  type: 1,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _loadGuideInfo() {
    Future.delayed(
      const Duration(milliseconds: 100),
      () async {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final checked =
              ByStorageUtils.getBool(Consts.kGuidClipVoiceHasShown) ?? false;
          if (checked) return;

          /// 获取坐标
          final RenderBox renderBox = _repaintBoundaryKey.currentContext!
              .findRenderObject() as RenderBox;
          final position = renderBox.localToGlobal(Offset.zero);

          // 获取 RepaintBoundary 的 RenderObject
          RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
              .findRenderObject() as RenderRepaintBoundary;

          // 截取截图并生成 ui.Image
          ui.Image image =
              await boundary.toImage(pixelRatio: 2); // 调整 pixelRatio 以提升截图清晰度
          setState(() {
            _captureOffset = position;
            _captureSize = renderBox.size;
            _snapshot = image;
            _showGuide = true;
          });
          ByStorageUtils.saveBool(Consts.kGuidClipVoiceHasShown, true);
        });
      },
    );
  }
}
