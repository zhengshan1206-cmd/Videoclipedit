import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PictureEraseResultPage extends StatelessWidget {
  const PictureEraseResultPage({
    super.key,
    required this.asset,
  });
  final AssetEntity? asset;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "图片擦除"),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          /// 视频、图片预览
          _buildPreview(context),

          /// 底部按钮
          _buildBottomBtn(context),
        ],
      ),
    );
  }

  /// 视频、图片预览
  Expanded _buildPreview(BuildContext context) {
    return Expanded(
      child: asset == null
          ? Container()
          : Container(
              color: Colors.green[100],
              child: FutureBuilder<Widget>(
                future: asset!.originBytes.then((data) {
                  if (data != null) {
                    return Image.memory(
                      data,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Container(
                      color: Colors.grey,
                    );
                  }
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
    );
  }

  /// 底部按钮
  Container _buildBottomBtn(BuildContext context) {
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: 8.h + ByScreenUtils.bottomSafeHeight,
      ),
      child: ByWidgetsUtil.commonBtn(
        title: "保存到相册",
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        borderRadius: 12.w,
        onClick: () {
          BotToast.showText(text: "保存成功");
        },
      ),
    );
  }
}
