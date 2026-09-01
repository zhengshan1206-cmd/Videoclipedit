// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_cartoon_random_template_bean.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiCartoonRandomTemplateBean _$AiCartoonRandomTemplateBeanFromJson(
    Map<String, dynamic> json) {
  return _AiCartoonRandomTemplateBean.fromJson(json);
}

/// @nodoc
mixin _$AiCartoonRandomTemplateBean {
  @JsonKey(name: "category")
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: "text")
  String get text => throw _privateConstructorUsedError;
  @JsonKey(name: "scale")
  Scale get scale => throw _privateConstructorUsedError;
  @JsonKey(name: "style")
  Style get style => throw _privateConstructorUsedError;
  @JsonKey(name: "tts")
  Tts get tts => throw _privateConstructorUsedError;

  /// Serializes this AiCartoonRandomTemplateBean to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiCartoonRandomTemplateBean
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiCartoonRandomTemplateBeanCopyWith<AiCartoonRandomTemplateBean>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiCartoonRandomTemplateBeanCopyWith<$Res> {
  factory $AiCartoonRandomTemplateBeanCopyWith(
          AiCartoonRandomTemplateBean value,
          $Res Function(AiCartoonRandomTemplateBean) then) =
      _$AiCartoonRandomTemplateBeanCopyWithImpl<$Res,
          AiCartoonRandomTemplateBean>;
  @useResult
  $Res call(
      {@JsonKey(name: "category") String category,
      @JsonKey(name: "text") String text,
      @JsonKey(name: "scale") Scale scale,
      @JsonKey(name: "style") Style style,
      @JsonKey(name: "tts") Tts tts});

  $ScaleCopyWith<$Res> get scale;
  $StyleCopyWith<$Res> get style;
  $TtsCopyWith<$Res> get tts;
}

