import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_clip_edit/controller/user_controller.dart';
import 'package:video_clip_edit/modules/purchase/scale_transition_widget.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_navigator_util.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/beans/cloud_video_bean.dart';
import 'package:video_clip_edit/flavors/build_config.dart';
import 'package:video_clip_edit/utils/channel/channel_config.dart';
import 'package:video_clip_edit/v2/business/widget/guide_last_step_view.dart';
import '../../../routes/app_pages.dart';
import '../../hotCreate/providers/new_short_play_list_controller.dart';
import '../../aiSquare/widgets/ai_video_player.dart';
import '../../../modules/main/controllers/main_controller.dart';

///双列布局的短剧卡片
class ShortPlayGridCell extends StatefulWidget {
  const ShortPlayGridCell({
    super.key,
    required this.index,
    this.fromPrompt = false,
    required this.shortPlayBean,
    this.prePagePath = "",
  });

  final int index;
  final bool fromPrompt;
  final CloudVideoListBean shortPlayBean;
  final String prePagePath;

  @override
  State<ShortPlayGridCell> createState() => _ShortPlayGridCellState();
}

class _ShortPlayGridCellState extends State<ShortPlayGridCell>
    with WidgetsBindingObserver {
  final GlobalKey _shimmerKey = GlobalKey();
  StreamSubscription? _triggerShimmerSubscription;
  bool _showScaleWidget = false; // 控制 ScaleTransitionWidget 的显示
  OverlayEntry? _overlayEntry; // Overlay 入口
  final GlobalKey _widgetKey = GlobalKey(); // 用于获取组件位置
  StreamSubscription? _scrollSubscription; // 滚动监听
  String? _currentRoute; // 记录当前路由

  // 静态变量：确保全局只有一个定位图显示
  static bool _hasScaleWidgetShowing = false;
  static _ShortPlayGridCellState? _currentShowingInstance;

  @override
  void initState() {
    super.initState();
    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);
    // 记录当前路由
    _currentRoute = Get.currentRoute;
    // 监听扫光触发事件
    _triggerShimmerSubscription =
        eventBus.on<TriggerShimmerEvent>().listen((event) {
      // 触发扫光效果 - 所有卡片都能触发扫光
      if (mounted) {
        // 延迟一帧执行，确保 widget 已经完全构建
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final state = _shimmerKey.currentState;
            if (state != null) {
              // 使用动态调用 play() 方法
              try {
                (state as dynamic).play();
              } catch (e) {
                // 如果方法不存在，忽略错误
                Get.log("Trigger shimmer error: $e");
              }
            }
          }
        });
      }

      // 只有右边第一个（index == 1）才显示手指定位图
      if (widget.index != 1) {
        return;
      }

      // 检查是否已经有定位图显示，如果有则不显示新的
      if (_hasScaleWidgetShowing && _currentShowingInstance != this) {
        return;
      }

      // 显示 ScaleTransitionWidget（定位图）
      if (mounted) {
        // 如果已经有其他实例显示定位图，先隐藏它
        if (_hasScaleWidgetShowing &&
            _currentShowingInstance != null &&
            _currentShowingInstance != this) {
          _currentShowingInstance!._hideScaleWidget();
        }

        setState(() {
          _showScaleWidget = true;
        });
        // 设置当前显示实例和标志
        _hasScaleWidgetShowing = true;
        _currentShowingInstance = this;
        // 延迟一帧后显示 Overlay，确保位置计算准确
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showOverlay();
        });
      }
    });
  }

  // 更新 Overlay 位置
  void _updateOverlayPosition() {
    if (!mounted || _overlayEntry == null) return;
    _overlayEntry!.markNeedsBuild();
  }

  // 显示 Overlay
  void _showOverlay() {
    if (!mounted) return;

    // 如果已存在，先移除
    _hideOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        // 检查 widget 是否还在当前页面
        if (!mounted) {
          return const SizedBox.shrink();
        }

        // 立即检查路由是否变化（最优先检查）
        try {
          final currentRoute = Get.currentRoute;
          if (_currentRoute != null && currentRoute != _currentRoute) {
            // 路由已变化，立即隐藏定位图
            _currentRoute = currentRoute;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _hideScaleWidget();
              }
            });
            return const SizedBox.shrink();
          }
        } catch (e) {
          // 路由检查失败，安全起见隐藏定位图
          return const SizedBox.shrink();
        }

        // 检查当前 tab 是否是推广页面（index 2）
        try {
          if (Get.isRegistered<MainController>()) {
            final mainController = Get.find<MainController>();
            if (mainController.currentIndex != 2) {
              // 当前不在推广页面，隐藏定位图
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _hideScaleWidget();
                }
              });
              return const SizedBox.shrink();
            }
          }
        } catch (e) {
          // MainController 检查失败，安全起见隐藏定位图
          return const SizedBox.shrink();
        }

        // 检查 widget 的 context 是否还在 widget tree 中
        final widgetContext = _widgetKey.currentContext;
        if (widgetContext == null) {
          // 延迟隐藏，避免在 builder 中直接修改状态
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _hideScaleWidget();
            }
          });
          return const SizedBox.shrink();
        }

        // 检查是否有弹窗显示，如果有则隐藏定位图
        if (_shouldHideOverlay()) {
          // 延迟隐藏，避免在 builder 中直接修改状态
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _hideScaleWidget();
            }
          });
          return const SizedBox.shrink();
        }

        final RenderBox? renderBox =
            widgetContext.findRenderObject() as RenderBox?;
        if (renderBox == null) return const SizedBox.shrink();

        final size = renderBox.size;
        final offset = renderBox.localToGlobal(Offset.zero);

        // 计算定位图的位置
        final top = offset.dy + size.height - 40.h;

        // 获取屏幕信息，判断是否在tab栏区域内
        final mediaQuery = MediaQuery.of(context);
        final statusBarHeight = mediaQuery.padding.top;
        // tab栏高度约为56.h，加上状态栏高度和顶部安全区域
        final tabBarAreaHeight = statusBarHeight + 56.h + 10.h; // 增加一些缓冲区域

        // 如果定位图在tab栏区域内，不显示（确保层级低于tab栏）
        if (top < tabBarAreaHeight) {
          return const SizedBox.shrink();
        }

        return Positioned(
          right: 20.w,
          top: top,
          child: Material(
            color: Colors.transparent,
            elevation: 0, // 设置elevation为0，确保层级低于tab栏
            child: GestureDetector(
              onTap: () {
                // 点击手指图片时，执行和点击卡片一样的操作
                if (mounted) {
                  _startCreateEvent();
                }
              },
              child: ScaleTransitionWidget(
                period: 150,
                child: Image.asset(
                  "assets/v2/promote/promote-5.png",
                  width: 52.w,
                  height: 52.w,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    // 延迟一帧后开始监听滚动，实时更新位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlayEntry != null) {
        // 开始位置更新循环，每帧更新位置
        _startPositionUpdateLoop();
      }
    });
  }

  // 开始位置更新循环
  void _startPositionUpdateLoop() {
    if (!mounted || _overlayEntry == null) return;

    // 使用 addPostFrameCallback 在每帧更新位置
    void updateLoop() {
      if (!mounted || _overlayEntry == null) return;

      // 检查 widget 是否还在当前页面
      final widgetContext = _widgetKey.currentContext;
      if (widgetContext == null) {
        // widget 不在 widget tree 中，隐藏定位图
        _hideScaleWidget();
        return;
      }

      // 检查是否有弹窗显示或路由变化，如果有则隐藏定位图
      if (_shouldHideOverlay()) {
        _hideScaleWidget();
        return;
      }

      _updateOverlayPosition();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateLoop();
      });
    }

    updateLoop();
  }

  // 隐藏 Overlay
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _scrollSubscription?.cancel();
    _scrollSubscription = null;
  }

  // 隐藏定位图
  void _hideScaleWidget() {
    if (_showScaleWidget) {
      setState(() {
        _showScaleWidget = false;
      });
      _hideOverlay();
      // 重置静态变量
      if (_currentShowingInstance == this) {
        _hasScaleWidgetShowing = false;
        _currentShowingInstance = null;
      }
    }
  }

  ///获取是否来自新短剧
  bool _getFromNewShortPlay() {
    bool fromNewShortPlay = false;
    dynamic arguments = Get.arguments;
    if (arguments != null && arguments is Map) {
      if (arguments["fromNewShortPlay"] != null) {
        if (arguments["fromNewShortPlay"] is bool) {
          fromNewShortPlay = arguments["fromNewShortPlay"];
        }
      }
    }
    return fromNewShortPlay;
  }

  ///立即创作的点击事件
  void _startCreateEvent() {
    // 只有右边第一个（index == 1）且触发了扫光才传递 true
    // 其他情况都传递 false
    bool showScaleWidget = widget.index == 1 && _showScaleWidget;
    print(
        "===startCreateEvent index: ${widget.index}, _showScaleWidget: $_showScaleWidget, showScaleWidget: $showScaleWidget");

    // 点击跳转时隐藏定位图
    _hideScaleWidget();

    ByNavigatorUtil.reportDataPoint(
      pageTag: "promotion_page_content_btn",
      operateType: "click",
      funcDetailTag: widget.shortPlayBean.id.toString(),
      funcDetailImg: widget.shortPlayBean.coverUrl,
    );

    final fromNewShortPlay = _getFromNewShortPlay();
    if (showScaleWidget) {
      Get.find<UserController>().showFinger(true);
    }
    ByNavigatorUtil.checkLogin(
        context: context,
        nextStepEvent: () {
          if (fromNewShortPlay) {
            eventBus.fire(RefreshDataEvent(arguments: {
              "fromPrompt": widget.fromPrompt,
              "videoListBean": widget.shortPlayBean,
            }));
          }
          Get.toNamed(Routes.newShortPlayListPage, arguments: {
            "fromPrompt": widget.fromPrompt,
            "videoListBean": widget.shortPlayBean,
            "prePagePath": widget.prePagePath,
            "showScaleWidget": showScaleWidget, // 传递定位图显示状态
          });
        });
  }

  // 检查是否有弹窗显示或路由变化
  bool _shouldHideOverlay() {
    try {
      // 检查 widget 是否还在当前页面（通过检查 context 是否有效）
      if (!mounted) {
        return true; // widget 已销毁，需要隐藏
      }

      // 检查 widget 的 context 是否还在 widget tree 中
      final context = _widgetKey.currentContext;
      if (context == null) {
        return true; // widget 不在 widget tree 中，需要隐藏
      }

      // 检查路由是否变化
      final currentRoute = Get.currentRoute;
      if (_currentRoute != null && currentRoute != _currentRoute) {
        _currentRoute = currentRoute;
        return true; // 路由变化，需要隐藏
      }

      // 检查当前 tab 是否是推广页面（index 2）
      if (Get.isRegistered<MainController>()) {
        final mainController = Get.find<MainController>();
        if (mainController.currentIndex != 2) {
          return true; // 当前不在推广页面，需要隐藏
        }
      }

      // 检查是否有弹窗显示
      if (Get.isDialogOpen == true ||
          Get.isSnackbarOpen == true ||
          Get.isBottomSheetOpen == true) {
        return true; // 有弹窗显示，需要隐藏
      }

      return false;
    } catch (e) {
      // 发生异常时，安全起见隐藏定位图
      return true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 当应用进入后台或暂停时，隐藏定位图
    if (state != AppLifecycleState.resumed) {
      _hideScaleWidget();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideOverlay();
    _triggerShimmerSubscription?.cancel();
    // 如果当前实例是显示定位图的实例，重置静态变量
    if (_currentShowingInstance == this) {
      _hasScaleWidgetShowing = false;
      _currentShowingInstance = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _widgetKey,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(
        bottom: 10.h,
        left: 6.w,
        right: 6.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.w),
        color: ByColorUtil.WhiteColor,
      ),
      child: GestureDetector(
        onTap: () {
          _startCreateEvent();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图片区域
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.w),
                        topRight: Radius.circular(12.w),
                      ),
                      child: widget.shortPlayBean.coverUrl.isEmpty
                          ? Container(
                              height: 218.h,
                              color: ByColorUtil.CommonPageBgColor,
                            )
                          : DiagonalShimmerWidget(
                              key: _shimmerKey,
                              autoPlay: false,
                              child: CachedNetworkImage(
                                imageUrl: widget.shortPlayBean.coverUrl,
                                width: double.infinity,
                                height: 218.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    // 播放图标
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        width: 24.w,
                        height: 24.w,
                        child: Image.asset(
                          "assets/v2/promote/promote-4.png",
                          width: 24.w,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ],
                ),
                // 内容区域
                Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      ByWidgetsUtil.commonText(
                        text: widget.shortPlayBean.materialName,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        textColor: ByColorUtil.CommonTextColor,
                        maxLines: 1,
                      ),
                      SizedBox(height: 6.h),
                      // 推广进账
                      if (!ChannelConfig.exclude_channel_earn
                          .contains(BuildConfig.instance.channelType.channel))
                        Row(
                          children: [
                            ByWidgetsUtil.commonText(
                              text: "推广进账:",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              textColor:
                                  const Color(0xFF0B1843).withOpacity(0.5),
                            ),
                            SizedBox(width: 4.w),
                            Image.asset(
                              "assets/v2/promote/promote-2.png",
                              width: 20.w,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(width: 3.w),
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) => const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFFFF8206),
                                  Color(0xFFFFB12F),
                                ],
                              ).createShader(
                                Rect.fromLTWH(
                                    0, 0, bounds.width, bounds.height),
                              ),
                              child: Text(
                                (widget.shortPlayBean.otherConfig?.maxIncome ??
                                        0)
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (!ChannelConfig.exclude_channel_earn
                          .contains(BuildConfig.instance.channelType.channel))
                        SizedBox(height: 6.h),
                      // 参与人数
                      Row(
                        children: [
                          ByWidgetsUtil.commonText(
                            text: "参与人数: ",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                            textColor: const Color(0xFF0B1843).withOpacity(0.5),
                          ),
                          ByWidgetsUtil.commonText(
                            text:
                                "${widget.shortPlayBean.otherConfig?.joinPeopleNum ?? 0}",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            textColor: const Color(0xFF0B1843).withOpacity(0.5),
                          ),
                        ],
                      ),

                      SizedBox(height: 10.h),
                      // 立即创作按钮
                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 36.h,
                      //   child: ByWidgetsUtil.commonBtn(
                      //     padding: EdgeInsets.zero,
                      //     borderRadius: 25.h,
                      //     title: "立即创作",
                      //     onClick: () {
                      //       startCreateEvent();
                      //     },
                      //   ),
                      // ),
                      SizedBox(
                        width: double.infinity,
                        height: 36.h,
                        child: Container(
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.h),
                            gradient: ByColorUtil.lineareGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colorStart: const Color(0xFFA060FC),
                              colorEnd: const Color(0xFF5B4BF7),
                            ),
                          ),
                          child: Center(
                            child: ByWidgetsUtil.commonText(
                              text: "立即创作",
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              textColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ScaleTransitionWidget 使用 Overlay 显示在最顶层，避免被列表项遮挡
            // 不再在这里直接显示，而是通过 Overlay 显示
          ],
        ),
      ),
    );
  }
}
