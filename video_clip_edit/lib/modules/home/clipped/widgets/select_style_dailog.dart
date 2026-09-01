import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/recreate/beans/role_bean.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class SelectStyleDialog<T extends MaterialBaseProvider> extends StatefulWidget {
  const SelectStyleDialog({
    super.key,
    required this.showRoles,
  });

  final bool showRoles;

  @override
  State<SelectStyleDialog> createState() => _SelectStyleDialogState<T>();
}

class _SelectStyleDialogState<T extends MaterialBaseProvider>
    extends State<SelectStyleDialog<T>> {
  // final TextEditingController wordsEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadStyles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              bottom: 14.h + ByScreenUtils.bottomSafeHeight,
              left: 11.w,
              right: 11.w,
            ),
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 13.h),
                _buildTitle(context),
                SizedBox(height: 10.h),
                _buildGrideView(context),
                if (widget.showRoles) SizedBox(height: 20.h),
                if (widget.showRoles)
                  Row(
                    children: [
                      Image.asset(
                        "assets/home/icon_role.png",
                        width: 13.w,
                        height: 16.h,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      ByWidgetsUtil.commonText(
                        text: "角色设置",
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ],
                  ),
                if (widget.showRoles) SizedBox(height: 14.h),
                if (widget.showRoles) _buildRoles(context),
                SizedBox(height: 35.h),
                SizedBox(
                  height: 44.h,
                  child: ByWidgetsUtil.commonBtn(
                    title: "立即改写",
                    fontSize: 16.sp,
                    onClick: () {
                      final provider = context.read<T>();
                      provider.changeVoiceStyle(
                        onSuccess: (String taskId) {
                          EasyLoading.show();
                          provider.queryVoiceStyleOptimizeState(
                            taskId: taskId,
                            onSuccess: (result) {
                              if (result.isNotEmpty) {
                                // wordsEditingController.text = result;
                                provider.updateSubtitle(result);
                                ByNavRouterUtils.goBack(context);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 标题
  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 30.w),
        const Spacer(),
        ByWidgetsUtil.commonText(
          text: "改写风格",
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 16.sp,
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ByNavRouterUtils.goBack(context);
          },
          child: Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/login/login_dialog_close.png",
              width: 12,
              height: 12,
            ),
          ),
        ),
        // SizedBox(width: 11.w),
      ],
    );
  }

  /// 风格列表
  _buildGrideView(BuildContext context) {
    return StyleGrideView<T>();
  }

  /// 角色列表
  _buildRoles(BuildContext context) {
    // final List<RoleBean> roles =
    //     context.select<T, List<RoleBean>>((p) => p.roles);
    final provider = context.watch<T>();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: provider.roles.length,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final role = provider.roles[index];
        return RoleNameEditCell<T>(role: role);
      },
    );
  }

  void _loadStyles() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        context.read<T>().loadStyles();
      },
    );
  }
}

class StyleGrideView<T extends MaterialBaseProvider> extends StatelessWidget {
  const StyleGrideView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<T>();
    final styles = provider.styles;
    return GridView.builder(
      itemCount: styles.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 20.0 / 9,
      ),
      itemBuilder: (context, index) {
        final stye = styles[index];
        final selected = provider.selectedStyle == stye;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            provider.updateSelectedStyle(stye);
          },
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? ByColorUtil.TabTextColorSelected.withOpacity(0.1)
                  : const Color(0xFFECF1F3),
              borderRadius: BorderRadius.circular(6.w),
            ),
            alignment: Alignment.center,
            child: ByWidgetsUtil.commonText(
              text: stye,
              textColor: selected
                  ? const Color(0xFF5B4BF7)
                  : ByColorUtil.CommonTextColor,
            ),
          ),
        );
      },
    );
  }
}

class RoleNameEditCell<T extends MaterialBaseProvider> extends StatelessWidget {
  const RoleNameEditCell({
    super.key,
    required this.role,
  });

  final RoleBean role;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key(role.userId.toString()),
      margin: const EdgeInsets.only(bottom: 10),
      height: 44.h,
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: role.avatar,
            width: 44.w,
            height: 44.h,
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: ByWidgetsUtil.commonContainer(
              borerRadius: 8.w,
              alignment: Alignment.center,
              bgColor: const Color(0xFFECF1F3),
              child: ByWidgetsUtil.commonText(
                text: role.name,
                fontSize: 14.sp,
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            ),
          ),
          SizedBox(width: 8.w),
          Image.asset(
            "assets/home/icon_role_edit.png",
            width: 15.w,
            height: 15.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ByWidgetsUtil.commonContainer(
              borerRadius: 8.w,
              alignment: Alignment.center,
              bgColor: const Color(0xFFECF1F3),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: TextField(
                maxLines: null,
                expands: true,
                cursorColor: ByColorUtil.CommonTextColor,
                // cursorHeight: 14.sp,
                onChanged: (value) {
                  role.nameEditing = value;
                  context.read<T>().updateRoles(role);
                },
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "输入修改名称",
                  contentPadding: EdgeInsets.only(top: 12.h),
                  hintStyle: TextStyle(
                    color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