/// @nodoc
class _$AiCartoonRandomTemplateBeanCopyWithImpl<$Res,
        $Val extends AiCartoonRandomTemplateBean>
    implements $AiCartoonRandomTemplateBeanCopyWith<$Res> {
  _$AiCartoonRandomTemplateBeanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiCartoonRandomTemplateBean
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? text = null,
    Object? scale = null,
    Object? style = null,
    Object? tts = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as Scale,
      style: null == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as Style,
      tts: null == tts
          ? _value.tts
          : tts // ignore: cast_nullable_to_non_nullable
              as Tts,
    ) as $Val);
  }

  /// Create a copy of AiCartoonRandomTemplateBean
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScaleCopyWith<$Res> get scale {
    return $ScaleCopyWith<$Res>(_value.scale, (value) {
      return _then(_value.copyWith(scale: value) as $Val);
    });
  }

  /// Create a copy of AiCartoonRandomTemplateBean
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StyleCopyWith<$Res> get style {
    return $StyleCopyWith<$Res>(_value.style, (value) {
      return _then(_value.copyWith(style: value) as $Val);
    });
  }

  /// Create a copy of AiCartoonRandomTemplateBean
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TtsCopyWith<$Res> get tts {
    return $TtsCopyWith<$Res>(_value.tts, (value) {
      return _then(_value.copyWith(tts: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AiCartoonRandomTemplateBeanImplCopyWith<$Res>
    implements $AiCartoonRandomTemplateBeanCopyWith<$Res> {
  factory _$$AiCartoonRandomTemplateBeanImplCopyWith(
          _$AiCartoonRandomTemplateBeanImpl value,
          $Res Function(_$AiCartoonRandomTemplateBeanImpl) then) =
      __$$AiCartoonRandomTemplateBeanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "category") String category,
      @JsonKey(name: "text") String text,
      @JsonKey(name: "scale") Scale scale,
      @JsonKey(name: "style") Style style,
      @JsonKey(name: "tts") Tts tts});

  @override
  $ScaleCopyWith<$Res> get scale;
  @override
  $StyleCopyWith<$Res> get style;
  @override
  $TtsCopyWith<$Res> get tts;
}

/// @nodoc
class __$$AiCartoonRandomTemplateBeanImplCopyWithImpl<$Res>
    extends _$AiCartoonRandomTemplateBeanCopyWithImpl<$Res,
        _$AiCartoonRandomTemplateBeanImpl>
    implements _$$AiCartoonRandomTemplateBeanImplCopyWith<$Res> {
  __$$AiCartoonRandomTemplateBeanImplCopyWithImpl(
      _$AiCartoonRandomTemplateBeanImpl _value,
      $Res Function(_$AiCartoonRandomTemplateBeanImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiCartoonRandomTemplateBean
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? text = null,
    Object? scale = null,
    Object? style = null,
    Object? tts = null,
  }) {
    return _then(_$AiCartoonRandomTemplateBeanImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as Scale,
      style: null == style
          ? _value.style
          : style // ignore: cast_nullable_to_non_nullable
              as Style,
      tts: null == tts
          ? _value.tts
          : tts // ignore: cast_nullable_to_non_nullable
              as Tts,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiCartoonRandomTemplateBeanImpl
    implements _AiCartoonRandomTemplateBean {
  const _$AiCartoonRandomTemplateBeanImpl(
      {@JsonKey(name: "category") required this.category,
      @JsonKey(name: "text") required this.text,
      @JsonKey(name: "scale") required this.scale,
      @JsonKey(name: "style") required this.style,
      @JsonKey(name: "tts") required this.tts});

  factory _$AiCartoonRandomTemplateBeanImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$AiCartoonRandomTemplateBeanImplFromJson(json);

  @override
  @JsonKey(name: "category")
  final String category;
  @override
  @JsonKey(name: "text")
  final String text;
  @override
  @JsonKey(name: "scale")
  final Scale scale;
  @override
  @JsonKey(name: "style")
  final Style style;
  @override
  @JsonKey(name: "tts")
  final Tts tts;

  @override
  String toString() {
    return 'AiCartoonRandomTemplateBean(category: $category, text: $text, scale: $scale, style: $style, tts: $tts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiCartoonRandomTemplateBeanImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.style, style) || other.style == style) &&
            (identical(other.tts, tts) || other.tts == tts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, category, text, scale, style, tts);

  /// Create a copy of AiCartoonRandomTemplateBean
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiCartoonRandomTemplateBeanImplCopyWith<_$AiCartoonRandomTemplateBeanImpl>
      get copyWith => __$$AiCartoonRandomTemplateBeanImplCopyWithImpl<
          _$AiCartoonRandomTemplateBeanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiCartoonRandomTemplateBeanImplToJson(
      this,
    );
  }
}

abstract class _AiCartoonRandomTemplateBean
    implements AiCartoonRandomTemplateBean {
  const factory _AiCartoonRandomTemplateBean(
          {@JsonKey(name: "category") required final String category,
          @JsonKey(name: "text") required final String text,
          @JsonKey(name: "scale") required final Scale scale,
          @JsonKey(name: "style") required final Style style,
          @JsonKey(name: "tts") required final Tts tts}) =
      _$AiCartoonRandomTemplateBeanImpl;

  factory _AiCartoonRandomTemplateBean.fromJson(Map<String, dynamic> json) =
      _$AiCartoonRandomTemplateBeanImpl.fromJson;

  @override
  @JsonKey(name: "category")
  String get category;
  @override
  @JsonKey(name: "text")
  String get text;
  @override
  @JsonKey(name: "scale")
  Scale get scale;
  @override
  @JsonKey(name: "style")
  Style get style;
  @override
  @JsonKey(name: "tts")
  Tts get tts;

  /// Create a copy of AiCartoonRandomTemplateBean
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiCartoonRandomTemplateBeanImplCopyWith<_$AiCartoonRandomTemplateBeanImpl>
      get copyWith => throw _privateConstructorUsedError;
}

Scale _$ScaleFromJson(Map<String, dynamic> json) {
  return _Scale.fromJson(json);
}

/// @nodoc
mixin _$Scale {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "scale")
  String get scale => throw _privateConstructorUsedError;
  @JsonKey(name: "unselect")
  String get unselect => throw _privateConstructorUsedError;
  @JsonKey(name: "selected")
  String get selected => throw _privateConstructorUsedError;

  /// Serializes this Scale to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Scale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScaleCopyWith<Scale> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScaleCopyWith<$Res> {
  factory $ScaleCopyWith(Scale value, $Res Function(Scale) then) =
      _$ScaleCopyWithImpl<$Res, Scale>;
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "scale") String scale,
      @JsonKey(name: "unselect") String unselect,
      @JsonKey(name: "selected") String selected});
}

/// @nodoc
class _$ScaleCopyWithImpl<$Res, $Val extends Scale>
    implements $ScaleCopyWith<$Res> {
  _$ScaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Scale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scale = null,
    Object? unselect = null,
    Object? selected = null,
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
      unselect: null == unselect
          ? _value.unselect
          : unselect // ignore: cast_nullable_to_non_nullable
              as String,
      selected: null == selected
          ? _value.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScaleImplCopyWith<$Res> implements $ScaleCopyWith<$Res> {
  factory _$$ScaleImplCopyWith(
          _$ScaleImpl value, $Res Function(_$ScaleImpl) then) =
      __$$ScaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "scale") String scale,
      @JsonKey(name: "unselect") String unselect,
      @JsonKey(name: "selected") String selected});
}

