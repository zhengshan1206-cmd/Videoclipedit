// ignore_for_file: must_be_immutable, use_build_context_synchronously, unused_field

import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_clip_edit/utils/comon/by_colors.dart';
import 'package:video_clip_edit/utils/comon/by_screen_utils.dart';
import 'package:video_clip_edit/utils/comon/by_widgets_util.dart';
import 'package:video_clip_edit/modules/home/providers/show_recreate_provider.dart';

const List<String> words = [
  "王伯成为人老实，做事木讷，在成亲前，他有份正当职业，倒也过得富足，可自从柯语柔过门后，王家的日子也变得紧巴巴起来。王伯成的母亲谢氏曾劝诫儿媳妇，你已身为人妇，应当全力相夫教子，现在连娃都未生，怎么能把钱都花在自己身上呢？富贵柯语柔可不管那么多，回怼道，你们王家要娶美女，就得有养美女的本事！谢氏本来身体就不好，被这么一气，驾鹤西去了。谢氏死后，柯语柔不仅不伤心，还说风凉话：家里少了个药罐子，日后能省下不少医药费呢！此话一出，气得王伯成全身直发抖，可他不善言辞，也不知道如何反驳媳妇，而且母亲谢氏本来就是行将就木的人，也不能盲目地将过错推到媳妇身上，最后也就不了了之。一天，王伯成早早地卖完肉，便提前回了家。在路过一处乱坟岗时，突然刮起一阵阴风，他将手握在杀猪刀把上，环顾四周。　　他哪里知道，是有人在跟踪他，乱坟岗处地势开放，跟踪的人无地可躲，只能迅速地趴下身子，到低洼处躲了起来，自然会有动静。　　此人是城里浪荡公子高俊的书童",
  "老鼠嫌弃你穷，给你叼来根两公斤重的金条，好让你去买套别墅改善生活。你当事人都傻了，但老鼠怕你守不住这笔横财，又给你叼来了权谱秘籍和调理身体的丹药。为了能让你安心过日子，他甚至还给你找了个绝色女友，只因你是他唯一的亲人。自从父母病逝之后，你就一直在用剩菜喂这只老鼠。本来只是为了排除寂寞，但当他知道你没钱买米下锅时，这老鼠竟然叼来一根金条。你不敢相信的扇了自己一巴掌，可金条依旧在你面前闪闪发光，这真的不是梦。现在金子一颗600块，两公斤就是200万。有了这200万不仅可以还清父母的欠款，还能剩下150万。你看着面前的老鼠一脸激动，随后拿起一包方便面，捏碎放在老鼠面前。这可真是个财神爷，你当即表示明天就把他的鼠窝翻新。不过老鼠吃饱后并没有看，只是点了下头就爬回了窝里。你抱着激动的心情一夜未眠。第二天一早就赶到了典当行。没有购买凭证的金条只能在这里出手。你让安保人员把你带到了包厢里，不过接待员看到你拿出的金条并没有吃惊，因为金条在这里很常见，就连门口的保安也见过几千次。接待员随意的戴上手套，但当金条入手后，接待员面色一变，大吃一惊，赶紧仔细的看了起来。这是古代金条，如果只是单纯的银行发售或自制金条，这些金条的价值一颗600，而古代金条可是古董，它不只在于金子的价格，还有更深层的收藏意义。所以这根金条的价值远超普通人想象。",
  "我穿越到平行世界，成为了一条龙，却想着抱国家的大腿，将自己伤交给国家。第二天，我就来到警署办理身份通行证。警察看到我，整个人压麻呆住。天啊龙啊，这个世界真有龙。而我之所以自己跑到警署来报道，全是因为我来到这个世界后，发现靠自己独自成长是那么困难的一件事，连维持最低的生活保障都办不到。虽然我现在是一条18厘米的幼年神龙，可生命所需要的物质能量都太高端了。尽管努力出去打猎，可消耗的能量比食物补充的能量更多，严重的入不敷出，没几天就饥肠辘辘，感觉要饿死了。刚穿越过来的那会，我虽是幼龙，还能喷雷吐火御风控水等超凡能力，可现在饿的只能喷出个小烟圈。于是我为了吃饱穿暖，我苦思冥想了1分钟，做出了一个重大决定，我要把自己上交给国家，只要别切片抽血，其他我都认了。所以这回我就来到警署报道，虽然我是主动上门求包养，但作为神龙，气质这块不能掉链子。只见我昂首挺胸，像个大爷，张嘴就短。龙在深山中修炼千载，如今要入市行走，体验红尘万种。为了避免和人类产生误会，特地来办理身份通行证。不知道流程要怎么走，警察一脸茫然。身份通行证他办过不少，但给龙办理还真没遇到，这业务他不熟啊。不过看到我，不像找茬的客气对着我说道：`神龙先生，龙类身份通行证办理手续，我上岗的时候没经过相关培训，要不您稍微等一下，我打电话问下上级。`不多时，警察署长骂骂咧咧的走过来，`这小丫头片子居然跟我开这种玩笑，龙在哪？`然而就在这时，一道有些稚嫩的声音在他背后响起，`你在找我吗？`当署长转过头，顿时吓得瘫坐在地上。只见我瞪着那卡姿兰般的金色眼睛，看着他，署长平复好久，才真的相信室友龙来办业务。可是署长也没有给龙办过身份通行证，于是他也赶紧联系了自己的上级领导，并且为了让上级领导相信他的话，还直接发的视频通话。上级领导也不知道该怎么办，于是相似的一幕再次出现，只能向更上级汇报。",
  "你明明是无敌于这个世界，唯一的一个陆地神仙。但你却只想当一条咸鱼，能躺着坚决不坐着，能坐着坚决不站着。由于你太过咸鱼，结果老天实在看不下去。于是降下天道金榜于世界，天道金榜可盘点世间一切，并将排列前世，公告天下。榜单分别为爵士榜、神兵榜、天君榜、角色榜。位列金榜可得天道赐福。而今日公布的，便是九州最强10位生灵的爵士榜。当听见天道金榜现世的一瞬间，整个九州大地，无论是王朝庙堂，还是江湖武林全都震动。但唯独你却摆出一副生无可恋的表情，这下完了，不会要把我给曝光了吧。你心中咯噔一跳，顿感不妙。要知道整个九州，能到大宗师的就已经寥寥无几，至于陆地神仙更是只有你一人。而且好像还有神兵榜和天君榜，望着那一个个榜单，你彻底麻了。要是把我家底都抖漏出来，那以后还怎么当咸鱼。此时一旁的侍女吴许见你这个模样，却掩嘴笑道“公子放心，以您的实力，一定可以登上金榜。”他还以为你是在担心金榜的问题。这大秦之中，谁都觉得九皇子盈云不堪大用，只知完。可吴许，却是知晓自家公子实力极其高深，表现出来的咸鱼模样，在他眼里只是为了韬光养晦。听着吴许安慰的话，你郁闷的点了点头，要是陆地神仙都不能登榜，那怕是也没人能上。但问题是把自己牢底曝光了，还怎么玩？罢了，走一步看一步吧！你摇了摇头，打算去逛逛街，缓解一下郁闷的心情。可没过多久，一道恢弘的声音回荡在天地之间：“爵士榜第十剑圣概念，境界一流可越级战宗师，宗师之下一换一！”随着天道之音落下，九州大地无数王朝出奇的寂静。“一流武者就可战宗师，这未免太离谱了些吧？”“而且如此恐怖的实力，只是排名第十？难道金榜前九竟是宗师强者？”话音未落，又是一道天道之音响起：“爵士榜第九袁天罡境界宗师，曾以一人之力打爆天外陨石！”望着天道金榜呈现出的画面九州大地再次呆滞。“这…一流武者就可战宗师？这前九竟然是宗师强者？”无数人脸上都掺杂着难以置信。“爵士榜第八铁胆神侯朱无世！”",
  "我真想给我爹两下。告诉我家里穷，上学千万别惹事，以至于我极度自卑，成了校园霸凌的对象。可成年这天，我才猛然发现，我们全家都是黑暗势力的大哥大，连高启强都是小弟中的小弟，拥有全球一半的顶级黑客、保镖界排名前100的保镖、恐怖组织公司都是家族产业，就连全世界的三大黑帮的领袖人物，也不过是我家族的三条狗。放眼全世界，恐怕也找不出第二个这么强大的家族。之所以之前那样教育我，只是怕我飘了，不好好学习。今天为庆祝我生日，父亲给我安排两个顶级美女保镖，凤凰和百合当保镖，姐姐随手给我6,000亿的零花钱，而母亲交给我一份名单，名单上有国内200余名高官的联系方式，只要我一个电话，他们就会乖乖替我办事。我心满意足的收下。突然想起今天学校举办毕业典礼，我叫来管家说自己要去青藤学院，而刘管家听到我的话，不由得有些惊讶的说道：“少爷，您居然愿意去。”看来您已经从失恋里走出来了呀。我微微一震，这才回忆起来，前不久，我曾经在青藤学院追求过一个女生，结果被无情拒绝不说，还被那女生当众羞辱。再加上心情低落，最近一直都没有回学院上课。想到这里，我摇头一笑。可是现在今世不同往日！不久之后一辆加长版的宾利就停在了青藤学院门口。我朝刘管家摆摆手，搂着保镖百合向教学楼走去。一路走来，路过的人无不投来羡慕的目光。到了教室门口我对百合笑道：“你在门口等我一下，我去领毕业证书。”“等会就出来。”随即我低下头在百合的唇上啄了一下后这才转身走进了教室。",
];

