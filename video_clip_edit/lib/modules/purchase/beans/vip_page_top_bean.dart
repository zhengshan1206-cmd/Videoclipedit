
class VipPageTopBeanResponse {
  final int status;
  final String message;
  final VipPageTopData? data;

  VipPageTopBeanResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory VipPageTopBeanResponse.fromJson(Map<String, dynamic> json) {
    return VipPageTopBeanResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: json['data'] != null ? VipPageTopData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class VipPageTopData {
  final int id;
  final String title;
  final int picsShowType;
  final String subTitle;
  final String content;
  final List<String> pics;
  final int status;
  final String updatedAt;
  final String createdAt;

  VipPageTopData({
    required this.id,
    required this.title,
    required this.picsShowType,
    required this.subTitle,
    required this.content,
    required this.pics,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
  });

  factory VipPageTopData.fromJson(Map<String, dynamic> json) {
    return VipPageTopData(
      id: json['id'] as int,
      title: json['title'] as String,
      picsShowType: json['pics_show_type'] as int,
      subTitle: json['sub_title'] as String,
      content: json['content'] as String,
      pics: (json['pics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as int,
      updatedAt: json['updated_at'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pics_show_type': picsShowType,
      'sub_title': subTitle,
      'content': content,
      'pics': pics,
      'status': status,
      'updated_at': updatedAt,
      'created_at': createdAt,
    };
  }
}
    