import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';

import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_square_model.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/_generation_settings_card.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_video_management_page.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';

import '../../../providers/launch_provider.dart';

class TextToVideoForm extends StatefulWidget {
  const TextToVideoForm({
    super.key,
    this.prompt,
    this.negativePrompt,
    this.cfgScale,
    this.aspectRatio,
    this.duration,
    this.mode,
    this.onChanged,
    this.fromChat = false,
  });

  final String? prompt;
  final String? negativePrompt;
  final double? cfgScale;
  final String? aspectRatio;
  final int? duration;
  final String? mode;
  final void Function(String)? onChanged;
  final bool fromChat;
  @override
  State<TextToVideoForm> createState() => _TextToVideoFormState();
}

class _TextToVideoFormState extends State<TextToVideoForm> {
  final _contentScrollController = ScrollController();
  final _promptFocus = FocusNode();
  late final _promptController = TextEditingController();
  late final _negativePromptController = TextEditingController();
  final optionsCardsKey = GlobalKey<GenerationSettingsCardState>();
  LaunchProvider get launchProvider => Get.context!.read<LaunchProvider>();

  String? bgmUrl;

  List<dynamic>? prompts;
  var _promptIndex = 0;
  void _nextPrompt() {
    if (prompts != null && prompts!.isNotEmpty) {
      setState(() {
        _promptIndex = Random().nextInt(prompts!.length);
        _promptController.text = prompts![_promptIndex]["prompt"];
        widget.onChanged?.call(_promptController.text);
      });
    }
  }

  void _loadPrompts() {
    Provider.of<AiVideoProvider>(context, listen: false).loadPrompts(
        type: AiVideoGenerationType.textToVideo,
        onSuccess: (prompts) {
          if (mounted) {
            setState(() {
              this.prompts = prompts;
              _promptIndex = Random().nextInt(prompts.length);
            });
          }
        });
  }

  RightsByType? _rights;
  void updateRights() {
    Provider.of<AiVideoProvider>(context, listen: false).loadRights(
        type: AiVideoGenerationType.textToVideo,
        onSuccess: (rights) {
          if (mounted) {
            setState(() {
              _rights = rights;
            });
          }
        });
  }

  @override
  void initState() {
    super.initState();
    _promptController.text = widget.prompt ?? "";
    _negativePromptController.text = widget.negativePrompt ?? "";
    _loadPrompts();
    updateRights();

    // 添加监听器
    final aivideoProvider = context.read<AiVideoProvider>();
    aivideoProvider.addListener(() {
      if (mounted && aivideoProvider.desc != _promptController.text) {
        _promptController.text = aivideoProvider.desc;
        widget.onChanged?.call(aivideoProvider.desc);
      }
    });
  }

  @override
  void dispose() {
    _contentScrollController.dispose();
    _promptController.dispose();
    _negativePromptController.dispose();
    if (widget.fromChat) {
      final integralVipController = IntegralVipController.getOrPut();
      integralVipController.init(
        requiredPoints: 0,
        type: "txt_knows",
      );
    }
    super.dispose();
  }

