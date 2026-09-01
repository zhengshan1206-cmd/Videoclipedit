import 'dart:developer';
import 'dart:io' show File;
import 'dart:math' show Random;
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/providers/ai_draw_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/bgm_dialog.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/draw/ai_draw_picker.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_square_model.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/_custom_slider_sharp.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_video_management_page.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';

import '../../../controller/user_controller.dart';
import '../../../core/util/manager/auth.dart';
import '../../../modules/home/providers/by_audio_player.dart';
import '../../../providers/launch_provider.dart';
import '../../aiClip/provider/ai_clip_provider.dart';
import '../../aiSquare/cartoon/beans/ai_cartoon_item_bean.dart';
import '../../aiSquare/cartoon/provider/ai_cartoon_bgm_provider.dart';
import '../../aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import '../../aiSquare/cartoon/widgets/ai_cartoon_bgm_dialog.dart';

class ImageToVideoForm extends StatefulWidget {
  const ImageToVideoForm(
      {super.key,
      this.prompt,
      this.negativePrompt,
      this.cfgScale,
      this.image,
      this.aspectRatio,
      this.duration,
      this.mode,
      this.onChanged,
      this.fromChat = false});

  final String? prompt;
  final String? negativePrompt;
  final String? image;
  final double? cfgScale;
  final String? aspectRatio;
  final int? duration;
  final String? mode;
  final void Function(String)? onChanged;
  final bool fromChat;

  @override
  State<ImageToVideoForm> createState() => _ImageToVideoFormState();
}

class _ImageToVideoFormState extends State<ImageToVideoForm> {
  final _contentScrollController = ScrollController();
  final _promptFocus = FocusNode();
  late final _promptController = TextEditingController();
  late final _negativePromptController = TextEditingController();
  String? _imageUrl;
  final _optimizePrompt = true;
  var _optionExpanded = false;
  var _cfgScale = 0.5;
  var _aspectRatio = "16:9";
  var _duration = 5;
  var _mode = "std";

  String? bgmUrl;
  String bgmTitle = "";
  String? id;

  RightsByType? _rights;

  LaunchProvider get launchProvider => Get.context!.read<LaunchProvider>();