class HyberClipGuidContentView extends StatefulWidget {
  bool type;
  final int index;

  HyberClipGuidContentView({
    super.key,
    this.showCommentary = true,
    this.type = true,
    required this.index,
  });

  ///  是否显示顶部的解说列表
  final bool showCommentary;
  @override
  State<HyberClipGuidContentView> createState() =>
      _HyberClipGuidContentViewState();
}

class _HyberClipGuidContentViewState extends State<HyberClipGuidContentView> {
  @override
  void initState() {
    super.initState();
  }

  late ShowRecreateProvider _provider;
// ignore: slash_for_doc_comments
/************************************************ UI构建 ************************************************/

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ..._buildCopywriterSection(context),

        /// 视频比例
        ..._buildVideoRatiosSection(context),

        /// 解说字幕
        ..._buildSubtitlesSection(context),

        /// 选择模式
        ..._buildModesSection(context),

        /// 选择特效
        ..._buildSpecialEffectsSection(context),

        /// 背景音乐
        ..._buildBgmSection(context),

        _buildSectionTitle(
          title: "去除视频原声",
          rightWidget: Selector<ShowRecreateProvider,
                  Tuple2<ShowRecreateProvider, bool>>(
              selector: (p0, p1) => Tuple2(p1, p1.removeVideoAudio),
              builder: (
                context,
                tuple,
                child,
              ) {
                return Switch(
                  value: tuple.item2,
                  activeColor: ByColorUtil.WhiteColor,
                  activeTrackColor: ByColorUtil.LoginBtnBgColor,
                  inactiveTrackColor:
                      ByColorUtil.CommonTextColor.withOpacity(0.2),
                  inactiveThumbColor: const Color(0xFFF8F8F8),
                  trackOutlineColor:
                      const WidgetStatePropertyAll(Colors.transparent),
                  onChanged: (value) {
                    tuple.item1.updateRemoveVideoAudioStatus(!tuple.item2);
                  },
                );
              }),
        ),

