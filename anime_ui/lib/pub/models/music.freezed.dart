// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'music.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Music {

 int? get id; int? get projectId; String get title; String get prompt; String get provider; String get model; String get audioUrl; double get duration; String get status; String get taskId;
/// Create a copy of Music
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MusicCopyWith<Music> get copyWith => _$MusicCopyWithImpl<Music>(this as Music, _$identity);

  /// Serializes this Music to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Music&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.model, model) || other.model == model)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.status, status) || other.status == status)&&(identical(other.taskId, taskId) || other.taskId == taskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,title,prompt,provider,model,audioUrl,duration,status,taskId);

@override
String toString() {
  return 'Music(id: $id, projectId: $projectId, title: $title, prompt: $prompt, provider: $provider, model: $model, audioUrl: $audioUrl, duration: $duration, status: $status, taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class $MusicCopyWith<$Res>  {
  factory $MusicCopyWith(Music value, $Res Function(Music) _then) = _$MusicCopyWithImpl;
@useResult
$Res call({
 int? id, int? projectId, String title, String prompt, String provider, String model, String audioUrl, double duration, String status, String taskId
});




}
/// @nodoc
class _$MusicCopyWithImpl<$Res>
    implements $MusicCopyWith<$Res> {
  _$MusicCopyWithImpl(this._self, this._then);

  final Music _self;
  final $Res Function(Music) _then;

/// Create a copy of Music
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? title = null,Object? prompt = null,Object? provider = null,Object? model = null,Object? audioUrl = null,Object? duration = null,Object? status = null,Object? taskId = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Music].
extension MusicPatterns on Music {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Music value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Music() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Music value)  $default,){
final _that = this;
switch (_that) {
case _Music():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Music value)?  $default,){
final _that = this;
switch (_that) {
case _Music() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? projectId,  String title,  String prompt,  String provider,  String model,  String audioUrl,  double duration,  String status,  String taskId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Music() when $default != null:
return $default(_that.id,_that.projectId,_that.title,_that.prompt,_that.provider,_that.model,_that.audioUrl,_that.duration,_that.status,_that.taskId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? projectId,  String title,  String prompt,  String provider,  String model,  String audioUrl,  double duration,  String status,  String taskId)  $default,) {final _that = this;
switch (_that) {
case _Music():
return $default(_that.id,_that.projectId,_that.title,_that.prompt,_that.provider,_that.model,_that.audioUrl,_that.duration,_that.status,_that.taskId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? projectId,  String title,  String prompt,  String provider,  String model,  String audioUrl,  double duration,  String status,  String taskId)?  $default,) {final _that = this;
switch (_that) {
case _Music() when $default != null:
return $default(_that.id,_that.projectId,_that.title,_that.prompt,_that.provider,_that.model,_that.audioUrl,_that.duration,_that.status,_that.taskId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Music extends Music {
  const _Music({this.id, this.projectId, this.title = '', this.prompt = '', this.provider = '', this.model = '', this.audioUrl = '', this.duration = 0, this.status = 'pending', this.taskId = ''}): super._();
  factory _Music.fromJson(Map<String, dynamic> json) => _$MusicFromJson(json);

@override final  int? id;
@override final  int? projectId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String prompt;
@override@JsonKey() final  String provider;
@override@JsonKey() final  String model;
@override@JsonKey() final  String audioUrl;
@override@JsonKey() final  double duration;
@override@JsonKey() final  String status;
@override@JsonKey() final  String taskId;

/// Create a copy of Music
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MusicCopyWith<_Music> get copyWith => __$MusicCopyWithImpl<_Music>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MusicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Music&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.prompt, prompt) || other.prompt == prompt)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.model, model) || other.model == model)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.status, status) || other.status == status)&&(identical(other.taskId, taskId) || other.taskId == taskId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,title,prompt,provider,model,audioUrl,duration,status,taskId);

@override
String toString() {
  return 'Music(id: $id, projectId: $projectId, title: $title, prompt: $prompt, provider: $provider, model: $model, audioUrl: $audioUrl, duration: $duration, status: $status, taskId: $taskId)';
}


}

/// @nodoc
abstract mixin class _$MusicCopyWith<$Res> implements $MusicCopyWith<$Res> {
  factory _$MusicCopyWith(_Music value, $Res Function(_Music) _then) = __$MusicCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? projectId, String title, String prompt, String provider, String model, String audioUrl, double duration, String status, String taskId
});




}
/// @nodoc
class __$MusicCopyWithImpl<$Res>
    implements _$MusicCopyWith<$Res> {
  __$MusicCopyWithImpl(this._self, this._then);

  final _Music _self;
  final $Res Function(_Music) _then;

/// Create a copy of Music
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? title = null,Object? prompt = null,Object? provider = null,Object? model = null,Object? audioUrl = null,Object? duration = null,Object? status = null,Object? taskId = null,}) {
  return _then(_Music(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,prompt: null == prompt ? _self.prompt : prompt // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