  void submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      BotToast.showText(text: "请输入创意描述");
      _promptFocus.requestFocus();
      return;
    }
    // final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    // if (isVip != 1) {
    //   ByNavRouterUtils.push(
    //     context,
    //     ChangeNotifierProvider(
    //       create: (BuildContext context) =>
    //           AiVipGuidProvider(),
    //       child: const AiVipGuidPage(),
    //     ),
    //   );
    //   return;
    // }
    final purchaseProvider = context.read<PurchaseProvider>();
    if (purchaseProvider.preLoginCheck(context) == false) return;

    final aivideoProvider = context.read<AiVideoProvider>();
    aivideoProvider.desc = prompt;

    final integralVipController = IntegralVipController.getOrPut();

    ///不是会员并且无试用-付费弹窗
    if (!chekVip() && integralVipController.isTest <= 0) {
      final provider = context.read<AiSquareProvider>();
      String mark = 'ai_text_to_video';
      provider.showModelPayDialog(context, mark);
      return;
    }
    // 检查积分是否足够
    if (!integralVipController.canContinueUse()) {
      integralVipController.showIntegralPayDialog();
      return;
    }

    aivideoProvider.detect(
      context,
      aivideoProvider.desc,
      onSuccess: () {
        byDebugPrint(aivideoProvider.bandedWords, tag: "违禁词洁厕结果:");
        if (aivideoProvider.bandedWords.isNotEmpty) {
          BotToast.showText(text: "当前存在违禁词");
          showDialog(
            context: context,
            useSafeArea: false,
            barrierDismissible: true,
            builder: (ctx) => ChangeNotifierProvider.value(
              value: aivideoProvider,
              child: const AiCartoonProhibitedWordsDailog<AiVideoProvider>(),
            ),
          );
        } else {
          Provider.of<AiVideoProvider>(context, listen: false).generate(
            prompt: prompt,
            negativePrompt: _negativePromptController.text.trim(),
            cfgScale: optionsCardsKey.currentState?.cfgScale,
            mode: optionsCardsKey.currentState?.mode,
            aspectRatio: optionsCardsKey.currentState?.aspectRatio,
            optimizePrompt: optionsCardsKey.currentState?.optimizePrompt,
            duration: optionsCardsKey.currentState?.duration,
            generationType: AiVideoGenerationType.textToVideo,
            bgmUrl: bgmUrl,
            onSuccess: () {
              integralVipController.init(
                requiredPoints: 0,
                type: "ai_text2_video",
              );
              updateRights();
              ByNavRouterUtils.pushReplacement(
                  context,
                  MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                          create: (context) => AiVideoManagementProvider()),
                    ],
                    child: const AiVideoManagementPage(),
                  ));
            },
          );
        }
      },
    );
  }

  void showRecords() {
    ByNavRouterUtils.push(
        context,
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (context) => AiVideoManagementProvider()),
          ],
          child: const AiVideoManagementPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _contentScrollController,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            children: [
              buildPromptInput(),
              SizedBox(height: 10.h),
              GenerationSettingsCard(
                key: optionsCardsKey,
                type: AiVideoGenerationType.textToVideo,
                cfgScale: widget.cfgScale,
                aspectRatio: widget.aspectRatio,
                duration: widget.duration,
                mode: widget.mode,
                onExpandChanged: (expanded) {
                  if (expanded) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _contentScrollController.animateTo(
                        _contentScrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.linear,
                      );
                    });
                  }
                },
                bgmUrlChange: (value) {
                  bgmUrl = value;
                  log("========bgmUrl==== $bgmUrl");
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
        buildBottomBar(),
      ],
    );
  }

  Widget buildPromptInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.w),
        border: Border.all(
          color: Colors.white,
          width: 0.5.w,
        ),
        gradient: const LinearGradient(
          colors: [
            Color(0x4DFCF9FF),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset("assets/ai/aiVideo/earth@2x.png", scale: 2),
              SizedBox(width: 3.w),
              Text(
                "创意描述",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: ByColorUtil.CommonTextColor,
                ),
              )
            ],
          ),
          SizedBox(height: 7.5.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.w),
              border: Border.all(
                color: const Color(0xFFF6DBFE),
                width: 0.5.w,
              ),
            ),
            child: Column(
              children: [
                TextField(
                  maxLength: 300,
                  minLines: 6,
                  maxLines: 10,
                  expands: false,
                  controller: _promptController,
                  focusNode: _promptFocus,
                  autofocus: false,
                  onChanged: (String value) {
                    widget.onChanged?.call(value);
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                      color: ByColorUtil.CommonTextColor,
                    ),
                    hintText: "请输入视频画面内容，如一个带眼镜的大熊猫正在吃火锅",
                    counterText: "",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                      color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                    ),
                  ),
                  cursorColor: ByColorUtil.CommonTextColor,
                ),
                Row(
                  children: [
                    ListenableBuilder(
                        listenable: _promptController,
                        builder: (context, _) {
                          return Text(
                            "${_promptController.text.length}/300",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  ByColorUtil.CommonTextColor.withOpacity(0.3),
                            ),
                          );
                        }),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final pasteText =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        if (pasteText?.text != null) {
                          var newText =
                              _promptController.text + pasteText!.text!;
                          if (newText.length > 300) {
                            newText = newText.substring(0, 300);
                          }
                          _promptController.text = newText;
                          widget.onChanged?.call(_promptController.text);
                        }
                      },
                      child: Text(
                        "粘贴",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 14,
                      child: VerticalDivider(
                        color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                        width: 20.w,
                        thickness: 1.w,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          _promptController.clear();
                          widget.onChanged?.call(_promptController.text);
                        },
                        child: Text(
                          "清空",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                          ),
                        )),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 12.5.h),
          if (prompts != null && prompts!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
              child: Row(children: [
                Expanded(
                    child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _promptController.text = prompts![_promptIndex]["prompt"];
                      widget.onChanged?.call(_promptController.text);
                    });
                  },
                  child: Text(
                    "推荐尝试：${prompts![_promptIndex]["prompt"]}",
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6547EE),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )),
                SizedBox(width: 18.w),
                GestureDetector(
                    onTap: _nextPrompt,
                    child: Image.asset("assets/ai/aiVideo/refresh@2x.png",
                        scale: 2)),
              ]),
            )
        ],
      ),
    );
  }

  Widget buildBottomBar() {
    final modeNotifier = optionsCardsKey.currentState?.modeNotifier;
    final durationNotifier = optionsCardsKey.currentState?.durationNotifier;
    return ListenableBuilder(
        listenable: Listenable.merge([
          modeNotifier,
          durationNotifier,
        ]),
        builder: (context, snapshot) {
          final mode = modeNotifier?.value;
          final duration = durationNotifier?.value;
          // 只有在标准模式std 时长5s的情况下  才展示限免次数。  其他情况统一展示积分消耗。
          final showFreeCount = _rights != null &&
              ((_rights!.currentIntegral == 0) ||
                  ((_rights!.freeCount > 0) && mode == "std" && duration == 5));
          final purchaseProvider = context.read<PurchaseProvider>();

          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: 12.w, vertical: Platform.isAndroid ? 12.h : 16.h),
            color: Colors.white,
            child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIntegralVipView(),
                    Row(
                      children: [
                        if (launchProvider.launchInfo?.isVip == 1)
                          SizedBox(
                            height: 50,
                            child: FilledButton(
                              onPressed: showRecords,
                              style: FilledButton.styleFrom(
                                foregroundColor: const Color(0xFF5B4BF7),
                                backgroundColor: const Color(0xFFEAEEFF),
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "创作记录",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        if (launchProvider.launchInfo?.isVip == 1)
                          SizedBox(width: 9.sp),
                        Expanded(
                            child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: submit,
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF5B4BF7),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "一键成片",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // if (showFreeCount &&
                            //     purchaseProvider.isIntegralOpen)
                            //   Positioned(
                            //       top: -12,
                            //       right: 0,
                            //       child: Container(
                            //         padding: EdgeInsets.symmetric(
                            //             horizontal: 11.w, vertical: 3.h),
                            //         decoration: BoxDecoration(
                            //           color: const Color(0xFFFF2A70),
                            //           borderRadius: BorderRadius.circular(12),
                            //         ),
                            //         child: Text(
                            //           "限免x${_rights!.freeCount}",
                            //           style: TextStyle(
                            //             fontSize: 12.sp,
                            //             color: Colors.white,
                            //           ),
                            //         ),
                            //       )),
                          ],
                        ))
                      ],
                    ),
                    // if (_rights != null && !showFreeCount)
                    //   Builder(builder: (context) {
                    //     // 计算规则：
                    //     // 标准（std）x 5s时长  =》 currentIntegral * 1
                    //     // 标准（std）x 10s时长  =》 currentIntegral * 2
                    //     // 高品质（pro）x 5s时长 =》 currentIntegral * 3.5
                    //     // 高品质（pro）x 10s时长 =》 currentIntegral * 7
                    //     var costIntegral = _rights!.currentIntegral.toDouble();
                    //     costIntegral *= (mode == "std") ? 1.0 : 4;
                    //     costIntegral *= (duration == 5) ? 1 : 2;
                    //     return Padding(
                    //       padding: EdgeInsets.only(top: 8.h),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Image.asset("assets/ai/aiVideo/coin@2x.png",
                    //               scale: 2),
                    //           SizedBox(width: 4.w),
                    //           Text(
                    //             _rights!.userIntegral.toString(),
                    //             style: TextStyle(
                    //               fontSize: 14.sp,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //           SizedBox(width: 10.w),
                    //           Flexible(
                    //             child: Text(
                    //               "本次消耗${costIntegral.floor()}积分",
                    //               style: TextStyle(
                    //                 fontSize: 12.sp,
                    //                 color: const Color(0xFF0B1843)
                    //                     .withOpacity(0.5),
                    //               ),
                    //             ),
                    //           )
                    //         ],
                    //       ),
                    //     );
                    //   })
                  ],
                )),
          );
        });
  }

  // 积分-vip-次数-消耗模块-文生视频
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "ai_text2_video", // 通过这个type请求权益接口获取实际积分
    );
  }

  bool chekVip() {
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
  }
}
