import 'dart:io';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/manager/auth.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../utils/comon/by_common_utils.dart';
import '../../../utils/comon/by_ffmpeg_util.dart';
import '../../../utils/comon/by_nav_router_utils.dart';
import '../../../utils/http/apis.dart';
import '../../../utils/http/http_utils.dart';
import '../../../v2/aiVideo/models/ai_video_square_model.dart';
import '../../../v2/aiVideo/pages/ai_video_management_page.dart';
import '../../../v2/aiVideo/provider/ai_video_management_provider.dart';
import '../../../v2/aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import '../../../v2/aiSquare/ai_vip_guid_page.dart';
import '../../../v2/aiSquare/providers/ai_vip_guid_provider.dart';
import '../../../v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import '../../../widgets/common/bgm_dialog.dart';
import '../../../widgets/toast_util.dart';
import '../../home/providers/words_extract_provider.dart';
import '../../home/words/beans/upload_info_bean.dart';
import '../../home/beans/text_risk_bean.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';

///新的ai视频的业务逻辑
class NewAiVideoController extends GetxController {
  ///单图模式 热门视频传
  List<AiVideoSquareModel> hotVideos1 = [];

  ///双图模式 热门视频
  List<AiVideoSquareModel> hotVideos2 = [];

  ///当前展示的热门视频数据
  List<AiVideoSquareModel> currentHotVideos = [];

  ///当前选择的模式 1-单图模式 2-双图模式
  int type = 1;

  ///单图模式选中的数据
  AiVideoSquareModel? currentOneTypeModel;

  ///双图模式选中的数据
  AiVideoSquareModel? currentTwoTypeModel1;
  AiVideoSquareModel? currentTwoTypeModel2;

  ///单图模式的输入框
  final TextEditingController editingController1 = TextEditingController();

  ///双图模式的输入框
  final TextEditingController editingController2 = TextEditingController();

  ///单图模式的提示词
  List<dynamic> prompts1 = [];

  ///双图模式的提示词
  List<dynamic> prompts2 = [];

  ///单图模式的提示语
  String promptsText1 = "";

  ///双图模式的提示语
  String promptsText2 = "";

  ///单图模式的imageUrl
  String imageUrl = "";

  ///双图模式的imageUrl
  String imageUrl2 = "";
  String imageUrl3 = "";

  ///单图模式的bgmUrl
  String bgmUrl1 = "";

  ///双图模式的bgmUrl
  String bgmUrl2 = "";

  ///单图模式的bgmId
  String? bgmId1;

  ///双图图模式的bgmId
  String? bgmId2;

  ///单图模式的bgmTitle
  String bgmTitle1 = "";

  ///双图模式的bgmTitle
  String bgmTitle2 = "";

  ///单图模式的focusNode
  FocusNode focusNode1 = FocusNode();

  ///双图模式的focusNode
  FocusNode focusNode2 = FocusNode();

  final ScrollController scrollController = ScrollController();

  ///违禁词列表
  RxList<String> bandedWords = <String>[].obs;

  ///选中的违禁词
  RxString selectedBandedWord = "".obs;

  ///当前检测的提示词
  RxString currentPrompt = "".obs;

  ///按钮是否可用
  RxBool isButtonEnabled = false.obs;

  ///积分VIP控制器
  final integralVipController = IntegralVipController.getOrPut();

  @override
  void onInit() {
    super.onInit();
    loadAllHotVideos();
    loadAllPrompts();
    initEditingController();
  }

  ///加载单图 双图热门视频
  void loadAllHotVideos() {
    loadVideos(
      onSuccess: (hotVideos) {
        hotVideos1 = hotVideos;
        updateCurrentHotVideos();
      },
      onFailed: () {},
      type: AiVideoGenerationType.imageToVideo,
    );

    loadVideos(
      onSuccess: (hotVideos) {
        hotVideos2 = hotVideos;
        updateCurrentHotVideos();
      },
      onFailed: () {},
      type: AiVideoGenerationType.embraceVideo,
    );
  }

