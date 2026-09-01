import 'dart:convert';

class UploadInfoBean {
  String ossAccessKeyId;
  String policy;
  String key;
  String url;
  String signature;
  String objectUrl;
  String coverUrl;

  UploadInfoBean({
    required this.ossAccessKeyId,
    required this.policy,
    required this.key,
    required this.url,
    required this.signature,
    required this.objectUrl,
    required this.coverUrl,
  });

  UploadInfoBean copyWith({
    String? ossAccessKeyId,
    String? policy,
    String? key,
    String? url,
    String? signature,
    String? objectUrl,
    String? coverUrl,
  }) =>
      UploadInfoBean(
        ossAccessKeyId: ossAccessKeyId ?? this.ossAccessKeyId,
        policy: policy ?? this.policy,
        key: key ?? this.key,
        url: url ?? this.url,
        signature: signature ?? this.signature,
        objectUrl: objectUrl ?? this.objectUrl,
        coverUrl: coverUrl ?? this.coverUrl,
      );

  factory UploadInfoBean.fromRawJson(String str) =>
      UploadInfoBean.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UploadInfoBean.fromJson(Map<String, dynamic> json) => UploadInfoBean(
        ossAccessKeyId: json["OSSAccessKeyId"],
        policy: json["policy"],
        key: json["key"],
        url: json["url"],
        signature: json["Signature"],
        objectUrl: json["object_url"],
        coverUrl: json["cover_url"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "OSSAccessKeyId": ossAccessKeyId,
        "policy": policy,
        "key": key,
        "url": url,
        "Signature": signature,
        "object_url": objectUrl,
        "cover_url": coverUrl,
      };
}
