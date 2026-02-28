// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProjectConfig {

 String get ratio; String get imageModel; String get videoModel; String get narration; String get shotDuration; String get videoStyle; String get lipSyncMode;
/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectConfigCopyWith<ProjectConfig> get copyWith => _$ProjectConfigCopyWithImpl<ProjectConfig>(this as ProjectConfig, _$identity);

  /// Serializes this ProjectConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectConfig&&(identical(other.ratio, ratio) || other.ratio == ratio)&&(identical(other.imageModel, imageModel) || other.imageModel == imageModel)&&(identical(other.videoModel, videoModel) || other.videoModel == videoModel)&&(identical(other.narration, narration) || other.narration == narration)&&(identical(other.shotDuration, shotDuration) || other.shotDuration == shotDuration)&&(identical(other.videoStyle, videoStyle) || other.videoStyle == videoStyle)&&(identical(other.lipSyncMode, lipSyncMode) || other.lipSyncMode == lipSyncMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ratio,imageModel,videoModel,narration,shotDuration,videoStyle,lipSyncMode);

@override
String toString() {
  return 'ProjectConfig(ratio: $ratio, imageModel: $imageModel, videoModel: $videoModel, narration: $narration, shotDuration: $shotDuration, videoStyle: $videoStyle, lipSyncMode: $lipSyncMode)';
}


}

