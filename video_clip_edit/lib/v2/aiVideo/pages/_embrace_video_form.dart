import 'dart:io' show File;
import 'dart:math' show Random, log;
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
import 'package:video_clip_edit/core/util/manager/auth.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/song/beans/rights_by_type.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_square_model.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/_custom_slider_sharp.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_video_management_page.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_videos_same_case_page.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';

import '../../../modules/home/beans/text_risk_bean.dart';
import '../../../providers/launch_provider.dart';
import '../../../widgets/common/bgm_dialog.dart';
import '../../aiClip/provider/ai_clip_provider.dart';
import '../../aiSquare/ai_vip_guid_page.dart';
import '../../aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import '../../aiSquare/providers/ai_vip_guid_provider.dart';
import '../../../v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';

class EmbraceVideoForm extends StatefulWidget {
  const EmbraceVideoForm({
    super.key,
    this.prompt,
    this.negativePrompt,
    this.images,
    this.cfgScale,
    this.fromChat = false,
    this.prePagePath = "",
  });

  final String? prompt;
  final String? negativePrompt;
  final List<String>? images;
  final double? cfgScale;
  final bool fromChat;
  final String prePagePath;
  @override
  State<EmbraceVideoForm> createState() => _EmbraceVideoFormState();
}

class _EmbraceVideoFormState extends State<EmbraceVideoForm> {
  final _promptFocus = FocusNode();
  late final _promptController = TextEditingController();
  late final _negativePromptController = TextEditingController();
  String? _imageUrl1;
  String? _imageUrl2;
  var _optimizePrompt = true;
  var _optionExpanded = false;
  var _cfgScale = 0.5;
  var _aspectRatio = "16:9";
  var _duration = 5;
  var _mode = "std";

  String? bgmUrl;
  String bgmTitle = "";
  String? id;

  LaunchProvider get launchProvider => Get.context!.read<LaunchProvider>();

