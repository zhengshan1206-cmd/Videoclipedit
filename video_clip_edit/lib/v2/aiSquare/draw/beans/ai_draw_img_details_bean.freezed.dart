// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_draw_img_details_bean.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiDrawImgDetailsBean _$AiDrawImgDetailsBeanFromJson(Map<String, dynamic> json) {
  return _AiDrawImgDetailsBean.fromJson(json);
}

/// @nodoc
mixin _$AiDrawImgDetailsBean {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "status")
  int get status => throw _privateConstructorUsedError;
  @JsonKey(name: "prompt")
  String get prompt => throw _privateConstructorUsedError;
  @JsonKey(name: "pic_url")
  String get picUrl => throw _privateConstructorUsedError;
  @JsonKey(name: "ratio")
  String get ratio => throw _privateConstructorUsedError;
  @JsonKey(name: "model_id")
  int get modelId => throw _privateConstructorUsedError;
  @JsonKey(name: "model")
  String get model => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AiDrawImgDetailsBean to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiDrawImgDetailsBean
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiDrawImgDetailsBeanCopyWith<AiDrawImgDetailsBean> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiDrawImgDetailsBeanCopyWith<$Res> {
  factory $AiDrawImgDetailsBeanCopyWith(AiDrawImgDetailsBean value,
          $Res Function(AiDrawImgDetailsBean) then) =
      _$AiDrawImgDetailsBeanCopyWithImpl<$Res, AiDrawImgDetailsBean>;
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "status") int status,
      @JsonKey(name: "prompt") String prompt,
      @JsonKey(name: "pic_url") String picUrl,
      @JsonKey(name: "ratio") String ratio,
      @JsonKey(name: "model_id") int modelId,
      @JsonKey(name: "model") String model,
      @JsonKey(name: "created_at") String? createdAt});
}

/// @nodoc
class _$AiDrawImgDetailsBeanCopyWithImpl<$Res,
        $Val extends AiDrawImgDetailsBean>
    implements $AiDrawImgDetailsBeanCopyWith<$Res> {
  _$AiDrawImgDetailsBeanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiDrawImgDetailsBean
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? prompt = null,
    Object? picUrl = null,
    Object? ratio = null,
    Object? modelId = null,
    Object? model = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      prompt: null == prompt
          ? _value.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
      picUrl: null == picUrl
          ? _value.picUrl
          : picUrl // ignore: cast_nullable_to_non_nullable
              as String,
      ratio: null == ratio
          ? _value.ratio
          : ratio // ignore: cast_nullable_to_non_nullable
              as String,
      modelId: null == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as int,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiDrawImgDetailsBeanImplCopyWith<$Res>
    implements $AiDrawImgDetailsBeanCopyWith<$Res> {
  factory _$$AiDrawImgDetailsBeanImplCopyWith(_$AiDrawImgDetailsBeanImpl value,
          $Res Function(_$AiDrawImgDetailsBeanImpl) then) =
      __$$AiDrawImgDetailsBeanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "status") int status,
      @JsonKey(name: "prompt") String prompt,
      @JsonKey(name: "pic_url") String picUrl,
      @JsonKey(name: "ratio") String ratio,
      @JsonKey(name: "model_id") int modelId,
      @JsonKey(name: "model") String model,
      @JsonKey(name: "created_at") String? createdAt});
}

