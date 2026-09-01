import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/create/create_details_page.dart';

class StoryCreatePage extends StatefulWidget {
  const StoryCreatePage({super.key});

  @override
  State<StoryCreatePage> createState() => _StoryCreatePageState();
}

class _StoryCreatePageState extends State<StoryCreatePage> {
  @override
  void initState() {
    super.initState();
    context.read<StroyCreateProvider>().loadExamples();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Container(
          //   height: 5.h,
          //   color: const Color(0xFFF5F8F9),
          // ),

          /// 输入框
          _buildInputArea(context),

          /// 创作按钮
          _buildBtn(context),
          SizedBox(height: 35.h),

          /// 示例header
          _buildSectionTitle(context),

          /// 示例列表
          _buildExampleList(context),
        ],
      ),
    );
  }

  /// 示例header
  Padding _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Image.asset(
            "assets/home/icon_story_hot.png",
            width: 24.w,
            height: 24.h,
          ),
          SizedBox(width: 2.w),
          ByWidgetsUtil.commonText(
              text: "试试以下例子", fontSize: 16.sp, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  Container _buildInputArea(BuildContext context) {
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 15.h,
        bottom: 10.h,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            /// 背景色
            Container(
              color: const Color(0xFFF5F8F9),
              height: 180.h,
            ),

            /// 输入框
            _buildTextArea(context),

            /// 工具条
            _buildToolBar(context),
          ],
        ),
      ),
    );
  }

  /// 输入框
  Positioned _buildTextArea(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        child: TextField(
          maxLines: null,
          expands: false,
          controller:
              context.read<StroyCreateProvider>().wordsEditingController,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor,
            ),
            hintText: "请输入文字内容...",
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor.withOpacity(0.5),
            ),
          ),
          cursorColor: ByColorUtil.CommonTextColor,
          // cursorHeight: 15.sp,
        ),
      ),
    );
  }

  /// 工具条
  Positioned _buildToolBar(BuildContext context) {
    final provider = context.watch<StroyCreateProvider>();
    return Positioned(
      bottom: 6.h,
      child: SizedBox(
        width: ByScreenUtils.screenWidth - 24.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
                ClipboardData? data = await Clipboard.getData('text/plain');
                provider.updateWords(
                    provider.wordsEditingController.text + (data?.text ?? ""));
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: ByWidgetsUtil.commonText(
                  text: "粘贴",
                  fontSize: 12.sp,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),
              ),
            ),
            Container(
              height: 29.h,
              alignment: Alignment.center,
              child: ByWidgetsUtil.commonText(
                text: "|",
                fontSize: 12.sp,
              ),
            ),
            GestureDetector(
              onTap: () {
                provider.wordsEditingController.clear();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 29.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: ByWidgetsUtil.commonText(
                  text: "清空",
                  fontSize: 12.sp,
                  textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
                ),
              ),
            ),
            const Spacer(),
            Container(
              height: 29.h,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: ByWidgetsUtil.commonText(
                text:
                    "${context.select<StroyCreateProvider, int>((p) => p.wordsEditingController.text.length)}/2000",
                fontSize: 12.sp,
                textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 创作按钮
  _buildBtn(BuildContext context) {
    return Container(
      color: ByColorUtil.WhiteColor,
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: ByWidgetsUtil.commonBtn(
        title: "立即创作",
        borderRadius: 12.w,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        onClick: () {
          _startAICreate(context);
        },
      ),
    );
  }

  void _startAICreate(BuildContext context) {
    final provider = context.read<StroyCreateProvider>();

    provider.clearAiCreatContents();
    String? configId;
    for (var e in provider.exampleBeans) {
      if (e.des == provider.creatTitle) {
        configId = e.id.toString();
      }
    }
    provider.loadMessageID(
      ask: provider.creatTitle,
      configId: "$configId",
      onSuccess: (infoBean) {
        bool needMoney = infoBean.isMoney == 1;
        if (needMoney) {
          context.read<PurchaseProvider>().loadVIPItems(
            onSuccess: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const DailogBonusLowestPrice();
                },
              );
            },
          );
          return;
        }
        provider.pid = infoBean.token;
        ByNavRouterUtils.push(
          context,
          ChangeNotifierProvider.value(
            value: context.read<StroyCreateProvider>(),
            child: const CreateDetailsPage(
              fromAi: false,
            ),
          ),
        );
      },
    );
  }

  /// 示例列表
  Expanded _buildExampleList(BuildContext context) {
    return Expanded(
      child: Consumer<StroyCreateProvider>(builder: (
        BuildContext ctx,
        StroyCreateProvider provider,
        Widget? child,
      ) {
        final exampleBeans = provider.exampleBeans;
        return ListView.builder(
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            top: 2.h,
            bottom: 2.h + ByScreenUtils.bottomSafeHeight,
          ),
          itemCount: exampleBeans.length,
          itemBuilder: (ctx, index) {
            final bean = exampleBeans[index];
            final color =
                provider.exampleColors[index % provider.exampleColors.length];
            return GestureDetector(
              onTap: () {
                provider.updateWords(bean.des);
              },
              child: ByWidgetsUtil.commonContainer(
                margin: EdgeInsets.symmetric(vertical: 5.h),
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 15.h,
                ),
                bgColor: const Color(0xFFF5F8F9),
                child: ByWidgetsUtil.commonRichText(
                  texts: [
                    TextSpan(
                        text: "${bean.title}: ",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        )),
                    TextSpan(text: bean.des),
                  ],
                  fontWeight: FontWeight.normal,
                  fontSize: 14.sp,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
