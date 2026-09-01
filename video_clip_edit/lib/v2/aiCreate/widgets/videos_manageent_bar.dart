import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class VideosManagementBar extends StatelessWidget {
  const VideosManagementBar({
    super.key,
    this.onCancel,
    this.onDelete,
    this.onDownload,
  });
  final void Function()? onCancel;
  final void Function()? onDelete;
  final void Function()? onDownload;

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.black,
      elevation: 10,
      child: Container(
        height: 66.h,
        width: double.infinity,
        color: ByColorUtil.WhiteColor,
        alignment: Alignment.center,
        child: SizedBox(
          height: 44.h,
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
                    // controller.videosEditing.value = false;
                    onCancel?.call();
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
                    onDelete?.call();
                    // final ids = provider.selectedVideoIdxs;
                    // if (ids.isEmpty) {
                    //   BotToast.showText(text: "请选择要删除的视频");
                    //   return;
                    // }
                    // showDialog(
                    //   context: context,
                    //   builder: (ctx) {
                    //     return CommonDialog(
                    //       reverse: false,
                    //       maxLine: 10,
                    //       contents: "请确认是否删除，删除后将不可回恢复，请谨慎操作",
                    //       confirmBtnTitle: "删除",
                    //       confirmCallback: () {
                    //         provider.deleteVideos(
                    //           ids.map((e) {
                    //             return provider.videoRecordBeans[e].id;
                    //           }).toList(),
                    //           onSuccess: () {
                    //             provider.resetPages();
                    //             provider.updateSelectAllStatus(false);
                    //             provider.loadVideoList();
                    //           },
                    //         );
                    //       },
                    //     );
                    //   },
                    // );
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
                  onClick: () {
                    onDownload?.call();
                    // if (await ByPermissionUtils.storage() == false)
                    //   return;
                    // showDialog(
                    //   // ignore: use_build_context_synchronously
                    //   context: context,
                    //   builder: (c) {
                    //     return AiVideosDownoadDialog(
                    //       contents: "",
                    //       maxLine: 10,
                    //       cancelBtnTitle: "取消",
                    //       confirmBtnTitle: "确定",
                    //       confirmCallback: () {},
                    //       videoUrls: provider.selectedVideoIdxs
                    //           .map((idx) =>
                    //               provider.videoRecordBeans[idx].videoUrl)
                    //           .toList(),
                    //     );
                    //   },
                    // );
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
    );
  }
}
