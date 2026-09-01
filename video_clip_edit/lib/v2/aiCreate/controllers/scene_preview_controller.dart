import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/data/model/folk/story_scene_bean.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/generating_controller.dart';

class ScenePreviewController extends GeneratingController {
  /// 分镜重绘
  sceneRepaint({
    required int storyId,
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
      },
    );
  }

  /// 修改分镜信息
  updateSceneInfo({
    required int storyId,
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
    required int storyId,
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
            onSuccessHandler?.call(bean);
            onComplete?.call(bean);
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

  ///获取分镜信息
  fetchSceneInfo({
    required int storyId,
    required int sceneId,
    void Function(dynamic)? onComplete,
  }){
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
