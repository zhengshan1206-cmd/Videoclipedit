import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

class MaterialVideoRatioTabbar<T extends MaterialBaseProvider>
    extends StatelessWidget {
  const MaterialVideoRatioTabbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<T, Tuple2<List<String>, int>>(
        selector: (BuildContext ctx, T provider) =>
            Tuple2(provider.videoRatios, provider.selectedRatioIdx),
        builder: (_, Tuple2<List<String>, int> tupel, __) {
          final List<String> ratios = tupel.item1;
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ratios.map((e) {
                final index = tupel.item2;
                final currentIdx = ratios.indexOf(e);
                final selected = index == currentIdx;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.read<T>().changeSelectedRatioIdx(currentIdx);
                    },
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? ByColorUtil.TabTextColorSelected
                            : ByColorUtil.WhiteColor,
                      ),
                      child: ByWidgetsUtil.commonText(
                        text: e,
                        textColor: selected
                            ? ByColorUtil.WhiteColor
                            : ByColorUtil.CommonTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        });
  }
}
