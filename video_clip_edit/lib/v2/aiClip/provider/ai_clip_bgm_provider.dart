import 'dart:io';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiSquare/mixin/ai_bgm_mixin.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_bean.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_cat_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_local_bean.dart';

import '../../../widgets/toast_util.dart';

class AiClipBgmProvider extends AiBgmMixin {
  ///新增bgmType
  final int bgmType;

  AiClipBgmProvider({
    required super.bgmUrlInitial,
    this.bgmType = 4,
  });

  /// bgm分类列表
  @override
  loadBgmCateoryList() {
    HttpUtils.get(
      APIs.aiBgmCateList,
      {},
      success: (data) {
        final List bgmCateData = data["data"]["items"] ?? [];
        final List<AiCartoonBgmCatBean> beans =
            bgmCateData.map((e) => AiCartoonBgmCatBean.fromJson(e)).toList();

        updateBgmCateoryBeans(beans);
        if (beans.isNotEmpty) {
          /// 默认选中第一个分类
          updateSelectedBgmCatId(beans.first.id);
        }
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 加载bgm列表
  @override
  loadBgmList({
    bool reset = false,
  }) {
    if (reset) {
      resetBgm();
    }
    HttpUtils.get(
      APIs.aiBgmList,
      {
        "page": bgmPage,
        "pageSize": bgmPageSize,
        // "cate": selectedBgmCatId,
        // "useScenes": 4,

        "type": bgmType,
      },
      showLoading: true,
      success: (data) {
        byDebugPrint(data["data"]["items"], tag: "bgm列表:");
        final List bgmData = data["data"]["items"] ?? [];
        final List<AiCartoonBgmBean> beans = bgmData.map((e) {
          final bean = AiCartoonBgmBean.fromJson(e);
          if (selectedBgmId == -1 && bgmUrlInitial == bean.url) {
            selectedBgmId = bean.id;
          }
          return bean;
        }).toList();
        bgmPage = bgmBeans.addElementsByRemovingLast(
          beans,
          currentPage: bgmPage,
          pageSize: bgmPageSize,
        );
        updateBgmBeans(bgmBeans);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 获取本地bgm素材库列表
  /// 状态 1待审核 2审核通过 3审核失败  4系统推荐 不传为所有状态
  @override
  loadCustomBgmList({
    bool reset = false,
  }) {
    if (reset) {
      resetBgm();
    }
    HttpUtils.get(
      APIs.customBgmList,
      {
        "page": 1,
        "size": 100,
        "type": "bgm",
      },
      showLoading: true,
      success: (data) {
        byDebugPrint(data["data"]["items"], tag: "本地bgm素材库列表:");
        final List bgmData = data["data"]["items"] ?? [];
        final List<AiCartoonBgmLocalBean> beans = bgmData.map((e) {
          final bean = AiCartoonBgmLocalBean.fromJson(e);
          if (selectedLocalBgmId == -1 && bgmUrlInitial == bean.url) {
            selectedLocalBgmId = bean.id;
          }
          return bean;
        }).toList();
        // bgmPageSize = bgmBeansLocal.addElementsByRemovingLast(
        //   beans,
        //   currentPage: bgmPage,
        //   pageSize: bgmPageSize,
        // );
        updateBbgmBeansLocal(beans);
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 上传 bgm
  @override
  uploadMusic({
    required AssetEntity? asset,
    required File file,
  }) {
    if (asset == null) return;
    ByFfmpegUtil.loadUploadInfo(
      type: MediaType.audio,
      onSuccess: (UploadInfoBean infoBean) {
        /// 上传
        ByFfmpegUtil.uploadFile(
          infoBean: infoBean,
          filePath: file.path,
          onSuccess: (resp) {
            HttpUtils.post(
              APIs.uploadBgm,
              {
                "type": "bgm",
                "url": infoBean.objectUrl,
                "duration": asset.duration,
                "needRisk": 1,
                "name":
                    "AUDIO_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}_${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}"
              },
              showLoading: true,
              success: (data) {
                byDebugPrint("上传结果:$data");
                loadCustomBgmList(reset: true);
              },
              fail: (code, msg) {
                // BotToast.showText(text: msg);
                ToastUtil().showToast(msg);
              },
            );
          },
        );
      },
    );
  }

  /// 查询本地音乐库列表
}
