import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/providers/launch_provider.dart';
import 'package:video_clip_edit/utils/comon/by_device_info_utils.dart';
import 'package:video_clip_edit/utils/http/apis.dart';
import 'package:video_clip_edit/utils/http/http_utils.dart';
import '../../controller/user_controller.dart';
import '../../modules/home/widgets/sub_funcs_view.dart';
import '../../modules/profile/beans/user_info_bean.dart';
import 'by_common_utils.dart';

class ByNavigatorUtil {
  ///点击事件
  static void itemClickEvent({
    required BuildContext context,
    required SubFunction e,
  }) async {
    final UserController controller = Get.find<UserController>();
    UserInfoBean? userInfo = controller.user.value;
    // num appChannelCode = BuildConfig.instance.channelType.code;
    if ((userInfo?.isFormal ?? 0) == 1) {
      if (controller.isNeedBindPhone) {
        await controller
            .needBindPhoneEvent(showTitle: true, needConfirm: true)
            .then((value) {
              userInfo = controller.user.value;
              if (userInfo?.isBindPhone == 1) {
                ByCommonUtils.subFunctionCase(context, e);
              }
            });
      } else {
        ByCommonUtils.subFunctionCase(context, e);
      }
    } else {
      controller.login().then((value) async {
        userInfo = controller.user.value;
        // if ((userInfo?.isFormal ?? 0) == 1) {
        //   ByCommonUtils.subFunctionCase(context, e);
        // }

        if (controller.isNeedBindPhone) {
          await controller
              .needBindPhoneEvent(showTitle: true, needConfirm: true)
              .then((value) {
                userInfo = controller.user.value;
                if (userInfo?.isBindPhone == 1) {
                  ByCommonUtils.subFunctionCase(context, e);
                }
              });
        } else {
          if ((userInfo?.isFormal ?? 0) == 1) {
            ByCommonUtils.subFunctionCase(context, e);
          }
        }
      });
    }
  }

  ///检查是否登陆
  ///点击事件
  static void checkLogin({
    required BuildContext context,
    required VoidCallback nextStepEvent,
    bool withOutGotoBind = false,
    VoidCallback? cancelLogin,

    ///是否需要直接登录
    bool needDirectLogin = false,
  }) async {
    final UserController controller = Get.find<UserController>();
    UserInfoBean? userInfo = controller.user.value;

    // num appChannelCode = BuildConfig.instance.channelType.code;
    ///已登录 3.10.39以前版本
    // if ((userInfo?.isFormal ?? 0) == 1) {
    //   if (controller.isNeedBindPhone) {
    //     if (withOutGotoBind) {
    //       nextStepEvent();
    //       return;
    //     }
    //     await controller
    //         .needBindPhoneEvent(
    //       showTitle: true,
    //       needConfirm: true,
    //       cancelBinding: (){
    //         cancelLogin?.call();
    //       }
    //     )
    //         .then((value) {
    //       if (controller.user.value?.isBindPhone == 1) {
    //         nextStepEvent();
    //       }
    //     });
    //   } else {
    //     nextStepEvent();
    //   }
    // } else {
    //   controller.login(cancelLogin: cancelLogin).then((value) async {
    //     userInfo = controller.user.value;
    //     if ((userInfo?.isFormal ?? 0) == 1) {
    //       // nextStepEvent();
    //       if (controller.isNeedBindPhone) {
    //         if (withOutGotoBind) {
    //           nextStepEvent();
    //           return;
    //         }
    //         await controller
    //             .needBindPhoneEvent(
    //           showTitle: true,
    //           needConfirm: true,
    //           cancelBinding: cancelLogin
    //         )
    //             .then((value) {
    //           if (controller.user.value?.isBindPhone == 1) {
    //             nextStepEvent();
    //           }
    //         });
    //       } else {
    //         if ((userInfo?.isFormal ?? 0) == 1) {
    //           nextStepEvent();
    //         }
    //       }
    //     }
    //   });
    // }

    ///已登录 3.10.39以后版本
    ///审核状态 是否在审核中 1是 0否
    final launchProvider = context.read<LaunchProvider>();
    final isAudit = launchProvider.launchInfo?.isAudit ?? 0;
    // const isAudit = 0;

    ///是否是48小时内重新归因的用户 0否 1是
    final isNewAttributionUser = userInfo?.isNewAttributionUser;
    // const isNewAttributionUser = 0;

    final isLoggedIn = (userInfo?.isFormal ?? 0) == 1;

    ///是否有过归因  1是 0否
    final hasAttribution = userInfo?.hasAttribution ?? 0;

    // 如果需要直接登录，跳过所有检查直接执行登录流程
    if (needDirectLogin && !isLoggedIn) {
      _handleLogin(
        controller: controller,
        cancelLogin: cancelLogin,
        withOutGotoBind: withOutGotoBind,
        nextStepEvent: nextStepEvent,
      );
      return;
    }

    if (isAudit == 1 || hasAttribution == 0) {
      ///审核状态
      if (!isLoggedIn) {
        ///未登录，弹出登录弹框
        _handleLogin(
          controller: controller,
          cancelLogin: cancelLogin,
          withOutGotoBind: withOutGotoBind,
          nextStepEvent: nextStepEvent,
        );
      } else {
        ///已登录状态
        _handleBindPhoneAndNextStep(
          controller: controller,
          withOutGotoBind: withOutGotoBind,
          cancelLogin: cancelLogin,
          nextStepEvent: nextStepEvent,
        );
      }
    } else {
      ///投放状态（非审核状态）
      if (isLoggedIn) {
        ///已登录状态
        _handleBindPhoneAndNextStep(
          controller: controller,
          withOutGotoBind: withOutGotoBind,
          cancelLogin: cancelLogin,
          nextStepEvent: nextStepEvent,
        );
      } else {
        ///未登录状态
        if (isNewAttributionUser == 1) {
          ///48小时内重新归因的用户，可先付费-后登录
          if (userInfo?.isVip == 1) {
            ///已是VIP，说明已经付费成功，需要登录并绑定手机号
            _handleLogin(
              controller: controller,
              cancelLogin: cancelLogin,
              withOutGotoBind: withOutGotoBind,
              nextStepEvent: nextStepEvent,
            );
          } else {
            ///不是VIP，允许先进行下一步（可能是付费流程），后续付费成功后再弹出登录弹框
            nextStepEvent();
          }
        } else {
          ///不是48小时内重新归因的用户，按正常流程：先登录
          _handleLogin(
            controller: controller,
            cancelLogin: cancelLogin,
            withOutGotoBind: withOutGotoBind,
            nextStepEvent: nextStepEvent,
          );
        }
      }
    }
  }