/// @nodoc
class __$$ScaleImplCopyWithImpl<$Res>
    extends _$ScaleCopyWithImpl<$Res, _$ScaleImpl>
    implements _$$ScaleImplCopyWith<$Res> {
  __$$ScaleImplCopyWithImpl(
      _$ScaleImpl _value, $Res Function(_$ScaleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Scale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? scale = null,
    Object? unselect = null,
    Object? selected = null,
  }) {
    return _then(_$ScaleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      scale: null == scale
          ? _value.scale
          : scale // ignore: cast_nullable_to_non_nullable
              as String,
      unselect: null == unselect
          ? _value.unselect
          : unselect // ignore: cast_nullable_to_non_nullable
              as String,
      selected: null == selected
          ? _value.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScaleImpl implements _Scale {
  const _$ScaleImpl(
      {@JsonKey(name: "id") required this.id,
      @JsonKey(name: "scale") required this.scale,
      @JsonKey(name: "unselect") required this.unselect,
      @JsonKey(name: "selected") required this.selected});

  factory _$ScaleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScaleImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "scale")
  final String scale;
  @override
  @JsonKey(name: "unselect")
  final String unselect;
  @override
  @JsonKey(name: "selected")
  final String selected;

  @override
  String toString() {
    return 'Scale(id: $id, scale: $scale, unselect: $unselect, selected: $selected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScaleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scale, scale) || other.scale == scale) &&
            (identical(other.unselect, unselect) ||
                other.unselect == unselect) &&
            (identical(other.selected, selected) ||
                other.selected == selected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, scale, unselect, selected);

  /// Create a copy of Scale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScaleImplCopyWith<_$ScaleImpl> get copyWith =>
      __$$ScaleImplCopyWithImpl<_$ScaleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScaleImplToJson(
      this,
    );
  }
}

abstract class _Scale implements Scale {
  const factory _Scale(
      {@JsonKey(name: "id") required final int id,
      @JsonKey(name: "scale") required final String scale,
      @JsonKey(name: "unselect") required final String unselect,
      @JsonKey(name: "selected") required final String selected}) = _$ScaleImpl;

  factory _Scale.fromJson(Map<String, dynamic> json) = _$ScaleImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "scale")
  String get scale;
  @override
  @JsonKey(name: "unselect")
  String get unselect;
  @override
  @JsonKey(name: "selected")
  String get selected;

  /// Create a copy of Scale
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScaleImplCopyWith<_$ScaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Style _$StyleFromJson(Map<String, dynamic> json) {
  return _Style.fromJson(json);
}

/// @nodoc
mixin _$Style {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "title")
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: "url")
  String get url => throw _privateConstructorUsedError;

  /// Serializes this Style to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Style
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StyleCopyWith<Style> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StyleCopyWith<$Res> {
  factory $StyleCopyWith(Style value, $Res Function(Style) then) =
      _$StyleCopyWithImpl<$Res, Style>;
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "url") String url});
}