/// @nodoc
class __$$AiDrawImgDetailsBeanImplCopyWithImpl<$Res>
    extends _$AiDrawImgDetailsBeanCopyWithImpl<$Res, _$AiDrawImgDetailsBeanImpl>
    implements _$$AiDrawImgDetailsBeanImplCopyWith<$Res> {
  __$$AiDrawImgDetailsBeanImplCopyWithImpl(_$AiDrawImgDetailsBeanImpl _value,
      $Res Function(_$AiDrawImgDetailsBeanImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiDrawImgDetailsBean
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? prompt = null,
    Object? picUrl = null,
    Object? ratio = null,
    Object? modelId = null,
    Object? model = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$AiDrawImgDetailsBeanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      prompt: null == prompt
          ? _value.prompt
          : prompt // ignore: cast_nullable_to_non_nullable
              as String,
      picUrl: null == picUrl
          ? _value.picUrl
          : picUrl // ignore: cast_nullable_to_non_nullable
              as String,
      ratio: null == ratio
          ? _value.ratio
          : ratio // ignore: cast_nullable_to_non_nullable
              as String,
      modelId: null == modelId
          ? _value.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as int,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiDrawImgDetailsBeanImpl implements _AiDrawImgDetailsBean {
  const _$AiDrawImgDetailsBeanImpl(
      {@JsonKey(name: "id") required this.id,
      @JsonKey(name: "status") required this.status,
      @JsonKey(name: "prompt") required this.prompt,
      @JsonKey(name: "pic_url") required this.picUrl,
      @JsonKey(name: "ratio") required this.ratio,
      @JsonKey(name: "model_id") required this.modelId,
      @JsonKey(name: "model") required this.model,
      @JsonKey(name: "created_at") required this.createdAt});

  factory _$AiDrawImgDetailsBeanImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiDrawImgDetailsBeanImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "status")
  final int status;
  @override
  @JsonKey(name: "prompt")
  final String prompt;
  @override
  @JsonKey(name: "pic_url")
  final String picUrl;
  @override
  @JsonKey(name: "ratio")
  final String ratio;
  @override
  @JsonKey(name: "model_id")
  final int modelId;
  @override
  @JsonKey(name: "model")
  final String model;
  @override
  @JsonKey(name: "created_at")
  final String? createdAt;

  @override
  String toString() {
    return 'AiDrawImgDetailsBean(id: $id, status: $status, prompt: $prompt, picUrl: $picUrl, ratio: $ratio, modelId: $modelId, model: $model, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiDrawImgDetailsBeanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.picUrl, picUrl) || other.picUrl == picUrl) &&
            (identical(other.ratio, ratio) || other.ratio == ratio) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, status, prompt, picUrl,
      ratio, modelId, model, createdAt);

  /// Create a copy of AiDrawImgDetailsBean
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiDrawImgDetailsBeanImplCopyWith<_$AiDrawImgDetailsBeanImpl>
      get copyWith =>
          __$$AiDrawImgDetailsBeanImplCopyWithImpl<_$AiDrawImgDetailsBeanImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiDrawImgDetailsBeanImplToJson(
      this,
    );
  }
}

abstract class _AiDrawImgDetailsBean implements AiDrawImgDetailsBean {
  const factory _AiDrawImgDetailsBean(
          {@JsonKey(name: "id") required final int id,
          @JsonKey(name: "status") required final int status,
          @JsonKey(name: "prompt") required final String prompt,
          @JsonKey(name: "pic_url") required final String picUrl,
          @JsonKey(name: "ratio") required final String ratio,
          @JsonKey(name: "model_id") required final int modelId,
          @JsonKey(name: "model") required final String model,
          @JsonKey(name: "created_at") required final String? createdAt}) =
      _$AiDrawImgDetailsBeanImpl;

  factory _AiDrawImgDetailsBean.fromJson(Map<String, dynamic> json) =
      _$AiDrawImgDetailsBeanImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "status")
  int get status;
  @override
  @JsonKey(name: "prompt")
  String get prompt;
  @override
  @JsonKey(name: "pic_url")
  String get picUrl;
  @override
  @JsonKey(name: "ratio")
  String get ratio;
  @override
  @JsonKey(name: "model_id")
  int get modelId;
  @override
  @JsonKey(name: "model")
  String get model;
  @override
  @JsonKey(name: "created_at")
  String? get createdAt;

  /// Create a copy of AiDrawImgDetailsBean
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiDrawImgDetailsBeanImplCopyWith<_$AiDrawImgDetailsBeanImpl>
      get copyWith => throw _privateConstructorUsedError;
}
