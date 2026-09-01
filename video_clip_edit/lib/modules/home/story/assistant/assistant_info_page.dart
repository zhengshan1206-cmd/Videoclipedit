import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/modules/home/providers/stroy_create_provider.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/assistant_page_info_bean.dart';
import 'package:video_clip_edit/modules/home/story/assistant/beans/creator_bean.dart';
import 'package:video_clip_edit/modules/home/story/assistant/widgets/assistant_info_widget.dart';
import 'package:video_clip_edit/modules/home/story/create/create_details_page.dart';
import 'package:video_clip_edit/modules/purchase/widgets/dailog_bonus_lowest_price.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_extension.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/v2/aiVideo/provider/ai_square_provider.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';
import 'package:video_clip_edit/widgets/common/integral_vip_view.dart';

///AI文案-对应的写文案页面
class AssistantInfoPage extends StatefulWidget {
  const AssistantInfoPage({
    super.key,
    required this.bean,
  });

  final CreatorBean bean;

  @override
  State<AssistantInfoPage> createState() => _AssistantInfoPageState();
}

class _AssistantInfoPageState extends State<AssistantInfoPage> {
  @override
  void initState() {
    super.initState();

    _resetValues();

    /// 加载页面配置
    _loadPageConifg();
  }

  @override
  Widget build(BuildContext context) {
    final pageInfoBean =
        context.select<StroyCreateProvider, AssitantPageInfoBean?>(
            (p) => p.pageInfoBean);
    final title = widget.bean.title;
    return Scaffold(
      appBar: ByWidgetsUtil.appBar(
          context: context,
          title: title.isEmpty ? (pageInfoBean?.templateName ?? "") : title),
      backgroundColor: ByColorUtil.WhiteColor,
      body: pageInfoBean == null
          ? Center(
              child: CupertinoActivityIndicator(
                color: ByColorUtil.CommonTextColor,
                radius: 12.w,
              ),
            )
          : ListView(
              children: [
                Container(
                  height: 5.h,
                  color: const Color(0xFFF5F8F9),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 20.h),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/mine/icon_info.png",
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 5.w),
                      ByWidgetsUtil.commonRichText(
                        fontSize: 12.sp,
                        texts: [
                          const TextSpan(text: "不知道该怎么写？试试这个"),
                          TextSpan(
                            text: pageInfoBean.templateName,
                            style: const TextStyle(
                                color: ByColorUtil.TabTextColorSelected),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                ByNavigatorUtil.checkLogin(
                                    context: context,
                                    nextStepEvent: () {
                                      byDebugPrint("随机填写");
                                      final List<String> template =
                                          pageInfoBean.template;
                                      context
                                          .read<StroyCreateProvider>()
                                          .updateTemplate(template);
                                      setState(() {});
                                    });
                                
                              },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ..._buildContents(pageInfoBean, context),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.only(left: 12.w, right: 4.w),
                  child: _buildIntegralVipView(),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  height: 45.h,
                  child: ByWidgetsUtil.commonBtn(
                    title: "立即创作",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    borderRadius: 12.w,
                    onClick: () {
                      final provider = context.read<StroyCreateProvider>();

                      final purchaseProvider = context.read<PurchaseProvider>();
                      if (purchaseProvider.preLoginCheck(context) == false) {
                        return;
                      }

                      String? canContinue = provider.pageInfoBean?.validate();
                      if (canContinue != null) {
                        BotToast.showText(text: canContinue);
                        return;
                      }

                      ///鉴黄
                      // provider.pageInfoBean?.items.forEach((e){
                      //   if(e.type==ItemType.text){
                      //     Get.log("text===> ${e.value}  ");
                      //   }
                      // });
                      //
                      // return;

                      // Map<String,dynamic> dataMap = pageInfoBean.editInfo();
                      // if(dataMap.isNotEmpty){
                      //   Get.log("用户自定义修改的文案===> ${pageInfoBean.editInfo()}");
                      //   Get.log("需要鉴黄的文案===> ${dataMap.values.first}");
                      // }
                      //
                      // return;

                      // provider.textRisk(content: content);

                      provider.creatorMessage(
                        creatorID: widget.bean.id,
                        values: pageInfoBean.editInfo(),
                        onSuccess: (infoBean) {
                          // bool needMoney = infoBean.isMoney == 1;
                          if (infoBean.isMoney == 1) {
                            context.read<PurchaseProvider>().loadVIPItems(
                              onSuccess: () {
                                // showDialog(
                                //   context: context,
                                //   builder: (context) {
                                //     return const DailogBonusLowestPrice();
                                //   },
                                // );
                                final provider =
                                    context.read<AiSquareProvider>();
                                String mark = 'ai_writing';
                                provider.showModelPayDialog(context, mark);
                              },
                            );

                            return;
                          }
                          //积分购买
                          if (infoBean.isMoney == 0 &&
                              infoBean.needIntegral == 1) {
                            final integralVipController =
                                IntegralVipController.getOrPut();
                            integralVipController.showIntegralPayDialog();
                            return;
                          }
                          provider.pid = infoBean.token;
                          provider.questionInfoBean = infoBean;
                          final providerS = context.read<StroyCreateProvider>();
                          ByNavRouterUtils.push(
                            context,
                            ChangeNotifierProvider.value(
                              value: providerS,
                              child: CreateDetailsPage(
                                showBottomFunctions: false,
                                isCreator: false,
                                fromAi: true,
                                provider: providerS,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.h + context.byBottomSafeHeight),
              ],
            ),
    );
  }

  void _loadPageConifg() {
    context
        .read<StroyCreateProvider>()
        .loadPageConfig(creatorID: widget.bean.id);
  }

  _buildContents(AssitantPageInfoBean bean, BuildContext context) {
    List<Widget> res = [];
    for (var e in bean.items) {
      res.add(AssistantInfoWidget(item: e));
    }
    return res;
  }

  void _resetValues() {
    /// 重置默认值
    context.read<StroyCreateProvider>().pageInfoBean = null;
  }

  // 积分-vip-次数-消耗模块-ai文案
  Widget _buildIntegralVipView() {
    return const IntegralVipView(
      requiredPoints: 0,
      type: "txt_creators", // 通过这个type请求权益接口获取实际积分
    );
  }
}