  ///处理绑定手机号和执行下一步
  static void _handleBindPhoneAndNextStep({
    required UserController controller,
    required bool withOutGotoBind,
    required VoidCallback? cancelLogin,
    required VoidCallback nextStepEvent,
  }) async {
    if (controller.isNeedBindPhone) {
      if (withOutGotoBind) {
        nextStepEvent();
        return;
      }
      // 先检查是否已经绑定，如果已绑定则直接执行下一步
      if (controller.user.value?.isBindPhone == 1) {
        nextStepEvent();
        return;
      }
      await controller
          .needBindPhoneEvent(
            showTitle: true,
            needConfirm: true,
            cancelBinding: cancelLogin,
          )
          .then((value) {
            if (controller.user.value?.isBindPhone == 1) {
              nextStepEvent();
            }
          });
    } else {
      nextStepEvent();
    }
  }

  ///处理登录逻辑
  static void _handleLogin({
    required UserController controller,
    required VoidCallback? cancelLogin,
    required bool withOutGotoBind,
    required VoidCallback nextStepEvent,
  }) {
    controller
        .login(
          cancelLogin: cancelLogin,
          successLogin: () {
            final userInfo = controller.user.value;
            if ((userInfo?.isFormal ?? 0) == 1) {
              _handleBindPhoneAndNextStep(
                controller: controller,
                withOutGotoBind: withOutGotoBind,
                cancelLogin: cancelLogin,
                nextStepEvent: nextStepEvent,
              );
            }
            // 如果登录失败（isFormal != 1），不执行下一步，这是合理的
          },
        )
        // .then((value) async {})
        .catchError((error) {
          // 如果登录过程中出现错误，不执行下一步
          debugPrint("登录过程出错: $error");
        });
  }

  ///新数据埋点上报
  ///
  ///undertake_type 承接模式：1：审核面上报 2：老的承接 3：短剧授权承接弹框 4：0粉丝变现承接页 0：无承接
  static Future<void> reportDataPoint({
    required String pageTag,
    required String operateType,
    required String funcDetailTag,
    required String funcDetailImg,
    String undertakeType = "0",
    Map<String, dynamic>? extra,
  }) async {
    final String network = await ByDeviceInfoUtils.getNetworkStatus();

    // 处理 extra 参数，过滤掉数组，然后转换为 JSON 字符串
    Map<String, dynamic> extraData = {};
    if (extra != null) {
      extra.forEach((key, value) {
        // 只保留非数组类型的值（字符串、数字、布尔值、null、嵌套对象）
        if (value is! List) {
          if (value is Map) {
            // 递归处理嵌套的 Map，确保也不包含数组
            extraData[key] = _filterExtraData(value);
          } else {
            extraData[key] = value;
          }
        }
        // 如果是数组，则跳过，不添加到 extraData 中
      });
    }

    // 将 extra 转换为 JSON 字符串
    String extraJson = jsonEncode(extraData);

    HttpUtils.post(
      APIs.apiPost,
      {
        "event": "behavior",
        "page_tag": pageTag, //页面标识 event=behavior必填
        "operate_type": operateType, //操作类型 view/click  event=behavior必填
        "func_detail_tag": funcDetailTag,
        "func_detail_img": funcDetailImg.isEmpty
            ? ""
            : funcDetailImg, //event=behavior 需要  点击的对应功能图片(如果有的话)
        "extra": extraJson, //额外参数 JSON字符串格式，已过滤掉数组
        "network": network, //网络类型 2G/3G/4G/WIFI
        // "undertake_type": undertakeType, //承接模式
      },
      showMsgWhenFailed: false, // 埋点上报失败时不显示错误提示，静默处理
      success: (data) {
        byDebugPrint(
          "上报参数: pageTag=$pageTag, operateType=$operateType, funcDetailTag=$funcDetailTag, network=$network, funcDetailImg=$funcDetailImg, extra=$extraJson",
          tag: "===数据埋点上报成功===",
        );
      },
      fail: (code, msg) {
        byDebugPrint("错误码: $code, 错误信息: $msg", tag: "===数据埋点上报失败===");
        byDebugPrint(
          "上报参数: pageTag=$pageTag, operateType=$operateType, funcDetailTag=$funcDetailTag, network=$network",
          tag: "===数据埋点上报失败===",
        );
      },
    );
  }

  /// 递归过滤 extra 数据，确保只包含 JSON 对象能接受的值（不包含数组）
  static Map<String, dynamic> _filterExtraData(Map<dynamic, dynamic> data) {
    Map<String, dynamic> result = {};
    data.forEach((key, value) {
      if (value is! List) {
        if (value is Map) {
          result[key.toString()] = _filterExtraData(value);
        } else {
          result[key.toString()] = value;
        }
      }
      // 如果是数组，则跳过
    });
    return result;
  }
}
