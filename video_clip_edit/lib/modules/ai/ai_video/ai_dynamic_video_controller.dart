import 'dart:io';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/core/util/manager/auth.dart';
import 'package:video_clip_edit/modules/ai/ai_video/image_edit_controller.dart';
import 'package:video_clip_edit/modules/home/beans/text_risk_bean.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart'
    as wep;
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/ai_vip_guid_page.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/provider/ai_cartoon_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/widgets/ai_cartoon_prohibited_words_dailog.dart';
import 'package:video_clip_edit/v2/aiSquare/providers/ai_vip_guid_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_generation_model.dart';
import 'package:video_clip_edit/v2/aiVideo/models/ai_video_square_model.dart';
import 'package:video_clip_edit/v2/aiVideo/pages/ai_video_management_page.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_video_management_provider.dart';
import 'package:video_clip_edit/v2/aiVideo/widgets/generate_mode_dialog.dart';
import 'package:video_clip_edit/v2/aiVideo/widgets/video_duration_dialog.dart';
import 'package:video_clip_edit/v2/aiVideo/widgets/video_ratio_dialog.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/bgm_dialog.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class Pair<K, V> {
  final K key;
  final V value;

  Pair(this.key, this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pair &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value;

  @override
  int get hashCode => key.hashCode ^ value.hashCode;

  @override
  String toString() => '($key, $value)';
}

typedef OnUploadSuccess = void Function(String url);

class AiDynamicVideoController extends GetxController {
  ///当前页面类型，0=>图生视频；1=>文生视频
  int type = 0;

  ///图生视频 热门同款（普通模式）
  List<AiVideoSquareModel> hotVideosForOne = [];

  ///图生视频 热门同款（首尾帧）
  List<AiVideoSquareModel> hotVideosForTwo = [];

  ///图生视频 热门同款（多图）
  List<AiVideoSquareModel> hotVideosForMultiple = [];

  ///文生视频 热门视频
  List<AiVideoSquareModel> hotVideos2 = [];

  ///当前模式（仅图生视频有效）。0=>普通模式；1=>首尾帧；2=>多图参考
  final RxInt _currentMode = 0.obs;

  RxInt get currentMode => _currentMode;

  ///图生视频创意描述
  final TextEditingController editingController1ForImageToVideo =
      TextEditingController();

  ///图生视频创意描述的focusNode
  FocusNode focusNode1ForImageToVideo = FocusNode();

  ///图生视频不希望呈现内容
  final TextEditingController editingController2ForImageToVideo =
      TextEditingController();

  ///图生视频不希望呈现内容的focusNode
  FocusNode focusNode2ForImageToVideo = FocusNode();

  ///文生视频创意描述
  final TextEditingController editingController1ForTextToVideo =
      TextEditingController();

  ///文生视频创意描述的focusNode
  FocusNode focusNode1ForTextToVideo = FocusNode();

  ///文生视频不希望呈现内容
  final TextEditingController editingController2ForTextToVideo =
      TextEditingController();

  ///文生视频不希望呈现内容的focusNode
  FocusNode focusNode2ForTextToVideo = FocusNode();

  ///图生视频的提示语
  String promptsTextForImageToVideo = "";

  ///文生视频的提示语
  String promptsTextForTextToVideo = "";

  ///普通模式下已选择图片（仅一张）
  final List<Pair<String, String>> _selectedImg0 = List.filled(1, Pair("", ""));

  List<Pair<String, String>> get selectedImg0 => _selectedImg0;

  ///首尾帧模式下已选择图片（最多两张）
  final List<Pair<String, String>> _selectedImg1 = List.filled(2, Pair("", ""));

  List<Pair<String, String>> get selectedImg1 => _selectedImg1;

  ///多图参考模式下已选择图片（最多四张）
  final List<Pair<String, String>> _selectedImg2 = List.filled(4, Pair("", ""));

  List<Pair<String, String>> get selectedImg2 => _selectedImg2;

  ///积分VIP控制器
  final integralVipController = IntegralVipController.getOrPut();

  ///多图模式下的继续上传按钮是否展示
  final RxBool showUpload = false.obs;

  RxBool showDeepSeekNotice = true.obs;

  ///deepSink帮忙写
  void randomPrompt() {
    List<dynamic> prompts = [];
    var promptIndex = 0;
    String text = "";
    prompts = prompts2;
    if (prompts.isNotEmpty) {
      promptIndex = Random().nextInt(prompts.length);
      text = prompts[promptIndex]["prompt"];
    }
    if (text.isNotEmpty) {
      editingController1ForTextToVideo.text = text;
    }
  }

  RxBool showTextToVideoPrompts = true.obs;

