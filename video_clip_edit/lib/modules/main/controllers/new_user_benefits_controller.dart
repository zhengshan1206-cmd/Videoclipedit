import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/main/controllers/main_controller.dart';
import 'package:video_clip_edit/modules/profile/beans/user_info_bean.dart';
import 'package:video_clip_edit/modules/purchase/beans/vip_type_bean.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/providers/purchase_provider.dart';
import 'package:video_clip_edit/routes/app_pages.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_storage_utils.dart';
import 'package:video_clip_edit/v2/aiCreate/widgets/drawing_view.dart';
import 'package:video_clip_edit/v2/business/get_red_envelope_dialog.dart';
import 'package:video_clip_edit/v2/integral/integral_vip_controller.dart';

class NewUserBenefitsController extends GetxController {
  UserController? _userController;

  /// 1=>展示新用户限时福利，2=>红包弹窗，3=>创作者抄底福利
  final RxInt _showType = 0.obs;

  RxInt get showType => _showType;

  /// 防止重复调用的标志
  bool _isCheckingTime = false;
  bool _isCheckingUserOpenTime = false;

  ///隐藏底部弹窗
  void hideBottom() {
    _showType.value = 0;
  }

  ///切换底部弹窗
  void switchShowType(int value) {
    _showType.value = value;
  }

  bool allowClosePay = false;

  ///支付挽留弹窗
  Future<bool> retentionDialog({VoidCallback? callPay}) async {
    if (_showType.value != 2) return true;
    if (Get.context == null || allowClosePay == true) {
      if (allowClosePay == true) {
        allowClosePay = false;
      }
      return true;
    }
    await Future.delayed(Duration.zero, () {
      if (showType.value == 2) {
        showDialog(
          context: Get.context!,
          builder: (context) => PopScope(
            child: GetRewardWidget(
              onTapForClaim: () {
                ///调起支付
                Navigator.pop(context);
                callPay?.call();
              },
            ),
            onPopInvoked: (_) {
              if (allowClosePay == false) {
                allowClosePay = true;
              }
            },
          ),
        ).then((value) {
          if (value == true) {
            allowClosePay = true;
          }
        });
      } else {
        showDialog(
          context: Get.context!,
          builder: (context) => PopScope(
            child: UseCouponWidget(
              onTapForClaim: () {
                ///调起支付
                Navigator.pop(context);
                callPay?.call();
              },
            ),
            onPopInvoked: (_) {
              if (allowClosePay == false) {
                allowClosePay = true;
              }
            },
          ),
        ).then((value) {
          if (value == true) {
            allowClosePay = true;
          }
        });
      }
    });
    return false;
  }

  PurchaseProvider? _purchaseProvider;

  @override
  void onInit() {
    super.onInit();
    _userController = Get.find<UserController>();
    _purchaseProvider = Get.context?.read<PurchaseProvider>();
    _purchaseProvider?.loadVIPItems(
      onSuccess: () {
        update(['updatePriceInfo']);
      },
    );

    ///获取前置配置
    _purchaseProvider?.preLoginConfig(onSuccess: () {});
    checkTime();
  }

  ///检测新用户是否需要弹出短剧引导弹窗
  void checkShortFilmGuideDialog() {
    ByNavigatorUtil.reportDataPoint(
      pageTag: "promotion_page_dialog",
      operateType: "view",
      funcDetailTag: "0",
      funcDetailImg: "",
    );
    Future.delayed(Duration.zero, () {
      if (Get.context != null) {
        // 使用日期作为key，用于标记今天已弹出
        final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final storageKey = 'short_film_guide_dialog_$date';

        showDialog(
          context: Get.context!,
          barrierColor: Colors.black.withOpacity(0.85),
          builder: (context) => ShortFilmGuideDialog(
            onClose: () {
              ByNavigatorUtil.reportDataPoint(
                pageTag: "promotion_page_dialog_unlock_btn",
                operateType: "click",
                funcDetailTag: "0",
                funcDetailImg: "",
              );

              ///通知授权（短剧引导弹窗点击解锁后立即请求）
              _requestNotificationPermission(delayMs: 300);
            },
            onTapForClaim: () {
              ByNavigatorUtil.reportDataPoint(
                pageTag: "promotion_page_dialog_close_btn",
                operateType: "click",
                funcDetailTag: "0",
                funcDetailImg: "",
              );

              ///跳转推广页
              Navigator.pop(context);
              // 设置推广页引导弹窗标志
              _userController?.isShowPromotePageGuide = true;
              // 检查MainController是否已注册
              bool isMainController = Get.isRegistered<MainController>();
              if (isMainController) {
                Get.find<MainController>().tabChanged(2);
              } else {
                // 如果MainController未注册，先导航到主页面
                Get.toNamed(Routes.main)?.then((_) {
                  if (Get.isRegistered<MainController>()) {
                    Get.find<MainController>().tabChanged(2);
                  }
                });
              }
            },
          ),
        ).then((value) {
          // 无论用户如何关闭弹窗（点击按钮、点击背景、按返回键等），都标记今天已弹出
          ByStorageUtils.saveBool(storageKey, true);
        });
      }
    });
  }

