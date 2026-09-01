import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_download_util.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/beans/ai_draw_img_details_bean.dart';

class AiDrawDetailsPage extends StatefulWidget {
  const AiDrawDetailsPage({
    super.key,
    required this.taskId,
  });

  final int taskId;

  @override
  State<AiDrawDetailsPage> createState() => _AiDrawDetailsPageState();
}

class _AiDrawDetailsPageState extends State<AiDrawDetailsPage>
    with SingleTickerProviderStateMixin {
  AiDrawImgDetailsBean? _drawImgDetailsBean;
  @override
  void initState() {
    super.initState();

    loadImgesDetails();
  }

  @override
  Widget build(BuildContext context) {
    final url = _drawImgDetailsBean?.picUrl ?? "";
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
        context: context,
        title: '绘图详情',
      ),
      backgroundColor: ByColorUtil.CommonPageBgColor,
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Expanded(
            child: url.isEmpty
                ? Container()
                : CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                  ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.only(
              top: 8.h,
              left: 12.w,
              right: 12.w,
              bottom: ByScreenUtils.bottomSafeHeight + 8.h,
            ),
            child: SizedBox(
              height: 50.h,
              child: ByWidgetsUtil.commonBtn(
                title: "保存到相册",
                textColor: ByColorUtil.WhiteColor,
                bgColor: ByColorUtil.LoginBtnBgColor,
                fontSize: 16.sp,
                borderRadius: 12.w,
                fontWeight: FontWeight.w600,
                onClick: () {
                  final url = _drawImgDetailsBean?.picUrl ?? "";
                  if (url.isEmpty) {
                    BotToast.showText(text: "图片保存失败");
                    return;
                  }
                  ByDownloadUtil.saveNetwrokImage(url);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void loadImgesDetails() {
    HttpUtils.get(
      APIs.aiImageDetails,
      showLoading: true,
      {"id": widget.taskId},
      success: (data) {
        byDebugPrint(data);
        final bean = AiDrawImgDetailsBean.fromJson(data["data"]);
        setState(() {
          _drawImgDetailsBean = bean;
        });
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