/// @nodoc
class _$StyleCopyWithImpl<$Res, $Val extends Style>
    implements $StyleCopyWith<$Res> {
  _$StyleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Style
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? url = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StyleImplCopyWith<$Res> implements $StyleCopyWith<$Res> {
  factory _$$StyleImplCopyWith(
          _$StyleImpl value, $Res Function(_$StyleImpl) then) =
      __$$StyleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "url") String url});
}

/// @nodoc
class __$$StyleImplCopyWithImpl<$Res>
    extends _$StyleCopyWithImpl<$Res, _$StyleImpl>
    implements _$$StyleImplCopyWith<$Res> {
  __$$StyleImplCopyWithImpl(
      _$StyleImpl _value, $Res Function(_$StyleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Style
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? url = null,
  }) {
    return _then(_$StyleImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StyleImpl implements _Style {
  const _$StyleImpl(
      {@JsonKey(name: "id") required this.id,
      @JsonKey(name: "title") required this.title,
      @JsonKey(name: "url") required this.url});

  factory _$StyleImpl.fromJson(Map<String, dynamic> json) =>
      _$$StyleImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "title")
  final String title;
  @override
  @JsonKey(name: "url")
  final String url;

  @override
  String toString() {
    return 'Style(id: $id, title: $title, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StyleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.url, url) || other.url == url));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, url);

  /// Create a copy of Style
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StyleImplCopyWith<_$StyleImpl> get copyWith =>
      __$$StyleImplCopyWithImpl<_$StyleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StyleImplToJson(
      this,
    );
  }
}

abstract class _Style implements Style {
  const factory _Style(
      {@JsonKey(name: "id") required final int id,
      @JsonKey(name: "title") required final String title,
      @JsonKey(name: "url") required final String url}) = _$StyleImpl;

  factory _Style.fromJson(Map<String, dynamic> json) = _$StyleImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "title")
  String get title;
  @override
  @JsonKey(name: "url")
  String get url;

  /// Create a copy of Style
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StyleImplCopyWith<_$StyleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Tts _$TtsFromJson(Map<String, dynamic> json) {
  return _Tts.fromJson(json);
}

/// @nodoc
mixin _$Tts {
  @JsonKey(name: "id")
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: "header_image")
  String get headerImage => throw _privateConstructorUsedError;
  @JsonKey(name: "title")
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: "speaker")
  String get speaker => throw _privateConstructorUsedError;
  @JsonKey(name: "need_vip")
  int get needVip => throw _privateConstructorUsedError;
  @JsonKey(name: "integral")
  int get integral => throw _privateConstructorUsedError;
  @JsonKey(name: "show_name")
  String get showName => throw _privateConstructorUsedError;
  @JsonKey(name: "demo_url")
  String get demoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: "isCollect")
  int get isCollect => throw _privateConstructorUsedError;
  @JsonKey(name: "mx_speed")
  int get mxSpeed => throw _privateConstructorUsedError;
  @JsonKey(name: "mx_intonation")
  int get mxIntonation => throw _privateConstructorUsedError;

  /// Serializes this Tts to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TtsCopyWith<Tts> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TtsCopyWith<$Res> {
  factory $TtsCopyWith(Tts value, $Res Function(Tts) then) =
      _$TtsCopyWithImpl<$Res, Tts>;
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "name") String name,
      @JsonKey(name: "header_image") String headerImage,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "speaker") String speaker,
      @JsonKey(name: "need_vip") int needVip,
      @JsonKey(name: "integral") int integral,
      @JsonKey(name: "show_name") String showName,
      @JsonKey(name: "demo_url") String demoUrl,
      @JsonKey(name: "isCollect") int isCollect,
      @JsonKey(name: "mx_speed") int mxSpeed,
      @JsonKey(name: "mx_intonation") int mxIntonation});
}

