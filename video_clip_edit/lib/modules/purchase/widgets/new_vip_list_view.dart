import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/modules/purchase/widgets/vip_type_view_new.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';

class NewVipListView extends StatelessWidget {
  const NewVipListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vipTypeBeans = context.select<PurchaseProvider, List<VipTypeBean>>(
      (provider) => provider.vipTypeBeans,
    );
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final itemH = math.max(128.h, shortest * 0.38);
    // 阔折内屏等宽屏上 Grid 按 aspect 算出的单元高度易偏矮，与卡片内 Column 实际高度不一致会裁切「≈x元/天」
    final minCellH = 160.h;
    final cellH = math.max(itemH * 1.34, minCellH);
    final marginHor = 12.w;
    const itemCount = 3;
    final contentW = context.byScreenWidth - marginHor * 2;
    final itemW = (contentW - marginHor * (itemCount - 1)) / itemCount;

    Get.log("vipTypeBeans===> ${vipTypeBeans.length}");

    return vipTypeBeans.isEmpty
        ? Container()
        : GridView.builder(
            padding: EdgeInsets.zero,
            // scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            shrinkWrap: true,
            itemCount: vipTypeBeans.length,
            physics: vipTypeBeans.length > itemCount
                ? null
                : const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: marginHor,
              crossAxisSpacing: marginHor,
              childAspectRatio: itemW / cellH,
            ),
            itemBuilder: (context, index) {
              return VipTypeViewNew(
                vipTypeBean: vipTypeBeans[index],
                index: index,
                onSelected: (VipTypeBean bean) {
                  context
                      .read<PurchaseProvider>()
                      .changeSelectedVipTypeIndex(index);
                },
              );
            },
          );
  }
}
