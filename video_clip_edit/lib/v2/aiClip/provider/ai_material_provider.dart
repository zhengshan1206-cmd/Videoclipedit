import 'dart:io';
import 'package:dio/dio.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/comon/by_list_ext.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:video_clip_edit/utils/comon/by_ffmpeg_util.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_material_item_bean.dart';
import 'package:video_clip_edit/v2/aiClip/beans/ai_show_list_item_bean.dart';
import 'package:video_clip_edit/modules/home/words/beans/upload_info_bean.dart';
import 'package:video_clip_edit/modules/home/providers/words_extract_provider.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_bgm_local_bean.dart';
import 'package:video_clip_edit/v2/aiSquare/cartoon/beans/ai_cartoon_video_ratio_bean.dart';

import '../../../widgets/toast_util.dart';

enum AiMaterialType { clip, show, mine }

/// 素材类型：素材剪辑、短剧素材、我的素材
extension AiMaterialTypeExt on AiMaterialType {
  int get rawValue {
    switch (this) {
      /// 素材剪辑
      case AiMaterialType.clip:
        return 1;

      /// 短剧素材
      case AiMaterialType.show:
        return 2;

      /// 我的素材
      default:
        return 3;
    }
  }

  static AiMaterialType typeFromRawValue(int value) {
    switch (value) {
      /// 素材剪辑
      case 1:
        return AiMaterialType.clip;

      /// 短剧素材
      case 2:
        return AiMaterialType.show;

      /// 我的素材
      default:
        return AiMaterialType.mine;
    }
  }
}

/// 素材选择类型：单素材/多素材
enum AiMaterialCategoryType { single, multi }

extension AiMaterialCategoryTypeExt on AiMaterialCategoryType {
  int get rawValue {
    switch (this) {
      /// 单素材
      case AiMaterialCategoryType.single:
        return 0;

      /// 多素材
      case AiMaterialCategoryType.multi:
        return 1;
      default:
        return 2;
    }
  }

  String get description {
    switch (this) {
      /// 单素材
      case AiMaterialCategoryType.single:
        return "单素材";

      /// 多素材
      case AiMaterialCategoryType.multi:
        return "多素材";
      default:
        return "单素材";
    }
  }

  static AiMaterialCategoryType typeFromRawValue(int value) {
    switch (value) {
      /// 单素材
      case 0:
        return AiMaterialCategoryType.single;

      /// 多素材
      case 1:
        return AiMaterialCategoryType.multi;
      default:
        return AiMaterialCategoryType.single;
    }
  }
}

class AiMaterialProvider extends BaseProvider {
  /// 选择素材类型
  AiMaterialType currentType = AiMaterialType.clip;
  updateMaterialType(AiMaterialType type) {
    currentType = type;
    notifyListeners();
  }

  /// 素材分类
  AiMaterialCategoryType categoryType = AiMaterialCategoryType.single;
  updateMaterialCatgoryType(AiMaterialCategoryType type) {
    categoryType = type;
    notifyListeners();
  }

  /// 视频比例
  List<AiCartoonVideoRatioBean> videoRatioBeans = [];

  List<MaterialPack> selectedClipMaterials = [];
  updateSelectedClipMaterials(List<MaterialPack> beans) {
    selectedClipMaterials = beans;
    notifyListeners();
  }

  updateSelectedClipMaterialsWithMaterialBean(MaterialPack bean) {
    final beans = List<MaterialPack>.from(selectedClipMaterials);
    bool contains = selectedClipMaterials.map((e) => e.id).contains(bean.id);
    if (contains) {
      beans.remove(selectedClipMaterials.firstWhere((e) => e.id == bean.id));
    } else {
      beans.add(bean);
    }
    updateSelectedClipMaterials(beans);
  }

  changeFoldStatsAtIndex(int index) {
    final beans = List<AiMaterialItemBean>.from(
        clipMaterialItemBeans.map((e) => e.copyWith()));
    beans[index].folde = !beans[index].folde;
    updateMaterialItemBeans(beans);
  }

