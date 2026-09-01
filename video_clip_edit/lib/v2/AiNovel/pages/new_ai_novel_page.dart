import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_color_utils.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiSquare/novelwriting/beans/ai_novel_singelchoice_bean.dart';
import 'package:video_clip_edit/widgets/common/right_navigation_bar.dart';
import '../../../modules/tool_box/videoExtraction/guide_page.dart';
import '../../../modules/tool_box/videoExtraction/providers/video_extraction_provider.dart';
import '../../../utils/comon/by_nav_router_utils.dart';
import '../../aiSquare/song/beans/rights_by_type.dart';
import '../providers/ai_novel_management_provider.dart';
import '../providers/ai_novel_provider.dart';
import 'ai_novel_management_page.dart';

class NewAiNovelPage extends StatefulWidget {
  const NewAiNovelPage({super.key});

  @override
  State<NewAiNovelPage> createState() => _NewAiNovelPageState();
}

class _NewAiNovelPageState extends State<NewAiNovelPage> {
  late AiNovelProvider provider;
  @override
  void initState() {
    super.initState();
    provider = context.read<AiNovelProvider>();
    provider.loadConfig();
    // provider.loadDefaultPrompt();
    updateRights();
  }

  RightsByType? _rights;
  void updateRights() {
    provider.loadRights(onSuccess: (rights) {
      if (mounted) {
        setState(() {
          _rights = rights;
        });
      }
    });
  }

  void submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    // final isVip = context.read<LaunchProvider>().launchInfo?.isVip ?? 0;
    // if (isVip != 1) {
    //   ByNavRouterUtils.push(
    //     context,
    //     ChangeNotifierProvider(
    //       create: (BuildContext context) =>
    //           AiVipGuidProvider(),
    //       child: const AiVipGuidPage(),
    //     ),
    //   );
    //   return;
    // }
    provider.generate(
      title: provider.titleCreateEditingController.text.trim(),
      prompt: provider.contentCreateEditingController.text.trim(),
      onSuccess: () {
        updateRights();
        ByNavRouterUtils.pushReplacement(
            context,
            MultiProvider(
              providers: [
                ChangeNotifierProvider(
                    create: (context) => AiNovelManagementProvider()),
              ],
              child: const AiNovelManagementPage(),
            ));
      },
    );
  }

  void showRecords() {
    ByNavRouterUtils.push(
        context,
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
                create: (context) => AiNovelManagementProvider()),
          ],
          child: const AiNovelManagementPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    provider = context.watch<AiNovelProvider>();
    return Scaffold(
      appBar: _buildAppBarWidget(),
      body: Column(
        children: [
          Expanded(child: _buildContentCreateWidget()),
          buildBottomBar(),
        ],
      ),
    );
  }

  ///内容创作
  _buildContentCreateWidget() {
    return ListView(
        padding: EdgeInsets.only(left: 12.5.w, right: 12.5.w, top: 14.h),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                Image.asset(
                  "assets/ai/aichuangzuo_nrcz.png",
                  width: 18.w,
                  height: 18.h,
                ),
                Text(
                  "  内容创作",
                  style: TextStyle(
                      color: ByColorUtils.hexColor('#0B1843'),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => provider.loadDefaultPrompt(),
              child: Row(
                children: [
                  Image.asset(
                    "assets/ai/aichuangzuo_sjcz.png",
                    width: 18.w,
                    height: 18.h,
                  ),
                  Text(
                    "  随机AI生成",
                    style: TextStyle(
                      color: ByColorUtils.hexColor('#5B4BF7'),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
          ]),
          _buildInputBodyWidget(),
          for (var item in provider.choiceConfig)
            Container(
              margin: EdgeInsets.only(top: 20.h),
              child: OptionChoiceWidget(
                provider: provider,
                title: item.$1,
                choices: item.$2,
                chooseMinNum: item.$3,
                chooseMaxNum: item.$4,
                onChanged: () => provider.updateChoice(item.$1, item.$2),
              ),
            ),
        ]);
  }

  Container _buildInputBodyWidget() {
    return Container(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        // border: Border.all(width: 1.0, color: ByColorUtil.TabTextColorSelected),
        color: ByColorUtils.hexColor('#F5F8F9'),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Column(
                children: [
                  TextField(
                      controller: provider.titleCreateEditingController,
                      decoration: InputDecoration(
                        hintText: "请输小说名字",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 16.sp,
                          color: ByColorUtils.hexColor('#A2A5B0'),
                        ),
                      )),
                ],
              )),
            ],
          ),
          Container(
            color: const Color(0xFF0B1843).withOpacity(0.3),
            height: 0.5.sp,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  minLines: 8,
                  maxLines: 16,
                  maxLength: 300,
                  controller: provider.contentCreateEditingController,
                  decoration: InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                    hintText: """题材：军事；
风格：科幻言情；
男主人设：骚气；
女主人设：疯批美人实则中二萌妹；
情节：逆天改命、穿书成反派后自救；
时空背景：二战太平洋孤岛；
视角：第三人称；
篇幅：中长篇；""",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: ByColorUtils.hexColor('#C8CAD1'),
                    ),
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ListenableBuilder(
                      listenable: provider.contentCreateEditingController,
                      builder: (context, _) => Text(
                            "${provider.contentCreateEditingController.text.length}/300",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: ByColorUtils.hexColor('#C8CAD1'),
                            ),
                          )),
                  const Spacer(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          ClipboardData? data =
                              await Clipboard.getData('text/plain');
                          var text =
                              "${provider.contentCreateEditingController.text}${data?.text ?? ""}";
                          if (text.length > 300) {
                            text = text.substring(0, 300);
                          }
                          provider.contentCreateEditingController.text = text;
                        },
                        child: Text('粘贴',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: ByColorUtils.hexColor('#C8CAD1'))),
                      ),
                      Text(' | ',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: ByColorUtils.hexColor('#C8CAD1'))),
                      GestureDetector(
                        onTap: () {
                          provider.contentCreateEditingController.clear();
                          provider.contentCreateEditingController.clear();
                          provider.notifyListeners();
                        },
                        child: Text('清空  ',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: ByColorUtils.hexColor('#C8CAD1'))),
                      ),
                    ],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  _buildAppBarWidget() {
    return PreferredSize(
      preferredSize: Size(double.infinity, ByScreenUtils.navigationBarHeight),
      child: Container(
        height: ByScreenUtils.navigationBarHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage("assets/ai/ai_app_bar_bg.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 30.w,
              height: 30.h,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/home/icon_back.png",
                width: 16.w,
                height: 16.h,
              ),
            ),
          ),
          title: Image.asset(
            height: 19.h,
            fit: BoxFit.fitHeight,
            "assets/ai/xiaoshuochuangzuotitle.png",
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          actions: const [
            Center(
            )
          ],
        ),
      ),
    );
  }

  Widget buildBottomBar() {
    final showFreeCount = _rights != null &&
        ((_rights!.currentIntegral == 0) || ((_rights!.freeCount > 0)));
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      color: Colors.white,
      child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: showRecords,
                      style: FilledButton.styleFrom(
                        foregroundColor: const Color(0xFF5B4BF7),
                        backgroundColor: const Color(0xFFEAEEFF),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "创作记录",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 9.sp),
                  Expanded(
                      child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: submit,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF5B4BF7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "生成小说",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (showFreeCount)
                        Positioned(
                            top: -12,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 11.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF2A70),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "限免x${_rights!.freeCount}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                    ],
                  ))
                ],
              ),
              if (_rights != null && !showFreeCount)
                Builder(builder: (context) {
                  var costIntegral = _rights!.currentIntegral.toDouble();
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/ai/aiVideo/coin@2x.png", scale: 2),
                        SizedBox(width: 4.w),
                        Text(
                          _rights!.userIntegral.toString(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Flexible(
                          child: Text(
                            "本次消耗${costIntegral.floor()}积分",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF0B1843).withOpacity(0.5),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                })
            ],
          )),
    );
  }
}

