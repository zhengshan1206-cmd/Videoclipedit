import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/data/model/folk/story_role_bean.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/input/normal_input_view.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/role_info_edit_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/prohited/prohibited_words_dailog.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/prohited/prohited_words_detect_mixin.dart';

// ignore: must_be_immutable
class RoleRegeneratePage extends StatefulWidget {
  const RoleRegeneratePage({
    super.key,
    required this.role,
  });

  final StoryRoleBean role;

  @override
  State<RoleRegeneratePage> createState() => _RoleRegeneratePageState();
}

class _RoleRegeneratePageState extends State<RoleRegeneratePage>
    with ProhitedWordsDetectMixin {
  RxInt selectedIdx = (-1).obs;
  final editController = Get.put(RoleInfoEditController());
  late final Rx<StoryRoleBean> _role = widget.role.obs;
  final CancelToken _cancelToken = CancelToken();

  @override
  void dispose() {
    _cancelToken.cancel();
    editController.dispose();
    Get.delete<RoleInfoEditController>();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _checkSelectedStatus();

    /// 轮询角色详情
    _checkRoleStatus();
  }

  void _checkSelectedStatus() {
    final redraw = _role.value.reworkUrl.isNotEmpty;
    if (redraw) {
      final rework = _role.value.reworkUrl.first;
      final status = rework.status;
      if (status == RoleRegenerateStatus.roleRedrawCompleted.rawValue) {
        selectedIdx.value = 1;
        return;
      }
    }

    final status = RoleRegenerateStatus.fromValue(_role.value.status);
    final success = RoleRegenerateStatus.roleDrawCompleted == status;
    if (success) {
      selectedIdx.value = 0;
    } else {
      selectedIdx.value = -1;
    }
  }

  void _checkRoleStatus() {
    editController.reset();

    editController.pollingRoleInfo(
      roleId: _role.value.id,
      cancelToken: _cancelToken,
      onValidateBefore: (roleBean) {
        _role.value = roleBean;
        _checkSelectedStatus();
      },
      onComplete: (roleBean) {
        editController.reset();
        _role.value = roleBean;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: "角色修改",
          onPop: () {
            Get.back(result: false);
          },
          showBottmLine: true,
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 25.h),
            _buildImageList(context),
            _buildDesc(context),
            _buildInputVIew(context),
            const Spacer(),
            _buildBottomBar(context),
          ],
        ));
  }

  Widget _buildInputVIew(BuildContext context) {
    return SizedBox(
      height: 160.h,
      width: double.infinity,
      child: ByWidgetsUtil.commonContainer(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        borerRadius: 10.w,
        bgColor: const Color(0xFFF4F8F9),
        child: Obx(() {
          return NormalInputView(
            maxWords: 200,
            key: UniqueKey(),
            placeholder: "请输入角色描述",
            initialValue: _role.value.desc,
            onChanged: (value) {
              _role.value.desc = value;
            },
          );
        }),
      ),
    );
  }

  Widget _buildDesc(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: 38.h,
      color: ByColorUtil.WhiteColor,
      child: Row(
        children: [
          Image.asset(
            "assets/v2/folk/icon_role_edit.png",
            width: 16.w,
            height: 16.h,
          ),
          SizedBox(width: 3.w),
          ByWidgetsUtil.commonText(
            text: "角色描述",
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  void onSelected(RoleRegenerateStatus status, int index) {
    if (index == selectedIdx.value) return;
    if (index == 0 && status == RoleRegenerateStatus.roleDrawCompleted) {
      selectedIdx.value = index;
      return;
    }

    /// 重绘完成
    if (index == 1 && status == RoleRegenerateStatus.roleRedrawCompleted) {
      selectedIdx.value = index;
      return;
    }
  }

  /// 角色图片列表(图片宽高比固定为3:4)
  Widget _buildImageList(BuildContext context) {
    final contentsW = ByScreenUtils.screenWidth - 12.w * 2;
    final margin = 5.w;
    final padding = 4.5.w;
    const showCount = 2.5;
    final width = (contentsW - margin * 2 * (showCount.ceil() - 1)) / showCount;
    final height = (width - padding * 2) * 4 / 3 + padding * 2;

    return Obx(() {
      final redraw = _role.value.reworkUrl.isNotEmpty;
      final total = redraw ? 2 : 1;
      return SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: redraw
                ? [
                    RoleRegenerateCell(
                      selected: selectedIdx.value == 0,
                      onSelected: onSelected,
                      index: 0,
                      width: width,
                      total: total,
                      role: _role.value,
                      isOriginal: true,
                    ),
                    RoleRegenerateCell(
                      selected: selectedIdx.value == 1,
                      onSelected: onSelected,
                      index: 1,
                      width: width,
                      total: total,
                      role: _role.value,
                      isOriginal: false,
                    ),
                  ]
                : [
                    RoleRegenerateCell(
                      selected: selectedIdx.value == 0,
                      onSelected: onSelected,
                      index: 0,
                      width: width,
                      total: total,
                      role: _role.value,
                      isOriginal: true,
                    ),
                  ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar(BuildContext context) {
    return ByWidgetsUtil.physicalModel(
      color: Colors.white,
      child: Container(
        height: 66.h,
        padding: EdgeInsets.symmetric(
          vertical: 8.h,
          horizontal: 12.w,
        ),
        child: Row(
          children: [
            Expanded(
              child: ByWidgetsUtil.commonBtn(
                title: "重新绘制",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                bgColor: const Color(0xFFEAEEFF),
                padding: EdgeInsets.zero,
                borderRadius: 12.w,
                textColor: ByColorUtil.LoginBtnBgColor,
                onClick: () {
                  final reworkNum = _role.value.reworkNum;
                  if (reworkNum <= 0) {
                    BotToast.showText(text: "已达到最大重绘次数");
                    return;
                  }
                  detect(
                    context,
                    _role.value.desc,
                    onSuccess: () {
                      editController.roleInfoRepaint(
                        roleId: _role.value.id,
                        desc: _role.value.desc,
                        onSucess: (data) {
                          /// 轮询角色详情
                          _checkRoleStatus();
                        },
                      );
                    },
                    onFail: () {
                      showDialog(
                          context: context,
                          useSafeArea: false,
                          barrierDismissible: true,
                          builder: (ctx) => ProhibitedWordsDailog(
                              originalContents: _role.value.desc,
                              onTextChanged: (value) {
                                _role.value.desc = value;
                              }));
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ByWidgetsUtil.commonBtn(
                title: "使用",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                bgColor: ByColorUtil.LoginBtnBgColor,
                padding: EdgeInsets.zero,
                borderRadius: 12.w,
                onClick: () {
                  if (selectedIdx.value != 1) {
                    Get.back(result: false);
                    return;
                  }
                  final reworkUrl =
                      _role.value.reworkUrl.firstOrNull?.img ?? "";

                  if (reworkUrl.isEmpty){
                    Get.back(result: false);
                    return;
                  } 

                  editController.updateRoleInfo(
                    roleId: _role.value.id,
                    url: reworkUrl,
                    desc: _role.value.desc,
                    onSucess: (data) {
                      Get.back(result: true);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleRegenerateCell extends StatelessWidget {
  const RoleRegenerateCell({
    super.key,
    this.onSelected,
    required this.total,
    required this.role,
    required this.index,
    required this.width,
    required this.selected,
    required this.isOriginal,
  });

  final int index;
  final int total;
  final double width;
  final bool selected;
  final bool isOriginal;
  final StoryRoleBean role;
  final void Function(RoleRegenerateStatus, int)? onSelected;

  @override
  Widget build(BuildContext context) {
    final rawValue = isOriginal ? role.status : role.reworkUrl.first.status;
    final status = RoleRegenerateStatus.fromValue(rawValue);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onSelected?.call(status, index);
      },
      child: ByWidgetsUtil.commonContainer(
        borerRadius: 15.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        border: Border.all(
          color: selected ? ByColorUtil.LoginBtnBgColor : Colors.transparent,
          width: 2.w,
        ),
        padding: EdgeInsets.all(2.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11.w),
          child: ByWidgetsUtil.commonContainer(
            border: Border.all(
              color:
                  selected ? ByColorUtil.WhiteColor : const Color(0xFFEAEEFF),
              width: 0.5.w,
            ),
            child: Stack(
              children: [
                _buildContentsByStatus(context, status),
                Positioned(
                  bottom: 5.h,
                  right: 5.w,
                  height: 20.h,
                  child: ByWidgetsUtil.commonContainer(
                    alignment: Alignment.center,
                    bgColor: const Color(0xFF000000).withOpacity(0.3),
                    padding: EdgeInsets.symmetric(horizontal: 7.w),
                    child: ByWidgetsUtil.commonText(
                      text: "${index + 1}/$total",
                      fontSize: 10.sp,
                      textColor: const Color(0xFFFFFFFF),
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentsByStatus(
    BuildContext context,
    RoleRegenerateStatus status,
  ) {
    final renderW = width - 5.w;
    if (isOriginal) {
      if (status == RoleRegenerateStatus.roleDrawCompleted) {
        return CachedNetworkImage(
          imageUrl: role.url,
          width: renderW,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      }
      if (status == RoleRegenerateStatus.roleDrawFailed) {
        return SizedBox(
          width: renderW,
          child: ByWidgetsUtil.commonContainer(
            bgColor: const Color(0xFFF8FAFB),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  "assets/v2/folk/generate_faild.png",
                  width: 44.w,
                  height: 44.w,
                ),
                SizedBox(height: 15.h),
                ByWidgetsUtil.commonText(
                  text: "生成失败",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: const Color(0xFF81899F),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      }
    }
    switch (status) {
      case RoleRegenerateStatus.roleExtracted:
      case RoleRegenerateStatus.roleDrawing:
      case RoleRegenerateStatus.roleRedrawing:
        return SizedBox(
          width: renderW,
          child: ByWidgetsUtil.commonContainer(
            bgColor: const Color(0xFFF8FAFB),
            child: Column(
              children: [
                const Spacer(),
                SizedBox(
                  width: 33.w,
                  height: 33.w,
                  child: ByWidgetsUtil.activityIndicator(),
                ),
                SizedBox(height: 15.h),
                ByWidgetsUtil.commonText(
                  text: "图片绘制中...",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.LoginBtnBgColor,
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      case RoleRegenerateStatus.roleRedrawCompleted:
        return CachedNetworkImage(
          imageUrl: role.reworkUrl.firstOrNull?.img ?? role.url,
          width: renderW,
          fit: BoxFit.cover,
        );
      case RoleRegenerateStatus.roleDrawFailed:
      case RoleRegenerateStatus.roleRedrawFailed:
        return SizedBox(
          width: renderW,
          child: ByWidgetsUtil.commonContainer(
            bgColor: const Color(0xFFF8FAFB),
            child: Column(
              children: [
                const Spacer(),
                Image.asset(
                  "assets/v2/folk/generate_faild.png",
                  width: 44.w,
                  height: 44.w,
                ),
                SizedBox(height: 15.h),
                ByWidgetsUtil.commonText(
                  text: "生成失败",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                  textColor: const Color(0xFF81899F),
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      default:
        return Container();
    }
  }
}
