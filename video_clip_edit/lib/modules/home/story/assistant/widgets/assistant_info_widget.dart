import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/assistant_page_info_bean.dart';

class AssistantInfoWidget extends StatefulWidget {
  const AssistantInfoWidget({
    super.key,
    required this.item,
    // required this.template,
  });

  final Item item;
  // final String? template;

  @override
  State<AssistantInfoWidget> createState() => _AssistantInfoWidgetState();
}

class _AssistantInfoWidgetState extends State<AssistantInfoWidget> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key(widget.item.id),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        _buildContent(context),
      ],
    );
  }

  /// 标题
  _buildSectionHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          color: ByColorUtil.WhiteColor,
          padding: EdgeInsets.only(
            left: 12.w,
            right: 5.w,
            top: 15.h,
            bottom: 10.h,
          ),
          child: ByWidgetsUtil.commonText(
            text: widget.item.title,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Offstage(
          offstage: widget.item.isRequisite != 1,
          child: Padding(
            padding: EdgeInsets.only(
              top: 10.h,
            ),
            child: ByWidgetsUtil.commonText(
                text: "*", textColor: ByColorUtil.HomeHotAuthNumberColor),
          ),
        )
      ],
    );
  }

  Container _buildInputArea(BuildContext context) {
    double height = ((widget.item.itemMaxSize ?? 10) > 50) ? 180.h : 59.h;
    if (widget.item.type == ItemType.number) height = 59.h;
    final value = widget.item.value;
    if (value != null && controller.text != value) {
      controller.text = value;
    }
    return Container(
      color: ByColorUtil.WhiteColor,
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        // top: 15.h,
        bottom: 10.h,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: Stack(
          children: [
            /// 背景色
            Container(
              color: const Color(0xFFF5F8F9),
              height: height,
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
    final Item item = widget.item;
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        child: TextFormField(
          maxLines: null,
          expands: false,
          controller: controller,
          keyboardType: item.type == ItemType.text
              ? TextInputType.text
              : TextInputType.number,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor,
            ),
            hintText: widget.item.itemDes,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: ByColorUtil.CommonTextColor.withOpacity(0.5),
            ),
          ),
          cursorColor: ByColorUtil.CommonTextColor,
          onChanged: (value) {
            // if (widget.item.type == ItemType.number) {
            //   controller.text = value;
            //   if (value.isNotEmpty && widget.item.itemMax != null) {
            //     if (int.parse(value) >= widget.item.itemMax!) {
            //       controller.text = widget.item.itemMax!.toString();
            //     }
            //   }
            // } else {
            //   controller.text = value;
            // }
            final provider = context.read<StroyCreateProvider>();
            final item = widget.item;
            final isNum = item.type == ItemType.number;
            final AssitantPageInfoBean pageInfoBean = provider.pageInfoBean!;
            final Item currentItem =
                pageInfoBean.items.firstWhere((e) => e.id == item.id);
            final text = controller.text;
            if (text.isEmpty) return;
            if (isNum) {
              final val = int.parse(text);
              if (val > item.itemMax!) {
                controller.text = text.substring(0, text.length);
              }
            } else {
              final len = text.length;
              if (len > item.itemMaxSize!) {
                controller.text = text.substring(0, text.length);
              }
            }

            currentItem.value = controller.text;
            provider.updateAssitantPageInfoBean(pageInfoBean);
          },
          // cursorHeight: 15.sp,
        ),
      ),
    );
  }

  /// 工具条
  Positioned _buildToolBar(BuildContext context) {
    if ((widget.item.itemMaxSize ?? 10) <= 50) {
      return Positioned(
        right: 0,
        child: GestureDetector(
          onTap: () {
            controller.clear();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 59.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: ByWidgetsUtil.commonText(
              text: "清空",
              fontSize: 12.sp,
              textColor: ByColorUtil.CommonTextColor.withOpacity(0.5),
            ),
          ),
        ),
      );
    }
    return Positioned(
      bottom: 6.h,
      child: SizedBox(
        width: ByScreenUtils.screenWidth - 24.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () async {
                ClipboardData? data = await Clipboard.getData('text/plain');
                controller.text = data?.text ?? "";
                final provider = context.read<StroyCreateProvider>();
                final AssitantPageInfoBean pageInfoBean =
                    provider.pageInfoBean!;
                final Item currentItem = pageInfoBean.items
                    .firstWhere((e) => e.id == widget.item.id);

                currentItem.value = controller.text;
                provider.updateAssitantPageInfoBean(pageInfoBean);
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
                controller.clear();
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
          ],
        ),
      ),
    );
  }

  _buildContent(
    BuildContext context,
  ) {
    switch (widget.item.type) {
      case ItemType.text:
        return _buildInputArea(context);
      case ItemType.number:
        return _buildInputArea(context);
      default:
        return _buildList(context);
    }
  }

  _buildList(BuildContext context) {
    final countItems = widget.item.items ?? [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      // height: 200.h,
      width: double.infinity,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 3 / 1.0),
        itemCount: countItems.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return MenuCountCell(item: widget.item, index: index);
        },
      ),
    );
  }
}

class MenuCountCell extends StatelessWidget {
  const MenuCountCell({
    super.key,
    required this.item,
    required this.index,
  });

  final Item item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StroyCreateProvider>();
    final AssitantPageInfoBean pageInfoBean = provider.pageInfoBean!;
    final Item currentItem =
        pageInfoBean.items.firstWhere((e) => e.id == item.id);
    final name = currentItem.items![index];
    final select = name == currentItem.selectedValue;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        currentItem.selectedValue = name;
        provider.updateAssitantPageInfoBean(pageInfoBean);
      },
      child: ByWidgetsUtil.commonContainer(
        // margin: EdgeInsets.only(right: 10.w),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 3.w),
        bgColor: select
            ? ByColorUtil.TabTextColorSelected
            : ByColorUtil.CommonPageBgColor, //const Color(0xFFF5F8F9)
        borerRadius: 8.w,
        child: ByWidgetsUtil.commonText(
          text: name,
          textColor: select ? ByColorUtil.WhiteColor : const Color(0xFF0D1A44),
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