class OptionChoiceWidget extends StatefulWidget {
  const OptionChoiceWidget({
    super.key,
    required this.provider,
    required this.title,
    required this.choices,
    required this.chooseMinNum,
    required this.chooseMaxNum,
    required this.onChanged,
  });

  final AiNovelProvider provider;
  final String title;
  final List<AiNovelSingelchoiceBean> choices;
  final int chooseMinNum;
  final int chooseMaxNum;
  final VoidCallback onChanged;

  @override
  State<OptionChoiceWidget> createState() => _OptionChoiceWidgetState();
}

class _OptionChoiceWidgetState extends State<OptionChoiceWidget> {
  var showAllOptions = false;

  @override
  Widget build(BuildContext context) {
    final isMultiChoice = widget.chooseMaxNum > 1;
    var showChoices = widget.choices;
    var hasMoreChoices = widget.choices.length > 7;
    if (hasMoreChoices && !showAllOptions) {
      showChoices = widget.choices.sublist(0, 6);
    }

    return Column(
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: TextStyle(
                  color: ByColorUtils.hexColor('#0B1843'),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              isMultiChoice ? "(多选)" : "(单选)",
              style: TextStyle(
                color: ByColorUtils.hexColor('#0B1843'),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 9.5.h),
        GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: showChoices.length + (hasMoreChoices ? 1 : 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 9,
                childAspectRatio: 80 / 36),
            itemBuilder: (_, position) {
              if (position == showChoices.length) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      showAllOptions = !showAllOptions;
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.h, vertical: 4.w),
                    decoration: BoxDecoration(
                      color: ByColorUtils.hexColor('#F8FAFB'),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      showAllOptions ? "收起" : "更多",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                );
              }

              AiNovelSingelchoiceBean item = showChoices[position];
              return GestureDetector(
                onTap: () {
                  if (isMultiChoice) {
                    if (!item.isSelect) {
                      if (item.txt == "随机") {
                        for (var choice in widget.choices) {
                          choice.isSelect = false;
                        }
                      }

                      /// 不能超过最大允许数量
                      else if (widget.choices
                              .where((element) => element.isSelect)
                              .length >=
                          widget.chooseMaxNum) {
                        BotToast.showText(
                            text:
                                "${widget.title}允许最多选择${widget.chooseMaxNum}项");
                        return;
                      }
                    }
                    item.isSelect = !item.isSelect;
                    if (item.txt != "随机") {
                      for (var choice in widget.choices) {
                        if (choice.txt == "随机") {
                          choice.isSelect = false;
                        }
                      }
                    }
                  } else {
                    if (item.isSelect) {
                      item.isSelect = false;
                    } else {
                      for (final choice in widget.choices) {
                        choice.isSelect = false;
                      }
                      item.isSelect = true;
                    }
                  }
                  widget.provider.notifyListeners();
                  widget.onChanged();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.h, vertical: 4.w),
                  decoration: BoxDecoration(
                    color: item.isSelect
                        ? ByColorUtils.hexColor('#5B4BF7')
                        : ByColorUtils.hexColor('#F8FAFB'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.txt,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: item.isSelect ? FontWeight.bold : null,
                      color: item.isSelect ? Colors.white : Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            })
      ],
    );
  }
}
