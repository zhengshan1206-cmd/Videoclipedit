import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';

class FunctionView extends StatelessWidget {
  final SubFunction functionBean;
  final void Function(SubFunction) onClick;
  const FunctionView({
    super.key,
    required this.functionBean,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onClick(functionBean);
      },
      child: Column(
        children: [
          CachedNetworkImage(
            imageUrl: functionBean.imgUrl,
            width: 34.w,
            height: 34.w,
          ),
          const Spacer(),
          Text(
            functionBean.des,
            style: TextStyle(
              color: ByColorUtil.CommonTextColor,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