  int clipPage = 1;
  List<AiMaterialItemBean> clipMaterialItemBeans = [];
  updateMaterialItemBeans(List<AiMaterialItemBean> beans) {
    clipMaterialItemBeans = beans;
    notifyListeners();
  }

  resetClipPage() {
    clipPage = 1;
    clipMaterialItemBeans.clear();
  }

  /// 按照视频比例获取素材列表
  /// [page] 当前页数
  /// [pageSize] 每页记录数
  /// [type] 1普通素材 2短剧
  /// [scale] 视频比例的id（eg：3=>16:9、4=> 9:16） 短剧传4（没有比例）
  aiMaterialsList({
    required int type,
    required int scale,
    bool reset = false,
    CancelToken? cancelToken,
    required EasyRefreshController controller,
  }) {
    if (reset) {
      clipPage = 1;
      clipMaterialItemBeans.clear();
    }
    HttpUtils.get(
      APIs.aiMaterialsList,
      {
        "page": clipPage,
        "pageSize": 10,
        "scale": scale,
        "type": currentType.rawValue
      },
      cancelToken: cancelToken,
      showLoading: true,
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        final List<AiMaterialItemBean> beans = List<AiMaterialItemBean>.from(
            items.map((e) => AiMaterialItemBean.fromJson(e)));

        final results = List<AiMaterialItemBean>.from(clipMaterialItemBeans);
        clipPage = results.addElementsByRemovingLast(
          beans,
          pageSize: 10,
          currentPage: clipPage,
        );
        updateMaterialItemBeans(results);
        if (reset) {
          controller.finishRefresh();
          controller.resetFooter();
        } else {
          controller.finishLoad(
            beans.length % 10 == 0
                ? IndicatorResult.success
                : IndicatorResult.noMore,
          );
        }
      },
      fail: (code, msg) {
        controller.finishLoad(IndicatorResult.fail);
        EasyLoading.dismiss();
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  int showPage = 1;

  /// 短剧模型列表
  List<AiMaterialItemBean> showMaterialItemBeans = [];
  updateShowMaterialItemBeans(List<AiMaterialItemBean> beans) {
    showMaterialItemBeans = beans;
    notifyListeners();
  }

  int selectedShowId = -1;

  /// 按照视频比例获取素材列表
  /// [page] 当前页数
  /// [pageSize] 每页记录数
  /// [type] 1普通素材 2短剧
  /// [scale] 视频比例的id（eg：3=>16:9、4=> 9:16） 短剧传4（没有比例）
  aiShowMaterialsList({
    required int type,
    required int scale,
    bool reset = false,
    required EasyRefreshController controller,
  }) {
    if (reset) {
      clipPage = 1;
      clipMaterialItemBeans.clear();
    }
    HttpUtils.get(
      APIs.aiMaterialsList,
      {
        "page": showPage,
        "pageSize": 10,
        "scale": scale,
        "type": 2
      },
      showLoading: false,
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        final List<AiMaterialItemBean> beans = List<AiMaterialItemBean>.from(
            items.map((e) => AiMaterialItemBean.fromJson(e)));
        if (reset) {
          controller.finishRefresh();
          controller.resetFooter();
        } else {
          controller.finishLoad(
            beans.length % 10 == 0
                ? IndicatorResult.success
                : IndicatorResult.noMore,
          );
        }
        final results = List<AiMaterialItemBean>.from(clipMaterialItemBeans);
        showPage = results.addElementsByRemovingLast(
          beans,
          pageSize: 10,
          currentPage: clipPage,
        );
        updateShowMaterialItemBeans(results);
      },
      fail: (code, msg) {
        controller.finishLoad(IndicatorResult.fail);
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  /// 短剧可选择的最大数量
  int maxSelectedShowCount = 5;
  int showListPage = 1;
  List<AiShowListItemBean> showListBeans = [];
  updateShowListItemBeans(List<AiShowListItemBean> beans) {
    showListBeans = beans;
    notifyListeners();
  }

  List<AiShowListItemBean> selectedShowListBeans = [];
  updateSelectedShowListItemBeans(List<AiShowListItemBean> beans) {
    selectedShowListBeans = beans;
    notifyListeners();
  }

  updateSelectedShowListItemBeansWithBean(AiShowListItemBean bean) {
    final selected = checkShowItemBeanSelected(bean);
    final results = List<AiShowListItemBean>.from(selectedShowListBeans);
    if (selected) {
      results.removeWhere((e) => e.id == bean.id);
    } else {
      results.add(bean);
    }
    updateSelectedShowListItemBeans(results);
  }

  ///是否选择了某个短剧素材
  checkShowItemBeanSelected(AiShowListItemBean bean) {
    if (selectedShowListBeans.isEmpty) return false;
    return selectedShowListBeans.map((e) => e.id).contains(bean.id);
  }

  /// 按分类获取明细列表
  aiLoadShowList({
    bool reset = false,
    required int pid,
    required EasyRefreshController controller,
  }) {
    if (reset) {
      showListBeans.clear();
      showListPage = 1;
    }
    HttpUtils.get(
      APIs.aiGetDetailList,
      {
        "pid": pid,
        "pageSize": 10,
        "page": showPage,
      },
      showLoading: false,
      success: (data) {
        final List items = data["data"]["data"] ?? [];
        final List<AiShowListItemBean> beans = List<AiShowListItemBean>.from(
            items.map((e) => AiShowListItemBean.fromJson(e)));
        if (reset) {
          controller.finishRefresh();
          controller.resetFooter();
        } else {
          controller.finishLoad(
            beans.length % 10 == 0
                ? IndicatorResult.success
                : IndicatorResult.noMore,
          );
        }
        final results = List<AiShowListItemBean>.from(clipMaterialItemBeans);
        showListPage = results.addElementsByRemovingLast(
          beans,
          pageSize: 10,
          currentPage: showListPage,
        );
        updateShowListItemBeans(results);
      },
      fail: (code, msg) {
        controller.finishLoad(IndicatorResult.fail);
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);
      },
    );
  }

  int minePage = 1;
  List<AiCartoonBgmLocalBean> mineMaterialItemBeans = [];
  updateMineMaterialItemBeans(List<AiCartoonBgmLocalBean> beans) {
    mineMaterialItemBeans = beans;
    notifyListeners();
  }

  List<AiCartoonBgmLocalBean> selectedMineMaterialItemBeans = [];
  updateSelectedMineMaterialItemBeans(List<AiCartoonBgmLocalBean> beans) {
    selectedMineMaterialItemBeans = beans;
    notifyListeners();
  }

  updateSelectedMineMaterialItemBeansWithBean(AiCartoonBgmLocalBean bean) {
    // selectedMineMaterialItemBeans = beans;
    final selected = checkMineMaterialItemBeanSelected(bean);
    final results =
        List<AiCartoonBgmLocalBean>.from(selectedMineMaterialItemBeans);
    if (selected) {
      results.removeWhere((e) => e.id == bean.id);
    } else {
      results.add(bean);
    }
    updateSelectedMineMaterialItemBeans(results);
  }

  ///是否选择了某个短剧素材
  checkMineMaterialItemBeanSelected(AiCartoonBgmLocalBean bean) {
    if (selectedMineMaterialItemBeans.isEmpty) return false;
    return selectedMineMaterialItemBeans.map((e) => e.id).contains(bean.id);
  }

  resetMinePage() {
    minePage = 1;
    mineMaterialItemBeans.clear();
  }

  int openingPage = 1;
  List<AiCartoonBgmLocalBean> openingMaterialItemBeans = [];
  updateOpeningMaterialItemBeans(List<AiCartoonBgmLocalBean> beans) {
    openingMaterialItemBeans = beans;
    notifyListeners();
  }

  List<AiCartoonBgmLocalBean> selectedOpeningMaterialItemBeans = [];
  updateSelectedOpeningMaterialItemBeans(List<AiCartoonBgmLocalBean> beans) {
    selectedOpeningMaterialItemBeans = beans;
    notifyListeners();
  }

  updateSelectedOpeningMaterialItemBeansWithBean(AiCartoonBgmLocalBean bean) {
    final selected = checkOpeningMaterialItemBeanSelected(bean);
    List<AiCartoonBgmLocalBean> results =
        List<AiCartoonBgmLocalBean>.from(selectedOpeningMaterialItemBeans);
    if (selected) {
      // results.removeWhere((e) => e.id == bean.id);
    } else {
      results = [bean];
    }
    updateSelectedOpeningMaterialItemBeans(results);
  }

  ///是否选择了某个短剧素材
  checkOpeningMaterialItemBeanSelected(AiCartoonBgmLocalBean bean) {
    if (selectedOpeningMaterialItemBeans.isEmpty) return false;
    return selectedOpeningMaterialItemBeans.map((e) => e.id).contains(bean.id);
  }

  resetOpeningPage() {
    openingPage = 1;
    openingMaterialItemBeans.clear();
  }

  /// 获取本地 video 素材库列表
  /// 状态 1待审核 2审核通过 3审核失败  4系统推荐 不传为所有状态
  aiMineMaterialsList({
    bool reset = false,
    bool isOpening = false,
    required EasyRefreshController controller,
  }) {
    if (reset) {
      if (isOpening) {
        openingPage = 1;
        openingMaterialItemBeans.clear();
      } else {
        minePage = 1;
        mineMaterialItemBeans.clear();
      }
    }
    HttpUtils.get(
      APIs.customBgmList,
      {
        "page": 1,
        "size": 100,
        "type": "video",
      },
      showLoading: false,
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        final List<AiCartoonBgmLocalBean> beans =
            List<AiCartoonBgmLocalBean>.from(
                items.map((e) => AiCartoonBgmLocalBean.fromJson(e)).toList());
        if (reset) {
          controller.finishRefresh();
          controller.resetFooter();
        } else {
          controller.finishLoad(
            beans.length % 10 == 0
                ? IndicatorResult.success
                : IndicatorResult.noMore,
          );
        }
        final results = List<AiCartoonBgmLocalBean>.from(
            isOpening ? openingMaterialItemBeans : mineMaterialItemBeans);
        if (isOpening) {
          openingPage = results.addElementsByRemovingLast(
            beans,
            pageSize: 10,
            currentPage: openingPage,
          );
          updateOpeningMaterialItemBeans(results);
        } else {
          minePage = results.addElementsByRemovingLast(
            beans,
            pageSize: 10,
            currentPage: minePage,
          );
          updateMineMaterialItemBeans(results);
        }
      },
      fail: (code, msg) {
        controller.finishLoad(IndicatorResult.fail);
        EasyLoading.dismiss();
        // BotToast.showText(text: msg);
        ToastUtil().showToast(msg);

      },
    );
  }

  /// 上传 video
  /// [asset] 鸿蒙选图/相机可能只返回路径，asset 为空时 duration 用 0
  uploadMaterial({
    AssetEntity? asset,
    required File file,
    required EasyRefreshController controller,
  }) {
    final duration = asset?.duration ?? 0;
    ByFfmpegUtil.loadUploadInfo(
      type: MediaType.video,
      onSuccess: (UploadInfoBean infoBean) {
        /// 上传
        ByFfmpegUtil.uploadFile(
          infoBean: infoBean,
          filePath: file.path,
          onSuccess: (resp) {
            HttpUtils.post(
              APIs.uploadBgm,
              {
                "type": "video",
                "url": infoBean.objectUrl,
                "duration": duration,
                "cover": infoBean.coverUrl,
                "needRisk": 1,
                "name":
                    "AUDIO_${DateTime.now().year}${DateTime.now().month.toStringAsFixed(2).padLeft(0)}${DateTime.now().day}_${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}"
              },
              showLoading: true,
              success: (data) {
                byDebugPrint("上传结果:$data");
                Map? dataFromServer = data["data"];
                if(dataFromServer!=null){
                  if(dataFromServer.isEmpty){
                    BotToast.showText(text: data["message"]);
                  }
                }
                aiMineMaterialsList(reset: true, controller: controller);
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
}
