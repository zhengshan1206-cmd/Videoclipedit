import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/data/model/folk/story_role_bean.dart';
import 'package:video_clip_edit/data/model/folk/story_scene_bean.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/generating_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

class SceneInfoEditController extends GeneratingController {
  late num? storyId;



  @override
  void onInit() {
    super.onInit();
    storyId = Get.find<CreateFolkStoryStepsController>().storyId;
  }

  /// 获取角色详情
  pollingRoleInfo({
    required int roleId,
    CancelToken? cancelToken,
    void Function(dynamic)? onComplete,
    void Function(dynamic)? onValidateBefore,
  }) {
    startPolling(
      pollingAction: ({onFaildHandler, onSuccessHandler}) {
        HttpUtils.get(
          APIs.roleInfo,
          {
            "folk_story_id": storyId,
            "folk_story_role_id": roleId,
          },
          cancelToken: cancelToken,
          success: (data) {
            final roleData = data["data"];
            final roleBean = StoryRoleBean.fromJson(roleData);
            onValidateBefore?.call(roleBean);
            onSuccessHandler?.call(roleBean);
          },
          fail: (code, msg) {
            onFaildHandler?.call(code);
          },
        );
      },
      onValid: (roleBean) {
        final reworkUrl = (roleBean as StoryRoleBean).reworkUrl;
        final redraw = reworkUrl.isNotEmpty;

        /// 有重绘：重绘成功/重绘失败
        if (redraw) {
          final rework = reworkUrl.first;
          return rework.status ==
                  RoleRegenerateStatus.roleRedrawCompleted.rawValue ||
              rework.status == RoleRegenerateStatus.roleRedrawFailed.rawValue;
        }

        /// 没有重绘：绘制成功/绘制失败
        return [
          RoleRegenerateStatus.roleDrawFailed.rawValue,
          RoleRegenerateStatus.roleDrawCompleted.rawValue,
        ].contains(roleBean.status);
      },
      onComplete: onComplete,
    );
  }

  /// 分镜重绘
  sceneRepaint({
    required int sceneId,
    required String prompt,
    void Function(dynamic)? onSucess,
  }) {
    HttpUtils.post(
      APIs.sceneRepaint,
      {
        "folk_story_id": storyId,
        "folk_story_scene_id": sceneId,
        "prompt": prompt,
      },
      success: (data) {
        onSucess?.call(data);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        final integralVipController = IntegralVipController.getOrPut();
        integralVipController.handleStatusCode(code, msg, "ai_tweets");
      },
    );
  }

  /// 修改分镜信息
  updateSceneInfo({
    required int sceneId,
    required String url,
    required String prompt,
    void Function(dynamic)? onSucess,
  }) {
    HttpUtils.post(
      APIs.updateSceneInfo,
      {
        "folk_story_id": storyId,
        "folk_story_scene_id": sceneId,
        "url": url,
        "prompt": prompt,
      },
      success: (data) {
        // final roleData = data["data"];
        onSucess?.call(data);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 轮询获取分镜信息
  pollingSceneInfo({
    required int sceneId,
    CancelToken? cancelToken,
    void Function(dynamic)? onComplete,
    void Function(dynamic)? onValidateBefore,
  }) {
    startPolling(
      pollingAction: ({onFaildHandler, onSuccessHandler}) {
        HttpUtils.get(
          APIs.sceneInfo,
          {
            "folk_story_id": storyId,
            "folk_story_scene_id": sceneId,
          },
          cancelToken: cancelToken,
          success: (json) {
            final data = json["data"];
            final StorySceneBean bean = StorySceneBean.fromJson(data);
            onValidateBefore?.call(bean);
            onSuccessHandler?.call(bean);
          },
          fail: (code, msg) {
            onFaildHandler?.call(code);
          },
        );
      },
      onValidateBefore: onValidateBefore,
      onValid: (roleBean) {
        final reworkUrl = (roleBean as StorySceneBean).reworkUrl;
        final redraw = reworkUrl.isNotEmpty;

        /// 有重绘：重绘成功/重绘失败
        if (redraw) {
          final rework = reworkUrl.first;
          return rework.status ==
                  StorySceneStatus.sceneRedrawCompleted.rawValue ||
              rework.status == StorySceneStatus.sceneRedrawFailed.rawValue;
        }

        /// 没有重绘：绘制成功/绘制失败
        return [
          StorySceneStatus.drawn.rawValue,
          StorySceneStatus.drawFailed.rawValue,
        ].contains(roleBean.status);
      },
      onComplete: onComplete,
    );
  }

  void getSceneInfo ({required int sceneId,void Function(dynamic)? onComplete}) {
    HttpUtils.get(
          APIs.sceneInfo,
          {
            "folk_story_id": storyId,
            "folk_story_scene_id": sceneId,
          },
          success: (json) {
            final data = json["data"];

            final StorySceneBean bean = StorySceneBean.fromJson(data);
            onComplete?.call(bean);
          },
          fail: (code, msg) {

          },
        );
  }
}
