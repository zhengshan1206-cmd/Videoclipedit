import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/modules/home/widgets/banner_view.dart';
import 'package:video_clip_edit/modules/home/widgets/sub_funcs_view.dart';
import 'package:video_clip_edit/v2/toolBox/providers/new_tool_box_provider.dart';

///工具箱页面
class ToolBoxBannerView extends StatefulWidget {
  const ToolBoxBannerView({
    super.key,
  });

  @override
  State<ToolBoxBannerView> createState() => _ToolBoxBannerViewState();
}

class _ToolBoxBannerViewState extends State<ToolBoxBannerView> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double offset = context.select<NewToolBoxProvider, double>(
      (value) => value.currentOffset,
    );
    if (offset > 210.h) {
      offset = 210.h;
    }
    byDebugPrint(offset, tag: "offset:");

    final bannerBeans = context.select<NewToolBoxProvider, List<SubFunction>>(
        (value) => value.bannerBeans);
    final urls = bannerBeans.map((e) => e.imgUrl).toList();
    return Positioned(
      left: 0,
      right: 0,
      top: -offset,
      child: Stack(
        children: [
          SizedBox(height: 200.h, width: double.infinity),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 200.h,
            child: BannerView(
              onTap: (index) {
                byDebugPrint("BannerView onTap $index");
                final banner = bannerBeans[index];
                ByCommonUtils.subFunctionCase(context, banner);
              },
              pagination: SwiperPagination(
                margin: EdgeInsets.zero,
                builder: SwiperCustomPagination(
                  builder: (BuildContext context, SwiperPluginConfig config) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(urls.length, (index) {
                          final isCurrent = index == config.activeIndex;
                          return Container(
                            width: isCurrent ? 14.w : 6.h,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: ByColorUtil.LoginBtnBgColor,
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
              fit: BoxFit.fill,
              urls: urls,
              //  const ["assets/newToolBox/tool_box_banner_1.png"]
            ),
          ),
          Positioned(
            bottom: 0.h,
            left: 0,
            right: 0,
            height: 40.h,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: ByColorUtil.lineareGradient(
                    colorStart: const Color(0xFFFFFFFF).withOpacity(0),
                    colorEnd: const Color(0xFFFFFFFF),
                    end: Alignment.bottomCenter,
                    begin: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              top: 50.w,
              left: 12.w,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (){
                  Get.back();
                },
                child: Image.asset("assets/newToolBox/arrow_back_ios.png",width: 32.w,height: 32.w,),
              ),
              SizedBox(width: 120.w,),
              Text("工具箱",style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),)
            ],
          )),
        ],
      ),
    );
  }
}