/// @nodoc
abstract mixin class $ProjectConfigCopyWith<$Res>  {
  factory $ProjectConfigCopyWith(ProjectConfig value, $Res Function(ProjectConfig) _then) = _$ProjectConfigCopyWithImpl;
@useResult
$Res call({
 String ratio, String imageModel, String videoModel, String narration, String shotDuration, String videoStyle, String lipSyncMode
});




}
/// @nodoc
class _$ProjectConfigCopyWithImpl<$Res>
    implements $ProjectConfigCopyWith<$Res> {
  _$ProjectConfigCopyWithImpl(this._self, this._then);

  final ProjectConfig _self;
  final $Res Function(ProjectConfig) _then;

/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ratio = null,Object? imageModel = null,Object? videoModel = null,Object? narration = null,Object? shotDuration = null,Object? videoStyle = null,Object? lipSyncMode = null,}) {
  return _then(_self.copyWith(
ratio: null == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as String,imageModel: null == imageModel ? _self.imageModel : imageModel // ignore: cast_nullable_to_non_nullable
as String,videoModel: null == videoModel ? _self.videoModel : videoModel // ignore: cast_nullable_to_non_nullable
as String,narration: null == narration ? _self.narration : narration // ignore: cast_nullable_to_non_nullable
as String,shotDuration: null == shotDuration ? _self.shotDuration : shotDuration // ignore: cast_nullable_to_non_nullable
as String,videoStyle: null == videoStyle ? _self.videoStyle : videoStyle // ignore: cast_nullable_to_non_nullable
as String,lipSyncMode: null == lipSyncMode ? _self.lipSyncMode : lipSyncMode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectConfig].
extension ProjectConfigPatterns on ProjectConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectConfig value)  $default,){
final _that = this;
switch (_that) {
case _ProjectConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ratio,  String imageModel,  String videoModel,  String narration,  String shotDuration,  String videoStyle,  String lipSyncMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectConfig() when $default != null:
return $default(_that.ratio,_that.imageModel,_that.videoModel,_that.narration,_that.shotDuration,_that.videoStyle,_that.lipSyncMode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ratio,  String imageModel,  String videoModel,  String narration,  String shotDuration,  String videoStyle,  String lipSyncMode)  $default,) {final _that = this;
switch (_that) {
case _ProjectConfig():
return $default(_that.ratio,_that.imageModel,_that.videoModel,_that.narration,_that.shotDuration,_that.videoStyle,_that.lipSyncMode);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ratio,  String imageModel,  String videoModel,  String narration,  String shotDuration,  String videoStyle,  String lipSyncMode)?  $default,) {final _that = this;
switch (_that) {
case _ProjectConfig() when $default != null:
return $default(_that.ratio,_that.imageModel,_that.videoModel,_that.narration,_that.shotDuration,_that.videoStyle,_that.lipSyncMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectConfig implements ProjectConfig {
  const _ProjectConfig({this.ratio = '1:1', this.imageModel = '', this.videoModel = '', this.narration = '无', this.shotDuration = '5', this.videoStyle = '', this.lipSyncMode = ''});
  factory _ProjectConfig.fromJson(Map<String, dynamic> json) => _$ProjectConfigFromJson(json);

@override@JsonKey() final  String ratio;
@override@JsonKey() final  String imageModel;
@override@JsonKey() final  String videoModel;
@override@JsonKey() final  String narration;
@override@JsonKey() final  String shotDuration;
@override@JsonKey() final  String videoStyle;
@override@JsonKey() final  String lipSyncMode;

/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectConfigCopyWith<_ProjectConfig> get copyWith => __$ProjectConfigCopyWithImpl<_ProjectConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectConfig&&(identical(other.ratio, ratio) || other.ratio == ratio)&&(identical(other.imageModel, imageModel) || other.imageModel == imageModel)&&(identical(other.videoModel, videoModel) || other.videoModel == videoModel)&&(identical(other.narration, narration) || other.narration == narration)&&(identical(other.shotDuration, shotDuration) || other.shotDuration == shotDuration)&&(identical(other.videoStyle, videoStyle) || other.videoStyle == videoStyle)&&(identical(other.lipSyncMode, lipSyncMode) || other.lipSyncMode == lipSyncMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ratio,imageModel,videoModel,narration,shotDuration,videoStyle,lipSyncMode);

@override
String toString() {
  return 'ProjectConfig(ratio: $ratio, imageModel: $imageModel, videoModel: $videoModel, narration: $narration, shotDuration: $shotDuration, videoStyle: $videoStyle, lipSyncMode: $lipSyncMode)';
}


}

/// @nodoc
abstract mixin class _$ProjectConfigCopyWith<$Res> implements $ProjectConfigCopyWith<$Res> {
  factory _$ProjectConfigCopyWith(_ProjectConfig value, $Res Function(_ProjectConfig) _then) = __$ProjectConfigCopyWithImpl;
@override @useResult
$Res call({
 String ratio, String imageModel, String videoModel, String narration, String shotDuration, String videoStyle, String lipSyncMode
});




}
/// @nodoc
class __$ProjectConfigCopyWithImpl<$Res>
    implements _$ProjectConfigCopyWith<$Res> {
  __$ProjectConfigCopyWithImpl(this._self, this._then);

  final _ProjectConfig _self;
  final $Res Function(_ProjectConfig) _then;

/// Create a copy of ProjectConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ratio = null,Object? imageModel = null,Object? videoModel = null,Object? narration = null,Object? shotDuration = null,Object? videoStyle = null,Object? lipSyncMode = null,}) {
  return _then(_ProjectConfig(
ratio: null == ratio ? _self.ratio : ratio // ignore: cast_nullable_to_non_nullable
as String,imageModel: null == imageModel ? _self.imageModel : imageModel // ignore: cast_nullable_to_non_nullable
as String,videoModel: null == videoModel ? _self.videoModel : videoModel // ignore: cast_nullable_to_non_nullable
as String,narration: null == narration ? _self.narration : narration // ignore: cast_nullable_to_non_nullable
as String,shotDuration: null == shotDuration ? _self.shotDuration : shotDuration // ignore: cast_nullable_to_non_nullable
as String,videoStyle: null == videoStyle ? _self.videoStyle : videoStyle // ignore: cast_nullable_to_non_nullable
as String,lipSyncMode: null == lipSyncMode ? _self.lipSyncMode : lipSyncMode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Project {

 String? get id; String get name; String get story; String get storyMode; ProjectConfig? get config; bool get mirrorMode; List<String> get segmentIds; DateTime? get updatedAt;
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCopyWith<Project> get copyWith => _$ProjectCopyWithImpl<Project>(this as Project, _$identity);

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.story, story) || other.story == story)&&(identical(other.storyMode, storyMode) || other.storyMode == storyMode)&&(identical(other.config, config) || other.config == config)&&(identical(other.mirrorMode, mirrorMode) || other.mirrorMode == mirrorMode)&&const DeepCollectionEquality().equals(other.segmentIds, segmentIds)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,story,storyMode,config,mirrorMode,const DeepCollectionEquality().hash(segmentIds),updatedAt);

@override
String toString() {
  return 'Project(id: $id, name: $name, story: $story, storyMode: $storyMode, config: $config, mirrorMode: $mirrorMode, segmentIds: $segmentIds, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectCopyWith<$Res>  {
  factory $ProjectCopyWith(Project value, $Res Function(Project) _then) = _$ProjectCopyWithImpl;
@useResult
$Res call({
 String? id, String name, String story, String storyMode, ProjectConfig? config, bool mirrorMode, List<String> segmentIds, DateTime? updatedAt
});


$ProjectConfigCopyWith<$Res>? get config;

}
/// @nodoc
class _$ProjectCopyWithImpl<$Res>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._self, this._then);

  final Project _self;
  final $Res Function(Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? story = null,Object? storyMode = null,Object? config = freezed,Object? mirrorMode = null,Object? segmentIds = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,story: null == story ? _self.story : story // ignore: cast_nullable_to_non_nullable
as String,storyMode: null == storyMode ? _self.storyMode : storyMode // ignore: cast_nullable_to_non_nullable
as String,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as ProjectConfig?,mirrorMode: null == mirrorMode ? _self.mirrorMode : mirrorMode // ignore: cast_nullable_to_non_nullable
as bool,segmentIds: null == segmentIds ? _self.segmentIds : segmentIds // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectConfigCopyWith<$Res>? get config {
    if (_self.config == null) {
    return null;
  }

  return $ProjectConfigCopyWith<$Res>(_self.config!, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}


/// Adds pattern-matching-related methods to [Project].
extension ProjectPatterns on Project {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Project value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Project value)  $default,){
final _that = this;
switch (_that) {
case _Project():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Project value)?  $default,){
final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String name,  String story,  String storyMode,  ProjectConfig? config,  bool mirrorMode,  List<String> segmentIds,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.story,_that.storyMode,_that.config,_that.mirrorMode,_that.segmentIds,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String name,  String story,  String storyMode,  ProjectConfig? config,  bool mirrorMode,  List<String> segmentIds,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Project():
return $default(_that.id,_that.name,_that.story,_that.storyMode,_that.config,_that.mirrorMode,_that.segmentIds,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String name,  String story,  String storyMode,  ProjectConfig? config,  bool mirrorMode,  List<String> segmentIds,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.story,_that.storyMode,_that.config,_that.mirrorMode,_that.segmentIds,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Project implements Project {
  const _Project({this.id, this.name = 'Untitled', this.story = '', this.storyMode = 'full_script', this.config, this.mirrorMode = true, final  List<String> segmentIds = const [], this.updatedAt}): _segmentIds = segmentIds;
  factory _Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

@override final  String? id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String story;
@override@JsonKey() final  String storyMode;
@override final  ProjectConfig? config;
@override@JsonKey() final  bool mirrorMode;
 final  List<String> _segmentIds;
@override@JsonKey() List<String> get segmentIds {
  if (_segmentIds is EqualUnmodifiableListView) return _segmentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_segmentIds);
}

@override final  DateTime? updatedAt;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCopyWith<_Project> get copyWith => __$ProjectCopyWithImpl<_Project>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.story, story) || other.story == story)&&(identical(other.storyMode, storyMode) || other.storyMode == storyMode)&&(identical(other.config, config) || other.config == config)&&(identical(other.mirrorMode, mirrorMode) || other.mirrorMode == mirrorMode)&&const DeepCollectionEquality().equals(other._segmentIds, _segmentIds)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,story,storyMode,config,mirrorMode,const DeepCollectionEquality().hash(_segmentIds),updatedAt);

@override
String toString() {
  return 'Project(id: $id, name: $name, story: $story, storyMode: $storyMode, config: $config, mirrorMode: $mirrorMode, segmentIds: $segmentIds, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$ProjectCopyWith(_Project value, $Res Function(_Project) _then) = __$ProjectCopyWithImpl;
@override @useResult
$Res call({
 String? id, String name, String story, String storyMode, ProjectConfig? config, bool mirrorMode, List<String> segmentIds, DateTime? updatedAt
});


@override $ProjectConfigCopyWith<$Res>? get config;

}
/// @nodoc
class __$ProjectCopyWithImpl<$Res>
    implements _$ProjectCopyWith<$Res> {
  __$ProjectCopyWithImpl(this._self, this._then);

  final _Project _self;
  final $Res Function(_Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? story = null,Object? storyMode = null,Object? config = freezed,Object? mirrorMode = null,Object? segmentIds = null,Object? updatedAt = freezed,}) {
  return _then(_Project(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,story: null == story ? _self.story : story // ignore: cast_nullable_to_non_nullable
as String,storyMode: null == storyMode ? _self.storyMode : storyMode // ignore: cast_nullable_to_non_nullable
as String,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as ProjectConfig?,mirrorMode: null == mirrorMode ? _self.mirrorMode : mirrorMode // ignore: cast_nullable_to_non_nullable
as bool,segmentIds: null == segmentIds ? _self._segmentIds : segmentIds // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProjectConfigCopyWith<$Res>? get config {
    if (_self.config == null) {
    return null;
  }

  return $ProjectConfigCopyWith<$Res>(_self.config!, (value) {
    return _then(_self.copyWith(config: value));
  });
}
}

// dart format on
