import 'package:video_clip_edit/utils/comon/by_common_utils.dart';

extension ByListExt<T> on List<T> {
  ///todo 数据漏了
  int addElementsByRemovingLast(
    List<T> elements, {
    /// 当前页码
    int currentPage = 1,

    /// 每页条数
    int pageSize = 10,
    bool reset = false,
  }) {
    /// 最后一页没有满，则移除最后一页的数据
    if (reset) {
      clear();
    } else if (length > pageSize * (currentPage - 1) &&
        length < pageSize * currentPage) {
      removeRange(pageSize * (currentPage - 1), length);
    }

    /// 数据满一页，页码数+一
    if (elements.length == pageSize) {
      currentPage++;
    }

    addAll(elements);
    return currentPage;
  }

  List<E> swap<E>(List<E> list, int from, int to) {
    if (from < 0 || from >= list.length || to < 0 || to >= list.length) {
      byDebugPrint('交换的元素下标无效:from - $from  to - $to');
      return list;
    }
    var temp = list[from];
    list[from] = list[to];
    list[to] = temp;
    return list;
  }
}