  RightsByType? _rights;
  void updateRights() {
    Provider.of<AiVideoProvider>(context, listen: false).loadRights(
        type: AiVideoGenerationType.embraceVideo,
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
    if (widget.images != null && widget.images!.length >= 2) {
      _imageUrl1 = widget.images![0];
      _imageUrl2 = widget.images![1];
    }
    _cfgScale = widget.cfgScale ?? 0.5;
    _loadPrompts();
    _loadHotVideos();
    updateRights();
    final integralVipController = IntegralVipController.getOrPut();
    integralVipController.init(
      requiredPoints: 0,
      type: "ai_image2_video",
    );
  }

  @override
  void dispose() {
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

  List<AiVideoSquareModel>? hotVideos;
  void _loadHotVideos() {
    Provider.of<AiVideoProvider>(context, listen: false).loadVideos(
        type: AiVideoGenerationType.embraceVideo,
        onSuccess: (hotVideos) {
          if (mounted) {
            setState(() {
              this.hotVideos = hotVideos;
            });
          }
        },
        onFailed: () {});
  }

  void uploadImage1() {
    AuthManager.materialAuth(
      onSuccess: () {
        ByCommonUtils.pickAssetsByType(
          context,
          maxCount: 1,
          type: RequestType.image,
          onSelectedCallback: (assets, {List<String>? urls}) async {
            File? file;
            if (urls != null && urls.isNotEmpty) {
              file = File(urls.first);
              if (!file.existsSync()) return;
            } else if (assets.isNotEmpty) {
              file = await assets.first.file;
            }
            if (file == null) return;
            final filePath = file.path;
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
                      filePath: filePath,
                      onSuccess: (resp) {
                        ///增加鉴黄逻辑
                        ByFfmpegUtil.contentsRisk(
                            url: infoBean.objectUrl,
                            onSuccess: () {
                              final networkUrl = infoBean.objectUrl;
                              if (ByCommonUtils.isNetworkUrl(networkUrl) && mounted) {
                                setState(() {
                                  _imageUrl1 = networkUrl;
                                });
                              } else if (mounted && !ByCommonUtils.isNetworkUrl(networkUrl)) {
                                BotToast.showText(text: "上传返回地址异常，请重试");
                              }
                            });
                      });
                });
          },
        );
      },
    );
  }

  void uploadImage2() {
    AuthManager.materialAuth(
      onSuccess: () {
        ByCommonUtils.pickAssetsByType(
          context,
          maxCount: 1,
          type: RequestType.image,
          onSelectedCallback: (assets, {List<String>? urls}) async {
            File? file;
            if (urls != null && urls.isNotEmpty) {
              file = File(urls.first);
              if (!file.existsSync()) return;
            } else if (assets.isNotEmpty) {
              file = await assets.first.file;
            }
            if (file == null) return;
            final filePath = file.path;
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
                      filePath: filePath,
                      onSuccess: (resp) {
                        ///增加鉴黄逻辑
                        ByFfmpegUtil.contentsRisk(
                            url: infoBean.objectUrl,
                            onSuccess: () {
                              final networkUrl = infoBean.objectUrl;
                              if (ByCommonUtils.isNetworkUrl(networkUrl) && mounted) {
                                setState(() {
                                  _imageUrl2 = networkUrl;
                                });
                              } else if (mounted && !ByCommonUtils.isNetworkUrl(networkUrl)) {
                                BotToast.showText(text: "上传返回地址异常，请重试");
                              }
                            });
                      });
                });
          },
        );
      },
    );
  }

  void submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_imageUrl1 == null) {
      BotToast.showText(text: "请上传图片一");
      return;
    } else if (_imageUrl2 == null) {
      BotToast.showText(text: "请上传图片二");
      return;
    }
    final purchaseProvider = context.read<PurchaseProvider>();
    if (purchaseProvider.preLoginCheck(context) == false) return;

    final integralVipController = IntegralVipController.getOrPut();

    ///不是会员并且无试用-付费弹窗
    if (!chekVip() && integralVipController.isTest <= 0) {
      final provider = context.read<AiSquareProvider>();
      String mark = 'ai_embrace_video';
      provider.showModelPayDialog(context, mark);
      return;
    }
    // 检查积分是否足够
    if (!integralVipController.canContinueUse()) {
      integralVipController.showIntegralPayDialog();
      return;
    }

    ///增加文字鉴黄
    if (_promptController.text.trim().isNotEmpty) {
      Provider.of<AiVideoProvider>(context, listen: false).desc =
          _promptController.text.trim();
      Provider.of<AiVideoProvider>(context, listen: false).textRisk(
          content: _promptController.text.trim(),
          onSuccess: (data) {
            Get.log("违禁词检查结果===> $data");
            final status = data["status"] ?? 0;
            if (status == 1002) {
              Get.to(
                ChangeNotifierProvider(
                  create: (BuildContext context) => AiVipGuidProvider(),
                  child: const AiVipGuidPage(),
                ),
              );
              return;
            }
            if (status == -1 || status == 200) {
              ///做违禁词更新操作
              final TextRiskBean riskBean = TextRiskBean.fromJson(data["data"]);
              final riskWords = riskBean.labelName;
              Provider.of<AiVideoProvider>(context, listen: false)
                  .updateBandedWords(riskWords);
              if (Provider.of<AiVideoProvider>(context, listen: false)
                  .bandedWords
                  .isNotEmpty) {
                BotToast.showText(text: "当前存在违禁词");
                showDialog(
                  context: context,
                  useSafeArea: false,
                  barrierDismissible: true,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: Provider.of<AiVideoProvider>(context, listen: false),
                    child:
                        const AiCartoonProhibitedWordsDailog<AiVideoProvider>(),
                  ),
                ).then((value) {
                  if (value != null) {
                    Get.log("返回新的经过检测的文本===> ${value["desc"]}");
                    _promptController.text = value["desc"];
                    if (mounted) {
                      setState(() {});
                    }
                    return;
                  }
                });
              } else {
                final purchaseProvider = context.read<PurchaseProvider>();
                if (purchaseProvider.preLoginCheck(context) == false) return;
                Provider.of<AiVideoProvider>(context, listen: false).generate(
                  prompt: _promptController.text.trim(),
                  negativePrompt: _negativePromptController.text.trim(),
                  images: [_imageUrl1!, _imageUrl2!],
                  cfgScale: _cfgScale,
                  mode: _mode,
                  aspectRatio: _aspectRatio,
                  optimizePrompt: _optimizePrompt,
                  duration: _duration,
                  generationType: AiVideoGenerationType.embraceVideo,
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
                                create: (context) =>
                                    AiVideoManagementProvider()),
                          ],
                          child: const AiVideoManagementPage(),
                        ));
                  },
                );
              }
            }
          });
    } else {
      Provider.of<AiVideoProvider>(context, listen: false).generate(
        prompt: _promptController.text.trim(),
        negativePrompt: _negativePromptController.text.trim(),
        images: [_imageUrl1!, _imageUrl2!],
        cfgScale: _cfgScale,
        mode: _mode,
        aspectRatio: _aspectRatio,
        optimizePrompt: _optimizePrompt,
        duration: _duration,
        generationType: AiVideoGenerationType.embraceVideo,
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
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            children: [
              buildInputGroup(),
              SizedBox(height: 10.h),
              buildOptionsCard(),
              if (hotVideos != null && hotVideos!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: buildHotsCard(),
                ),
              SizedBox(height: 120.h),
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
              Image.asset("assets/ai/aiVideo/earth@2x.png", scale: 2),
              SizedBox(width: 3.w),
              Text(
                "让图片动起来",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: ByColorUtil.CommonTextColor,
                ),
              )
            ],
          ),
          SizedBox(height: 7.5.h),
          Row(
            children: [
              Expanded(child: buildImage1Card()),
              SizedBox(width: 10.h),
              Expanded(child: buildImage2Card()),
            ],
          ),
          SizedBox(height: 10.h),
          buildPromptInput(),
          SizedBox(height: 4.h),
          if (prompts != null && prompts!.isNotEmpty) buildPrompsBar(),
        ],
      ),
    );
  }

  Widget buildImage1Card() {
    if (_imageUrl1 != null) {
      return Stack(
        children: [
          Container(
            height: 90.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.w),
              child: CachedNetworkImage(
                imageUrl: _imageUrl1!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
                child: FilledButton(
              onPressed: () => setState(() => _imageUrl1 = null),
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

    return GestureDetector(
      onTap: () {
        ByNavigatorUtil.checkLogin(
            context: context,
            nextStepEvent: () {
              uploadImage1();
            });
      },
      child: Container(
        height: 90.h,
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/ai/aiVideo/upload_lg@2x.png", scale: 2),
                SizedBox(height: 6.h),
                Text(
                  "点我上传图片(一)",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF5B4BF7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImage2Card() {
    if (_imageUrl2 != null) {
      return Stack(
        children: [
          Container(
            height: 90.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.w),
              child: CachedNetworkImage(
                imageUrl: _imageUrl2!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
                child: FilledButton(
              onPressed: () => setState(() => _imageUrl2 = null),
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

    return GestureDetector(
      onTap: () {
        ByNavigatorUtil.checkLogin(
            context: context,
            nextStepEvent: () {
              uploadImage2();
            });
      },
      child: Container(
        height: 90.h,
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/ai/aiVideo/upload_lg@2x.png", scale: 2),
                SizedBox(height: 6.h),
                Text(
                  "点我上传图片(二)",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF5B4BF7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container buildPromptInput() {
    return Container(
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
            maxLength: 200,
            minLines: 3,
            maxLines: 8,
            expands: false,
            controller: _promptController,
            focusNode: _promptFocus,
            autofocus: false,
            onChanged: (String value) {},
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: ByColorUtil.CommonTextColor,
              ),
              hintText: "请输入您想要动起来的图片～",
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
              // const Spacer(),
              ListenableBuilder(
                  listenable: _promptController,
                  builder: (context, _) {
                    return Text(
                      "${_promptController.text.length}/200",
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
                    if (newText.length > 200) {
                      newText = newText.substring(0, 200);
                    }
                    _promptController.text = newText;
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
                  onTap: () => _promptController.clear(),
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
    );
  }

  Widget buildPrompsBar() {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final prompt in prompts!)
                      GestureDetector(
                        onTap: () => _promptController.text = prompt["prompt"],
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
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
              Positioned(
                top: 0,
                right: -10,
                bottom: 0,
                child: SizedBox(
                  width: 40.w,
                  child: ByWidgetsUtil.gradientBgContainer(
                    borderRadius: 0,
                    gradient: ByColorUtil.lineareGradient(
                      colorStart: const Color(0xFFFFFFFF).withOpacity(0),
                      colorEnd: const Color(0xFFFFFFFF),
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    child: Container(),
                  ),
                ),
              ),
            ],
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
            onTap: () => setState(() => _optionExpanded = !_optionExpanded),
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
                // const Spacer(),
                // _optionExpanded
                //     ? Image.asset("assets/ai/aiVideo/expand_down@2x.png", scale: 2)
                //     : RotatedBox(
                //         quarterTurns: -1,
                //         child: Image.asset("assets/ai/aiVideo/expand_down@2x.png", scale: 2)
                //     ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          InkResponse(
            onTap: () {
              Get.log("===点击了背景音乐===");
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
          //     Switch(
          //         value: _optimizePrompt,
          //         onChanged: (value) => setState(() => _optimizePrompt = value),
          //         activeColor: const Color(0xFF5B4BF7),
          //         inactiveTrackColor: const Color(0xFFB5B9C6),
          //         thumbColor: WidgetStateProperty.all(Colors.white),
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

  Widget buildHotsCard() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _optionExpanded = !_optionExpanded),
            child: Row(
              children: [
                Image.asset("assets/ai/aiVideo/stack@2x.png", scale: 2),
                SizedBox(width: 3.w),
                Text(
                  "热门素材",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ByColorUtil.CommonTextColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "选择下列素材可直接生成",
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF0B1843).withOpacity(0.5),
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final videoInfo in hotVideos!)
                  Container(
                    margin: EdgeInsets.only(right: 10.w),
                    child: GestureDetector(
                      onTap: () {
                        ByNavRouterUtils.pushReplacement(
                            context,
                            AiVideosSameCasePage(
                              caseBean: videoInfo,
                              preview: false,
                              isOldEmbrace: true,
                              prePagePath: widget.prePagePath,
                            ));
                      },
                      child: Stack(
                        children: [
                          Container(
                            height: 110,
                            width: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.w),
                              child: CachedNetworkImage(
                                imageUrl: videoInfo.coverUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                                child: Image.asset(
                              "assets/ai/ai_case_play.png",
                              fit: BoxFit.contain,
                              width: 24.w,
                              height: 24.h,
                            )),
                          )
                        ],
                      ),
                    ),
                  )
              ],
            ),
          )
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
          type: 3,
        );
      },
    ).then((value) {
      if (value != null) {
        bgmUrl = value[0];
        bgmTitle = value[1];
        id = value[2];
        setState(() {});
      }
      Get.log("选中的音频数据===> $value");
    });
  }

  bool chekVip() {
    final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    return isVip == 1;
  }
}