  void checkTime({bool? openDialog = true}) {
    // 防止重复调用
    if (_isCheckingTime) {
      Get.log('checkTime 正在执行中，跳过本次调用');
      return;
    }

    _isCheckingTime = true;

    try {
      UserInfoBean? userInfo = _userController?.user.value;

      final isAudit =
          Get.context?.read<LaunchProvider>().launchInfo?.isAudit ?? 0;

      final newUserUndertakeType =
          Get.context
              ?.read<LaunchProvider>()
              .launchInfo
              ?.verConfig
              .newUserUndertakeType ??
          "";

      print("isAudit: $isAudit");
      print("userInfo?.hasAttribution: ${userInfo?.hasAttribution}");
      print("userInfo?.isVip: ${userInfo?.isVip}");
      print(
        "userInfo?.isNewAttributionUser: ${userInfo?.isNewAttributionUser}",
      );
      print(
        "isShowNewUserRedEnvelope: ${_userController?.isShowNewUserRedEnvelope}",
      );

      ///如果用户是VIP，则不展示弹窗.  是否审核。是否有过检测链接
      if (userInfo?.isVip == 1 ||
          isAudit == 1 ||
          userInfo?.hasAttribution == 0) {
        _requestNotificationPermission();
        return;
      }
      // /检测新用户是否需要弹出短剧引导弹窗（每天只弹一次，并且归因下和未审核才展示）
      // 使用日期作为key，检查今天是否已经弹出过
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final storageKey = 'short_film_guide_dialog_$date';
      final hasShownToday = ByStorageUtils.getBool(storageKey) ?? false;

      if (_userController?.isShowNewUserRedEnvelope == true) {
        if (userInfo?.isNewAttributionUser == 1 &&
            userInfo?.isVip == 0 &&
            !hasShownToday &&
            isAudit == 0) {
          checkShortFilmGuideDialog();
        }
        return;
      }

      // if (_userController?.isShowNewUserRedEnvelope == true) {
      //   if (userInfo?.isNewAttributionUser == 1 &&
      //       userInfo?.isVip == 0 &&
      //       !hasShownToday &&
      //       isAudit == 0) {
      //     checkShortFilmGuideDialog();
      //   } else {
      //     checkUserOpenTimeEvent(openDialog: openDialog);
      //   }
      //   return;
      // }

      // if (userInfo?.isNewAttributionUser == 1 &&
      //     isAudit == 0 &&
      //     userInfo?.hasAttribution == 1 &&
      //     userInfo?.isVip == 0 &&
      //     !hasShownToday &&
      //     newUserUndertakeType == "0_fans") {
      //   ByStorageUtils.saveBool(storageKey, true);
      //   // 延迟执行跳转，确保 Navigator 已经准备好
      //   // 使用 WidgetsBinding.addPostFrameCallback 确保在当前帧渲染完成后执行
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     if (Get.context != null && Get.context!.mounted) {
      //       ByNavigatorUtil.reportDataPoint(
      //         pageTag: "promotion_page_0fans_dialog",
      //         operateType: "view",
      //         funcDetailTag: "0",
      //         funcDetailImg: _userController?.shortDramaGuideImage ?? "",
      //       );
      //       Get.toNamed(Routes.shortDramaPage);
      //     }
      //   });
      //   return;
      // }

      // if (newUserUndertakeType == "red_package") {
      //   checkUserOpenTimeEvent(openDialog: openDialog);
      //   return;
      // }

      // if (newUserUndertakeType == "drama_auth") {
      //   if (userInfo?.isVip == 0 && !hasShownToday) {
      //     if (userInfo?.isNewAttributionUser == 1 && isAudit == 0) {
      //       checkShortFilmGuideDialog();
      //     }
      //   } else {
      //     checkUserOpenTimeEvent(openDialog: openDialog);
      //   }
      //   return;
      // }

      checkUserOpenTimeEvent(openDialog: openDialog);
    } finally {
      // 延迟重置标志，避免快速连续调用
      Future.delayed(const Duration(milliseconds: 100), () {
        _isCheckingTime = false;
      });
    }
  }

  void checkUserOpenTimeEvent({bool? openDialog = true}) {
    checkUserOpenTime(
      firstDatOpen: firstDayOpenEvent,
      openAgain: () => openAgain(openDialog: openDialog),
      open: () async {
        bool isUserController = Get.isRegistered<UserController>();
        UserController controller;
        if (isUserController) {
          controller = Get.find<UserController>();
          if (controller.user.value?.isFormal == 1) {
            // Get.find<UserController>().checkNeedPhoneBind();
            await controller.reloadUserInfo();
          }
        } else {
          controller = Get.put(UserController());
          // Get.find<UserController>().checkNeedPhoneBind();
          await controller.reloadUserInfo();
        }

        UserInfoBean? userInfo = controller.user.value;
        if ((userInfo?.isFormal ?? 0) == 1) {
          ///已经登录
          debugPrint("已经登录");
          if (userInfo?.isVip != 1) {
            if (openDialog == true) {
              ///登录成功
              // if (Get.context != null) {
              //   Get.context
              //       ?.read<LaunchProvider>()
              //       .gotoPay(Get.context!, closePay: true);
              // }
            }
            _showType.value = 3;
          } else {
            _showType.value = 0;
            // 用户是VIP，不会显示弹窗，可以请求通知权限
            _requestNotificationPermission();
          }
        } else {
          ///未登录
          debugPrint("未登录");
          if (userInfo?.isVip != 1) {
            // 移除自动调用 gotoPay，避免未登录时自动打开登录页面
            if (openDialog == true) {
              if (Get.context != null) {
                Get.context?.read<LaunchProvider>().gotoPay(
                  Get.context!,
                  closePay: true,
                  needCheckLogin: false,
                );
              }
            }
            _showType.value = 3;
          } else {
            _showType.value = 0;
            // 用户是VIP，不会显示弹窗，可以请求通知权限
            _requestNotificationPermission();
          }
        }
      },
    );
  }

  ///用户次日打开触发事件
  void openAgain({bool? openDialog = true}) async {
    bool isUserController = Get.isRegistered<UserController>();
    UserController controller;
    if (isUserController) {
      controller = Get.find<UserController>();
      if (controller.user.value?.isFormal == 1) {
        // Get.find<UserController>().checkNeedPhoneBind();
        await controller.reloadUserInfo();
      }
    } else {
      controller = Get.put(UserController());
      // Get.find<UserController>().checkNeedPhoneBind();
      await controller.reloadUserInfo();
    }

    UserInfoBean? userInfo = controller.user.value;
    if ((userInfo?.isFormal ?? 0) == 1) {
      ///已经登录
      debugPrint("已经登录");
      if (userInfo?.isVip != 1) {
        ///未付费=>领取红包弹窗
        if (openDialog == true) {
          Future.delayed(Duration.zero, () {
            ByNavigatorUtil.reportDataPoint(
              pageTag: "promotion_page_red_pack_dialog",
              operateType: "view",
              funcDetailTag: "0",
              funcDetailImg: "",
              extra: {"desc": "本地图片2"},
            );
            showDialog(
              context: Get.context!,
              builder: (context) => GetRedEnvelopeWidget(
                onTapForClose: () {
                  ByNavigatorUtil.reportDataPoint(
                    pageTag: "promotion_page_red_pack_dialog_close_btn",
                    operateType: "click",
                    funcDetailTag: "0",
                    funcDetailImg: "",
                    extra: {"desc": "本地图片2"},
                  );
                },
                onTapForClaim: () {
                  ByNavigatorUtil.reportDataPoint(
                    pageTag: "promotion_page_red_pack_dialog_unlock_btn",
                    operateType: "click",
                    funcDetailTag: "0",
                    funcDetailImg: "",
                    extra: {"desc": "本地图片2"},
                  );
                },
              ),
            ).then((value) {
              if (value != true) {
                if (Get.context != null) {
                  Get.context?.read<LaunchProvider>().gotoPay(
                    Get.context!,
                    closePay: false,
                  );
                }
              }
              _showType.value = 2;
              // 弹窗关闭后，请求通知权限
              _requestNotificationPermission();
            });
          });
        } else {
          _showType.value = 2;
        }
      }
    } else {
      ///未登录
      debugPrint("未登录");
      if (userInfo?.isVip != 1) {
        ///未付费=>领取红包弹窗
        if (openDialog == true) {
          Future.delayed(Duration.zero, () {
            showDialog(
              context: Get.context!,
              builder: (context) => const GetRedEnvelopeWidget(),
            ).then((value) {
              if (value != true) {
                if (Get.find<UserController>().user.value?.isVip != 1) {
                  _showType.value = 2;
                }
                ByNavigatorUtil.checkLogin(
                  withOutGotoBind: false,
                  context: Get.context!,
                  nextStepEvent: () {
                    update();
                    IntegralVipController.getOrPut();
                    if ((Get.find<UserController>().user.value?.activeDay ??
                                0) <=
                            2 &&
                        Get.find<UserController>().user.value?.isVip != 1) {
                      ///登录成功
                      if (Get.context != null) {
                        Get.context?.read<LaunchProvider>().gotoPay(
                          Get.context!,
                          closePay: true,
                        );
                      }
                      _showType.value = 2;
                    } else {
                      _showType.value = 0;
                    }
                  },
                );
              } else {
                if (Get.find<UserController>().user.value?.isVip != 1) {
                  _showType.value = 2;
                }
              }
              // 弹窗关闭后，请求通知权限
              _requestNotificationPermission();
            });
          });
        } else {
          _showType.value = 2;
        }
      }
    }
  }

  VipTypeBean? getVipHappy() {
    PurchaseProvider? provider = Get.context?.read<PurchaseProvider>();
    if (provider == null) return null;
    List<VipTypeBean> happys = provider.vipTypeBeans;
    if (happys.isNotEmpty == true) {
      return happys[0];
    }
    return null;
  }

  ///用户第一天打开应用触发的事件
  void firstDayOpenEvent() async {
    ///
    bool isUserController = Get.isRegistered<UserController>();
    UserController controller;
    if (isUserController) {
      controller = Get.find<UserController>();
      if (controller.user.value?.isFormal == 1) {
        // Get.find<UserController>().checkNeedPhoneBind();
        await controller.reloadUserInfo();
      }
    } else {
      controller = Get.put(UserController());
      // Get.find<UserController>().checkNeedPhoneBind();
      await controller.reloadUserInfo();
    }

    UserInfoBean? userInfo = controller.user.value;
    if ((userInfo?.isFormal ?? 0) == 1) {
      ///已经登录
      if (userInfo?.isVip != 1) {
        ///未付费=>
        // claimNewUserGift();
      }
    } else {
      ///未登录
      if (userInfo?.isVip != 1) {
        ///未付费=>弹出迎新弹窗
        Future.delayed(Duration.zero, () {
          ByNavigatorUtil.reportDataPoint(
            pageTag: "promotion_page_red_pack_dialog",
            operateType: "view",
            funcDetailTag: "0",
            funcDetailImg: "",
            extra: {"desc": "本地图片1"},
          );

          showDialog(
            context: Get.context!,
            builder: (context) => NewUserWidget(
              onTapForClaim: () {
                ByNavigatorUtil.reportDataPoint(
                  pageTag: "promotion_page_red_pack_dialog_unlock_btn",
                  operateType: "click",
                  funcDetailTag: "0",
                  funcDetailImg: "",
                  extra: {"desc": "本地图片1"},
                );
                claimNewUserGift();
              },
              onTapForClose: () {
                ByNavigatorUtil.reportDataPoint(
                  pageTag: "promotion_page_red_pack_dialog_close_btn",
                  operateType: "click",
                  funcDetailTag: "0",
                  funcDetailImg: "",
                  extra: {"desc": "本地图片1"},
                );
              },
            ),
          ).then((_) {
            ///展示底部新用户限时福利UI
            if (Get.find<UserController>().user.value?.isVip != 1) {
              _showType.value = 1;
            }
            // 弹窗关闭后，请求通知权限（延迟500ms确保弹窗完全关闭）
            _requestNotificationPermission(delayMs: 500);
          });
        });
      }
    }
  }

  void claimNewUserGift() {
    ByNavigatorUtil.checkLogin(
      withOutGotoBind: false,
      context: Get.context!,
      nextStepEvent: () {
        update();
        IntegralVipController.getOrPut();

        ///登录成功
        if ((Get.find<UserController>().user.value?.activeDay ?? 0) <= 1 &&
            Get.find<UserController>().user.value?.isVip != 1) {
          ///展示底部新用户限时福利UI
          _showType.value = 1;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Get.toNamed(Routes.benefitsForCreatorPage)?.then((value) {
            //   if (value == false) {
            //     _showType.value = 1;
            //   }
            //   if (Get.find<NewUserBenefitsController>().agreed.value == true) {
            //     _agreed.value = false;
            //     if (Get.context != null) {
            //       Get.context!
            //           .read<PurchaseProvider>()
            //           .agreementCheckedStatusChanged(agreed.value);
            //     }
            //   }
            // });

            ///跳转付费页
            if (Get.context != null) {
              Get.context?.read<LaunchProvider>().gotoPay(
                Get.context!,
                closePay: true,
              );
            }
          });
        } else {
          _showType.value = 0;
        }
      },
    );
  }

  ///检查用户第一次的打开时间
  void checkUserOpenTime({
    ///首次打开
    VoidCallback? firstDatOpen,

    ///首次打开后次日再次打开
    VoidCallback? openAgain,

    ///非首日非次日
    VoidCallback? open,
  }) async {
    // 防止重复调用
    if (_isCheckingUserOpenTime) {
      Get.log('checkUserOpenTime 正在执行中，跳过本次调用');
      return;
    }

    _isCheckingUserOpenTime = true;

    try {
      LaunchProvider? launchProvider = Get.context?.read<LaunchProvider>();
      if (launchProvider == null ||
          launchProvider.launchInfo?.userCreatedAt.isNotEmpty != true) {
        _requestNotificationPermission();
        return;
      }

      // 检查 UserController 是否已注册
      if (!Get.isRegistered<UserController>()) {
        Get.log('UserController 未注册，无法检查用户打开时间');
        _requestNotificationPermission();
        return;
      }

      // 获取第一次打开的时间(从服务端获取)
      final firstOpenTime = DateTime.parse(
        launchProvider.launchInfo!.userCreatedAt,
      );
      // final firstOpenTime = DateTime(
      //   DateTime.now().year,
      //   DateTime.now().month,
      //   DateTime.now().day,
      // ).subtract(const Duration(days: 1));

      // 获取第一次打开时间的第二天 00:00:00
      final nextDayZero = DateTime(
        firstOpenTime.year,
        firstOpenTime.month,
        firstOpenTime.day,
      ).add(const Duration(days: 1));
      final now = DateTime.now();
      if (now.isAfter(nextDayZero)) {
        ///下次打开。这里需要一个活跃天数，活跃天数为2则当前代表次日，否则非首日/非次日
        int activeDay = Get.find<UserController>().user.value?.activeDay ?? 0;
        if (activeDay <= 2) {
          ///次日
          openAgain?.call();
        } else if (activeDay > 2) {
          ///非首日及非次日
          WidgetsBinding.instance.addPostFrameCallback((_) {
            open?.call();
          });
        }
      } else {
        ///第一天
        firstDatOpen?.call();
      }
    } finally {
      // 延迟重置标志，避免快速连续调用
      Future.delayed(const Duration(milliseconds: 100), () {
        _isCheckingUserOpenTime = false;
      });
    }
  }

  ///新用户欢迎礼与红包倒计时
  int countdownForMill() {
    DateTime firstOpenTime = DateTime.now();
    if (showType.value == 0) {
      LaunchProvider? launchProvider = Get.context?.read<LaunchProvider>();
      if (launchProvider == null ||
          launchProvider.launchInfo?.userCreatedAt.isNotEmpty != true) {
        return 0;
      }
      firstOpenTime = DateTime.parse(launchProvider.launchInfo!.userCreatedAt);
    }

    // 获取第一次打开时间的第二天 00:00:00
    final nextDayZero = DateTime(
      firstOpenTime.year,
      firstOpenTime.month,
      firstOpenTime.day,
    ).add(const Duration(days: 1));
    return nextDayZero.difference(DateTime.now()).inMilliseconds;
  }

  ///当前支付方式，0=>微信支付，1=>支付宝支付
  final RxInt _currentPay = 0.obs;

  RxInt get currentPay => _currentPay;

  ///切换支付方式
  void switchPayType() {
    if (currentPay.value == 0) {
      currentPay.value = 1;
    } else {
      currentPay.value = 0;
    }
  }

  ///是否同意协议
  final RxBool _agreed = false.obs;

  RxBool get agreed => _agreed;

  ///是否同意支付协议
  void switchAgree() {
    _agreed.value = !_agreed.value;
  }

  /// 请求通知权限（在弹窗关闭后调用）
  /// 统一通过MainController的安全方法请求，避免重复请求
  void _requestNotificationPermission({int delayMs = 500}) {
    // 检查MainController是否已注册
    if (!Get.isRegistered<MainController>()) {
      Get.log('MainController未注册，无法请求通知权限');
      return;
    }

    // 使用MainController的统一入口，带防重复机制
    Get.find<MainController>().requestNotificationPermissionSafely(
      delayMs: delayMs,
    );
  }
}
