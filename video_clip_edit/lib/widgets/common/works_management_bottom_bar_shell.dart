import 'package:flutter/material.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';

/// 作品管理类页面底部操作栏外壳：不透明白底铺满宽度，并延伸盖住底部安全区/手势条，
/// 避免 Stack 下层列表在 Row 缝隙处「透底」；与 [VideosManagementBar]、个人中心管理页思路一致。
class WorksManagementBottomBarShell extends StatelessWidget {
  const WorksManagementBottomBarShell({
    super.key,
    required this.barSurfaceHeight,
    required this.actionRowHeight,
    required this.actionsRow,
    this.materialElevation = 0,
  });

  final double barSurfaceHeight;
  final double actionRowHeight;
  final Widget actionsRow;
  final double materialElevation;

  @override
  Widget build(BuildContext context) {
    final bottomInset = ByScreenUtils.bottomInsetForScrollable(context);
    return ColoredBox(
      color: ByColorUtil.WhiteColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: ByColorUtil.WhiteColor,
            elevation: materialElevation,
            shadowColor:
                materialElevation > 0 ? Colors.black26 : Colors.transparent,
            child: SizedBox(
              width: double.infinity,
              height: barSurfaceHeight,
              child: Center(
                child: SizedBox(
                  height: actionRowHeight,
                  child: ColoredBox(
                    color: ByColorUtil.WhiteColor,
                    child: actionsRow,
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
