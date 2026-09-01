import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/core/util/fonts.dart';
import 'package:video_clip_edit/generated/assets.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/widgets/common_button.dart';
import 'package:video_clip_edit/utils/comon/by_datetime_ext.dart';

///权益类型
enum BenefitsType {
  unlockAllFunctions,
  shortDramaAIMixedCutting,
  hotSellingNovelTweets,
  folkStoryGeneration,
  aiDynamicVideo,
  drawingStyles,
  iconEnjoyExclusiveBenefits,
  vipCustomerServiceRunning;

  String get title {
    switch (this) {
      case unlockAllFunctions:
        return '解锁全部功能';
      case shortDramaAIMixedCutting:
        return '短剧AI混剪';
      case hotSellingNovelTweets:
        return '爆款小说推文';
      case folkStoryGeneration:
        return '民间故事生成';
      case aiDynamicVideo:
        return 'AI动态视频';
      case drawingStyles:
        return '30+绘图风格';
      case iconEnjoyExclusiveBenefits:
        return '满血Deepseek';
      case vipCustomerServiceRunning:
        // return '7*24小时客服';
        return '专属客服';
    }
  }

  String get image {
    switch (this) {
      case unlockAllFunctions:
        return Assets.mineIconUnlockAllFunctions;
      case shortDramaAIMixedCutting:
        return Assets.mineIconShortDramaAiMixedCutting;
      case hotSellingNovelTweets:
        return Assets.mineIconHotSellingNovelTweets;
      case folkStoryGeneration:
        return Assets.mineIconFolkStoryGeneration;
      case aiDynamicVideo:
        return Assets.mineIconAiDynamicVideo;
      case drawingStyles:
        return Assets.mineIconDrawingStyles;
      case iconEnjoyExclusiveBenefits:
        return Assets.mineIconEnjoyExclusiveBenefits;
      case vipCustomerServiceRunning:
        return Assets.mineIconVipCustomerServiceRunning;
    }
  }
}

class ProfileMemberCard extends StatelessWidget {
  const ProfileMemberCard({
    super.key,
    required this.subscribeAction,
    this.userInfo,
  });

  final UserInfoBean? userInfo;
  final VoidCallback subscribeAction;

