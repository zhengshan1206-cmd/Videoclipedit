// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_permission_utils.dart';
import 'package:video_clip_edit/v2/aiClip/ai_clip_page.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/ai_cartoon_page.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_material_provider.dart';
import 'package:video_clip_edit/v2/aiClip/provider/ai_clip_opening_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/assistant_record_item_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/widgets/ai_files_downoad_dialog.dart';

class AssistantRecordDetailPage extends StatelessWidget {
  final AssistantRecordItemBean recordItemBean;
  final bool fromAi;
  final StroyCreateProvider? provider;
  const AssistantRecordDetailPage({
    super.key,
    required this.recordItemBean,
    this.fromAi = false,
    this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "创作详情"),
      backgroundColor: ByColorUtil.WhiteColor,
      body: Column(
        children: [
          Container(
            height: 5.h,
            color: const Color(0xFFF5F8F9),
          ),
          _buildListView(context),
          if (fromAi) SizedBox(height: 10.h),
          if (fromAi) _buildActions(context),
          _buildCopyBtn(context),
        ],
      ),
    );
  }

  Expanded _buildListView(BuildContext context) {
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// 创作标题
            _buildTitle(context),

            /// AI生成的创作内容
            _buildAIContents(context),
          ],
        ),
      ),
    );
  }

  /// 创作标题
  Padding _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
      child: ByWidgetsUtil.commonContainer(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 13.h,
        ),
        bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
        child: ByWidgetsUtil.commonText(
          text: recordItemBean.sketch,
          textColor: ByColorUtil.TabTextColorSelected,
          fontSize: 14.sp,
          maxLines: 1000,
        ),
      ),
    );
  }

  /// AI生成的创作内容
  _buildAIContents(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
      ),
      child: ByWidgetsUtil.commonContainer(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 13.h,
        ),
        bgColor: const Color(0xFFF5F8F9),
        child: ByWidgetsUtil.commonRichText(
          texts: [
            TextSpan(text: recordItemBean.answer),
          ],
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 14.sp,
          // maxLines: 1000,
        ),
      ),
    );
  }

  /// 复制按钮
  _buildCopyBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: 10.h + ByScreenUtils.bottomSafeHeight,
        top: 10.h,
      ),
      child: SizedBox(
        height: 50.h,
        child: ByWidgetsUtil.commonBtn(
          title: fromAi ? "一键创作视频" : "复制",
          borderRadius: 12.w,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          onClick: () {
            if (fromAi) {
              _selectVideoStyleDialog(context);
            } else {
              Clipboard.setData(
                ClipboardData(text: recordItemBean.answer),
              );
              BotToast.showText(text: "复制成功");
            }
          },
        ),
      ),
    );
  }

  _selectVideoStyleDialog(BuildContext context) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (BuildContext ctx) {
        //构建弹框中的内容
        return StatefulBuilder(builder: (c, setBottomSheetState) {
          return Container(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 12, right: 12),
            alignment: Alignment.center,
            height: 265.h,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Text(
                      "选择视频类型",
                      style: TextStyle(
                          color: ByColorUtils.hexColor("#0B1843"),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Image.asset(
                        "assets/ai/aichat_hsgb.png",
                        width: 14.w,
                        height: 14.h,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        ByNavRouterUtils.goBack(context);
                        final provider = AiCartoonProvider();
                        provider.desc = recordItemBean.answer;
                        ByNavRouterUtils.push(
                          context,
                          ChangeNotifierProvider(
                            create: (context) => provider,
                            child: const AiCartoonPage(),
                          ),
                        );
                      },
                      child: Image.asset(
                        "assets/ai/aichat_mahuatuiwen.png",
                        height: 180.h,
                      ),
                    )),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        ByNavRouterUtils.goBack(context);
                        final clipProvider = AiClipProvider();
                        clipProvider.desc = recordItemBean.answer;
                        ByNavRouterUtils.push(
                            context,
                            MultiProvider(providers: [
                              ChangeNotifierProvider(
                                create: (context) => clipProvider,
                              ),
                              ChangeNotifierProvider(
                                create: (BuildContext context) =>
                                    AiMaterialProvider(),
                              ),
                              ChangeNotifierProvider(
                                create: (BuildContext context) =>
                                    AiClipOpeningProvider(),
                              ),
                            ], child: const AiClipPage()));
                      },
                      child: Image.asset(
                        "assets/ai/aichat_znhj.png",
                        height: 180.h,
                      ),
                    )),
                  ],
                )
              ],
            ),
          );
        });
      },
      context: context,
    );
  }

  _buildActions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      child: SizedBox(
        height: 36.h,
        child: Row(
          children: [
            Expanded(
              child: ByWidgetsUtil.btnWithIcon(
                title: "复制文案",
                borderRadius: 8.w,
                padding: EdgeInsets.zero,
                bgColor: const Color(0xFFF8FAFB),
                fontSize: 14.sp,
                textColor: ByColorUtil.CommonTextColor,
                iconPath: "assets/mine/score_icon_copy.png",
                onClick: () {
                  Clipboard.setData(
                    ClipboardData(text: recordItemBean.answer),
                  );
                  BotToast.showText(text: "复制成功");
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ByWidgetsUtil.btnWithIcon(
                title: "导出Word",
                borderRadius: 8.w,
                padding: EdgeInsets.zero,
                bgColor: const Color(0xFFF8FAFB),
                fontSize: 14.sp,
                textColor: ByColorUtil.CommonTextColor,
                iconPath: "assets/mine/score_icon_word.png",
                onClick: () {
                  provider?.exportDoc(
                    ids: recordItemBean.token,
                    type: "word",
                    onSuccess: (url) async {
                      final status = await ByPermissionUtils.storage();
                      if (!status) return;
                      showDialog(
                        context: context,
                        builder: (c) {
                          return AiFilesDownoadDialog(
                            contents: "",
                            maxLine: 10,
                            cancelBtnTitle: "取消",
                            confirmBtnTitle: "确定",
                            confirmCallback: () {},
                            fileUrls: [url],
                            onSuccess: (index, filePath) async {
                              await Share.shareXFiles([XFile(filePath)],
                                  text: 'Word Document Shared');
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ByWidgetsUtil.btnWithIcon(
                title: "导出TXT",
                borderRadius: 8.w,
                padding: EdgeInsets.zero,
                bgColor: const Color(0xFFF8FAFB),
                fontSize: 14.sp,
                textColor: ByColorUtil.CommonTextColor,
                iconPath: "assets/mine/score_icon_txt.png",
                onClick: () async {
                  final directory = await getApplicationCacheDirectory();
                  final filePath =
                      "${directory.path}/files/file_${DateTime.now().millisecondsSinceEpoch}.txt";
                  // 创建文件并写入内容
                  File file = File(filePath);
                  await file.writeAsString(
                    "标题: ${recordItemBean.sketch}\n\n\n时间: ${recordItemBean.answerEndTime}\n\n\n内容: ${recordItemBean.answer}\n\n\n",
                  );

                  await Share.shareXFiles([XFile(filePath)],
                      text: 'Txt Document Shared');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