/// @nodoc
class _$TtsCopyWithImpl<$Res, $Val extends Tts> implements $TtsCopyWith<$Res> {
  _$TtsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? headerImage = null,
    Object? title = null,
    Object? speaker = null,
    Object? needVip = null,
    Object? integral = null,
    Object? showName = null,
    Object? demoUrl = null,
    Object? isCollect = null,
    Object? mxSpeed = null,
    Object? mxIntonation = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      headerImage: null == headerImage
          ? _value.headerImage
          : headerImage // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      speaker: null == speaker
          ? _value.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as String,
      needVip: null == needVip
          ? _value.needVip
          : needVip // ignore: cast_nullable_to_non_nullable
              as int,
      integral: null == integral
          ? _value.integral
          : integral // ignore: cast_nullable_to_non_nullable
              as int,
      showName: null == showName
          ? _value.showName
          : showName // ignore: cast_nullable_to_non_nullable
              as String,
      demoUrl: null == demoUrl
          ? _value.demoUrl
          : demoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isCollect: null == isCollect
          ? _value.isCollect
          : isCollect // ignore: cast_nullable_to_non_nullable
              as int,
      mxSpeed: null == mxSpeed
          ? _value.mxSpeed
          : mxSpeed // ignore: cast_nullable_to_non_nullable
              as int,
      mxIntonation: null == mxIntonation
          ? _value.mxIntonation
          : mxIntonation // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TtsImplCopyWith<$Res> implements $TtsCopyWith<$Res> {
  factory _$$TtsImplCopyWith(_$TtsImpl value, $Res Function(_$TtsImpl) then) =
      __$$TtsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "id") int id,
      @JsonKey(name: "name") String name,
      @JsonKey(name: "header_image") String headerImage,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "speaker") String speaker,
      @JsonKey(name: "need_vip") int needVip,
      @JsonKey(name: "integral") int integral,
      @JsonKey(name: "show_name") String showName,
      @JsonKey(name: "demo_url") String demoUrl,
      @JsonKey(name: "isCollect") int isCollect,
      @JsonKey(name: "mx_speed") int mxSpeed,
      @JsonKey(name: "mx_intonation") int mxIntonation});
}

/// @nodoc
class __$$TtsImplCopyWithImpl<$Res> extends _$TtsCopyWithImpl<$Res, _$TtsImpl>
    implements _$$TtsImplCopyWith<$Res> {
  __$$TtsImplCopyWithImpl(_$TtsImpl _value, $Res Function(_$TtsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Tts
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? headerImage = null,
    Object? title = null,
    Object? speaker = null,
    Object? needVip = null,
    Object? integral = null,
    Object? showName = null,
    Object? demoUrl = null,
    Object? isCollect = null,
    Object? mxSpeed = null,
    Object? mxIntonation = null,
  }) {
    return _then(_$TtsImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      headerImage: null == headerImage
          ? _value.headerImage
          : headerImage // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      speaker: null == speaker
          ? _value.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as String,
      needVip: null == needVip
          ? _value.needVip
          : needVip // ignore: cast_nullable_to_non_nullable
              as int,
      integral: null == integral
          ? _value.integral
          : integral // ignore: cast_nullable_to_non_nullable
              as int,
      showName: null == showName
          ? _value.showName
          : showName // ignore: cast_nullable_to_non_nullable
              as String,
      demoUrl: null == demoUrl
          ? _value.demoUrl
          : demoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isCollect: null == isCollect
          ? _value.isCollect
          : isCollect // ignore: cast_nullable_to_non_nullable
              as int,
      mxSpeed: null == mxSpeed
          ? _value.mxSpeed
          : mxSpeed // ignore: cast_nullable_to_non_nullable
              as int,
      mxIntonation: null == mxIntonation
          ? _value.mxIntonation
          : mxIntonation // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TtsImpl implements _Tts {
  const _$TtsImpl(
      {@JsonKey(name: "id") required this.id,
      @JsonKey(name: "name") required this.name,
      @JsonKey(name: "header_image") required this.headerImage,
      @JsonKey(name: "title") required this.title,
      @JsonKey(name: "speaker") required this.speaker,
      @JsonKey(name: "need_vip") required this.needVip,
      @JsonKey(name: "integral") required this.integral,
      @JsonKey(name: "show_name") required this.showName,
      @JsonKey(name: "demo_url") required this.demoUrl,
      @JsonKey(name: "isCollect") required this.isCollect,
      @JsonKey(name: "mx_speed") required this.mxSpeed,
      @JsonKey(name: "mx_intonation") required this.mxIntonation});

  factory _$TtsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TtsImplFromJson(json);

  @override
  @JsonKey(name: "id")
  final int id;
  @override
  @JsonKey(name: "name")
  final String name;
  @override
  @JsonKey(name: "header_image")
  final String headerImage;
  @override
  @JsonKey(name: "title")
  final String title;
  @override
  @JsonKey(name: "speaker")
  final String speaker;
  @override
  @JsonKey(name: "need_vip")
  final int needVip;
  @override
  @JsonKey(name: "integral")
  final int integral;
  @override
  @JsonKey(name: "show_name")
  final String showName;
  @override
  @JsonKey(name: "demo_url")
  final String demoUrl;
  @override
  @JsonKey(name: "isCollect")
  final int isCollect;
  @override
  @JsonKey(name: "mx_speed")
  final int mxSpeed;
  @override
  @JsonKey(name: "mx_intonation")
  final int mxIntonation;

  @override
  String toString() {
    return 'Tts(id: $id, name: $name, headerImage: $headerImage, title: $title, speaker: $speaker, needVip: $needVip, integral: $integral, showName: $showName, demoUrl: $demoUrl, isCollect: $isCollect, mxSpeed: $mxSpeed, mxIntonation: $mxIntonation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TtsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.headerImage, headerImage) ||
                other.headerImage == headerImage) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.speaker, speaker) || other.speaker == speaker) &&
            (identical(other.needVip, needVip) || other.needVip == needVip) &&
            (identical(other.integral, integral) ||
                other.integral == integral) &&
            (identical(other.showName, showName) ||
                other.showName == showName) &&
            (identical(other.demoUrl, demoUrl) || other.demoUrl == demoUrl) &&
            (identical(other.isCollect, isCollect) ||
                other.isCollect == isCollect) &&
            (identical(other.mxSpeed, mxSpeed) || other.mxSpeed == mxSpeed) &&
            (identical(other.mxIntonation, mxIntonation) ||
                other.mxIntonation == mxIntonation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      headerImage,
      title,
      speaker,
      needVip,
      integral,
      showName,
      demoUrl,
      isCollect,
      mxSpeed,
      mxIntonation);

  /// Create a copy of Tts
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TtsImplCopyWith<_$TtsImpl> get copyWith =>
      __$$TtsImplCopyWithImpl<_$TtsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TtsImplToJson(
      this,
    );
  }
}

