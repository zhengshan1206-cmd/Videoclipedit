import 'package:video_clip_edit/providers/base_provider.dart';
import 'dart:convert';

class AiVipGuidTaskBean {
  String taskName;
  String taskNameFinished;
  int staus;

  AiVipGuidTaskBean({
    required this.taskName,
    required this.taskNameFinished,
    required this.staus,
  });

  AiVipGuidTaskBean copyWith({
    String? taskName,
    String? taskNameFinished,
    int? staus,
  }) =>
      AiVipGuidTaskBean(
        taskName: taskName ?? this.taskName,
        taskNameFinished: taskNameFinished ?? this.taskNameFinished,
        staus: staus ?? this.staus,
      );

  factory AiVipGuidTaskBean.fromRawJson(String str) =>
      AiVipGuidTaskBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AiVipGuidTaskBean.fromJson(Map<String, dynamic> json) =>
      AiVipGuidTaskBean(
        taskName: json["taskName"],
        taskNameFinished: json["taskNameFinished"],
        staus: json["staus"],
      );

  Map<String, dynamic> toJson() => {
        "taskName": taskName,
        "taskNameFinished": taskNameFinished,
        "staus": staus,
      };
}

class AiVipGuidProvider extends BaseProvider {
  /// 任务列表
  List<AiVipGuidTaskBean> tasks = [
    AiVipGuidTaskBean.fromJson({
      "taskName": "任务提交中...",
      "taskNameFinished": "任务提交完成",
      "staus": 0,
    }),
    AiVipGuidTaskBean.fromJson({
      "taskName": "正在调度算力...",
      "taskNameFinished": "调度算力完成",
      "staus": 0,
    }),
    AiVipGuidTaskBean.fromJson({
      "taskName": "任务进行中...",
      "taskNameFinished": "任务完成，解锁会员查看结果",
      "staus": 0,
    }),
  ];

  /// 更新任务列表
  updateTasks(List<AiVipGuidTaskBean> beans) {
    tasks = beans;
  }

  /// 任务列表
  List<AiVipGuidTaskBean> tasksDisplay = [];

  /// 更新任务列表
  updateTasksDisplay(List<AiVipGuidTaskBean> beans) {
    tasksDisplay = beans;
    notifyListeners();
  }

  /// 检查任务是否全部完成
  bool checkAllTasksFinished() {
    if (tasks.isEmpty) return true;
    for (var e in tasks) {
      if (e.staus == 0) {
        return false;
      }
    }
    return true;
  }

  nextTask() {
    final tasksCopy = List<AiVipGuidTaskBean>.from(tasks);
    final tasksDisplayCopy = List<AiVipGuidTaskBean>.from(tasksDisplay);

    final task = tasksCopy.firstWhere((e) => e.staus == 0);
    tasksDisplayCopy.add(task);
    updateTasksDisplay(tasksDisplayCopy);
  }

  finishNextTask() {
    final tasksCopy = List<AiVipGuidTaskBean>.from(tasks);
    final task = tasksCopy.firstWhere((e) => e.staus == 0);
    task.staus = 1;
    updateTasks(tasksCopy);

    final tasksDisplayCopy =
        List<AiVipGuidTaskBean>.generate(tasksDisplay.length, (index) {
      return tasksDisplay[index].copyWith();
    });
    final lastTask = tasksDisplayCopy.last;
    lastTask.staus = 1;
    updateTasksDisplay(tasksDisplayCopy);
  }

  AiVipGuidProvider() {
    _checkStatus();
  }

  void _checkStatus() {
    if (checkAllTasksFinished()) {
      return;
    }

    /// 取出下一个任务
    nextTask();
    Future.delayed(
      const Duration(seconds: 2),
      () {
        /// 完成下一个任务
        finishNextTask();

        if (!checkAllTasksFinished()) {
          _checkStatus();
        }
      },
    );
  }
}
