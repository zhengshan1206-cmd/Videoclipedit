// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_draw_config_bean.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiDrawConfigBean _$AiDrawConfigBeanFromJson(Map<String, dynamic> json) {
  return _AiDrawConfigBean.fromJson(json);
}

/// @nodoc
mixin _$AiDrawConfigBean {
  @JsonKey(name: "ratios")
  List<Ratio> get ratios => throw _privateConstructorUsedError;
  @JsonKey(name: "imgStyles")
  List<ImgStyle> get imgStyles => throw _privateConstructorUsedError;

  /// Serializes this AiDrawConfigBean to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiDrawConfigBean
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiDrawConfigBeanCopyWith<AiDrawConfigBean> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiDrawConfigBeanCopyWith<$Res> {
  factory $AiDrawConfigBeanCopyWith(
          AiDrawConfigBean value, $Res Function(AiDrawConfigBean) then) =
      _$AiDrawConfigBeanCopyWithImpl<$Res, AiDrawConfigBean>;
  @useResult
  $Res call(
      {@JsonKey(name: "ratios") List<Ratio> ratios,
      @JsonKey(name: "imgStyles") List<ImgStyle> imgStyles});
}

/// @nodoc
class _$AiDrawConfigBeanCopyWithImpl<$Res, $Val extends AiDrawConfigBean>
    implements $AiDrawConfigBeanCopyWith<$Res> {
  _$AiDrawConfigBeanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiDrawConfigBean
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ratios = null,
    Object? imgStyles = null,
  }) {
    return _then(_value.copyWith(
      ratios: null == ratios
          ? _value.ratios
          : ratios // ignore: cast_nullable_to_non_nullable
              as List<Ratio>,
      imgStyles: null == imgStyles
          ? _value.imgStyles
          : imgStyles // ignore: cast_nullable_to_non_nullable
              as List<ImgStyle>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiDrawConfigBeanImplCopyWith<$Res>
    implements $AiDrawConfigBeanCopyWith<$Res> {
  factory _$$AiDrawConfigBeanImplCopyWith(_$AiDrawConfigBeanImpl value,
          $Res Function(_$AiDrawConfigBeanImpl) then) =
      __$$AiDrawConfigBeanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "ratios") List<Ratio> ratios,
      @JsonKey(name: "imgStyles") List<ImgStyle> imgStyles});
}

/// @nodoc
class __$$AiDrawConfigBeanImplCopyWithImpl<$Res>
    extends _$AiDrawConfigBeanCopyWithImpl<$Res, _$AiDrawConfigBeanImpl>
    implements _$$AiDrawConfigBeanImplCopyWith<$Res> {
  __$$AiDrawConfigBeanImplCopyWithImpl(_$AiDrawConfigBeanImpl _value,
      $Res Function(_$AiDrawConfigBeanImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiDrawConfigBean
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ratios = null,
    Object? imgStyles = null,
  }) {
    return _then(_$AiDrawConfigBeanImpl(
      ratios: null == ratios
          ? _value._ratios
          : ratios // ignore: cast_nullable_to_non_nullable
              as List<Ratio>,
      imgStyles: null == imgStyles
          ? _value._imgStyles
          : imgStyles // ignore: cast_nullable_to_non_nullable
              as List<ImgStyle>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiDrawConfigBeanImpl implements _AiDrawConfigBean {
  const _$AiDrawConfigBeanImpl(
      {@JsonKey(name: "ratios") required final List<Ratio> ratios,
      @JsonKey(name: "imgStyles") required final List<ImgStyle> imgStyles})
      : _ratios = ratios,
        _imgStyles = imgStyles;

  factory _$AiDrawConfigBeanImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiDrawConfigBeanImplFromJson(json);

  final List<Ratio> _ratios;
  @override
  @JsonKey(name: "ratios")
  List<Ratio> get ratios {
    if (_ratios is EqualUnmodifiableListView) return _ratios;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ratios);
  }

  final List<ImgStyle> _imgStyles;
  @override
  @JsonKey(name: "imgStyles")
  List<ImgStyle> get imgStyles {
    if (_imgStyles is EqualUnmodifiableListView) return _imgStyles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imgStyles);
  }

  @override
  String toString() {
    return 'AiDrawConfigBean(ratios: $ratios, imgStyles: $imgStyles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiDrawConfigBeanImpl &&
            const DeepCollectionEquality().equals(other._ratios, _ratios) &&
            const DeepCollectionEquality()
                .equals(other._imgStyles, _imgStyles));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_ratios),
      const DeepCollectionEquality().hash(_imgStyles));

  /// Create a copy of AiDrawConfigBean
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiDrawConfigBeanImplCopyWith<_$AiDrawConfigBeanImpl> get copyWith =>
      __$$AiDrawConfigBeanImplCopyWithImpl<_$AiDrawConfigBeanImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiDrawConfigBeanImplToJson(
      this,
    );
  }
}

