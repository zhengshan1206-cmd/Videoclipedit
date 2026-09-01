class PageHelper {
  PageHelper();

  int page = 1;
  int row = 10; //一个请求多少个数据

  void resetPage() {
    page = 1;
  }

  void addPage() {
    page += 1;
  }
}
