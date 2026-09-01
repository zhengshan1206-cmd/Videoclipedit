import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';
import 'package:video_clip_edit/modules/home/recreate/beans/commentary_item_bean.dart';
import 'package:video_clip_edit/modules/home/recreate/widgets/role_words_cell.dart';
import 'package:video_clip_edit/modules/home/words/beans/audio_result_bean.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_common_utils.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/utils/comon/by_nav_router_utils.dart';
import 'package:video_clip_edit/modules/home/providers/material_base_provider.dart';

enum RoleEditType {
  /// 角色名称
  roleName,

  /// 角色台词
  roleQuotes
}

extension RoleEditTypeExt on RoleEditType {
  String get dailogTitle {
    switch (this) {
      case RoleEditType.roleName:
        return "修改角色名";
      default:
        return "修改台词";
    }
  }

  String get dailogHintText {
    switch (this) {
      case RoleEditType.roleName:
        return "请输入名称";
      default:
        return "请输入台词";
    }
  }

  TextAlign get inputAlignment {
    switch (this) {
      case RoleEditType.roleName:
        return TextAlign.center;
      default:
        return TextAlign.left;
    }
  }

  String dailogValueOrigin(AudioResultBean bean) {
    switch (this) {
      case RoleEditType.roleName:
        return bean.speaker;
      default:
        return bean.text;
    }
  }
}

class RoleEditDailog<T extends MaterialBaseProvider> extends StatefulWidget {
  final RoleEditType type;
  final RoleWordsCellType cellType;
  final AudioResultBean? roleWordsBean;
  final CommentaryItemBean? commentaryItemBean;
  final int? storylineIndex;
  final int? wordIndex;
  final bool? commentary;

  /// 步骤2中台词的下标
  final int? indexInStep2;
  final bool showConfirm;

  const RoleEditDailog({
    super.key,
    required this.type,
    required this.roleWordsBean,
    this.cellType = RoleWordsCellType.nromal,
    this.storylineIndex,
    this.wordIndex,
    this.commentaryItemBean,
    this.commentary,
    this.indexInStep2,
    this.showConfirm = false,
  });

  @override
  State<RoleEditDailog<T>> createState() => _RoleEditDailogState<T>();
}