abstract class _AiDrawConfigBean implements AiDrawConfigBean {
  const factory _AiDrawConfigBean(
      {@JsonKey(name: "ratios") required final List<Ratio> ratios,
      @JsonKey(name: "imgStyles")
      required final List<ImgStyle> imgStyles}) = _$AiDrawConfigBeanImpl;

  factory _AiDrawConfigBean.fromJson(Map<String, dynamic> json) =
      _$AiDrawConfigBeanImpl.fromJson;

  @override
  @JsonKey(name: "ratios")
  List<Ratio> get ratios;
  @override
  @JsonKey(name: "imgStyles")
  List<ImgStyle> get imgStyles;

  /// Create a copy of AiDrawConfigBean
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiDrawConfigBeanImplCopyWith<_$AiDrawConfigBeanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImgStyle _$ImgStyleFromJson(Map<String, dynamic> json) {
  return _ImgStyle.fromJson(json);
}

/// @nodoc
mixin _$ImgStyle {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "title")
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: "url")
  String get url => throw _privateConstructorUsedError;
  @JsonKey(name: "prompts")
  List<String> get prompts => throw _privateConstructorUsedError;
  @JsonKey(name: "integral_user")
  int get integralUser => throw _privateConstructorUsedError;

  /// Serializes this ImgStyle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImgStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImgStyleCopyWith<ImgStyle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImgStyleCopyWith<$Res> {
  factory $ImgStyleCopyWith(ImgStyle value, $Res Function(ImgStyle) then) =
      _$ImgStyleCopyWithImpl<$Res, ImgStyle>;
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "url") String url,
      @JsonKey(name: "prompts") List<String> prompts,
      @JsonKey(name: "integral_user") int integralUser});
}

/// @nodoc
class _$ImgStyleCopyWithImpl<$Res, $Val extends ImgStyle>
    implements $ImgStyleCopyWith<$Res> {
  _$ImgStyleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImgStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? url = null,
    Object? prompts = null,
    Object? integralUser = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      prompts: null == prompts
          ? _value.prompts
          : prompts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      integralUser: null == integralUser
          ? _value.integralUser
          : integralUser // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImgStyleImplCopyWith<$Res>
    implements $ImgStyleCopyWith<$Res> {
  factory _$$ImgStyleImplCopyWith(
          _$ImgStyleImpl value, $Res Function(_$ImgStyleImpl) then) =
      __$$ImgStyleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "url") String url,
      @JsonKey(name: "prompts") List<String> prompts,
      @JsonKey(name: "integral_user") int integralUser});
}

/// @nodoc
class __$$ImgStyleImplCopyWithImpl<$Res>
    extends _$ImgStyleCopyWithImpl<$Res, _$ImgStyleImpl>
    implements _$$ImgStyleImplCopyWith<$Res> {
  __$$ImgStyleImplCopyWithImpl(
      _$ImgStyleImpl _value, $Res Function(_$ImgStyleImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImgStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? url = null,
    Object? prompts = null,
    Object? integralUser = null,
  }) {
    return _then(_$ImgStyleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      prompts: null == prompts
          ? _value._prompts
          : prompts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      integralUser: null == integralUser
          ? _value.integralUser
          : integralUser // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImgStyleImpl implements _ImgStyle {
  const _$ImgStyleImpl(
      {@JsonKey(name: "id") required this.id,
      @JsonKey(name: "title") required this.title,
      @JsonKey(name: "url") required this.url,
      @JsonKey(name: "prompts") required final List<String> prompts,
      @JsonKey(name: "integral_user") required this.integralUser})
      : _prompts = prompts;

  factory _$ImgStyleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImgStyleImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "title")
  final String title;
  @override
  @JsonKey(name: "url")
  final String url;
  final List<String> _prompts;
  @override
  @JsonKey(name: "prompts")
  List<String> get prompts {
    if (_prompts is EqualUnmodifiableListView) return _prompts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_prompts);
  }

  @override
  @JsonKey(name: "integral_user")
  final int integralUser;

  @override
  String toString() {
    return 'ImgStyle(id: $id, title: $title, url: $url, prompts: $prompts, integralUser: $integralUser)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImgStyleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other._prompts, _prompts) &&
            (identical(other.integralUser, integralUser) ||
                other.integralUser == integralUser));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, url,
      const DeepCollectionEquality().hash(_prompts), integralUser);

  /// Create a copy of ImgStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImgStyleImplCopyWith<_$ImgStyleImpl> get copyWith =>
      __$$ImgStyleImplCopyWithImpl<_$ImgStyleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImgStyleImplToJson(
      this,
    );
  }
}