  ///监听输入框事件
  initEditingController() {
    editingController1ForImageToVideo.addListener(() {
      promptsTextForImageToVideo = editingController1ForImageToVideo.text;
      update(['promptsTextNumber']);
      checkParams();
    });
    editingController1ForTextToVideo.addListener(() {
      promptsTextForTextToVideo = editingController1ForTextToVideo.text;
      update(["promptsTextNumber"]);
      if (promptsTextForTextToVideo.isNotEmpty == true) {
        showDeepSeekNotice.value = false;
      } else {
        showDeepSeekNotice.value = true;
      }
      if (promptsTextForTextToVideo.isNotEmpty == true) {
        showTextToVideoPrompts.value = false;
      } else {
        showTextToVideoPrompts.value = true;
      }
      checkParams();
    });

    // focusNode1.addListener(() {
    //   if (focusNode1.hasFocus) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       scrollController.animateTo(
    //         scrollController.position.maxScrollExtent,
    //         duration: const Duration(milliseconds: 100),
    //         curve: Curves.linear,
    //       );
    //     });
    //     Get.log("单图模式获取到焦点");
    //   } else {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       scrollController.animateTo(
    //         scrollController.position.minScrollExtent,
    //         duration: const Duration(milliseconds: 100),
    //         curve: Curves.linear,
    //       );
    //     });
    //   }
    // });
    //
    // focusNode2.addListener(() {
    //   if (focusNode2.hasFocus) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       scrollController.animateTo(
    //         scrollController.position.maxScrollExtent,
    //         duration: const Duration(milliseconds: 100),
    //         curve: Curves.linear,
    //       );
    //     });
    //     Get.log("双图模式获取到焦点");
    //   } else {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       scrollController.animateTo(
    //         scrollController.position.minScrollExtent,
    //         duration: const Duration(milliseconds: 100),
    //         curve: Curves.linear,
    //       );
    //     });
    //   }
    // });
  }

  void cancelFocusNode() {
    if (type == 0) {
      if (focusNode1ForImageToVideo.hasFocus) {
        focusNode1ForImageToVideo.unfocus();
      }
      if (focusNode2ForImageToVideo.hasFocus) {
        focusNode2ForImageToVideo.unfocus();
      }
    }
    if (type == 1) {
      if (focusNode1ForTextToVideo.hasFocus) {
        focusNode1ForTextToVideo.unfocus();
      }
      if (focusNode2ForTextToVideo.hasFocus) {
        focusNode2ForTextToVideo.unfocus();
      }
    }
    update();
  }

  ///清空提示词
  void deletePrompts() {
    if (type == 0) {
      editingController1ForImageToVideo.text = "";
      promptsTextForImageToVideo = "";
    } else {
      editingController1ForTextToVideo.text = "";
      promptsTextForTextToVideo = "";
    }
    checkParams();
  }

  ///添加提示词
  void addPrompts(String text) {
    if (type == 0) {
      editingController1ForImageToVideo.text = text;
    } else {
      editingController1ForTextToVideo.text = text;
    }
  }

  ///获取焦点
  void requestFocus() {
    if (type == 1) {
      focusNode1ForTextToVideo.requestFocus();
    } else {
      focusNode1ForImageToVideo.requestFocus();
    }
  }

  ///获取提示词
  String getPrompts() {
    String text = "";
    if (type == 0) {
      text = promptsTextForImageToVideo;
    } else {
      text = promptsTextForTextToVideo;
    }
    return text;
  }

  ///权益类型
  String equityType = "ai_image2_video";

  void switchMode(int targetMode) {
    _currentMode.value = targetMode;
    update(["hotVideosForImage"]);
    if (type == 1) {
      ///文生视频
      equityType = "ai_text2_video";
    } else if (_currentMode.value == 0) {
      ///图生视频
      equityType = "ai_image2_video";
      loadPrompts(loadType: 1);
    } else if (_currentMode.value == 1) {
      ///首尾帧
      equityType = "ai_video_f2e";
      loadPrompts(loadType: 3);
    } else if (_currentMode.value == 2) {
      ///多图
      equityType = "ai_video_multi";
      loadPrompts(loadType: 4);
    }
    editingController1ForImageToVideo.text = "";
    initIntegralVipController();
    checkParams();
  }

  final PageController _pageController = PageController();

  PageController get pageController => _pageController;

  void switchType(int targetType) {
    type = targetType;
    if (type == 1) {
      ///文生视频
      equityType = "ai_text2_video";
    } else if (_currentMode.value == 0) {
      ///图生视频
      equityType = "ai_image2_video";
    } else if (_currentMode.value == 1) {
      ///首尾帧
      equityType = "ai_video_f2e";
    } else if (_currentMode.value == 2) {
      ///多图
      equityType = "ai_video_multi";
    }
    initIntegralVipController();
    checkParams();
    update(["updateType", "updateTab"]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.animateToPage(
        targetType,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    });
  }