  ///加载热门视频接口
  void loadVideos({
    AiVideoGenerationType? type,
    int page = 1,
    int pageSize = 10,
    required void Function(List<AiVideoSquareModel> data) onSuccess,
    required void Function() onFailed,
  }) {
    HttpUtils.get(
      APIs.aiVideoCategoryDetail,
      {
        "page": page,
        "pageSize": pageSize,
        if (type != null) "category_id": type.code,
      },
      success: (data) {
        byDebugPrint(data, tag: "loadVideos");
        final success = data["status"] == 200;
        if (!success) {
          onFailed.call();
          return;
        }
        final List items = data["data"]["data"] ?? [];
        final caseBeans = List<AiVideoSquareModel>.from(
          items.map((ele) => AiVideoSquareModel.fromJson(ele)),
        );
        onSuccess.call(caseBeans);
      },
      fail: (code, msg) {
        onFailed.call();
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///更新当前的热门同款视频
  void updateCurrentHotVideos() {
    if (type == 1) {
      currentHotVideos = hotVideos1;
    }
    if (type == 2) {
      currentHotVideos = hotVideos2;
    }
    update(['hotVideos']);
  }

  ///单 双图模式切换
  void changeMode({required int modeValue}) {
    type = modeValue;

    initIntegralVipController();
    updateCurrentHotVideos();
    updateButtonState();
    update();
  }

  void initIntegralVipController() {
    integralVipController.init(requiredPoints: 0, type: "ai_image2_video");
    update();
  }

  ///使用相同的同款案例
  void useSame({required AiVideoSquareModel models}) {
    if (type == 1) {
      currentOneTypeModel = models;
      imageUrl = models.coverUrl;
      editingController1.text = models.prompt ?? "";
    }
    if (type == 2) {
      currentTwoTypeModel1 = models;
      List<String>? multiImage = models.multiImage;
      if (multiImage != null) {
        if (multiImage.isNotEmpty) {
          if (multiImage.isNotEmpty) {
            imageUrl2 = multiImage.first;
          }

          if (multiImage.length > 1) {
            imageUrl3 = multiImage[1];
          }

          editingController2.text = models.prompt ?? "";
        }
      }
      Get.log("json====> ${models.toJson()}");
    }
    updateButtonState();
    update();
  }

  ///加载所有提示词
  void loadAllPrompts() {
    loadPrompts(
      type: AiVideoGenerationType.imageToVideo,
      onSuccess: (value) {
        prompts1 = value;
        Get.log("加载所有提示词===> $value");
        update(['prompts']);
      },
    );
    loadPrompts(
      type: AiVideoGenerationType.embraceVideo,
      onSuccess: (value) {
        prompts2 = value;
        Get.log("加载所有提示词===> $prompts2");
        update(['prompts']);
      },
    );
  }

  /// 预制提示词
  void loadPrompts({
    required AiVideoGenerationType type,
    required void Function(List<dynamic>) onSuccess,
  }) {
    HttpUtils.get(
      "VideoAi/getDefaultPrompt",
      {"type": type.code},
      success: (data) {
        if (data["data"] is List) {
          final prompts = (data["data"] as List);
          byDebugPrint(prompts);
          onSuccess(prompts);
        }
      },
      fail: (code, msg) {
        /// BotToast.showText(text: msg);
      },
    );
  }

  ///快捷选择提示词
  void changePrompts({required String text}) {
    if (type == 1) {
      editingController1.text = text;
      promptsText1 = text;
    } else {
      editingController2.text = text;
      promptsText2 = text;
    }
  }

  ///清空提示词
  void deletePrompts() {
    if (type == 1) {
      editingController1.text = "";
      promptsText1 = "";
    } else {
      editingController2.text = "";
      promptsText2 = "";
    }
  }

  ///监听输入框事件
  initEditingController() {
    editingController1.addListener(() {
      promptsText1 = editingController1.text;
      update(['promptsTextNumber']);
      updateButtonState();
    });
    editingController2.addListener(() {
      promptsText2 = editingController2.text;
      update(["promptsTextNumber"]);
      updateButtonState();
    });

    focusNode1.addListener(() {
      if (focusNode1.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
        });
        Get.log("单图模式获取到焦点");
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
        });
      }
    });

