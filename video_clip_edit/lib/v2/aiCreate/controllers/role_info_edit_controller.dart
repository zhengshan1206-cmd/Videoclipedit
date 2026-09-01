import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:video_clip_edit/data/model/folk/story_role_bean.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/create_folk_story_steps_controller.dart';
import 'package:video_clip_edit/v2/aiCreate/controllers/generating_controller.dart';

class RoleInfoEditController extends GeneratingController {

  CreateFolkStoryStepsController get createFolkStoryStepscontroller => Get.find<CreateFolkStoryStepsController>();

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
            "folk_story_id": createFolkStoryStepscontroller.storyId,
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

  /// 开始重绘

  /// 角色重绘
  roleInfoRepaint({
    required int roleId,
    required String desc,
    void Function(dynamic)? onSucess,
  }) {
    HttpUtils.post(
      APIs.roleRepaint,
      {
        "folk_story_id": createFolkStoryStepscontroller.storyId,
        "folk_story_role_id": roleId,
        "desc": desc,
      },
      showLoading: true,
      success: (data) {
        onSucess?.call(data);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 修改角色信息(使用)
  updateRoleInfo({
    required int roleId,
    required String url,
    required String desc,
    void Function(dynamic)? onSucess,
  }) {
    HttpUtils.post(
      APIs.updateRoleInfo,
      {
        "folk_story_id": createFolkStoryStepscontroller.storyId,
        "folk_story_role_id": roleId,
        "url": url,
        "desc": desc,
      },
      showLoading: true,
      success: (data) {
        onSucess?.call(data);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
