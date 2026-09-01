// 用于控制配音任务处理
// 包括当前完成进度统计
import 'package:bot_toast/bot_toast.dart';
import 'package:video_clip_edit/providers/base_provider.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import 'package:video_clip_edit/modules/home/clipped/beans/speaker_bean.dart';
import 'package:video_clip_edit/modules/home/recreate/beans/commentary_item_bean.dart';

class VideoRecreateDubbingProvider extends BaseProvider {
  /// 存放所有的配音任务id
  final List<String> taskIds = [];
  List<CommentaryItemBean> commentaryItemBeans = [];

  /// 总任务数
  int tasksCount = 0;
  changeTasksCount(int count) {
    tasksCount = count;
    notifyListeners();
  }

  /// 当前进度
  int progress = 0;
  changeProgress(int p) {
    progress = p;
    notifyListeners();
  }

  /// 计算总的任务数
  calculateTotalTasks(List<CommentaryItemBean> commentaryItemBeans) {
    final commentaries =
        commentaryItemBeans.where((e) => e.talkSelected == false).toList();
    return commentaries.length;
  }

  /// 开始创建配音
  startGenerateDubbing(
    List<CommentaryItemBean> commentaryItemBeans,
    String speaker, {
    void Function(List<String> urls)? onSuccess,
    void Function(String)? onFaild,
  }) {
    this.commentaryItemBeans = commentaryItemBeans;

    final commentaries =
        commentaryItemBeans.where((e) => e.talkSelected == false).toList();

    if (commentaries.isEmpty) {
      onSuccess?.call([]);
      return;
    }
    final contents = commentaries.map((e) => e.commentary.commentary).toList();
    final param = {
      "text": contents,
      "speaker": speaker,
      "name": "audio_${DateTime.now().millisecondsSinceEpoch}",
      "speed": 0,
      "pitch": 0,
      "pid": "",
      "startTask": true,
      "platform": "volcengine",
    };
    print("ddddddddddddddddd创建批量任务参数：$param");
    _createDubbingTask(
      param: param,
      onSuccess: (ids) {
        print("ddddddddddddddddd创建批量任务结果：$ids");
        taskIds.addAll(ids.map((e) => e.toString()));

        /// 轮询解说配音生成的状态
        queryWords2AudioStatus(
          taskIds,
          onSuccess: (urls) {
            /// 所有的配音生成完成后，将得到的音频远程地址返回
            onSuccess?.call(urls);
            // ByFfmpegUtil.downloadAudio(url, fileName)
          },
          onFaild: () {
            onFaild?.call("");
          },
        );
      },
      onFaild: (val) {
        onFaild?.call(val);
      },
    );
  }

  /// 创建单个配音任务
  _createDubbingTask({
    required Map<String, dynamic> param,
    void Function(List taskId)? onSuccess,
    void Function(String)? onFaild,
  }) {
    HttpUtils.post(
      APIs.ttsV1Batch,
      param,
      success: (data) {
        print("批量查询结果$data");
        final List taskIds = data["data"]["taskIds"];
        final taskMap = data["data"]["taskMap"];

        /// 将 taskId 设置到对应的解说数据模型中
        for (var taskId in taskIds) {
          final str = taskMap[taskId.toString()] ?? "";
          final commentary = commentaryItemBeans.firstWhere((e) {
            return e.commentary.commentary == str;
          });
          commentary.taskId = taskId.toString();
        }
        onSuccess?.call(taskIds);
      },
      fail: (code, msg) {
        onFaild?.call(msg);
      },
    );
  }

  /// 查询配音列表
  loadSpeakers({
    String? domainId = "影视",
    String? sex = "男",
    String? age = "少年",
    String? platform = "volcengine",
    void Function(List<SpeakerBean>)? onSuccess,
  }) {
    HttpUtils.post(
      APIs.speakerList,
      {
        // "domainId": domainId,
        // "mainEmotion": "",
        // "sex": sex,
        // "age": age,
        "platform": platform,
        "page": 1,
        "size": 999,
      },
      showLoading: true,
      success: (data) {
        if (data["status"] == 200) {
          final items = data["data"]["items"] ?? [];
          List<SpeakerBean> speakerBeans = List<SpeakerBean>.from(
              (items).map((x) => SpeakerBean.fromJson(x)));
          onSuccess?.call(speakerBeans);
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 查询配音生成进度
  queryWords2AudioStatus(
    List<String> taskIds, {
    void Function(List<String> urls)? onSuccess,
    void Function()? onFaild,
  }) {
    HttpUtils.post(
      APIs.getTtsByPids,
      {
        "pids": taskIds,
      },
      showMsgWhenFailed: false,
      success: (data) {
        final List orders = data["data"]["order"] ?? [];
        if (orders.isEmpty) {
          BotToast.showText(text: "生成配音失败，请重试");
          return;
        }
        int successCount = 0;
        final totalCount = calculateTotalTasks(commentaryItemBeans);
        final finishedCount = totalCount - taskIds.length;
        final remainCount = taskIds.length;

        /// 1、判断是否全成功
        for (var element in orders) {
          /// 3: 失败 2: 成功
          final status = element["status"];
          if (status == 3) {
            /// 有配音创建失败，交回给上层处理 - 返沪上一页
            onFaild?.call();
            return;
          }

          if (status == 2) {
            /// 成功数量+1
            successCount++;

            // 将得到的 audioUrl 更新到解说数据模型中
            final audioUrl = element["audio_link"] ?? "";
            final paramId = element["param_id"] ?? "";
            final srtLink = element["srt_link"] ?? "";
            final commentary = commentaryItemBeans.firstWhere((e) {
              return e.taskId == paramId.toString();
            });

            commentary.audioUrl = audioUrl;
            commentary.srtUrl = srtLink;
            commentary.commentaryDuration =
                double.parse((element["duration"] ?? "0.0").toString());

            /// 将成功的 taskId 从查询列表中移除
            taskIds.remove(paramId.toString());
          }
        }

        /// 更新解说音频生成进度
        changeProgress(
            (((successCount + finishedCount) * 1.0 / totalCount) * 100)
                .floor());

        /// 成功回调
        if (successCount == remainCount) {
          onSuccess?.call(commentaryItemBeans
              .where((e) => !e.talkSelected)
              .map((e) => e.audioUrl)
              .toList());
          return;
        }

        /// 延迟 1s 重试查询
        Future.delayed(
          const Duration(seconds: 1),
          () {
            queryWords2AudioStatus(
              taskIds,
              onSuccess: onSuccess,
              onFaild: onFaild,
            );
          },
        );
      },
      fail: (code, msg) {
        /// 延迟 1s 重试查询
        Future.delayed(
          const Duration(seconds: 1),
          () {
            queryWords2AudioStatus(
              taskIds,
              onSuccess: onSuccess,
              onFaild: onFaild,
            );
          },
        );
      },
    );
  }
}