  @override
  Widget build(BuildContext context) {
    var imageWidth = Get.width - 24.w;
    var imageHeight = imageWidth * 82 / 351;
    var marginTop = imageHeight * 12.5 / 82;
    final userController = Get.find<UserController>();
    return Obx(
      () => GestureDetector(
        onTap: subscribeAction,
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  userController.isShowSpringStyle.value
                      ? "assets/springFestival/springFestival-9.png"
                      : Assets.mineIconMemberVipBg,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  left: 92.w,
                  top: marginTop,
                  right: 10.w,
                  bottom: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (userInfo?.isVip ?? 0) == 0
                                ? Image.asset(
                                    userController.isShowSpringStyle.value
                                        ? Assets.mineIconAsLowAsVIP
                                              .replaceFirst(
                                                RegExp(r'\.png$'),
                                                '_1.png',
                                              )
                                        : Assets.mineIconAsLowAsVIP,
                                    width: 145.w,
                                    height: 22.h,
                                  )
                                : BYText.instance(
                                    "会员类型：${userInfo!.vipLevelName}",
                                    18.sp,
                                    color: ByColorUtil.colorFAE3C8,
                                    fontWeight: BYFontWeight.semiBold,
                                  ),
                            SizedBox(
                              height: (userInfo?.isVip ?? 0) == 0 ? 6.h : 8.h,
                            ),
                            Flexible(
                              child: BYText.instance(
                                (userInfo?.isVip ?? 0) == 0
                                    ? "立即体验AI创作超能力"
                                    // : "会员到期时间：${userInfo!.isPremiumMember() ? "永久" : '${userInfo!.vipEndTime?.formattedTime(format: "yyyy-MM-dd") ?? ""}'}",
                                    : userInfo!.isPremiumMember()
                                    ? "立即体验AI创作超能力"
                                    : '会员到期时间：${userInfo!.vipEndTime?.formattedTime(format: "yyyy-MM-dd") ?? ""}',
                                //
                                14.sp,
                                color: (userInfo?.isVip ?? 0) == 0
                                    ? ByColorUtil.colorFAE3C8
                                    : ByColorUtil.colorFAE3C8.withOpacity(0.8),
                                fontWeight: BYFontWeight.medium,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      (userInfo?.isVip ?? 0) == 0
                          ? userController.isShowSpringStyle.value
                                ? SizedBox(
                                    width: 85.w,
                                    height: 32.h,
                                    child: Image.asset(
                                      "assets/springFestival/springFestival-7.png",
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : CommonButton(
                                    padding: EdgeInsets.zero,
                                    minSize: 0,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      height: 32.h,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 11.5.w,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          begin: Alignment.centerRight,
                                          end: Alignment(-0.8, 0),
                                          colors: [
                                            ByColorUtil.colorFFCB86,
                                            ByColorUtil.colorFFEEDA,
                                          ],
                                          stops: [0, 1],
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          BYText.instance(
                                            '立即抢购',
                                            12.sp,
                                            color: ByColorUtil.color131420,
                                            fontWeight: BYFontWeight.semiBold,
                                          ),
                                          SizedBox(width: 3.w),
                                          Image.asset(
                                            Assets.mineIconRegisterMemberArrow,
                                            width: 12.w,
                                            height: 12.h,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                          : Provider.of<PurchaseProvider>(
                              context,
                            ).isIntegralOpen
                          ? const SizedBox(height: 0)
                          : GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.integralPage);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(top: 16.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "积分",
                                          style: TextStyle(
                                            color: ByColorUtil.colorFAE3C8,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Image.asset(
                                          "assets/mine/mine-jf-icon-rigth.png",
                                          width: 10.w,
                                          height: 10.h,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "${userInfo?.integral ?? 0}",
                                      style: TextStyle(
                                        color: ByColorUtil.colorFAE3C8,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            _buildMemberBenefitsIntro(),
          ],
        ),
      ),
    );
  }

  ///会员权益介绍
  _buildMemberBenefitsIntro() {
    final userController = Get.find<UserController>();
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: userController.isShowSpringStyle.value
              ? Colors.transparent
              : ByColorUtil.color202026,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          image: userController.isShowSpringStyle.value
              ? const DecorationImage(
                  image: AssetImage(
                    "assets/springFestival/springFestival-8.png",
                  ),
                  fit: BoxFit.fill,
                )
              : null,
          border: Border(
            top: userController.isShowSpringStyle.value
                ? const BorderSide(
                    color: Color(0xFFFDBC9A),
                    width: 0.5,
                    style: BorderStyle.solid,
                  )
                : const BorderSide(color: ByColorUtil.color4E4C4B, width: 0.5),
          ),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 每行的列
            mainAxisSpacing: 10.h, // 垂直间隔
            mainAxisExtent: 41.h,
          ),
          itemCount: BenefitsType.values.length,
          itemBuilder: (context, index) {
            var benefitsType = BenefitsType.values[index];
            return _buildBenefitsItem(benefitsType);
          },
        ),
      ),
    );
  }

  _buildBenefitsItem(BenefitsType benefitsType) {
    final userController = Get.find<UserController>();
    return CommonButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            userController.isShowSpringStyle.value
                ? benefitsType.image.replaceFirst(RegExp(r'\.png$'), '_1.png')
                : benefitsType.image,
            width: 27.w,
            height: 27.h,
          ),
          BYText.instance(
            benefitsType.title,
            10.sp,
            color: userController.isShowSpringStyle.value
                ? const Color(0xFFFAE3C8)
                : ByColorUtil.colorFAE3C8.withOpacity(0.6),
            height: 1.0,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