  void updateRights() {
    Provider.of<AiVideoProvider>(context, listen: false).loadRights(
        type: AiVideoGenerationType.imageToVideo,
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
    _imageUrl = widget.image;
    _cfgScale = widget.cfgScale ?? 0.5;
    _aspectRatio = widget.aspectRatio ?? "16:9";
    _duration = widget.duration ?? 5;
    _mode = widget.mode ?? "std";
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

  List<dynamic>? prompts;
  void _randPrompt() {
    if (prompts != null && prompts!.isNotEmpty) {
      setState(() {
        prompts?.shuffle();
        final index = Random().nextInt(prompts!.length);
        _promptController.text = prompts![index]["prompt"];
        widget.onChanged?.call(_promptController.text);
      });
    }
  }

  void _loadPrompts() {
    Provider.of<AiVideoProvider>(context, listen: false).loadPrompts(
        type: AiVideoGenerationType.imageToVideo,
        onSuccess: (prompts) {
          if (mounted) {
            setState(() {
              this.prompts = prompts;
            });
          }
        });
  }

  void uploadImage() async {
    AuthManager.materialAuth(
      onSuccess: () {
        ByCommonUtils.pickAssetsByType(
          context,
          maxCount: 1,
          type: RequestType.image,
          onSelectedCallback: (asstes) async {
            if (asstes.isEmpty) return;
            File? file = await asstes.first.file;
            if (file == null) return;
            final fileSize = ImageSizeGetter.getSize(FileInput(file));
            if (fileSize.width < 300 || fileSize.height < 200) {
              BotToast.showText(text: "图片尺寸过小，请重新选择");
              return;
            }

            ByFfmpegUtil.loadUploadInfo(
                type: MediaType.picture,
                onSuccess: (UploadInfoBean infoBean) {
                  ByFfmpegUtil.uploadFile(
                      infoBean: infoBean,
                      filePath: file.path,
                      onSuccess: (resp) {
                        ///增加鉴黄逻辑
                        ByFfmpegUtil.contentsRisk(
                            url: infoBean.objectUrl,
                            onSuccess: () {
                              if (mounted) {
                                setState(() {
                                  _imageUrl = infoBean.objectUrl;
                                });
                              }
                            });
                      });
                });
          },
        );
      },
    );
    
  }

  void pickDrawRecord() async {
    final drawBean = await showAiDrawPicker(context);
    if (drawBean != null) {
      if (mounted) {
        setState(() {
          _imageUrl = drawBean.picUrl;
        });
      }
    }
  }

  void submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_imageUrl == null) {
      BotToast.showText(text: "请上传图片");
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
    aivideoProvider.desc = _promptController.text.trim();

    final integralVipController = IntegralVipController.getOrPut();

    ///不是会员并且无试用-付费弹窗
    if (!chekVip() && integralVipController.isTest <= 0) {
      final provider = context.read<AiSquareProvider>();
      String mark = 'ai_image_to_video';
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
            prompt: _promptController.text.trim(),
            negativePrompt: _negativePromptController.text.trim(),
            images: [_imageUrl!],
            cfgScale: _cfgScale,
            mode: _mode,
            aspectRatio: _aspectRatio,
            optimizePrompt: _optimizePrompt,
            duration: _duration,
            generationType: AiVideoGenerationType.imageToVideo,
            bgmUrl: bgmUrl,
            onSuccess: () {
              integralVipController.init(
                requiredPoints: 0,
                type: "ai_image2_video",
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
              buildInputGroup(),
              SizedBox(height: 10.h),
              buildOptionsCard(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
        buildBottomBar(),
      ],
    );
  }

  Widget buildInputGroup() {
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
              // Image.asset("assets/ai/aiVideo/earth@2x.png", scale: 2),
              // SizedBox(width: 3.w),
              Text(
                "上传图片",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: ByColorUtil.CommonTextColor,
                ),
              )
            ],
          ),
          SizedBox(height: 7.5.h),
          buildImageCard(),
          SizedBox(height: 11.5.h),
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
          SizedBox(height: 10.h),
          buildPromptInput(),
        ],
      ),
    );
  }

  Widget buildImageCard() {
    if (_imageUrl != null) {
      return Stack(
        children: [
          Container(
            height: 110.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.w),
              child: CachedNetworkImage(
                imageUrl: _imageUrl!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
                child: FilledButton(
              onPressed: () => setState(() => _imageUrl = null),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.36),
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: Colors.white,
                      width: 1.w,
                    ),
                  ),
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                  )),
              child: const Text("清除图片"),
            )),
          )
        ],
      );
    }

    return Container(
      height: 110.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(
          color: const Color(0xFFF6DBFE),
          width: 0.5.w,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/ai/aiVideo/upload@2x.png", scale: 2),
              SizedBox(width: 4.5.w),
              GestureDetector(
                onTap: uploadImage,
                child: Text(
                  "点我上传图片",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFFFF2BB2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "或从",
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(width: 4.5.w),
              GestureDetector(
                onTap: pickDrawRecord,
                child: Text(
                  "绘画记录",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF5B4BF7),
                  ),
                ),
              ),
              SizedBox(width: 4.5.w),
              Text(
                "选择",
                style: TextStyle(
                  fontSize: 14.sp,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildPromptInput() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
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
                  hintText: "请输入提示词，如画面中这位男子正在喝啤酒（非必填）",
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
                            color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                          ),
                        );
                      }),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final pasteText =
                          await Clipboard.getData(Clipboard.kTextPlain);
                      if (pasteText?.text != null) {
                        var newText = _promptController.text + pasteText!.text!;
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
        // SizedBox(height: 4.h),
        // if (prompts != null && prompts!.isNotEmpty) buildPrompsBar(),
      ],
    );
  }

  Widget buildPrompsBar() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final prompt in prompts!)
                  GestureDetector(
                    onTap: () {
                      _promptController.text = prompt["prompt"];
                      widget.onChanged?.call(_promptController.text);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECF1F3),
                        borderRadius: BorderRadius.circular(14.w),
                      ),
                      child: Text(
                        prompt["tag"],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF0B1843),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        TextButton.icon(
          onPressed: _randPrompt,
          icon: Image.asset("assets/ai/aiVideo/dice@2x.png", scale: 2),
          label: const Text("随机"),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            textStyle: TextStyle(
              fontSize: 12.sp,
            ),
          ),
        )
      ],
    );
  }

  Widget buildOptionsCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.5.w, vertical: 14.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.w),
        border: Border.all(
          color: Colors.white,
          width: 0.5.w,
        ),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF6DBFE),
            Colors.white,
          ],
          begin: Alignment.topRight,
          end: Alignment(0.5, 0.01),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() => _optionExpanded = !_optionExpanded);
              if (_optionExpanded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _contentScrollController.animateTo(
                    _contentScrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.linear,
                  );
                });
              }
            },
            child: Row(
              children: [
                Image.asset("assets/ai/aiVideo/settings@2x.png", scale: 2),
                SizedBox(width: 3.w),
                Text(
                  "参数设置",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ByColorUtil.CommonTextColor,
                  ),
                ),
                const Spacer(),
                // _optionExpanded
                //     ? Image.asset("assets/ai/aiVideo/expand_down@2x.png", scale: 2)
                //     : RotatedBox(
                //         quarterTurns: -1,
                //         child: Image.asset("assets/ai/aiVideo/expand_down@2x.png", scale: 2)
                //     ),
              ],
            ),
          ),
          SizedBox(height: 15.h),

          // Row(
          //   children: [
          //     Text(
          //       "创意想象力",
          //       style: TextStyle(
          //         fontSize: 14.sp,
          //         color: ByColorUtil.CommonTextColor,
          //       ),
          //     ),
          //     Expanded(
          //         child: SliderTheme(
          //       data: SliderThemeData(
          //         thumbColor: Colors.white,
          //         activeTrackColor: const Color(0xFF5B4BF7),
          //         inactiveTrackColor: const Color(0xFFFF2BB2),
          //         trackShape: CustomSliderShape(),
          //       ),
          //       child: Slider(
          //         value: _cfgScale,
          //         onChanged: (value) => setState(() => _cfgScale = value),
          //         min: 0,
          //         max: 1,
          //       ),
          //     )),
          //     Text(
          //       "创意相关性",
          //       style: TextStyle(
          //         fontSize: 14.sp,
          //         color: ByColorUtil.CommonTextColor,
          //       ),
          //     ),
          //   ],
          // ),

          InkResponse(
            onTap: () {
              log("===点击了背景音乐===");
              _showBgmDialog(context);
            },
            child: Row(
              children: [
                Text(
                  "背景音乐",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: ByColorUtil.CommonTextColor,
                  ),
                ),
                const Spacer(),
                Text(
                  bgmTitle.isEmpty ? "选择" : bgmTitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: ByColorUtil.CommonTextColor.withOpacity(0.8),
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Image.asset(
                  "assets/ai/ai_back_icon.png",
                  width: 15.w,
                  height: 15.w,
                )
              ],
            ),
          )
          // SizedBox(height: 12.h),
          // Row(
          //   children: [
          //     SizedBox(
          //       width: 80.w,
          //       child: Row(
          //         children: [
          //           Flexible(
          //             child: Text(
          //               "生成模式",
          //               style: TextStyle(
          //                 fontSize: 14.sp,
          //                 color: ByColorUtil.CommonTextColor,
          //               ),
          //             ),
          //           ),
          //           SizedBox(width: 4.w),
          //           GestureDetector(
          //               onTap: () => showAiVideoGenerationModeTips(context),
          //               child: Image.asset("assets/ai/aiVideo/info@2x.png", scale: 2)
          //           ),
          //         ],
          //       ),
          //     ),
          //     GestureDetector(
          //       onTap: () => setState(() => _mode = "std"),
          //       child: Row(
          //         children: [
          //           _mode == "std"
          //             ? Image.asset("assets/ai/aiVideo/radio_checked@2x.png", scale: 2)
          //             : Image.asset("assets/ai/aiVideo/radio@2x.png", scale: 2),
          //           SizedBox(width: 5.w),
          //           Text(
          //             "标准",
          //             style: TextStyle(
          //               fontSize: 14.sp,
          //               color: ByColorUtil.CommonTextColor,
          //             ),
          //           )
          //         ],
          //       ),
          //     ),
          //     SizedBox(width: 15.w),
          //     GestureDetector(
          //       onTap: () => setState(() => _mode = "pro"),
          //       child: Row(
          //         children: [
          //           _mode == "pro"
          //               ? Image.asset("assets/ai/aiVideo/radio_checked@2x.png", scale: 2)
          //               : Image.asset("assets/ai/aiVideo/radio@2x.png", scale: 2),
          //           SizedBox(width: 5.w),
          //           Text(
          //             "高品质",
          //             style: TextStyle(
          //               fontSize: 14.sp,
          //               color: ByColorUtil.CommonTextColor,
          //             ),
          //           )
          //         ],
          //       ),
          //     )
          //   ],
          // ),
          // SizedBox(height: 12.h),
          // Row(
          //   children: [
          //     SizedBox(
          //       width: 80.w,
          //       child: Text(
          //         "提示词优化",
          //         style: TextStyle(
          //           fontSize: 14.sp,
          //           color: ByColorUtil.CommonTextColor,
          //         ),
          //       ),
          //     ),
          //     CupertinoSwitch(
          //         value: _optimizePrompt,
          //         onChanged: (value) => setState(() => _optimizePrompt = value),
          //         activeTrackColor: const Color(0xFF5B4BF7),
          //         inactiveTrackColor: const Color(0xFFB5B9C6),
          //         thumbColor: Colors.white,
          //     )
          //   ],
          // ),
          // if (_optionExpanded) Padding(
          //   padding: EdgeInsets.only(top: 12.h),
          //   child: Row(
          //     children: [
          //       SizedBox(
          //         width: 80.w,
          //         child: Text(
          //           "生成时长",
          //           style: TextStyle(
          //             fontSize: 14.sp,
          //             color: ByColorUtil.CommonTextColor,
          //           ),
          //         ),
          //       ),
          //       GestureDetector(
          //         onTap: () => setState(() => _duration = 5),
          //         child: Row(
          //           children: [
          //             _duration == 5
          //                 ? Image.asset("assets/ai/aiVideo/radio_checked@2x.png", scale: 2)
          //                 : Image.asset("assets/ai/aiVideo/radio@2x.png", scale: 2),
          //             SizedBox(width: 5.w),
          //             Text(
          //               "5s",
          //               style: TextStyle(
          //                 fontSize: 14.sp,
          //                 color: ByColorUtil.CommonTextColor,
          //               ),
          //             )
          //           ],
          //         ),
          //       ),
          //       SizedBox(width: 15.w),
          //       GestureDetector(
          //         onTap: () => setState(() => _duration = 10),
          //         child: Row(
          //           children: [
          //             _duration == 10
          //                 ? Image.asset("assets/ai/aiVideo/radio_checked@2x.png", scale: 2)
          //                 : Image.asset("assets/ai/aiVideo/radio@2x.png", scale: 2),
          //             SizedBox(width: 5.w),
          //             Text(
          //               "10s",
          //               style: TextStyle(
          //                 fontSize: 14.sp,
          //                 color: ByColorUtil.CommonTextColor,
          //               ),
          //             )
          //           ],
          //         )
          //       )
          //     ],
          //   ),
          // ),
          // if (_optionExpanded) Padding(
          //   padding: EdgeInsets.only(top: 12.h),
          //   child: Row(
          //     children: [
          //       SizedBox(
          //         width: 80.w,
          //         child: Text(
          //           "视频比例",
          //           style: TextStyle(
          //             fontSize: 14.sp,
          //             color: ByColorUtil.CommonTextColor,
          //           ),
          //         ),
          //       ),
          //       GestureDetector(
          //         onTap: () => setState(() => _aspectRatio = "16:9"),
          //         child: Builder(
          //           builder: (context) {
          //             final isActive = _aspectRatio == "16:9";
          //             return Column(
          //               children: [
          //                 Image.asset(
          //                     "assets/ai/aiVideo/ratio_16v9@2x.png",
          //                     color: isActive ? const Color(0xFF5B4BF7) : ByColorUtil.CommonTextColor,
          //                     scale: 2,
          //                 ),
          //                 SizedBox(width: 3.5.w),
          //                 Text(
          //                   "16:9",
          //                   style: TextStyle(
          //                     fontSize: 14.sp,
          //                     color: isActive ? const Color(0xFF5B4BF7) : ByColorUtil.CommonTextColor,
          //                   ),
          //                 )
          //               ],
          //             );
          //           }
          //         ),
          //       ),
          //       SizedBox(width: 30.w),
          //       GestureDetector(
          //         onTap: () => setState(() => _aspectRatio = "9:16"),
          //         child: Builder(
          //             builder: (context) {
          //               final isActive = _aspectRatio == "9:16";
          //               return Column(
          //                 children: [
          //                   Image.asset(
          //                     "assets/ai/aiVideo/ratio_9v16@2x.png",
          //                     color: isActive ? const Color(0xFF5B4BF7) : ByColorUtil.CommonTextColor,
          //                     scale: 2,
          //                   ),
          //                   SizedBox(width: 3.5.w),
          //                   Text(
          //                     "9:16",
          //                     style: TextStyle(
          //                       fontSize: 14.sp,
          //                       color: isActive ? const Color(0xFF5B4BF7) : ByColorUtil.CommonTextColor,
          //                     ),
          //                   )
          //                 ],
          //               );
          //             }
          //         ),
          //       ),
          //       SizedBox(width: 30.w),
          //       GestureDetector(
          //         onTap: () => setState(() => _aspectRatio = "1:1"),
          //         child: Builder(
          //             builder: (context) {
          //               final isActive = _aspectRatio == "1:1";
          //               return Column(
          //                 children: [
          //                   Image.asset(
          //                     "assets/ai/aiVideo/ratio_1v1@2x.png",
          //                     color: isActive ? const Color(0xFF5B4BF7) : ByColorUtil.CommonTextColor,
          //                     scale: 2,
          //                   ),
          //                   SizedBox(width: 3.5.w),
          //                   Text(
          //                     "1:1",
          //                     style: TextStyle(
          //                       fontSize: 14.sp,
          //                       color: isActive ? const Color(0xFF5B4BF7) : ByColorUtil.CommonTextColor,
          //                     ),
          //                   )
          //                 ],
          //               );
          //             }
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // if (_optionExpanded) Padding(
          //   padding: EdgeInsets.only(top: 12.h),
          //   child: Row(
          //     children: [
          //       SizedBox(
          //         width: 80.w,
          //         child: Text(
          //           "生成数量",
          //           style: TextStyle(
          //             fontSize: 14.sp,
          //             color: ByColorUtil.CommonTextColor,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  Widget buildBottomBar() {
    final modeNotifier = ValueNotifier('std');
    final durationNotifier = ValueNotifier(5.0);
    return ListenableBuilder(
        listenable: Listenable.merge([
          modeNotifier,
          durationNotifier,
        ]),
        builder: (context, snapshot) {
          final mode = modeNotifier.value;
          final duration = durationNotifier.value;
          // 只有在标准模式std 时长5s的情况下  才展示限免次数。  其他情况统一展示积分消耗。
          final showFreeCount = _rights != null &&
              ((_rights!.currentIntegral == 0) ||
                  ((_rights!.freeCount > 0) && mode == "std" && duration == 5));
          final purchaseProvider = context.read<PurchaseProvider>();

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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

  // 积分-vip-次数-消耗模块-图生视频
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "ai_image2_video", // 通过这个type请求权益接口获取实际积分
    );
  }

  void _showBgmDialog(BuildContext context) {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (ctx) {
        return BgmDialog(
          id: id,
          type: 2,
        );
      },
    ).then((value) {
      if (value != null) {
        bgmUrl = value[0];
        bgmTitle = value[1];
        id = value[2];
        setState(() {});
      }
      log("选中的音频数据===> $value");
    });
  }

  bool chekVip() {
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
  }
}
