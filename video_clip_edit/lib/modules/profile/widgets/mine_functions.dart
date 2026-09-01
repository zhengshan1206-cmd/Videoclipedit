import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/profile/widgets/function_view.dart';
import 'package:video_clip_edit/providers/mine_page_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';

class MineFunctionsView extends StatelessWidget {
  const MineFunctionsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MinePageProvider>();
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: ByColorUtil.WhiteColor,
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 14,
        ),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: provider.menuItemBeans?.length ?? 0,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 4,
          crossAxisSpacing: 8,
          childAspectRatio: 41 / 32,
          crossAxisCount: 4,
        ),
        itemBuilder: (context, index) {
          return FunctionView(
            functionBean: provider.menuItemBeans![index],
            onClick: (functionBean) {
              final url = functionBean.jumpUrl;
              if (url.startsWith("http")) {
                ByNavRouterUtils.jumpWebViewPage(
                    context, functionBean.des, url);
              }
            },
          );
        },
      ),
    );
  }
}
