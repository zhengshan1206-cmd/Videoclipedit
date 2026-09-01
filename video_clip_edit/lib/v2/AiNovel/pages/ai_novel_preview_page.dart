// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/main/main_page.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/AiNovel/models/ai_novel_model.dart';
import 'package:video_clip_edit/v2/AiNovel/providers/ai_novel_management_provider.dart';

import '../../../main.dart';
import '../../../utils/comon/by_permission_utils.dart';
import '../../aiClip/ai_clip_page.dart';
import '../../aiClip/provider/ai_clip_opening_provider.dart';
import '../../aiClip/provider/ai_clip_provider.dart';
import '../../aiClip/provider/ai_material_provider.dart';
import '../../aiSquare/cartoon/ai_cartoon_page.dart';
import '../../aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import '../../aiSquare/draw/widgets/ai_files_downoad_dialog.dart';
import '../models/ai_novel_generation_model.dart';

class AiNovelPreviewPage extends StatefulWidget {
  final AiNovelGenerationTaskModel novelBean;
  final bool backToHme;

  const AiNovelPreviewPage({
    super.key,
    this.backToHme = false,
    required this.novelBean,
  });

  @override
  State<AiNovelPreviewPage> createState() => _AiNovelPreviewPageState();
}

class _AiNovelPreviewPageState extends State<AiNovelPreviewPage>
    with RouteAware {
  _AiNovelPreviewPageState();

  AiNovelModel? novelInfo;

  void getNovelInfo() {
    context.read<AiNovelManagementProvider>().getNovel(widget.novelBean.id,
        onSuccess: (novel) {
      if (mounted) {
        setState(() {
          novelInfo = novel;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getNovelInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ByWidgetsUtil.appBar(
          context: context,
          title: "小说详情",
          onPop: () {
            if (widget.backToHme) {
              Get.find<MainController>().backToMain();
            } else {
              ByNavRouterUtils.goBack(context);
            }
          },
        ),
        body: (novelInfo == null)
            ? const SizedBox.shrink()
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Column(
                          children: [
                            Container(
                                margin: EdgeInsets.only(top: 10.w),
                                padding: EdgeInsets.symmetric(
                                    vertical: 20.h, horizontal: 15.5.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F8F9),
                                  borderRadius: BorderRadius.circular(12.w),
                                ),
                                child: Column(
                                  children: [
                                    Row(children: [
                                      const Text(
                                        "标题",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Expanded(
                                          child: Text(
                                        novelInfo!.title ?? "-",
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                    ]),
                                    SizedBox(height: 19.5.h),
                                    // Row(
                                    //     children: [
                                    //       const Text(
                                    //         "小说类型",
                                    //         style: TextStyle(
                                    //           fontSize: 14,
                                    //         ),
                                    //       ),
                                    //       Expanded(child: Text(
                                    //         "${widget.novelBean.totalWords}字",
                                    //         textAlign: TextAlign.end,
                                    //         style: const TextStyle(
                                    //           fontSize: 14,
                                    //         ),
                                    //       )),
                                    //     ]
                                    // ),
                                    // SizedBox(height: 19.5.h),
                                    Row(children: [
                                      const Text(
                                        "当前篇幅字数",
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      Expanded(
                                          child: Text(
                                        "${novelInfo!.countWords()}字",
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      )),
                                    ]),
                                    // SizedBox(height: 19.5.h),
                                    // Row(
                                    //     children: [
                                    //       Text(
                                    //         "操作",
                                    //         style: TextStyle(
                                    //           fontSize: 14.sp,
                                    //         ),
                                    //       ),
                                    //       Expanded(child: Align(
                                    //         alignment: Alignment.centerRight,
                                    //         child: GestureDetector(
                                    //           onTap: () => null,
                                    //           child: Text(
                                    //             "举报",
                                    //             textAlign: TextAlign.end,
                                    //             style: TextStyle(
                                    //               color: const Color(0xFFFF8D40),
                                    //               fontSize: 14.sp,
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       )),
                                    //     ]
                                    // ),
                                  ],
                                )),
                            Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(top: 10.w),
                                padding: EdgeInsets.symmetric(
                                    vertical: 20.h, horizontal: 15.5.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F8F9),
                                  borderRadius: BorderRadius.circular(12.w),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      novelInfo!.getContent()!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            "assets/ai/aiNovel/info@2x.png",
                                            scale: 2),
                                        SizedBox(width: 4.5.w),
                                        Text(
                                          "AI智能生成的内容仅供参考",
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: const Color(0xFF0B1843)
                                                  .withOpacity(0.6)),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildActions(context),
                ],
              ));
  }

  _buildActions(BuildContext context) {
    final provider = context.watch<AiNovelManagementProvider>();
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        child: Column(
          children: [
            SizedBox(
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
                          ClipboardData(text: novelInfo!.toText()!),
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
                        provider.export(
                          ids: [widget.novelBean.id],
                          type: "word",
                          onSuccess: (urls) async {
                            final status = await ByPermissionUtils.storage();
                            if (!status) return;

                            final List<String> files = [];
                            await showDialog(
                              context: navigatorKey.currentContext!,
                              builder: (c) {
                                return AiFilesDownoadDialog(
                                  contents: "",
                                  maxLine: 10,
                                  cancelBtnTitle: "取消",
                                  confirmBtnTitle: "确定",
                                  confirmCallback: () {},
                                  fileUrls: urls,
                                  onSuccess: (index, filePath) async {
                                    files.add(filePath);
                                  },
                                );
                              },
                            );

                            await Share.shareXFiles(
                                files.map((e) => XFile(e)).toList(),
                                text: 'Word Document Shared');
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
                        provider.export(
                          ids: [widget.novelBean.id],
                          type: "txt",
                          onSuccess: (urls) async {
                            final status = await ByPermissionUtils.storage();
                            if (!status) return;

                            final List<String> files = [];
                            await showDialog(
                              context: navigatorKey.currentContext!,
                              builder: (c) {
                                return AiFilesDownoadDialog(
                                  contents: "",
                                  maxLine: 10,
                                  cancelBtnTitle: "取消",
                                  confirmBtnTitle: "确定",
                                  confirmCallback: () {},
                                  fileUrls: urls,
                                  onSuccess: (index, filePath) async {
                                    await Share.shareXFiles([XFile(filePath)],
                                        text: 'Txt Document Shared');
                                  },
                                );
                              },
                            );

                            await Share.shareXFiles(
                                files.map((e) => XFile(e)).toList(),
                                text: 'Word Document Shared');
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: FilledButton(
                  onPressed: () => _selectVideoStyleDialog(context),
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4BF7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      )),
                  child: const Text("生成推文视频")),
            )
          ],
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
                        provider.desc = novelInfo!.toText() ?? "";
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
                        clipProvider.currentDesc = novelInfo!.toText() ?? "";
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
}
