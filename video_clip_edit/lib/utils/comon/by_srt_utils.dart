import 'dart:io';

/**
 * 字母
 */
class BySrtUtils {
  List<String> _contentList = [];

  /**
   * 添加内容
   */
  addContent(double offset, String content) {
    RegExp exp = RegExp(
        r'(\d{2}:\d{2}:\d{2}),(\d{3})\s+-->\s+(\d{2}:\d{2}:\d{2}),(\d{3})\r?\n(.+)?\r?\n');
    Iterable<Match> matches = exp.allMatches(content);
    for (Match match in matches) {
      var stime = match.group(1) ?? "";
      var stimehm = match.group(2) ?? "";
      var endtime = match.group(3) ?? "";
      var endtimehm = match.group(4) ?? "";
      List<String> parts = stime.split(":");
      double s = int.parse(parts[0]) * 3600 +
          int.parse(parts[1]) * 60 +
          int.parse(parts[2]) +
          int.parse(stimehm) / 1000 +
          offset;
      parts = endtime.split(":");
      double e = int.parse(parts[0]) * 3600 +
          int.parse(parts[1]) * 60 +
          int.parse(parts[2]) +
          int.parse(endtimehm) / 1000 +
          offset;
      stime = (s / 3600).floor().toString().padLeft(2, '0') +
          ":" +
          ((s % 3600) / 60).floor().toString().padLeft(2, '0') +
          ":" +
          ((s % 60).floor()).toString().padLeft(2, '0') +
          "," +
          ((s % 1) * 1000).floor().toString().padLeft(3, '0');
      endtime = (e / 3600).floor().toString().padLeft(2, '0') +
          ":" +
          ((e % 3600) / 60).floor().toString().padLeft(2, '0') +
          ":" +
          ((e % 60).floor()).toString().padLeft(2, '0') +
          "," +
          ((e % 1) * 1000).floor().toString().padLeft(3, '0');
      var txt = "${stime} --> ${endtime}\n${match.group(5)}";
      _contentList.add(txt);
    }
    return true;
  }

  /**
   * 获取长度
   */
  getSize() {
    return _contentList.length;
  }

  /**
   * 添加文件目录
   */
  addFilePath(double offset, String filePath) {
    File file = new File(filePath);
    return addFile(offset, file);
  }

  /**
   * 添加文件
   */
  addFile(double offset, File file) {
    if (!file.existsSync()) {
      return false;
    }
    var content = file.readAsStringSync();
    return addContent(offset, content);
  }

  /**
   * 返回Srt文件内容
   */
  toContent() {
    var texts = "";
    for (var i = 0; i < _contentList.length; i++) {
      texts = "${texts}${i + 1}\n${_contentList[i]}\n\n";
    }
    return texts;
  }

  /**
   * 保存到文件
   */
  toFile(String filePath) {
    File file = new File(filePath);
    return saveFile(file);
  }

  /**
   * 保存到文件
   */
  saveFile(File file) {
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(toContent());
    return file;
  }

  /**
   * 处理单个文件
   */
  static handleSingleFile(double offset, File file) {
    BySrtUtils util = new BySrtUtils();
    util.addFile(offset, file);
    return util.saveFile(file);
  }

  /**
   * 处理单个文件目录
   */
  static handleSingleFilePath(double offset, String filePath) {
    File file = new File(filePath);
    file = handleSingleFile(offset, file);
    return file.path;
  }
}
