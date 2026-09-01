import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';

class DailogBonusNew extends StatelessWidget {


  final String imageNetworkUrl;
  const DailogBonusNew({
    super.key,
    // required this.value,
    this.imageNetworkUrl = "",
  });

  // final String value;

  Widget _netWorkImage({required String imageUrl,required BuildContext context}){
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: (){
              ByNavRouterUtils.goBack(context);
              context
                  .read<LaunchProvider>()
                  .gotoPay(context, closePay: true);
            },
            child:  CachedNetworkImage(imageUrl: imageUrl,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              width: 320.w,
              height: 400.h,
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/purchase/dailog_bonus_close.png",
                width: 32,
                height: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if(imageNetworkUrl!=""){
      return _netWorkImage(imageUrl: imageNetworkUrl,context: context);
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 320.w,
                height: 400.h,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage("assets/purchase/dailog_bonus_bg_new.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                bottom: 25.h,
                right: 30.w,
                left: 30.w,
                height: 60.h,
                child: ScaleTransitionWidget(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ByNavRouterUtils.goBack(context);
                      context
                          .read<LaunchProvider>()
                          .gotoPay(context, closePay: true);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.w),
                      child: ByWidgetsUtil.gradientBgContainer(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFAECC7),
                            Color(0xFFFFE49B),
                          ],
                          begin: Alignment.centerLeft,
                          //渐变结束于下面的中间
                          end: Alignment.centerRight,
                        ),
                        child: Center(
                          child: ByWidgetsUtil.commonText(
                            text: "立即解锁",
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            textColor: const Color(0xFFFF2F5F),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              ByNavRouterUtils.goBack(context);
            },
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/purchase/dailog_bonus_close.png",
                width: 32,
                height: 32,
              ),
            ),
          )
        ],
      ),
    );
  }
}
