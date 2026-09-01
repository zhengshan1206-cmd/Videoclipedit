import 'dart:async';
import 'package:get/get.dart';
import 'package:video_clip_edit/core/base/controllers/base_controller.dart';

abstract class GeneratingController extends BaseController {
  /// 内容是否正在生成中（角色绘制、分镜绘制）
  RxBool isGenerating = true.obs;

  /// 当前生成进度
  RxInt progress = 0.obs;

  /// 轮询定时器
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    reset();
  }

  @override
  onClose() {
    /// 关闭进度定时器
    stop();
    super.onClose();
  }

  void stop() {
    _cancelProgressTimer();
    stopPolling();
    reset();
  }

  /// 启动轮询
  void startPolling({
    required void Function({
      void Function(dynamic)? onSuccessHandler,
      void Function(dynamic)? onFaildHandler,
    }) pollingAction,
    required bool Function(dynamic) onValid,
    void Function(dynamic)? onValidateBefore,
    int interval = 1,
    void Function(dynamic)? onComplete,
  }) {
    if (isGenerating.value == false) return;
    isGenerating.value = true;

    pollingAction.call(
      onSuccessHandler: (data) {
        onValidateBefore?.call(data);

        final isValid = onValid.call(data);
        if (isValid) {
          stopPolling();
          onComplete?.call(data);
        } else {
          _pollingTimer?.cancel();
          _pollingTimer = Timer(Duration(seconds: interval), () {
            startPolling(
              pollingAction: pollingAction,
              onValid: onValid,
              interval: interval,
            );
          });
        }
      },
      onFaildHandler: (data) {
        _pollingTimer?.cancel();
        _pollingTimer = Timer(Duration(seconds: interval), () {
          startPolling(
            pollingAction: pollingAction,
            onValid: onValid,
            interval: interval,
          );
        });
      },
    );
  }

  /// 停止轮询
  void stopPolling() {
    isGenerating.value = false;
    _pollingTimer?.cancel();
  }

  /// 进度定时器
  Timer? _progressTimer;

  /// 进度阻塞时间(ms)
  int blockmMilliseconds = 10000;

  /// 消耗时间(ms)
  int costMilliseconds = 0;

  /// 开启进度定时器
  startProgressTimer({
    void Function()? onComplete,
  }) {
    const interval = 150;
    _progressTimer = Timer.periodic(
      const Duration(milliseconds: interval),
      (timer) {
        costMilliseconds += interval;

        if (costMilliseconds < blockmMilliseconds) {
          _checkProgress(onComplete: onComplete);
          return;
        }

        if (isGenerating.value == false) {
          if (progress.value < 100) {
            progress.value = 100;
          }

          /// 关闭进度定时器
          _onProgressCompeleted(onComplete: onComplete);
        }
      },
    );
  }

  /// 关闭进度定时器
  _cancelProgressTimer() {
    _progressTimer?.cancel();
  }

  _onProgressCompeleted({
    void Function()? onComplete,
  }) {
    /// 关闭进度定时器
    _cancelProgressTimer();

    Future.delayed(const Duration(milliseconds: 100), () {
      onComplete?.call();
    });
  }

  _checkProgress({
    void Function()? onComplete,
  }) {
    if (isGenerating.value) {
      progress.value += 1;
    } else {
      progress.value = 100;
      _onProgressCompeleted(onComplete: onComplete);
    }
  }

  /// 步骤2稍后查看
  viewLater() {
    Get.back();
  }

  /// 重置状态
  void reset() {
    isGenerating.value = true;
    progress.value = 0;
    costMilliseconds = 0;
  }
}
