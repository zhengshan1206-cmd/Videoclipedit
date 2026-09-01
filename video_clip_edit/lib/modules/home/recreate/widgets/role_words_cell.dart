import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/role_edit_dailog.dart';
import 'package:video_clip_edit/modules/home/words/beans/audio_result_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

enum RoleWordsCellType { nromal, storylien }

class RoleWordsCell<T extends MaterialBaseProvider> extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final AudioResultBean bean;
  final RoleWordsCellType type;
  final int? storylineIndex;
  final int? wordIndex;
  final bool canEdit;

  const RoleWordsCell({
    super.key,
    required this.bean,
    this.margin,
    this.type = RoleWordsCellType.nromal,
    this.storylineIndex,
    this.wordIndex,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ??
          EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            bottom: 5.h,
          ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8F9),
        borderRadius: BorderRadius.circular(8.w),
      ),
      height: 40.h,
      child: Row(
        children: [
          Container(
            width: 90.w,
            alignment: Alignment.center,
            child: canEdit
                ? ByWidgetsUtil.btnWithIcon(
                    title: bean.speaker,
                    padding: EdgeInsets.zero,
                    iconW: 13.w,
                    iconH: 13.h,
                    iconPath: "assets/home/icon_words_edit.png",
                    bgColor: const Color(0xFFF5F8F9),
                    textColor: ByColorUtil.CommonTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    onClick: () {
                      context
                          .read<ShowRecreateProvider>()
                          .updateVideoOffset(bean);
                      _editRoleName(context, bean);
                    },
                  )
                : ByWidgetsUtil.commonBtn(
                    title: bean.speaker,
                    bgColor: const Color(0xFFF5F8F9),
                    textColor: ByColorUtil.CommonTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    onClick: () {},
                  ),
          ),
          Container(
            color: ByColorUtil.WhiteColor,
            width: 2,
          ),
          SizedBox(width: 10.w),
          if (canEdit)
            GestureDetector(
              onTap: () {
                context.read<ShowRecreateProvider>().updateVideoOffset(bean);
                _editRoleWords(context, bean);
              },
              behavior: HitTestBehavior.opaque,
              child: Image.asset(
                "assets/home/icon_words_edit.png",
                width: 13.w,
                height: 13.h,
                fit: BoxFit.contain,
              ),
            ),
          if (canEdit) SizedBox(width: 5.w),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (canEdit) {
                  context.read<ShowRecreateProvider>().updateVideoOffset(bean);
                  _editRoleWords(context, bean);
                }
              },
              child: ByWidgetsUtil.commonText(
                text: bean.text,
                fontWeight: FontWeight.normal,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 5.w),
        ],
      ),
    );
  }

  /// 编辑角色名称
  _editRoleName(
    BuildContext context,
    AudioResultBean bean,
  ) =>
      showDialog(
        context: context,
        useSafeArea: false,
        barrierDismissible: false,
        builder: (ctx) => ChangeNotifierProvider.value(
          value: context.read<T>(),
          child: RoleEditDailog<T>(
            type: RoleEditType.roleName,
            roleWordsBean: bean,
            cellType: type,
            wordIndex: wordIndex,
            storylineIndex: storylineIndex,
          ),
        ),
      );

  /// 编辑角色台词
  void _editRoleWords(
    BuildContext context,
    AudioResultBean bean,
  ) =>
      showDialog(
        context: context,
        useSafeArea: false,
        barrierDismissible: false,
        builder: (ctx) => ChangeNotifierProvider.value(
          value: context.read<T>(),
          child: RoleEditDailog<T>(
            showConfirm: true,
            type: RoleEditType.roleQuotes,
            roleWordsBean: bean,
            cellType: type,
            wordIndex: wordIndex,
            storylineIndex: storylineIndex,
          ),
        ),
      );
}