abstract class _Tts implements Tts {
  const factory _Tts(
          {@JsonKey(name: "id") required final int id,
          @JsonKey(name: "name") required final String name,
          @JsonKey(name: "header_image") required final String headerImage,
          @JsonKey(name: "title") required final String title,
          @JsonKey(name: "speaker") required final String speaker,
          @JsonKey(name: "need_vip") required final int needVip,
          @JsonKey(name: "integral") required final int integral,
          @JsonKey(name: "show_name") required final String showName,
          @JsonKey(name: "demo_url") required final String demoUrl,
          @JsonKey(name: "isCollect") required final int isCollect,
          @JsonKey(name: "mx_speed") required final int mxSpeed,
          @JsonKey(name: "mx_intonation") required final int mxIntonation}) =
      _$TtsImpl;

  factory _Tts.fromJson(Map<String, dynamic> json) = _$TtsImpl.fromJson;

  @override
  @JsonKey(name: "id")
  int get id;
  @override
  @JsonKey(name: "name")
  String get name;
  @override
  @JsonKey(name: "header_image")
  String get headerImage;
  @override
  @JsonKey(name: "title")
  String get title;
  @override
  @JsonKey(name: "speaker")
  String get speaker;
  @override
  @JsonKey(name: "need_vip")
  int get needVip;
  @override
  @JsonKey(name: "integral")
  int get integral;
  @override
  @JsonKey(name: "show_name")
  String get showName;
  @override
  @JsonKey(name: "demo_url")
  String get demoUrl;
  @override
  @JsonKey(name: "isCollect")
  int get isCollect;
  @override
  @JsonKey(name: "mx_speed")
  int get mxSpeed;
  @override
  @JsonKey(name: "mx_intonation")
  int get mxIntonation;

  /// Create a copy of Tts
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TtsImplCopyWith<_$TtsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
