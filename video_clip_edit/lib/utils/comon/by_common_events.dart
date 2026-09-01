///app 自定义事件
library;

///AI数字人口播  上传历史视频
class RequestMyAIOralVideoDataEvent {
  final bool needRequestData;
  const RequestMyAIOralVideoDataEvent({
    required this.needRequestData,
  });
}



///
class PauseVideoEvent{
  const PauseVideoEvent();
}


///网络异常处理
class NetworkErrorEvent{
  const NetworkErrorEvent();
}