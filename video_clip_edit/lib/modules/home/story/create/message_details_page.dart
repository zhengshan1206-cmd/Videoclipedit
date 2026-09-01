import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/create/beans/ai_create_bean.dart';
import 'package:video_clip_edit/modules/home/story/create/create_details_page.dart';
import 'package:video_clip_edit/modules/home/story/create/widgets/edit_dailog.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class MessageDetailsPage extends StatefulWidget {
  final AiCreateBean bean;

  const MessageDetailsPage({
    super.key,
    required this.bean,
  });

  @override
  State<MessageDetailsPage> createState() => _MessageDetailsPageState();
}

class _MessageDetailsPageState extends State<MessageDetailsPage> {
  AiCreateBean? aiCreateBean;

  bool isAbbreviation = false;

  @override
  void initState() {
    super.initState();

    _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(context: context, title: "创作详情"),
      backgroundColor: ByColorUtil.WhiteColor,
      body: Column(
        children: [
          Container(
            height: 5.h,
            color: const Color(0xFFF5F8F9),
          ),
          _buildListView(context),

          _buildFunctionBtns(context),

          /// 复制按钮
          _buildCopyBtn(context),
        ],
      ),
    );
  }

  Expanded _buildListView(BuildContext context) {
    return Expanded(
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            /// 创作标题
            _buildTitle(context),

            /// AI生成的创作内容
            _buildAIContents(context),
          ],
        ),
      ),
    );
  }

  /// 创作标题
  Padding _buildTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 10.h,
      ),
      child: ByWidgetsUtil.commonContainer(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 13.h,
        ),
        bgColor: const Color(0xFF2E54FF).withOpacity(0.1),
        child: ByWidgetsUtil.commonText(
          text: aiCreateBean?.ask ?? "",
          textColor: ByColorUtil.TabTextColorSelected,
          fontSize: 14.sp,
          maxLines: 1000,
        ),
      ),
    );
  }

  /// AI生成的创作内容
  _buildAIContents(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
      ),
      child: ByWidgetsUtil.commonContainer(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 13.h,
        ),
        bgColor: const Color(0xFFF5F8F9),
        child: ByWidgetsUtil.commonRichText(
          texts: [
            TextSpan(text: aiCreateBean?.answer ?? ""),
          ],
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 14.sp,
          // maxLines: 1000,
        ),
      ),
    );
  }

  /// 复制按钮
  _buildCopyBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: 10.h + ByScreenUtils.bottomSafeHeight,
      ),
      child: SizedBox(
        height: 50.h,
        child: ByWidgetsUtil.commonBtn(
          title: isAbbreviation ? "开始读写" : "复制",
          borderRadius: 12.w,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          onClick: () {
            if (isAbbreviation) {
              /// 直接缩写
              _startAbbreviation(context);
              return;
            }
            updateAbbreviation(false);

            if (widget.bean.answer.isNotEmpty) {
              Clipboard.setData(
                ClipboardData(text: widget.bean.answer),
              );
              BotToast.showText(text: "复制成功");
            } else {
              BotToast.showText(text: "暂无创作内容");
            }
          },
        ),
      ),
    );
  }

  /// 处理屏幕滚动
  bool _handleScrollNotification(ScrollNotification notification) {
    StroyCreateProvider provider = context.read<StroyCreateProvider>();
    if (notification is ScrollStartNotification) {
      // 用户开始滑动
      provider.updateScrollByUser(true);
    } else if (notification is ScrollEndNotification) {
      // 用户停止滑动
      provider.updateScrollByUser(false);
    }
    return true;
  }

  _buildFunctionBtns(BuildContext context) {
    final icons = [
      "assets/home/icon_continue.png",
      "assets/home/icon_modify.png",
      "assets/home/icon_expand.png",
      "assets/home/icon_shrink.png"
    ];
    final titles = ["续写", "改写", "扩写", "缩写"];
    EditDailogType getType(String title) {
      return {
        "续写": EditDailogType.continuation,
        "改写": EditDailogType.modify,
        "扩写": EditDailogType.extension,
        "缩写": EditDailogType.abbreviation,
      }[title] as EditDailogType;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
        vertical: 15.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: icons.map((e) {
          final idx = icons.indexOf(e);
          final type = getType(titles[idx]);
          Color color = const Color(0xFF2E54FF).withOpacity(0.1);
          Color textColor = ByColorUtil.TabTextColorSelected;
          BoxDecoration? boxDecoration;
          if (type == EditDailogType.abbreviation && isAbbreviation) {
            // color = Colors.green;
            color = Colors.white;
            textColor = const Color(0xff5B4BF7);
            boxDecoration = BoxDecoration(
              borderRadius: BorderRadius.circular(8.w),
              color: color,
              border: Border.all(color: textColor, width: 0.5),
            );
          }
          return SizedBox(
            height: 36.h,
            child: ByWidgetsUtil.btnWithIcon(
              title: titles[idx],
              iconPath: e,
              bgColor: color,
              fontSize: 14.sp,
              textColor: textColor,
              boxDecoration: boxDecoration,
              padding: EdgeInsets.only(
                left: 10.w,
                right: 18.w,
                top: 9.h,
                bottom: 9.h,
              ),
              onClick: () {
                debugPrint("点击了:$idx");
                final type = getType(titles[idx]);
                if (type == EditDailogType.abbreviation) {
                  /// 直接缩写
                  updateAbbreviation(!isAbbreviation);
                  return;
                }

                updateAbbreviation(false);

                /// 弹出编辑框
                showDialog(
                  context: context,
                  useSafeArea: false,
                  builder: (ctx) => ChangeNotifierProvider.value(
                    value: context.read<StroyCreateProvider>(),
                    child: EditDialog(
                      type: type,
                      bean: widget.bean,
                      isMany: true,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 开始缩写
  void _startAbbreviation(BuildContext context) {
    final provider = context.read<StroyCreateProvider>();
    provider.loadMessageID(
      ask: "",
      configId: "",
      parentId: widget.bean.token,
      opt: EditDailogType.abbreviation.typeKey,
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
        ByNavRouterUtils.pushReplacement(
          context,
          ChangeNotifierProvider.value(
            value: context.read<StroyCreateProvider>(),
            child: const CreateDetailsPage(
              showBottomFunctions: false,
              isMany: true,
              fromAi: false,
            ),
          ),
        );
      },
    );
  }

  void _loadDetails() {
    context.read<StroyCreateProvider>().loadMessageDetails(
          msgID: widget.bean.token,
          onSuccess: (data) {
            final beanData = data["data"];
            AiCreateBean bean = AiCreateBean.fromJson(beanData);
            debugPrint("-----${bean.answer}");
            setState(() {
              aiCreateBean = bean;
            });
          },
        );
  }

  void updateAbbreviation(bool value) {
    if (mounted) {
      setState(() {
        isAbbreviation = value;
      });
    }
  }
}