        /// 安全距离
        SliverToBoxAdapter(
          child: SizedBox(height: ByScreenUtils.bottomSafeHeight + 60.h),
        ),
      ],
    );
  }

  /// 背景音乐组
  List<Widget> _buildBgmSection(BuildContext context) {
    final provider = context.watch<ShowRecreateProvider>();
    return [
      _buildSectionTitle(title: "背景音乐"),
      _buildSectionGride(
        itemCount: provider.bgms.length,
        crossAxisCount: 3,
        childAspectRatio: 109 / 36,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: _buildBGMCell(provider, index),
          );
        },
      ),
    ];
  }

  Container _buildBGMCell(ShowRecreateProvider provider, int index) {
    bool select = provider.selectedBgmIndex == index;
    if (select) {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ByColorUtil.LoginBtnBgColor,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(width: 16.w),
            ByWidgetsUtil.commonText(
              text: provider.bgms[provider.selectedBgmIndex],
              textColor: ByColorUtil.WhiteColor,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ByColorUtil.WhiteColor,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: ByWidgetsUtil.commonText(
          text: provider.bgms[index],
          textColor: ByColorUtil.CommonTextColor,
          fontWeight: FontWeight.normal,
        ),
      );
    }
  }

  /// 模式组
  _buildModesSection(BuildContext context) {
    final provider = context.watch<ShowRecreateProvider>();
    return [
      _buildSectionTitle(title: "选择模式"),
      _buildSectionGride(
        itemCount: provider.modes.length,
        crossAxisCount: 4,
        childAspectRatio: 20 / 9,
        itemBuilder: (ctx, index) {
          final modes = provider.modes;
          var selected = provider.selectedModes.contains(modes[index]);
          return GestureDetector(
            onTap: () {
              provider.updateSelectedModes(modes[index]);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: provider.modes[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// 特效组
  _buildSpecialEffectsSection(BuildContext context) {
    final provider = context.watch<ShowRecreateProvider>();
    return [
      _buildSectionTitle(title: "选择特效"),
      _buildSectionGride(
        itemCount: provider.speciaEffects.length,
        crossAxisCount: 4,
        childAspectRatio: 20 / 9,
        itemBuilder: (ctx, index) {
          final speciaEffects = provider.speciaEffects;
          var selected =
              provider.selectedSpeciaEffect.contains(speciaEffects[index]);
          return GestureDetector(
            onTap: () {
              provider.updateSelectedSpeciaEffect(speciaEffects[index]);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: provider.speciaEffects[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// 视频比例组
  _buildVideoRatiosSection(BuildContext context) {
    final Tuple3<List<String>, String, ShowRecreateProvider> ratiosTuple =
        context.select<ShowRecreateProvider,
            Tuple3<List<String>, String, ShowRecreateProvider>>(
      (p) => Tuple3(p.ratios, p.selectedRatio, p),
    );
    return [
      _buildSectionTitle(title: "视频比例"),
      _buildSectionGride(
        itemCount: ratiosTuple.item1.length,
        crossAxisCount: 5,
        childAspectRatio: 5 / 3,
        itemBuilder: (ctx, index) {
          final ratios = ratiosTuple.item1;
          var selected = ratios[index] == ratiosTuple.item2;
          return GestureDetector(
            onTap: () {},
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: ratiosTuple.item1[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  /// 字幕组
  _buildSubtitlesSection(BuildContext context) {
    final provider = context.watch<ShowRecreateProvider>();
    return [
      _buildSectionTitle(title: "解说字幕"),
      _buildSectionGride(
        itemCount: provider.subTitles.length,
        crossAxisCount: 4,
        childAspectRatio: 20 / 9,
        itemBuilder: (ctx, index) {
          final current = provider.subTitles[index];
          var selected = current == provider.selectedSubTitle;
          return GestureDetector(
            onTap: () {
              provider.updateSelectedSubTitle(current);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ByColorUtil.LoginBtnBgColor
                    : ByColorUtil.WhiteColor,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: ByWidgetsUtil.commonText(
                text: provider.subTitles[index],
                textColor: selected
                    ? ByColorUtil.WhiteColor
                    : ByColorUtil.CommonTextColor,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    ];
  }

  _buildCopywriterSection(BuildContext ctx) {
    return [
      _buildSectionTitle(
          title: "解说文案",
          rightWidget: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/home/icon_edit.png",
                  width: 12.w,
                  height: 12.h,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 5),
                ByWidgetsUtil.commonText(
                  text: "修改",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  textColor: ByColorUtil.TabTextColorSelected,
                )
              ],
            ),
          )),
      SliverToBoxAdapter(
        child: ByWidgetsUtil.commonContainer(
          margin: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            bottom: 10.h,
          ),
          padding: EdgeInsets.all(12.w),
          child: ByWidgetsUtil.commonText(
            maxLines: 10,
            text: words[widget.index],
            fontSize: 14.sp,
          ),
        ),
      ),
    ];
  }

  /// 组标题
  _buildSectionTitle({
    required String title,
    Widget? rightWidget,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 10.h,
        ),
        child: Row(
          children: [
            ByWidgetsUtil.commonText(
              text: title,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
            const Spacer(),
            if (rightWidget != null) rightWidget
          ],
        ),
      ),
    );
  }

  /// 九宫格
  _buildSectionGride({
    required int crossAxisCount,
    required int? itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    double childAspectRatio = 1.0,
  }) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        bottom: 10.h,
      ),
      sliver: SliverGrid.builder(
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: childAspectRatio),
        itemBuilder: (context, index) {
          return itemBuilder(context, index);
        },
      ),
    );
  }

/************************************************ UI构建 ************************************************/
}