    focusNode2.addListener(() {
      if (focusNode2.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
        });
        Get.log("双图模式获取到焦点");
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
        });
      }
    });
  }

  ///更新选中的图片
  void updateImageUrl({int selectImageType = 1}) {
    ByNavigatorUtil.checkLogin(
      context: Get.context!,
      nextStepEvent: () {
        AuthManager.materialAuth(
          onSuccess: () {
            ByCommonUtils.pickAssetsByType(
              Get.context!,
              maxCount: 1,
              type: RequestType.image,
              onSelectedCallback: (asstes, {List<String>? urls}) async {
                File? file;
                if (urls != null && urls.isNotEmpty) {
                  file = File(urls.first);
                  if (!file.existsSync()) return;
                } else if (asstes.isNotEmpty) {
                  file = await asstes.first.file;
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
                        Get.log("上传的数据信息===> ${infoBean.toJson()}");

                        ///增加鉴黄逻辑
                        contentsRisk(
                          url: infoBean.objectUrl,
                          onSuccess: () {
                            /// 仅使用服务端返回的 object_url，且必须为网络地址，避免提交本地路径
                            final networkUrl = infoBean.objectUrl;
                            if (!ByCommonUtils.isNetworkUrl(networkUrl)) {
                              BotToast.showText(text: "上传返回地址异常，请重试");
                              return;
                            }
                            if (selectImageType == 1) {
                              imageUrl = networkUrl;
                            } else if (selectImageType == 2) {
                              imageUrl2 = networkUrl;
                            } else {
                              imageUrl3 = networkUrl;
                            }
                            updateButtonState();
                            update();
                          },
                        );
                        update();
                        updateButtonState();
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  ///删除图片事件
  void deleteImageUrlEvent({int? index1, int? index2}) {
    if (type == 1) {
      imageUrl = "";
    } else {
      if (index1 == 1) {
        imageUrl2 = "";
      }
      if (index2 == 2) {
        imageUrl3 = "";
      }
    }
    update();
    updateButtonState();
  }

  ///更新按钮状态
  void updateButtonState() {
    if (type == 1) {
      // 单图模式：需要有一张图片
      isButtonEnabled.value = imageUrl.isNotEmpty;
    } else {
      // 双图模式：需要有两张图片
      isButtonEnabled.value = imageUrl2.isNotEmpty && imageUrl3.isNotEmpty;
    }
  }

  ///展示音乐弹窗
  void showBgmDialog() {
    int bgmType = 2;
    String? id;
    if (type == 1) {
      bgmType = 2;
      id = bgmId1;
    } else {
      bgmType = 3;
      id = bgmId2;
    }
    showDialog(
      useSafeArea: false,
      context: Get.context!,
      builder: (ctx) {
        return BgmDialog(id: id, type: bgmType);
      },
    ).then((value) {
      if (value != null) {
        if (type == 1) {
          bgmUrl1 = value[0];
          bgmTitle1 = value[1];
          bgmId1 = value[2];
        } else {
          bgmUrl2 = value[0];
          bgmTitle2 = value[1];
          bgmId2 = value[2];
        }
        update();
      }

      Get.log("选中的音频数据===> $value");
    });
  }

  ///更新违禁词列表
  void updateBandedWords(List<String> words) {
    bandedWords.value = words;
  }

  ///违禁词检测
  void detect(
    BuildContext context,
    String content, {
    void Function()? onSuccess,
  }) {
    currentPrompt.value = content;
    textRisk(
      content: content,
      onSuccess: (data) {
        byDebugPrint(data, tag: "违禁词信息:");
        final status = data["status"] ?? 0;
        if (status == 1002) {
          ByNavRouterUtils.push(
            context,
            ChangeNotifierProvider(
              create: (BuildContext context) => AiVipGuidProvider(),
              child: const AiVipGuidPage(),
            ),
          );
          return;
        }
        if (status == -1 || status == 200) {
          final TextRiskBean riskBean = TextRiskBean.fromJson(data["data"]);
          final riskWords = riskBean.labelName;
          updateBandedWords(riskWords);
          byDebugPrint(bandedWords, tag: "违禁词列表:");
          onSuccess?.call();
        }
      },
    );
  }

  ///文本风险检测
  void textRisk({
    String? type,
    String? needMark,
    required String content,
    void Function(dynamic)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.textRisk,
      {
        "type": type ?? "3",
        "needMark": needMark ?? "2",
        "labelType": "499001",
        "content": content,
      },
      showLoading: true,
      loadingText: "违禁词检测中",
      forceData: true,
      success: (data) {
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  ///创作记录按钮点击事件
  void clickCreationRecordEvent() {
    ByNavRouterUtils.push(
      Get.context!,
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => AiVideoManagementProvider(),
          ),
        ],
        child: const AiVideoManagementPage(),
      ),
    );
  }

  ///一键成片事件
  void clickOneKeyEvent() {
    AiVideoGenerationType generationType = AiVideoGenerationType.imageToVideo;
    String? prompt;
    List<String>? images;
    String? bgmUrl;
    if (type == 1) {
      generationType = AiVideoGenerationType.imageToVideo;
      prompt = promptsText1;
      bgmUrl = bgmUrl1;
      if (imageUrl.isEmpty) {
        BotToast.showText(text: "请上传图片");
        return;
      }
      images = [imageUrl];
    } else {
      generationType = AiVideoGenerationType.embraceVideo;
      bgmUrl = bgmUrl2;
      prompt = promptsText2;
      if (imageUrl2.isEmpty || imageUrl3.isEmpty) {
        BotToast.showText(text: "请上传两张图片");
        return;
      }
      images = [imageUrl2, imageUrl3];
    }

    Get.log("点击一键成片事件  提示词==> $prompt");

    final purchaseProvider = Provider.of<PurchaseProvider>(
      Get.context!,
      listen: false,
    );
    if (purchaseProvider.preLoginCheck(Get.context!) == false) return;

    ///不是会员并且无试用-付费弹窗
    if (!checkVip() && integralVipController.isTest <= 0) {
      final provider = Provider.of<AiSquareProvider>(
        Get.context!,
        listen: false,
      );
      String mark = type == 1 ? 'ai_image_to_video' : 'ai_embrace_video';
      provider.showModelPayDialog(Get.context!, mark);
      return;
    }

    // 检查积分是否足够
    if (!integralVipController.canContinueUse()) {
      integralVipController.showIntegralPayDialog();
      return;
    }

    // 添加违禁词检测
    detect(
      Get.context!,
      prompt ?? "",
      onSuccess: () {
        if (bandedWords.isNotEmpty) {
          BotToast.showText(text: "当前存在违禁词");
          final provider = AiCartoonProvider();
          provider.updateBandedWords(bandedWords.toList());
          provider.desc = currentPrompt.value;
          // provider.selectedDubbingId = sele
          showDialog(
            context: Get.context!,
            useSafeArea: false,
            barrierDismissible: true,
            builder: (ctx) => ChangeNotifierProvider.value(
              value: provider,
              child: const AiCartoonProhibitedWordsDailog<AiCartoonProvider>(),
            ),
          ).then((value) {
            // 对话框关闭后，将修改后的提示词同步回输入框
            Get.log("value===> $value");
            if (value != null) {
              if (value["desc"] != null) {
                if (type == 1) {
                  editingController1.text = value["desc"];
                  promptsText1 = value["desc"];
                } else {
                  editingController2.text = value["desc"];
                  promptsText2 = value["desc"];
                }
              }
              update();
            }
          });
        } else {
          generate(
            generationType: generationType,
            prompt: prompt,
            images: images,
            bgmUrl: bgmUrl,
          );
        }
      },
    );
  }

  ///一键成片接口调用
  void generate({
    required AiVideoGenerationType generationType,
    String? prompt,
    String? negativePrompt,
    List<String>? images,
    String? imageTail,
    bool? optimizePrompt,
    double? cfgScale,
    String? aspectRatio,
    int? duration,
    String? mode,
    void Function()? onSuccess,
    String? bgmUrl,
  }) {
    optimizePrompt ??= true;
    cfgScale ??= 0.5;
    aspectRatio ??= "16:9";
    duration ??= 5;
    mode ??= "std";
    dynamic args;
    String mark = "";
    if (generationType == AiVideoGenerationType.textToVideo) {
      mark = "ai_text_to_video";
      if (prompt == null || prompt.isEmpty) {
        BotToast.showText(text: "请输入创意描述");
        return;
      }
      args = {
        "prompt": prompt,
        "negative_prompt": negativePrompt,
        "cfg_scale": double.parse(cfgScale.toStringAsFixed(2)),
        "optimize_prompt": optimizePrompt ? 1 : 2,
        "aspect_ratio": aspectRatio,
        "duration": duration,
        "mode": mode,
      };
    } else if (generationType == AiVideoGenerationType.imageToVideo) {
      mark = "ai_image_to_video";
      if (images == null || images.isEmpty) {
        BotToast.showText(text: "请上传图片");
        return;
      }
      args = {
        "images": images,
        "image_tail": imageTail,
        "prompt": prompt,
        "negative_prompt": negativePrompt,
        "optimize_prompt": optimizePrompt ? 1 : 2,
        "cfg_scale": double.parse(cfgScale.toStringAsFixed(2)),
        "aspect_ratio": aspectRatio,
        "duration": duration,
        "mode": mode,
      };
    } else if (generationType == AiVideoGenerationType.embraceVideo) {
      mark = "ai_embrace_video";
      if (images == null || images.length < 2) {
        BotToast.showText(text: "请上传图片");
        return;
      }
      args = {
        "images": images,
        "image_tail": imageTail,
        "negative_prompt": negativePrompt,
        "optimize_prompt": optimizePrompt ? 1 : 2,
        "cfg_scale": double.parse(cfgScale.toStringAsFixed(2)),
        "aspect_ratio": aspectRatio,
        "duration": duration,
        "mode": mode,
        "prompt": prompt,
      };
    }

    args["bgm_url"] = bgmUrl;

    HttpUtils.post(
      "VideoAi/createAiVideoTask",
      args,
      success: (data) {
        initIntegralVipController();
        byDebugPrint(data);

        promptsText1 = "";
        promptsText2 = "";
        imageUrl = "";
        imageUrl2 = "";
        imageUrl3 = "";
        bgmUrl1 = "";
        bgmUrl2 = "";
        bgmId1 = "";
        bgmId2 = "";
        bgmTitle1 = "";
        bgmTitle2 = "";
        editingController1.text = "";
        editingController2.text = "";
        update();
        ByNavRouterUtils.push(
          Get.context!,
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => AiVideoManagementProvider(),
              ),
            ],
            child: const AiVideoManagementPage(),
          ),
        );
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
        integralVipController.handleStatusCode(code, msg, mark);
      },
    );
  }

  randomPrompt() {
    List<dynamic> prompts = [];
    var promptIndex = 0;
    String text = "";
    if (type == 1) {
      prompts = prompts1;
    } else {
      prompts = prompts2;
    }
    if (prompts.isNotEmpty) {
      promptIndex = Random().nextInt(prompts.length);
      text = prompts[promptIndex]["prompt"];
    }
    if (text.isNotEmpty) {
      if (type == 1) {
        editingController1.text = text;
      } else {
        editingController2.text = text;
      }
    }
  }

  cancelFocusNode() {
    if (focusNode1.hasFocus) {
      focusNode1.unfocus();
    }
    if (focusNode2.hasFocus) {
      focusNode2.unfocus();
    }
    update();
  }

  /// 鉴黄
  ///[type] 鉴黄类型: 2图片 3音频 4视频
  ///[url]  url地址
  contentsRisk({
    int type = 2,
    required String url,
    void Function()? onSuccess,
  }) {
    Get.log("==创建了鉴黄任务==");
    HttpUtils.post(
      APIs.contentsRisk,
      showLoading: false,
      showMsgWhenFailed: false,
      {"type": type, "url": url},
      success: (data) {
        Get.log("鉴黄任务创建成功===$data");
        onSuccess?.call();
      },
      fail: (code, msg) {
        Get.log("鉴黄任务创建失败结果===$code  msg==$msg");
        if (code == -1) {
          // BotToast.showText(text: msg);
          ToastUtil().showToast(msg);
        } else {
          // BotToast.showText(text: msg);
          ToastUtil().showToast(msg);
        }
      },
    );
  }

  bool checkVip() {
    final isVip = Provider.of<LaunchProvider>(
          Get.context!,
          listen: false,
        ).launchInfo?.isVip ??
        0;
    return isVip == 1;
  }
}
