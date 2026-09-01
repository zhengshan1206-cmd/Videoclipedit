import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/story/create/beans/ai_create_bean.dart';
import 'package:video_clip_edit/modules/home/story/create/create_details_page.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';

enum EditDailogType { continuation, modify, extension, abbreviation }

extension EditDailogTypeExt on EditDailogType {
  String get typeNme {
    switch (this) {
      case EditDailogType.continuation:
        return "续写";
      case EditDailogType.modify:
        return "改写";
      case EditDailogType.extension:
        return "扩写";
      case EditDailogType.abbreviation:
        return "缩写";
      default:
        return "";
    }
  }

  String get typeKey {
    switch (this) {
      case EditDailogType.continuation:
        return "proceed";
      case EditDailogType.modify:
        return "rewrite";
      case EditDailogType.extension:
        return "enlarge";
      case EditDailogType.abbreviation:
        return "refine";
      default:
        return "";
    }
  }

  String get tips {
    switch (this) {
      case EditDailogType.continuation:
        return "续写风格:";
      case EditDailogType.modify:
        return "改写风格:";
      case EditDailogType.extension:
        return "扩写长度";
      case EditDailogType.abbreviation:
        return "缩写";
      default:
        return "";
    }
  }
}

class EditDialog extends StatefulWidget {
  final EditDailogType type;
  final AiCreateBean? bean;
  final bool isMany;
  const EditDialog({
    super.key,
    required this.type,
    this.bean,
    this.isMany = false,
  });

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  final TextEditingController wordsEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              bottom: 14.h + ByScreenUtils.bottomSafeHeight,
              left: 11.w,
              right: 11.w,
            ),
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 13.h),
                _buildTitle(context),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    ByWidgetsUtil.commonText(
                      text: widget.type.tips,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildMenu(context),
                SizedBox(height: 67.h),
                SizedBox(
                  height: 50.h,
                  child: ByWidgetsUtil.commonBtn(
                    fontSize: 16.sp,
                    title: "开始${widget.type.typeNme}",
                    borderRadius: 12.w,
                    fontWeight: FontWeight.w600,
                    onClick: () {
                      _startAICreate(context);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 标题
  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 30.w),
        const Spacer(),
        ByWidgetsUtil.commonText(
          text: widget.type.typeNme,
          textColor: ByColorUtil.CommonTextColor,
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ByNavRouterUtils.goBack(context);
          },
          child: Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/login/login_dialog_close.png",
              width: 12,
              height: 12,
            ),
          ),
        ),
        // SizedBox(width: 11.w),
      ],
    );
  }

  /// 角色列表
  _buildMenu(BuildContext context) {
    final provider = context.watch<StroyCreateProvider>();
    const crossAxisCount = 4;
    final itemW =
        (MediaQuery.of(context).size.width - 10.w * (crossAxisCount - 1)) /
            crossAxisCount;
    final ratio = itemW / 36.h;
    byDebugPrint(itemW);
    return GridView.builder(
      itemCount: provider.menuItems.length,
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return MenuEditCell(name: provider.menuItems[index]);
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10.w,
        childAspectRatio: ratio,
      ),
    );
  }

  void _loadConfig() {
    final StroyCreateProvider provider = context.read<StroyCreateProvider>();

    if (widget.bean != null) {
      debugPrint("pid:${widget.bean!.token}");
      provider.pid = widget.bean!.token;
    }

    provider.loadRichMessageConfig(
      onSuccess: (menuData) {
        final menus = menuData[widget.type.typeKey] ?? [];
        provider.updateMenuItems(menus.cast<String>());
      },
    );
  }

  void _startAICreate(BuildContext context) {
    final provider = context.read<StroyCreateProvider>();
    provider.clearAiCreatContents();
    provider.loadMessageID(
      ask: "",
      configId: "",
      parentId: provider.pid,
      opt: widget.type.typeKey,
      optParam: provider.selectedItem,
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
        ByNavRouterUtils.goBack(context);

        ByNavRouterUtils.pushReplacement(
          context,
          ChangeNotifierProvider.value(
            value: context.read<StroyCreateProvider>(),
            child: CreateDetailsPage(
              showBottomFunctions: widget.isMany,
              isMany: widget.isMany,
              fromAi: false,
            ),
          ),
        );
      },
    );
  }
}

class MenuEditCell extends StatelessWidget {
  const MenuEditCell({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StroyCreateProvider>();
    final select = name == provider.selectedItem;
    return SizedBox(
      height: 36.h,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          provider.updateSelectedItem(name);
        },
        child: ByWidgetsUtil.commonContainer(
          alignment: Alignment.center,
          // padding: EdgeInsets.symmetric(horizontal: 27.w),
          bgColor: select
              ? const Color(0xFF2E54FF).withOpacity(0.1)
              : const Color(0xFFF5F8F9),
          borerRadius: 8.w,
          child: ByWidgetsUtil.commonText(
            text: name,
            textColor: select
                ? ByColorUtil.TabTextColorSelected
                : const Color(0xFF0D1A44),
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