class _RoleEditDailogState<T extends MaterialBaseProvider>
    extends State<RoleEditDailog<T>> {
  final TextEditingController wordsEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              bottom: 14.h + ByScreenUtils.bottomSafeHeight,
              left: 11.w,
              right: 11.w,
            ),
            decoration: BoxDecoration(
              color: ByColorUtil.WhiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.w),
                topRight: Radius.circular(18.w),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 13.h),
                _buildTitle(context),
                SizedBox(height: 20.h),
                _buildOriginalValue(context),
                SizedBox(height: 7.h),
                Image.asset(
                  "assets/home/icon_clip_replace.png",
                  width: 16.w,
                  height: 16.w,
                ),
                SizedBox(height: 7.h),
                _buildInput(),
                SizedBox(height: 10.h),
                if (!widget.showConfirm)
                  Row(
                    children: [
                      Expanded(
                        child: ByWidgetsUtil.commonBtn(
                          title: "修改单句",
                          fontSize: 16.sp,
                          onClick: () {
                            if (wordsEditingController.text.isEmpty) {
                              BotToast.showText(text: "请输入修改内容");
                              return;
                            }
                            final provider =
                                context.read<T>() as ShowRecreateProvider;
                            if (widget.type == RoleEditType.roleQuotes) {
                              if (widget.cellType == RoleWordsCellType.nromal) {
                                provider.modifyQuotes(
                                  bean: widget.roleWordsBean!,
                                  replace: wordsEditingController.text,
                                  onSuccess: () {
                                    ByNavRouterUtils.goBack(context);
                                  },
                                );
                              } else {
                                final replaced = wordsEditingController.text;
                                if (widget.commentary ?? false) {
                                  byDebugPrint(
                                      "widget.storylineIndex:${widget.storylineIndex} --- replaced:$replaced");
                                  provider.modifyCommentary(
                                    bean: widget.commentaryItemBean!,
                                    index: widget.storylineIndex!,
                                    replace: replaced,
                                    onSuccess: (changed) {
                                      ByNavRouterUtils.goBack(context);
                                    },
                                  );
                                } else {
                                  final CommentaryItemBean commentaryItemBean =
                                      provider.commentaryItemBeans[
                                              widget.storylineIndex!]
                                          .copyWith();
                                  commentaryItemBean.talk[widget.wordIndex!]
                                      .text = wordsEditingController.text;
                                  provider.updateCommentaryItemBeanAtIndex(
                                      widget.storylineIndex!,
                                      commentaryItemBean);
                                  ByNavRouterUtils.goBack(context);
                                }
                              }
                            } else {
                              if (widget.cellType == RoleWordsCellType.nromal) {
                                provider.modifyCurrentRoleName(
                                  bean: widget.roleWordsBean!,
                                  replace: wordsEditingController.text,
                                  onSuccess: () {
                                    ByNavRouterUtils.goBack(context);
                                  },
                                );
                              } else {
                                final replaced = wordsEditingController.text;
                                if (widget.commentary ?? false) {
                                  provider.modifyRoleName(
                                    bean: widget.roleWordsBean!,
                                    replace: replaced,
                                    onSuccess: () {
                                      for (var bean
                                          in provider.commentaryItemBeans) {
                                        for (var ele in bean.talk) {
                                          if (ele.speaker ==
                                              widget.roleWordsBean!.speaker) {
                                            ele.speaker = replaced;
                                          }
                                        }
                                      }
                                      ByNavRouterUtils.goBack(context);
                                    },
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 10.h),
                      Expanded(
                        child: ByWidgetsUtil.commonBtn(
                          title: "全部修改",
                          fontSize: 16.sp,
                          onClick: () {
                            if (wordsEditingController.text.isEmpty) {
                              BotToast.showText(text: "请输入修改内容");
                              return;
                            }
                            final provider =
                                context.read<T>() as ShowRecreateProvider;
                            if (widget.type == RoleEditType.roleQuotes) {
                              if (widget.cellType == RoleWordsCellType.nromal) {
                                provider.modifyQuotes(
                                  bean: widget.roleWordsBean!,
                                  replace: wordsEditingController.text,
                                  onSuccess: () {
                                    ByNavRouterUtils.goBack(context);
                                  },
                                );
                              } else {
                                final replaced = wordsEditingController.text;
                                if (widget.commentary ?? false) {
                                  byDebugPrint(
                                      "widget.storylineIndex:${widget.storylineIndex} --- replaced:$replaced");
                                  provider.modifyCommentary(
                                    bean: widget.commentaryItemBean!,
                                    index: widget.storylineIndex!,
                                    replace: replaced,
                                    onSuccess: (changed) {
                                      ByNavRouterUtils.goBack(context);
                                    },
                                  );
                                } else {
                                  final CommentaryItemBean commentaryItemBean =
                                      provider.commentaryItemBeans[
                                              widget.storylineIndex!]
                                          .copyWith();
                                  commentaryItemBean.talk[widget.wordIndex!]
                                      .text = wordsEditingController.text;
                                  provider.updateCommentaryItemBeanAtIndex(
                                      widget.storylineIndex!,
                                      commentaryItemBean);
                                  ByNavRouterUtils.goBack(context);
                                }
                              }
                            } else {
                              if (widget.cellType == RoleWordsCellType.nromal) {
                                provider.modifyRoleName(
                                  bean: widget.roleWordsBean!,
                                  replace: wordsEditingController.text,
                                  onSuccess: () {
                                    ByNavRouterUtils.goBack(context);
                                  },
                                );
                              } else {
                                final replaced = wordsEditingController.text;
                                if (widget.commentary ?? false) {
                                  provider.modifyRoleName(
                                    bean: widget.roleWordsBean!,
                                    replace: replaced,
                                    onSuccess: () {
                                      for (var bean
                                          in provider.commentaryItemBeans) {
                                        for (var ele in bean.talk) {
                                          if (ele.speaker ==
                                              widget.roleWordsBean!.speaker) {
                                            ele.speaker = replaced;
                                          }
                                        }
                                      }
                                      ByNavRouterUtils.goBack(context);
                                    },
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                if (widget.showConfirm)
                  ByWidgetsUtil.commonBtn(
                    title: "确认",
                    fontSize: 16.sp,
                    onClick: () {
                      if (wordsEditingController.text.isEmpty) {
                        BotToast.showText(text: "请输入修改内容");
                        return;
                      }
                      final provider =
                          context.read<T>() as ShowRecreateProvider;
                      if (widget.type == RoleEditType.roleQuotes) {
                        if (widget.cellType == RoleWordsCellType.nromal) {
                          provider.modifyQuotes(
                            bean: widget.roleWordsBean!,
                            replace: wordsEditingController.text,
                            onSuccess: () {
                              ByNavRouterUtils.goBack(context);
                            },
                          );
                        } else {
                          final replaced = wordsEditingController.text;
                          if (widget.commentary ?? false) {
                            byDebugPrint(
                                "widget.storylineIndex:${widget.storylineIndex} --- replaced:$replaced");
                            provider.modifyCommentary(
                              bean: widget.commentaryItemBean!,
                              index: widget.storylineIndex!,
                              replace: replaced,
                              onSuccess: (changed) {
                                ByNavRouterUtils.goBack(context);
                              },
                            );
                          } else {
                            final CommentaryItemBean commentaryItemBean =
                                provider
                                    .commentaryItemBeans[widget.storylineIndex!]
                                    .copyWith();
                            commentaryItemBean.talk[widget.wordIndex!].text =
                                wordsEditingController.text;
                            provider.updateCommentaryItemBeanAtIndex(
                                widget.storylineIndex!, commentaryItemBean);
                            ByNavRouterUtils.goBack(context);
                          }
                        }
                      } else {
                        if (widget.cellType == RoleWordsCellType.nromal) {
                          provider.modifyRoleName(
                            bean: widget.roleWordsBean!,
                            replace: wordsEditingController.text,
                            onSuccess: () {
                              ByNavRouterUtils.goBack(context);
                            },
                          );
                        } else {
                          final replaced = wordsEditingController.text;
                          if (widget.commentary ?? false) {
                            provider.modifyRoleName(
                              bean: widget.roleWordsBean!,
                              replace: replaced,
                              onSuccess: () {
                                for (var bean in provider.commentaryItemBeans) {
                                  for (var ele in bean.talk) {
                                    if (ele.speaker ==
                                        widget.roleWordsBean!.speaker) {
                                      ele.speaker = replaced;
                                    }
                                  }
                                }
                                ByNavRouterUtils.goBack(context);
                              },
                            );
                          }
                        }
                      }
                    },
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 30.w),
        const Spacer(),
        ByWidgetsUtil.commonText(
          text: (widget.commentary ?? false) ? "修改解说" : widget.type.dailogTitle,
          textColor: ByColorUtil.CommonTextColor,
          fontSize: 16.sp,
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ByNavRouterUtils.goBack(context);
          },
          child: Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/home/icon_close_dark.png",
              width: 12,
              height: 12,
            ),
          ),
        ),
      ],
    );
  }

  _buildOriginalValue(BuildContext context) {
    final origin = (widget.commentary ?? false)
        ? widget.commentaryItemBean!.commentary.commentary
        : widget.type.dailogValueOrigin(widget.roleWordsBean!);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 50.h),
      child: GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: origin));
          BotToast.showText(text: "复制成功");
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFECF1F3),
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: ByWidgetsUtil.commonText(
            maxLines: 100,
            text: origin,
            textColor: ByColorUtil.CommonTextColor,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  _buildInput() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      height: (widget.type == RoleEditType.roleQuotes) ? 100.h : 50.h,
      decoration: BoxDecoration(
        color: const Color(0xFFECF1F3),
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: TextField(
        minLines: 1,
        maxLines: 100,
        // cursorHeight: 16.sp,
        controller: wordsEditingController,
        textAlign: widget.type.inputAlignment,
        textAlignVertical: TextAlignVertical.top,
        cursorColor: ByColorUtil.CommonTextColor,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 20 - 8.sp),
          border: InputBorder.none,
          labelStyle: TextStyle(
            fontSize: 16.sp,
            color: ByColorUtil.CommonTextColor,
          ),
          hintStyle: TextStyle(
            fontSize: 16.sp,
            color: ByColorUtil.CommonTextColor.withOpacity(0.3),
          ),
          hintText: widget.type.dailogHintText,
        ),
      ),
    );
  }
}
