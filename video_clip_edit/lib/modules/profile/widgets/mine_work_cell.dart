import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/clipped/add_material_page.dart';
import 'package:video_clip_edit/modules/home/clipped/video_clip_hyber_preview.dart';
import 'package:video_clip_edit/modules/home/providers/clipped_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/providers/mine_page_provider.dart';
import 'package:video_clip_edit/utils/comon/by_assets_util.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_datetime_ext.dart';
import 'package:video_clip_edit/modules/profile/beans/my_work_bean.dart';
import 'package:video_clip_edit/modules/profile/widgets/work_type_view.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

enum MyWorkType { iClip, recreate, normalClip }

extension MyWorkTypeExt on MyWorkType {
  int get rawValue {
    switch (this) {
      case MyWorkType.iClip:
        return 1;
      case MyWorkType.recreate:
        return 2;
      case MyWorkType.normalClip:
        return 11;
    }
  }

  String get typeName {
    switch (this) {
      case MyWorkType.iClip:
        return "智能混剪";
      case MyWorkType.recreate:
        return "短剧二创";
      case MyWorkType.normalClip:
        return "普通剪辑";
    }
  }

  static String fromRawValue(int value) {
    return MyWorkType.values
        .firstWhere((val) => val.rawValue == value)
        .typeName;
  }

  static MyWorkType typeFromRawValue(int raw) {
    switch (raw) {
      case 1:
        return MyWorkType.iClip;
      case 2:
        return MyWorkType.recreate;
      default:
        return MyWorkType.normalClip;
    }
  }
}

class MineWorkCell extends StatefulWidget {
  final MyWorkBean myWorkBean;
  final bool canSelect;

  const MineWorkCell({
    super.key,
    required this.myWorkBean,
    this.canSelect = false,
  });

  @override
  State<MineWorkCell> createState() => _MineWorkCellState();
}

class _MineWorkCellState extends State<MineWorkCell> {
  bool fileExists = true;

  @override
  void initState() {
    super.initState();

    _checkExists();
  }

