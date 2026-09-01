import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/network/result.dart';
import '../../../flavors/build_config.dart';
import '../../../utils/comon/by_colors.dart';
import '../../../utils/comon/by_screen_utils.dart';
import '../../../utils/comon/by_widgets_util.dart';
import '../../../utils/http/apis.dart';
import '../../aiClip/widgets/ai_commentary_progress_bar.dart';
import '../../slicing/mixin/stream_data_mixin.dart';

/// AI创作文案弹窗 后面改用 GetX
class AiCreateTextDialog extends StatefulWidget {
  final int maxCount;
  const AiCreateTextDialog({
    super.key,
    this.maxCount = 500,
  });

  @override
  State<AiCreateTextDialog> createState() => _AiCreateTextDialogState();
}

class _AiCreateTextDialogState extends State<AiCreateTextDialog>
    with StreamDataMixin {
  ///选中的文本类型
  int type = 0;

  ///字数要求数据集合
  final List<TextNumberModel> textNumberList = [
    TextNumberModel(maxCounts: 100, hintText: "<100字", index: 0),
    TextNumberModel(maxCounts: 200, hintText: "<200字", index: 1),
    TextNumberModel(maxCounts: 300, hintText: "<300字", index: 2),
    TextNumberModel(maxCounts: 400, hintText: "<400字", index: 3),
    TextNumberModel(maxCounts: 500, hintText: "<500字", index: 4),
  ];

  ///文案主题和要求输入框
  final TextEditingController textEditingController = TextEditingController();

  ///AI创作输入框 （方便后续拓展为可编辑）
  final TextEditingController textEditingController2 = TextEditingController();

  ///文案主题输入的文字数量
  int textSubjectCounts = 0;

  ///是否正在请求随机热门灵感
  bool isGetRandom = false;


  /// 消息流订阅
  StreamSubscription<String>? messageSubscription;

  ///选中的最大文本数
  int maxCount = 100;

  ///是否正在得到AI创作文案结果
  bool isGetAIResult = false;

  /// AI创作文案消息流订阅
  StreamSubscription<String>? messageSubscription2;

  ///当前进度类型 1（文案主题） 2（过渡动画） 3（Ai创作文案结果）

  int currentType = 1;

  ///AI创作文案的文字数量
  int textSubjectCounts2 = 0;

  @override
  void initState() {
    initData();
    super.initState();
  }

  Widget _bodyView() {
    if (currentType == 1) {
      return _startCreateTextView();
    } else if (currentType == 2) {
      return _progressView();
    } else if (currentType == 3) {
      return _resultView();
    }

    return const SizedBox();
  }

  ///AI创作文案
  Widget _aiCreateTextDialog() {
    /// 底部系统安全区画在白色面板内，避免底部仅靠 margin 透出遮罩（视觉上「镂空」）。
    final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;
    return SizedBox(
      height: 0.7.sh,
      child: Container(
        height: 0.6.sh,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(18.w),
              topLeft: Radius.circular(18.w),
            )),
        padding: EdgeInsets.only(
          left: 13.w,
          right: 13.w,
          bottom: bottomSafe,
        ),
        child: _bodyView(),
      ),
    );
  }

  ///开始创作按钮
  Widget _startCreateBtn() {
    return InkResponse(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        onTap: () {
          _starCreateEvent();
        },
        child: Container(
          width: 1.sw,
          decoration: BoxDecoration(
            color: const Color(0XFF5B4BF7),
            borderRadius: BorderRadius.circular(12.w),
          ),
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.only(
            top: 17.5.w,
            bottom: 17.5.w,
          ),
          alignment: Alignment.center,
          child: Text(
            "开始创作",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ));
  }

  ///构建底部区域
  Widget _buildBottomView() {
    return Text(
      "$textSubjectCounts/${widget.maxCount}",
      style: TextStyle(
        color: const Color(0XFF0B1843).withOpacity(0.5),
        fontSize: 12.sp,
      ),
    );
  }

  ///清除文本事件
  clearTextEvent() {
    if(isGetRandom){
      BotToast.showText(text: "正在生成随机热门灵感~");
      return;
    }
    textEditingController.text = "";
    textSubjectCounts = 0;
    setState(() {});
  }


  clearTextEvent2() {
    if(isGetAIResult){
      BotToast.showText(text: "正在生成AI创作文案~");
      return;
    }
    Get.log("点击清除AI创作文案事件");
    textEditingController2.text = "";
    textSubjectCounts2 = 0;
    setState(() {});
  }

  ///选中文本字数要求事件
  selectTextCountEvent({
    required int index,
    required int maxCounts,
  }) {
    if (type == index) {
      return;
    } else {
      type = index;
      maxCount = maxCounts;
    }
    Get.log("选中的最大字数===>$maxCount");
    setState(() {});
  }

  ///初始化数据
  void initData() {
    textEditingController.addListener(() {
      textSubjectCounts = textEditingController.text.length;
      if (mounted) {
        setState(() {});
      }
      // Get.log("监听字数发生了变化======= ${textSubjectCounts}");
    });
    textEditingController2.addListener(() {
      textSubjectCounts2 = textEditingController2.text.length;
      if (mounted) {
        setState(() {});
      }
      // Get.log("监听字数发生了变化======= ${textSubjectCounts}");
    });
  }

  ///随机热门灵感事件
  void _clickRandomEvent() async {
    ///如果正在随机热门灵感 不可点击
    if (isGetRandom) {
      // Get.log("如果正在随机热门灵感 不可点击");
      BotToast.showText(text: "正在随机热门灵感~");
      return;
    }
    isGetRandom = true;
    textEditingController.text = "";
    if (mounted) {
      setState(() {});
    }
    messageSubscription?.cancel();
    final stream = await getStream(
        url: BuildConfig.instance.environment.domain + APIs.randomPrompt,
        body: {
          "type": 2,
        });
    messageSubscription = stream.listen((data) {
      Get.log("获取随机热门灵感词===>$data");
      textEditingController.text += data;
      isGetRandom = true;
    }, onDone: () {
      isGetRandom = false;
      if (mounted) {
        setState(() {});
      }
      messageSubscription?.cancel();
    }, onError: (error) {
      if (error is APIError) {
        BotToast.showText(text: error.message);
        messageSubscription?.cancel();
      }
    });
  }

  ///文案预设中 view
  Widget _startCreateTextView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 138.w,
            ),
            Text(
              "AI创作文案",
              style: TextStyle(
                  color: const Color(0XFF0B1843),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            InkResponse(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              onTap: () {
                Get.back();
              },
              child: Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/ai/oralVideos/ai_oral_icon_close.png",
                  width: 15,
                  height: 15,
                  fit: BoxFit.fitHeight,
                ),
              ),
            )
          ],
        ),

        ///1. 文案主题和要求
        Padding(
          padding: EdgeInsets.only(bottom: 10.w),
          child: Text(
            "1、文案主题和要求",
            style: TextStyle(
                color: const Color(0XFF0B1843),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600),
          ),
        ),

        ///1.文案主题输入框
        Container(
            decoration: BoxDecoration(
                color: const Color(0XFFEAEEFF),
                border: Border.all(
                  color: const Color(0XFFEAEEFF),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12.w)),
            padding: EdgeInsets.only(
                top: 0.w, left: 12.w, right: 12.w, bottom: 10.w),
            child: Stack(
              children: [
                Container(
                  height:0.28.sh,
                  margin: EdgeInsets.only(bottom: 30.h),
                  child:ListView(
                    padding: EdgeInsets.zero,
                    physics:textEditingController.text.length<120? const NeverScrollableScrollPhysics():null,
                    children: [
                      ExtendedTextField(
                        maxLines: 100,
                        minLines: 1,
                        expands: false,
                        controller: textEditingController,
                        // focusNode: focusNode,
                        autofocus: false,
                        onChanged: (String value) {},
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.normal,
                            color: ByColorUtil.CommonTextColor,
                          ),
                          hintText:
                          "请输入文案主题和要求。\n例如：我是一家开咖啡厅的，请从门店环境，咖啡味道，产品质量等角度帮我创作一篇门店推广的口播文案。",
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.normal,
                            color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                          ),
                          enabled: isGetRandom ? false : true,
                        ),
                        cursorColor: ByColorUtil.CommonTextColor,
                      ),
                    ],
                  )
                ),

                ///生成提示区域
                if (isGetRandom && textEditingController.text.isEmpty)
                  Positioned(
                    top: 20.w,
                    left: 150.w,
                    child: ByWidgetsUtil.activityIndicator(radius: 13.w),
                  ),

                ///底部区域
                Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: 1.sw,
                      child: Row(
                        children: [
                          _buildBottomView(),
                          GestureDetector(
                            onTap: () {
                              clearTextEvent();
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 5.w,
                                ),
                                Text(
                                  "清空",
                                  style: TextStyle(
                                    color: Color(0XFF0B1843).withOpacity(0.5),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          InkResponse(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            onTap: () {
                              _clickRandomEvent();
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/ai/aiVideo/new_ai_refersh_icon.png",
                                  width: 12.w,
                                  height: 12.w,
                                ),
                                SizedBox(
                                  width: 5.5.w,
                                ),
                                Text(
                                  "随机热门灵感",
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0XFF5B4BF7)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 50.w,
                          ),
                        ],
                      ),
                    )),
              ],
            )),

        ///2. 字数要求
        Padding(
          padding: EdgeInsets.only(bottom: 18.w, top: 18.w),
          child: Text(
            "2、字数要求",
            style: TextStyle(
                color: const Color(0XFF0B1843),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          width: 1.sw,
          height: 42.w,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...textNumberList.map((e) => InkResponse(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    onTap: () {
                      selectTextCountEvent(
                          index: e.index, maxCounts: e.maxCounts);
                    },
                    child: Container(
                      // width: 0.5.sw,
                      height: 20.w,
                      padding: EdgeInsets.only(
                        left: 21.w,
                        right: 21.w,
                      ),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: type == e.index
                                ? const Color(0XFF5B4BF7)
                                : Colors.transparent,
                            width: 1.5.w,
                          ),
                          borderRadius: BorderRadius.circular(12.w),
                          color: type == e.index
                              ? const Color(0XFFEAEEFF)
                              : const Color(0XFFF4F6FA)),
                      child: Text(
                        e.hintText,
                        style: TextStyle(
                            color: type == e.index
                                ? const Color(0Xff5B4BF7)
                                : const Color(0XFF0B1843),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ))
            ],
          ),
        ),
        const Spacer(),

        ///3.立即创作按钮
        _startCreateBtn(),
      ],
    );
  }

  ///文案创作中，请耐心等待
  Widget _progressView() {
    final maxW = ByScreenUtils.screenWidth - 24.w;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 120.h),
        Image.asset(
          "assets/common/loading_large.gif",
          width: 120.w,
          height: 124.h,
        ),
        SizedBox(height: 25.h),
        ByWidgetsUtil.commonText(
          text: "文案创作中，请耐心等待。",
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
        ),
        SizedBox(height: 120.h),
      ],
    );
  }

  ///AI创作文案完成结果
  Widget _resultView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 138.w,
            ),
            Text(
              "AI创作文案",
              style: TextStyle(
                  color: const Color(0XFF0B1843),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            InkResponse(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              onTap: () {
                Get.back();
              },
              child: Container(
                width: 40.w,
                height: 40.w,
                // color: Colors.red,
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/ai/oralVideos/ai_oral_icon_close.png",
                  width: 15,
                  height: 15,
                  fit: BoxFit.fitHeight,
                ),
              ),
            )
          ],
        ),

        SizedBox(height: 10.w,),

        ///1.文案主题输入框
        Container(
            decoration: BoxDecoration(
                color: const Color(0XFFEAEEFF),
                border: Border.all(
                  color: const Color(0XFFEAEEFF),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12.w)),
            padding: EdgeInsets.only(
                top: 0.w, left: 12.w, right: 12.w, bottom: 10.w),
            child: Stack(
              children: [
                Container(
                  height:0.4.sh,
                  margin: EdgeInsets.only(bottom: 30.h),
                  child:ListView(
                    physics:textEditingController2.text.length<220? const NeverScrollableScrollPhysics():null,
                    children: [
                      ExtendedTextField(
                        style: TextStyle(
                          color: const Color(0XFF0B1843),
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                        ),
                        maxLines: 100,
                        minLines: 1,
                        expands: false,
                        controller: textEditingController2,
                        autofocus: false,
                        onChanged: (String value) {},
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.normal,
                              color: ByColorUtil.CommonTextColor,
                            ),
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.normal,
                              color: ByColorUtil.CommonTextColor.withOpacity(0.3),
                            ),
                            // enabled:isGetAIResult? false:true,
                            enabled: false,

                        ),
                        cursorColor: ByColorUtil.CommonTextColor,
                      ),
                    ],
                  )
                ),

                ///生成提示区域
                if (isGetAIResult && textEditingController2.text.isEmpty)
                  Positioned(
                    top: 20.w,
                    left: 150.w,
                    child: ByWidgetsUtil.activityIndicator(radius: 13.w),
                  ),

                ///底部区域
                Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: 1.sw,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _starCreateEvent();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: const Color(0XFFF0F2F9),
                                  borderRadius: BorderRadius.circular(12.w)),
                              padding: EdgeInsets.only(top:6.w,bottom: 6.w,left:8.w,right: 8.w  ),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/v2/home/recreate_icon.png",
                                    width: 12.w,
                                    height: 12.w,
                                  ),
                                  SizedBox(width: 2.w,),
                                  Text(
                                    "重新生成",
                                    style: TextStyle(
                                        color: const Color(0XFF0B1843)
                                            .withOpacity(0.5),
                                        fontSize: 12.sp),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "$textSubjectCounts2/${widget.maxCount}",
                            style: TextStyle(
                              color: const Color(0XFF0B1843).withOpacity(0.5),
                              fontSize: 12.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              clearTextEvent2();
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 5.w,
                                ),
                                Text(
                                  "清空",
                                  style: TextStyle(
                                    color: const Color(0XFF0B1843)
                                        .withOpacity(0.5),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 55.w,
                          ),
                        ],
                      ),
                    )),
              ],
            )),
        const Spacer(),

        ///2.使用文案按钮
        InkResponse(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              _useTextEvent();
            },
            child: Container(
              width: 1.sw,
              decoration: BoxDecoration(
                color: const Color(0XFF5B4BF7),
                borderRadius: BorderRadius.circular(12.w),
              ),
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.only(
                top: 17.5.w,
                bottom: 17.5.w,
              ),
              alignment: Alignment.center,
              child: Text(
                "使用文案",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ))
      ],
    );
  }

  ///开始创作点击事件
  void _starCreateEvent() {
    ///检查参数
    if(isGetRandom){
      BotToast.showText(text: "正在生成随机灵感~");
      return;
    }
    if(isGetAIResult){
      BotToast.showText(text: "正在生成AI创作文案~");
      return;
    }
    if (textEditingController.text.trim().isEmpty) {
      BotToast.showText(text: "文案主题不能为空~");
      return;
    }
    setState(() {
      currentType = 2;
    });
    Future.delayed(const Duration(seconds: 3)).then((value) async {
      ///如果正在随机热门灵感 不可点击
      currentType = 3;
      if (isGetAIResult) {
        Get.log("如果正在生成文案 不可点击");
        return;
      }
      isGetAIResult = true;
      textEditingController2.text = "";
      if (mounted) {
        setState(() {});
      }
      messageSubscription2?.cancel();
      final stream = await getStream(
          url: BuildConfig.instance.environment.domain + APIs.randomPrompt,
          body: {
            "type": 1,
            "word_num": maxCount,
            "prompt": textEditingController.text
          });
      messageSubscription2 = stream.listen((data) {
        Get.log("获取AI创作文案结果===>$data");
        textEditingController2.text += data;
        isGetAIResult = true;
      }, onDone: () {
        isGetAIResult = false;
        if (mounted) {
          setState(() {});
        }
        messageSubscription2?.cancel();
      }, onError: (error) {
        if (error is APIError) {
          BotToast.showText(text: error.message);
          messageSubscription2?.cancel();
        }
      });
    });
  }

  ///使用文案点击事件
  void _useTextEvent(){
    if(isGetAIResult){
      BotToast.showText(text: "正在生成AI创作文案中~");
      return;
    }
    if(textEditingController2.text.isEmpty){
      BotToast.showText(text: "AI创作文案不能为空~,请重新生成");
      return;
    }
    Get.back(result: {
      "ai_result":textEditingController2.text
    });
  }

  @override
  Widget build(BuildContext context) {
    return _aiCreateTextDialog();
  }
}

class TextNumberModel {
  final int maxCounts;
  final String hintText;
  final int index;
  TextNumberModel({
    required this.maxCounts,
    required this.hintText,
    required this.index,
  });
}