  @override
  void onInit() {
    super.onInit();
    integralVipController.isShowIntegral = true;
    loadAllHotVideos();
    loadPrompts();
    initEditingController();
    var arg = Get.arguments;
    if (arg is AiVideoGenerationTaskModel) {
      initData(arg);
    } else if (arg is AiVideoSquareModel) {
      if (arg.type == AiVideoGenerationType.textToVideo) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ///切换到文生视频
          switchType(1);
          useSame(models: arg);
        });
      } else if (arg.type == AiVideoGenerationType.imageToVideo) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ///切换到图生视频
          switchType(0);
          useSame(models: arg);
        });
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initIntegralVipController();
    });
  }

  void initData(AiVideoGenerationTaskModel arg) {
    if (arg.type == AiVideoGenerationType.textToVideo) {
      ///切换到文生视频
      switchType(1);
      generateMode1.value =
          (VideoQuality.fromKey(arg.mode) ?? VideoQuality.standard).value;
      videoRatio.value = arg.aspectRatio.replaceAll(":", "/");
      setVideoDuration(arg.duration);
    } else {
      generateMode0.value =
          (VideoQuality.fromKey(arg.mode) ?? VideoQuality.standard).value;

      ///图生视频
      if (arg.type == AiVideoGenerationType.imageToVideo) {
        setVideoDuration(arg.duration);
        currentRatio0 = arg.aspectRatio.replaceAll(":", "/");
        switchMode(0);
        _selectedImg0[0] = Pair(arg.image ?? "", arg.image ?? "");
        update(["updateImage0"]);
      } else if (arg.type == AiVideoGenerationType.firstAndEndFrame) {
        ///切换到首尾帧
        switchMode(1);
        currentRatio1 = arg.aspectRatio.replaceAll(":", "/");
        selectedImg1[0] = Pair(arg.image ?? "", arg.image ?? "");
        if (arg.imageTail?.isNotEmpty == true) {
          selectedImg1[1] = Pair(arg.imageTail!, arg.imageTail!);
        }
        update(["updateImage1"]);
      } else if (arg.type == AiVideoGenerationType.multipleImages) {
        ///切换到多图
        switchMode(2);
        currentRatio2 = arg.aspectRatio.replaceAll(":", "/");
        if (arg.multiImages?.isNotEmpty == true) {
          for (int i = 0; i < arg.multiImages!.length; i++) {
            selectedImg2[i] = Pair(arg.multiImages![i], arg.multiImages![i]);
          }
          update(["updateImage2"]);
          if (validIndex().length == 2 || validIndex().length == 3) {
            showUpload.value = true;
          } else {
            showUpload.value = false;
          }
        }
      }
    }
    loadBgmList(arg.bgmUrl ?? "");
    addPrompts(arg.prompt ?? "");
    checkParams();
  }

  ///加载热门视频
  void loadAllHotVideos() {
    loadVideos(
      onSuccess: (hotVideos) {
        hotVideosForOne = hotVideos;
        _safeUpdateHotVideosImage();
      },
      onFailed: () {},
      code: AiVideoGenerationType.imageToVideo.code,
    );

    ///首尾帧
    // loadVideos(
    //   onSuccess: (hotVideos) {
    //     hotVideosForTwo = hotVideos;
    //     if (currentMode.value == 1) {
    //       update(['hotVideosForImage']);
    //     }
    //   },
    //   onFailed: () {},
    //   code: AiVideoGenerationType.firstAndEndFrame.code,
    // );

    ///多图
    // loadVideos(
    //   onSuccess: (hotVideos) {
    //     hotVideosForMultiple = hotVideos;
    //     if (currentMode.value == 2) {
    //       update(['hotVideosForImage']);
    //     }
    //   },
    //   onFailed: () {},
    //   code: AiVideoGenerationType.multipleImages.code,
    // );

    ///文生视频
    loadVideos(
      onSuccess: (hotVideos) {
        hotVideos2 = hotVideos;
        _safeUpdateHotVideosText();
      },
      onFailed: () {},
      code: AiVideoGenerationType.textToVideo.code,
    );
  }

  /// 在下一帧刷新图生视频热门同款，避免在 build 期间调用 update 导致不显示
  void _safeUpdateHotVideosImage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update(['hotVideosForImage']);
    });
  }

  /// 在下一帧刷新文生视频热门同款，避免在 build 期间调用 update 导致不显示
  void _safeUpdateHotVideosText() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update(['hotVideosForText']);
    });
  }

  ///背景音乐数据（图生视频）
  List<AiCartoonBgmBean> bgmListForImage = [];

  ///背景音乐数据（文生图片）
  List<AiCartoonBgmBean> bgmListForText = [];

  ///加载背景音乐
  loadBgmList(String bgmUrl) {
    int bgmType = 2;
    if (type == 0) {
      bgmType = 2;
    } else {
      bgmType = 1;
    }

    if (type == 0) {
      if (bgmUrl.isNotEmpty != true) {
        bgmTitle1 = "无";
        return;
      }
    } else if (type == 1) {
      if (bgmUrl.isNotEmpty != true) {
        bgmTitle2 = "无";
        return;
      }
    }
    HttpUtils.get(
      APIs.bgmListNew,
      {
        "page": 1,
        "pageSize": 200,
        "type": bgmType,
        // "cate": 1,
        // "useScenes": 4,
      },
      showLoading: false,
      success: (data) {
        byDebugPrint(data["data"]["items"], tag: "bgm列表:");
        final List bgmData = data["data"]["items"] ?? [];
        if (type == 1) {
          bgmListForText = bgmData.map((e) {
            final bean = AiCartoonBgmBean.fromJson(e);
            if (bean.url.isNotEmpty == true && bgmUrl == bean.url) {
              bgmUrl2 = bean.url;
              bgmTitle2 = bean.title;
              bgmId2 = bean.id.toString();
              if (bgmTitle2.isNotEmpty != true) {
                bgmTitle2 = "无";
              }
              update(["updateBgm"]);
              checkParams();
            }
            return bean;
          }).toList();
        } else if (type == 0) {
          bgmListForImage = bgmData.map((e) {
            final bean = AiCartoonBgmBean.fromJson(e);
            if (bean.url.isNotEmpty == true && bgmUrl == bean.url) {
              bgmUrl1 = bean.url;
              bgmTitle1 = bean.title;
              bgmId1 = bean.id.toString();
              if (bgmTitle1.isNotEmpty != true) {
                bgmTitle1 = "无";
              }
              update(["updateBgm"]);
              checkParams();
            }
            return bean;
          }).toList();
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
      },
    );
  }

  ///加载热门视频接口
  void loadVideos({
    int? code,
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
        if (code != null) "category_id": code,
      },
      success: (data) {
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
        BotToast.showText(text: msg);
      },
    );
  }

  ///使用相同的同款案例
  void useSame({required AiVideoSquareModel models}) {
    if (type == 1) {
      editingController1ForTextToVideo.text = models.prompt ?? "";
      generateMode1.value =
          (VideoQuality.fromKey(models.mode) ?? VideoQuality.standard).value;
      videoRatio.value = models.aspectRatio.replaceAll(":", "/");
    } else if (type == 0) {
      editingController1ForImageToVideo.text = models.prompt ?? "";
      generateMode0.value =
          (VideoQuality.fromKey(models.mode) ?? VideoQuality.standard).value;
      if (_currentMode.value == 0) {
        ///普通视频
        currentRatio0 = models.aspectRatio.replaceAll(":", "/");
        // _selectedImg0[0] = Pair(models.coverUrl, models.coverUrl);
        // update(["updateImage0"]);
        if (models.multiImage?.isNotEmpty == true) {
          // for (int i = 0; i < models.multiImage!.length; i++) {
          //
          // }
          if (models.multiImage?.first.isNotEmpty == true) {
            _selectedImg0[0] = Pair(
              models.multiImage![0],
              models.multiImage![0],
            );
          }
          update(["updateImage0"]);
        }
      } else if (_currentMode.value == 1) {
        ///首尾帧
        currentRatio1 = models.aspectRatio.replaceAll(":", "/");
        // selectedImg1[0] = Pair(models.coverUrl, models.coverUrl);
        // if (models.imageTail?.isNotEmpty == true) {
        //   selectedImg1[1] = Pair(models.imageTail!, models.imageTail!);
        // }
        // update(["updateImage1"]);
        if (models.multiImage?.isNotEmpty == true) {
          for (int i = 0; i < models.multiImage!.length; i++) {
            _selectedImg1[i] = Pair(
              models.multiImage![i],
              models.multiImage![i],
            );
          }
          update(["updateImage1"]);
        }
      } else if (_currentMode.value == 2) {
        ///多图
        currentRatio2 = models.aspectRatio.replaceAll(":", "/");
        if (models.multiImage?.isNotEmpty == true) {
          for (int i = 0; i < models.multiImage!.length; i++) {
            selectedImg2[i] = Pair(
              models.multiImage![i],
              models.multiImage![i],
            );
          }
          update(["updateImage2"]);
          if (validIndex().length == 2 || validIndex().length == 3) {
            showUpload.value = true;
          } else {
            showUpload.value = false;
          }
        }
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addPrompts(models.prompt ?? "");
    });
    loadBgmList(models.bgmUrl ?? "");
    checkParams();
  }

  final ScrollController _imageScrollController = ScrollController();

  ScrollController get imageScrollController => _imageScrollController;

  void deleteImage({
    ///当前图片的位置
    int index = 0,
  }) {
    if (currentMode.value == 0) {
      selectedImg0[index] = Pair("", "");
      update(["updateImage0"]);
      currentRatio0 = null;
    } else if (currentMode.value == 1) {
      selectedImg1[index] = Pair("", "");
      update(["updateImage1"]);
      if (_selectedImg1.every((ele) => ele.key.isEmpty == true) == true) {
        currentRatio1 = null;
      }
    } else if (currentMode.value == 2) {
      selectedImg2[index] = Pair("", "");
      List<Pair<String, String>> list = [];
      for (Pair<String, String> pair in selectedImg2) {
        if (pair.key.isNotEmpty == true) {
          list.add(pair);
        }
      }
      for (int i = 0; i < list.length; i++) {
        selectedImg2[i] = list[i];
      }
      for (int i = list.length; i < selectedImg2.length; i++) {
        selectedImg2[i] = Pair("", "");
      }
      update(["updateImage2"]);
      if (_selectedImg2.every((ele) => ele.key.isEmpty == true) == true) {
        currentRatio2 = null;
      }
      if (validIndex().length == 2 || validIndex().length == 3) {
        showUpload.value = true;
      } else {
        showUpload.value = false;
      }
    }
    checkParams();
  }

  String? currentRatio0;
  String? currentRatio1;
  String? currentRatio2;

  String? get currentRatio => currentMode.value == 0
      ? currentRatio0
      : currentMode.value == 1
      ? currentRatio1
      : currentMode.value == 2
      ? currentRatio2
      : null;

  ///上传/更新选中的图片
  void updateImageUrl({
    ///当前图片的位置
    int index = 0,
  }) {
    AuthManager.materialAuth(
      onSuccess: () {
        ByCommonUtils.pickAssetsForVideoByType(
          Get.context!,
          maxCount: 1,
          type: RequestType.image,
          onSelectedCallback: (asstes, {List<String>? urls}) async {
            if (asstes.isEmpty) {
              ///截止2025/05/13号，仅展示单图模式
              if (urls?.isNotEmpty == true) {
                if (index < _selectedImg0.length) {
                  _selectedImg0[index] = Pair(urls![0], urls[0]);
                  update(["updateImage0"]);
                  checkParams();
                }
              }
              return;
            }
            File? file = await asstes.first.file;
            if (file == null) return;
            final fileSize = ImageSizeGetter.getSize(FileInput(file));
            if (fileSize.width < 300 || fileSize.height < 200) {
              BotToast.showText(text: "图片尺寸过小，请重新选择");
              return;
            }

            ///截止2025/05/13号，仅展示单图模式
            if (index < _selectedImg0.length) {
              uploadImgToRemote(
                file.path,
                onSuccess: (url) {
                  _selectedImg0[index] = Pair(file.path, url);
                  // currentRatio0 = value[1];
                  update(["updateImage0"]);
                  checkParams();
                },
              );
            }
            return;
          },
        );
      },
    );
  }

  void uploadImgToRemote(String path, {OnUploadSuccess? onSuccess}) {
    ByFfmpegUtil.loadUploadInfo(
      type: wep.MediaType.picture,
      onSuccess: (UploadInfoBean infoBean) {
        ByFfmpegUtil.uploadFile(
          infoBean: infoBean,
          filePath: path,
          onSuccess: (resp) {
            Get.log("上传的数据信息===> ${infoBean.toJson()}");

            ///增加鉴黄逻辑
            contentsRisk(
              url: infoBean.objectUrl,
              onSuccess: () {
                onSuccess?.call(infoBean.objectUrl);
              },
            );
          },
        );
      },
    );
  }

  void swapImage({int? start}) {
    if (start == null) return;
    if (currentMode.value == 1) {
      ///首尾帧模式
      if (selectedImg1.every((ele) => ele.key.isNotEmpty == true) == true) {
        Pair<String, String> ele = selectedImg1[start];
        selectedImg1[start] = selectedImg1[start + 1];
        selectedImg1[start + 1] = ele;
        update(["updateImage1"]);
      }
    } else if (currentMode.value == 2) {
      ///多图模式
      Pair<String, String> ele = selectedImg2[start];
      selectedImg2[start] = selectedImg2[start + 1];
      selectedImg2[start + 1] = ele;
      update(["updateImage2"]);
    }
  }

  ///在多图模式下，获取有效的索引（有效即图片路径不为空）
  List<int> validIndex() {
    List<Pair<String, String>> pairs = _selectedImg2;
    List<int> list = [];
    for (int i = 0; i < pairs.length; i++) {
      if (pairs[i].key.isNotEmpty == true) {
        list.add(i);
      }
    }
    return list;
  }

  ///图生视频模式的bgmUrl
  String bgmUrl1 = "";

  ///文生视频的bgmUrl
  String bgmUrl2 = "";

  ///图生视频的bgmId
  String? bgmId1;

  ///文生视频的bgmId
  String? bgmId2;

  ///图生视频的bgmTitle
  String bgmTitle1 = "";

  ///文生视频的bgmTitle
  String bgmTitle2 = "";

  ///展示音乐弹窗
  void showBgmDialog() {
    int bgmType = 2;
    String? id;
    if (type == 0) {
      bgmType = 2;
      id = bgmId1;
    } else {
      bgmType = 1;
      id = bgmId2;
    }
    showDialog(
      useSafeArea: true,
      context: Get.context!,
      builder: (ctx) {
        return BgmDialog(id: id, type: bgmType);
      },
    ).then((value) {
      if (value != null) {
        if (type == 0) {
          bgmUrl1 = value[0];
          bgmTitle1 = value[1];
          bgmId1 = value[2];
          if (bgmTitle1.isNotEmpty != true) {
            bgmTitle1 = "无";
          }
        } else {
          bgmUrl2 = value[0];
          bgmTitle2 = value[1];
          bgmId2 = value[2];
          if (bgmTitle2.isNotEmpty != true) {
            bgmTitle2 = "无";
          }
        }
        update(["updateBgm"]);
        checkParams();
      }
    });
  }

  ///图生视频生成模式
  RxInt generateMode0 = 0.obs;

  ///文生视频生成模式
  RxInt generateMode1 = 0.obs;

  int get generateMode => type == 0 ? generateMode0.value : generateMode1.value;

  ///展示生成模式弹窗
  void showGenerateModeDialog() {
    showDialog(
      context: Get.context!,
      builder: (ctx) {
        return GenerateModeDialog(
          videoQuality: type == 0 ? generateMode0.value : generateMode1.value,
        );
      },
    ).then((value) {
      if (value != null && value is List && value.isNotEmpty) {
        if (type == 0) {
          generateMode0.value = value[0];
        } else {
          generateMode1.value = value[0];
        }
        initIntegralVipController();
      }
    });
  }

  ///图生视频时长
  RxInt videoDurationForImage = 5.obs;

  ///文生视频时长
  RxInt videoDurationForText = 5.obs;

  int getVideoDuration() {
    if (type == 1) {
      return videoDurationForText.value;
    } else {
      return videoDurationForImage.value;
    }
  }

  RxInt get videoDuration {
    if (type == 1) {
      return videoDurationForText;
    } else {
      return videoDurationForImage;
    }
  }

  void setVideoDuration(int value) {
    if (type == 1) {
      videoDurationForText.value = value;
    } else {
      videoDurationForImage.value = value;
    }
  }

  ///图生视频时长弹窗
  void showVideoDurationDialog() {
    showDialog(
      context: Get.context!,
      builder: (ctx) {
        return VideoDurationDialog(videoDuration: getVideoDuration());
      },
    ).then((value) {
      if (value != null && value is List && value.isNotEmpty) {
        setVideoDuration(value[0]);
        initIntegralVipController();
      }
    });
  }

  ///视频比例（仅文生视频）
  RxString videoRatio = ImageAspectRatio.ratio4_3.label.obs;

  ///展示视频比例弹窗
  void showVideoRatioDialog() {
    showDialog(
      context: Get.context!,
      builder: (ctx) {
        return VideoRatioDialog(videoRatio: videoRatio.value);
      },
    ).then((value) {
      if (value != null && value is List && value.isNotEmpty) {
        videoRatio.value = value[0];
      }
    });
  }

  /// 鉴黄
  ///[type] 鉴黄类型: 2图片 3音频 4视频
  ///[url]  url地址
  void contentsRisk({
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
          BotToast.showText(text: msg);
        } else {
          BotToast.showText(text: msg);
        }
      },
    );
  }

  RxBool allowRequest = false.obs;

  void checkParams() {
    ///获取提示词
    String text = getPrompts();

    ///校验提示词
    if (type == 1 && text.isNotEmpty != true) {
      allowRequest.value = false;
      return;
    }

    if (type == 0) {
      ///校验视频比例（截止2025/05/13，暂不校验视频比例）
      // String? aspectRatio = currentRatio;
      // if (aspectRatio?.isNotEmpty != true) {
      //   allowRequest.value = false;
      //   return;
      // }

      bool hasImage = checkImage();
      if (hasImage == false) {
        allowRequest.value = false;
        return;
      }
    }
    allowRequest.value = true;
  }

  bool checkImage() {
    if (currentMode.value == 1 &&
        selectedImg1.every((ele) => ele.value.isNotEmpty == true) != true) {
      ///判断首尾帧是否选择了图片
      return false;
    } else if (currentMode.value == 2) {
      List<String> urls = [];
      for (Pair<String, String> pair in selectedImg2) {
        if (pair.value.isNotEmpty == true) {
          urls.add(pair.value);
        }
      }

      ///多图模式下图片不能少于2张
      if (urls.length < 2) {
        return false;
      }
    } else if (currentMode.value == 0 &&
        selectedImg0.every((ele) => ele.value.isNotEmpty == true) != true) {
      ///判断单图是否选择了图片
      return false;
    }
    return true;
  }

  ///当前检测的提示词
  RxString currentPrompt = "".obs;

  ///违禁词列表
  RxList<String> bandedWords = <String>[].obs;

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
        BotToast.showText(text: msg);
      },
    );
  }

  /// 视频生成
  void generateVideo() {
    String text = getPrompts();

    if (allowRequest.value != true) {
      if (type == 0 && checkImage() != true) {
        BotToast.showText(text: "请先上传图片哦", align: Alignment.center);
      } else if (type == 1 && text.isNotEmpty != true) {
        BotToast.showText(text: "请先输入您想要生成的视频内容哦", align: Alignment.center);
        requestFocus();
      }
      return;
    }
    String? aspectRatio = currentRatio;

    Map<String, dynamic> data = {
      "prompt": text,
      "mode": generateMode == 1 ? "pro" : "std",
      "type": "${currentMode.value == 1 ? 5 : 6}",
    };
    if (type == 0 && bgmUrl1.isNotEmpty == true) {
      data['bgm_url'] = bgmUrl1;
    } else if (type == 1 && bgmUrl2.isNotEmpty == true) {
      data['bgm_url'] = bgmUrl2;
    }
    if (currentMode.value == 1) {
      data['image'] = selectedImg1[0].value;
      data['image_tail'] = selectedImg1[1].value;
    } else if (currentMode.value == 2) {
      List<String> urls = [];
      for (Pair<String, String> pair in selectedImg2) {
        if (pair.value.isNotEmpty == true) {
          urls.add(pair.value);
        }
      }

      ///多图
      data['images'] = urls;
    }
    debugPrint("上报数据===>${data}");

    // 添加违禁词检测
    detect(
      Get.context!,
      text,
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
                  editingController1ForTextToVideo.text = value["desc"];
                  promptsTextForTextToVideo = value["desc"];
                } else {
                  editingController1ForImageToVideo.text = value["desc"];
                  promptsTextForImageToVideo = value["desc"];
                }
              }
              // update();
            }
          });
        } else {
          ///生成视频
          if (currentMode.value == 1 || currentMode.value == 2) {
            data["aspect_ratio"] = aspectRatio!.replaceAll("/", ":");

            ///首尾帧与多图生成视频请求接口
            HttpUtils.post(
              APIs.createFunnyVideoTask,
              showMsgWhenFailed: true,
              data,
              success: (data) {
                debugPrint("生成成功===>${data}");
                initIntegralVipController();
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
                if (code == -1) {
                  BotToast.showText(text: msg);
                } else {
                  BotToast.showText(text: msg);
                }
              },
            );
          } else {
            ///文生视频与单图生成视频
            data['optimize_prompt'] = 1;
            data['cfg_scale'] = double.parse(0.5.toStringAsFixed(2));
            data['duration'] = getVideoDuration();
            if (type == 0) {
              data['images'] = [_selectedImg0[0].value];
              // data["aspect_ratio"] = aspectRatio!.replaceAll("/", ":");
            } else if (type == 1) {
              data['aspect_ratio'] = videoRatio.replaceAll("/", ":");
            }
            HttpUtils.post(
              "VideoAi/createAiVideoTask",
              data,
              success: (data) {
                byDebugPrint(data);
                initIntegralVipController();
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
                // onSuccess?.call();
              },
              fail: (code, msg) {
                BotToast.showText(text: msg);
              },
            );
          }
        }
      },
    );
  }

  void initIntegralVipController() {
    // print(
    //     "0000000000000-${equityType}-${generateMode == 1 ? "pro" : "std"}-${getVideoDuration()}");
    // generateMode生成模式  videoDuration视频时长
    WidgetsBinding.instance.addPostFrameCallback((_) {
      integralVipController.init(
        requiredPoints: 0,
        type: equityType,
        generateMode: generateMode == 1 ? "pro" : "std",
        // videoDuration: type == 1 ? 5 : videoDuration.value,
        videoDuration: getVideoDuration(),
      );
      update(["updateIntegralVipInfo"]);
    });
  }

  /// 从网络获取提示词
  void _loadPromptsForRemote({
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
        } else {
          onSuccess([]);
        }
      },
      fail: (code, msg) {
        /// BotToast.showText(text: msg);
      },
    );
  }

  ///图生视频的提示词
  List<dynamic> prompts1 = [];

  ///图生视频（首尾帧）的提示词
  List<dynamic> prompts3 = [];

  ///图生视频（多图）的提示词
  List<dynamic> prompts4 = [];

  ///文生视频的提示词
  List<dynamic> _prompts2 = [];

  ///文生视频提示词索引
  int index2 = 1;

  ///文生视频提示词每页条数
  int pageSizeForTwo = 5;

  ///文生视频提示词是否滚动中
  RxBool scrollingForTextToVideo = false.obs;

  ///文生视频提示词
  List<dynamic> get prompts2 {
    int start = (index2 - 1) * pageSizeForTwo;
    int end = min(
      (index2 - 1) * pageSizeForTwo + pageSizeForTwo,
      _prompts2.length,
    );
    return _prompts2.sublist(start, end);
  }

  ///加载提示词，0=>加载所以，1=>仅加载图生视频，2=>仅加载文生视频，3=>首尾帧，4=>多图
  void loadPrompts({int loadType = 0}) {
    if (loadType == 0) {
      _loadPromptsForRemote(
        type: AiVideoGenerationType.imageToVideo,
        onSuccess: (value) {
          prompts1 = value;
          if (currentMode.value == 0) {
            update(['promptsForImage']);
          }
        },
      );
      if (_prompts2.isNotEmpty != true) {
        _loadPromptsForRemote(
          type: AiVideoGenerationType.textToVideo,
          onSuccess: (value) {
            _prompts2 = value;
            update(['promptsForText']);
          },
        );
      }
      // _loadPromptsForRemote(
      //     type: AiVideoGenerationType.firstAndEndFrame,
      //     onSuccess: (value) {
      //       prompts3 = value;
      //       if (currentMode.value == 1) {
      //         update(['promptsForImage']);
      //       }
      //     });
      // _loadPromptsForRemote(
      //     type: AiVideoGenerationType.multipleImages,
      //     onSuccess: (value) {
      //       prompts4 = value;
      //       if (currentMode.value == 2) {
      //         update(['promptsForImage']);
      //       }
      //     });
    } else if (loadType == 1) {
      _loadPromptsForRemote(
        type: AiVideoGenerationType.imageToVideo,
        onSuccess: (value) {
          prompts1 = value;
          update(['promptsForImage']);
        },
      );
    } else if (loadType == 2) {
      _loadPromptsForRemote(
        type: AiVideoGenerationType.textToVideo,
        onSuccess: (value) {
          _prompts2 = value;
          update(['promptsForText']);
        },
      );
      // } else if (loadType == 3) {
      //   _loadPromptsForRemote(
      //       type: AiVideoGenerationType.firstAndEndFrame,
      //       onSuccess: (value) {
      //         prompts3 = value;
      //         update(['promptsForImage']);
      //       });
      // } else if (loadType == 4) {
      //   _loadPromptsForRemote(
      //       type: AiVideoGenerationType.multipleImages,
      //       onSuccess: (value) {
      //         prompts4 = value;
      //         update(['promptsForImage']);
      //       });
    }
  }

  ///加载提示词，0=>加载所以，1=>仅加载图生视频，2=>仅加载文生视频，3=>首尾帧，4=>多图
  void refreshPrompts({int loadType = 0}) {
    if (loadType == 0) {
      _loadPromptsForRemote(
        type: AiVideoGenerationType.imageToVideo,
        onSuccess: (value) {
          prompts1 = value;
          if (currentMode.value == 0) {
            update(['promptsForImage']);
          }
        },
      );
      if (_prompts2.isNotEmpty != true) {
        _loadPromptsForRemote(
          type: AiVideoGenerationType.textToVideo,
          onSuccess: (value) {
            _prompts2 = value;
            update(['promptsForText']);
          },
        );
      }
      // _loadPromptsForRemote(
      //     type: AiVideoGenerationType.firstAndEndFrame,
      //     onSuccess: (value) {
      //       prompts3 = value;
      //       if (currentMode.value == 1) {
      //         update(['promptsForImage']);
      //       }
      //     });
      // _loadPromptsForRemote(
      //     type: AiVideoGenerationType.multipleImages,
      //     onSuccess: (value) {
      //       prompts4 = value;
      //       if (currentMode.value == 2) {
      //         update(['promptsForImage']);
      //       }
      //     });
    } else if (loadType == 1) {
      _loadPromptsForRemote(
        type: AiVideoGenerationType.imageToVideo,
        onSuccess: (value) {
          prompts1 = value;
          update(['promptsForImage']);
        },
      );
    } else if (loadType == 2) {
      if (_prompts2.isNotEmpty != true) {
        _loadPromptsForRemote(
          type: AiVideoGenerationType.textToVideo,
          onSuccess: (value) {
            _prompts2 = value;
            int pageNum = (_prompts2.length % pageSizeForTwo) == 0
                ? _prompts2.length ~/ pageSizeForTwo
                : _prompts2.length ~/ pageSizeForTwo + 1;
            index2++;
            if (index2 > pageNum) {
              index2 = 1;
            }
            update(['promptsForText']);
          },
        );
      } else {
        int pageNum = (_prompts2.length % pageSizeForTwo) == 0
            ? _prompts2.length ~/ pageSizeForTwo
            : _prompts2.length ~/ pageSizeForTwo + 1;
        index2++;
        if (index2 > pageNum) {
          index2 = 1;
        }
        update(['promptsForText']);
      }
      scrollingForTextToVideo.value = false;
      // } else if (loadType == 3) {
      //   _loadPromptsForRemote(
      //       type: AiVideoGenerationType.firstAndEndFrame,
      //       onSuccess: (value) {
      //         prompts3 = value;
      //         update(['promptsForImage']);
      //       });
      // } else if (loadType == 4) {
      //   _loadPromptsForRemote(
      //       type: AiVideoGenerationType.multipleImages,
      //       onSuccess: (value) {
      //         prompts4 = value;
      //         update(['promptsForImage']);
      //       });
    }
  }

  ///给底部一个默认的高度，主要是用来计算需要设置的高度
  RxDouble bottomHeightForImage = (400.h).obs;

  ///给底部一个默认的高度，主要是用来计算需要设置的高度
  RxDouble bottomHeightForText = (400.h).obs;

  ///返回按钮是否拦截
  bool shouldInterception() {
    if (type == 1) {
      ///文生视频
      String text = editingController1ForTextToVideo.text;
      if (text.isNotEmpty == true) {
        return true;
      }
      if (selectedImg0.every((ele) => ele.key.isNotEmpty == true) == true) {
        return true;
      }
    } else {
      ///图生视频
      String text = editingController1ForImageToVideo.text;
      if (text.isNotEmpty == true) {
        return true;
      }
    }

    return false;
  }
}