  @override
  Widget build(BuildContext context) {
    final isInprogress =
        widget.myWorkBean.status == 1 || widget.myWorkBean.status == 0;
    final selected = widget.myWorkBean.selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.canSelect) {
          widget.myWorkBean.selected = !widget.myWorkBean.selected;
          if (widget.myWorkBean.selected == false) {
            context.read<MinePageProvider>().updateSelectAllStatus(false);
          }
          setState(() {});
        } else if (fileExists) {
          ByNavRouterUtils.push(
            context,
            VideoClipHyberPrevicew(widget.myWorkBean.fileCoverUrl),
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            Positioned.fill(
              child: widget.myWorkBean.fileCoverUrl.isEmpty
                  ? Container(
                      color: ByColorUtil.BlackColor.withOpacity(0.1),
                    )
                  : fileExists
                      ? ByDownloadUtil.videoCover(
                          widget.myWorkBean.fileCoverUrl)
                      : Container(),
            ),
            WorkTypeView(
              typeName: MyWorkTypeExt.fromRawValue(widget.myWorkBean.type),
            ),
            Positioned.fill(
              child: Offstage(
                offstage: fileExists || isInprogress,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/mine/work_failed_bg.png"),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      width: 82.w,
                      height: 82.w,
                      fit: BoxFit.contain,
                      "assets/mine/work_missed.png",
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                child: Offstage(
              offstage: !isInprogress,
              child: Image.asset("assets/mine/work_in_progress.png"),
            )),
            Positioned.fill(
              child: Offstage(
                offstage: !isInprogress,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ByWidgetsUtil.commonText(
                      text: MyWorkTypeExt.fromRawValue(widget.myWorkBean.type),
                      fontSize: 14.sp,
                      textColor: ByColorUtil.WhiteColor,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    ByWidgetsUtil.commonText(
                      text: " 创作中",
                      fontSize: 14.sp,
                      textColor: ByColorUtil.WhiteColor,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          /// 加载作品详情
                          HttpUtils.get(
                            APIs.getWorkDetail,
                            {
                              "id": widget.myWorkBean.id,
                            },
                            showLoading: true,
                            success: (data) {
                              byDebugPrint(data, tag: "作品详情:");
                              MyWorkBean bean =
                                  MyWorkBean.fromJson(data["data"]);
                              byDebugPrint(bean.id);
                              // final details = bean.details ?? [];

                              final typeRawValue = widget.myWorkBean.type;
                              final typeValue =
                                  MyWorkTypeExt.typeFromRawValue(typeRawValue);

                              /// 恢复数据
                              if (typeValue == MyWorkType.recreate) {
                                final provider = ShowRecreateProvider();
                                // provider.selectedMaterials =
                                //     details.map((e) => File(e.fileUrl)).toList();
                                ByNavRouterUtils.push(
                                  context,
                                  ChangeNotifierProvider.value(
                                    value: provider,
                                    child: const AddMaterialPage<
                                        ShowRecreateProvider>(),
                                  ),
                                );
                              } else if (typeValue == MyWorkType.iClip) {
                                final provider = ClippedProvider();
                                // provider.selectedMaterials =
                                //     details.map((e) => File(e.fileUrl)).toList();
                                ByNavRouterUtils.push(
                                    context,
                                    ChangeNotifierProvider.value(
                                      value: provider,
                                      child: const AddMaterialPage<
                                          ClippedProvider>(),
                                    ));
                              }
                            },
                            fail: (code, msg) {
                              BotToast.showText(text: "获取作品详情失败，请稍后再试");
                            },
                          );
                        },
                        child: Container(
                          width: 90.w,
                          height: 32.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: ByColorUtil.LoginBtnBgColor,
                          ),
                          child: Text(
                            "继续编辑",
                            style: TextStyle(
                              color: ByColorUtil.WhiteColor,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10.w,
              bottom: 5.w,
              child: Text(
                widget.myWorkBean.updatedAt.formattedTime(),
                style: TextStyle(
                  color: ByColorUtil.WhiteColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Positioned(
                right: 10.w,
                top: 10.w,
                child: Offstage(
                  offstage: !widget.canSelect,
                  child: Image.asset(
                    selected
                        ? "assets/login/mywork_cell_selected.png"
                        : "assets/login/mywork_cell_unselected.png",
                    width: 24.w,
                    height: 24.h,
                    fit: BoxFit.contain,
                  ),
                )),
            // Positioned(
            //   right: 5.w,
            //   top: 5.h,
            //   child: GestureDetector(
            //     behavior: HitTestBehavior.opaque,
            //     onTap: () {
            //       showDialog(
            //         context: context,
            //         builder: (ctx) {
            //           return CommonDialog(
            //             reverse: false,
            //             maxLine: 10,
            //             contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
            //             confirmBtnTitle: "删除",
            //             confirmCallback: () {
            //               final provider = context.read<MinePageProvider>();
            //               provider.removeRecord(
            //                 workId: widget.myWorkBean.id.toString(),
            //                 onSuccess: () {
            //                   provider.resetPages();
            //                   provider.loadWorkList();
            //                 },
            //               );
            //             },
            //           );
            //         },
            //       );
            //     },
            //     child: Container(
            //       alignment: Alignment.topRight,
            //       width: 35.w,
            //       height: 35.h,
            //       child: Image.asset(
            //         "assets/purchase/dailog_bonus_close.png",
            //         width: 20.w,
            //         height: 20.h,
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _loadAssetPath(MyWorkBean workBean) async {
    final cover = workBean.fileCoverUrl;
    if (cover.isEmpty) {
      return null;
    }
    final asset = await ByAssetsUtil.getAssetEntityByName(
        workBean.fileCoverUrl.split(Platform.pathSeparator).last);
    if (asset == null) {
      return null;
    }
    final data =
        await asset.thumbnailDataWithSize(const ThumbnailSize(170, 170));
    return data;
  }

  _checkExists() async {
    final fileUrl = widget.myWorkBean.fileUrl;
    if (fileUrl.isEmpty) {
      setState(() {
        fileExists = false;
      });
      return false;
    }

    final wrokFile = File(fileUrl);
    final exists = await wrokFile.exists();
    if (!exists) {
      setState(() {
        fileExists = false;
      });
      return false;
    }

    setState(() {
      fileExists = true;
    });
    return true;
  }
}