abstract class _ImgStyle implements ImgStyle {
  const factory _ImgStyle(
          {@JsonKey(name: "id") required final int id,
          @JsonKey(name: "title") required final String title,
          @JsonKey(name: "url") required final String url,
          @JsonKey(name: "prompts") required final List<String> prompts,
          @JsonKey(name: "integral_user") required final int integralUser}) =
      _$ImgStyleImpl;

  factory _ImgStyle.fromJson(Map<String, dynamic> json) =
      _$ImgStyleImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "title")
  String get title;
  @override
  @JsonKey(name: "url")
  String get url;
  @override
  @JsonKey(name: "prompts")
  List<String> get prompts;
  @override
  @JsonKey(name: "integral_user")
  int get integralUser;

  /// Create a copy of ImgStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImgStyleImplCopyWith<_$ImgStyleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Ratio _$RatioFromJson(Map<String, dynamic> json) {
  return _Ratio.fromJson(json);
}

/// @nodoc
mixin _$Ratio {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "scale")
  String get scale => throw _privateConstructorUsedError;
  @JsonKey(name: "pic1")
  String get pic1 => throw _privateConstructorUsedError;
  @JsonKey(name: "pic2")
  String get pic2 => throw _privateConstructorUsedError;

  /// Serializes this Ratio to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Ratio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RatioCopyWith<Ratio> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RatioCopyWith<$Res> {
  factory $RatioCopyWith(Ratio value, $Res Function(Ratio) then) =
      _$RatioCopyWithImpl<$Res, Ratio>;
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "scale") String scale,
      @JsonKey(name: "pic1") String pic1,
      @JsonKey(name: "pic2") String pic2});
}

/// @nodoc
class _$RatioCopyWithImpl<$Res, $Val extends Ratio>
    implements $RatioCopyWith<$Res> {
  _$RatioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Ratio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scale = null,
    Object? pic1 = null,
    Object? pic2 = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as String,
      pic1: null == pic1
          ? _value.pic1
          : pic1 // ignore: cast_nullable_to_non_nullable
              as String,
      pic2: null == pic2
          ? _value.pic2
          : pic2 // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RatioImplCopyWith<$Res> implements $RatioCopyWith<$Res> {
  factory _$$RatioImplCopyWith(
          _$RatioImpl value, $Res Function(_$RatioImpl) then) =
      __$$RatioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "scale") String scale,
      @JsonKey(name: "pic1") String pic1,
      @JsonKey(name: "pic2") String pic2});
}

/// @nodoc
class __$$RatioImplCopyWithImpl<$Res>
    extends _$RatioCopyWithImpl<$Res, _$RatioImpl>
    implements _$$RatioImplCopyWith<$Res> {
  __$$RatioImplCopyWithImpl(
      _$RatioImpl _value, $Res Function(_$RatioImpl) _then)
      : super(_value, _then);

  /// Create a copy of Ratio
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scale = null,
    Object? pic1 = null,
    Object? pic2 = null,
  }) {
    return _then(_$RatioImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as String,
      pic1: null == pic1
          ? _value.pic1
          : pic1 // ignore: cast_nullable_to_non_nullable
              as String,
      pic2: null == pic2
          ? _value.pic2
          : pic2 // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RatioImpl implements _Ratio {
  const _$RatioImpl(
      {@JsonKey(name: "id") required this.id,
      @JsonKey(name: "scale") required this.scale,
      @JsonKey(name: "pic1") required this.pic1,
      @JsonKey(name: "pic2") required this.pic2});

  factory _$RatioImpl.fromJson(Map<String, dynamic> json) =>
      _$$RatioImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "scale")
  final String scale;
  @override
  @JsonKey(name: "pic1")
  final String pic1;
  @override
  @JsonKey(name: "pic2")
  final String pic2;

  @override
  String toString() {
    return 'Ratio(id: $id, scale: $scale, pic1: $pic1, pic2: $pic2)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RatioImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.pic1, pic1) || other.pic1 == pic1) &&
            (identical(other.pic2, pic2) || other.pic2 == pic2));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, scale, pic1, pic2);

  /// Create a copy of Ratio
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RatioImplCopyWith<_$RatioImpl> get copyWith =>
      __$$RatioImplCopyWithImpl<_$RatioImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RatioImplToJson(
      this,
    );
  }
}

abstract class _Ratio implements Ratio {
  const factory _Ratio(
      {@JsonKey(name: "id") required final int id,
      @JsonKey(name: "scale") required final String scale,
      @JsonKey(name: "pic1") required final String pic1,
      @JsonKey(name: "pic2") required final String pic2}) = _$RatioImpl;

  factory _Ratio.fromJson(Map<String, dynamic> json) = _$RatioImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "scale")
  String get scale;
  @override
  @JsonKey(name: "pic1")
  String get pic1;
  @override
  @JsonKey(name: "pic2")
  String get pic2;

  /// Create a copy of Ratio
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RatioImplCopyWith<_$RatioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
