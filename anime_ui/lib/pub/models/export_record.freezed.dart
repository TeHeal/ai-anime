// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'export_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExportRecord {

 String? get id; String? get projectId; String get format; String get resolution; String get status; String get outputUrl; int get fileSize; String get taskId; String? get error; int get progress;
/// Create a copy of ExportRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExportRecordCopyWith<ExportRecord> get copyWith => _$ExportRecordCopyWithImpl<ExportRecord>(this as ExportRecord, _$identity);

  /// Serializes this ExportRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExportRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.format, format) || other.format == format)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.status, status) || other.status == status)&&(identical(other.outputUrl, outputUrl) || other.outputUrl == outputUrl)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.error, error) || other.error == error)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,format,resolution,status,outputUrl,fileSize,taskId,error,progress);

@override
String toString() {
  return 'ExportRecord(id: $id, projectId: $projectId, format: $format, resolution: $resolution, status: $status, outputUrl: $outputUrl, fileSize: $fileSize, taskId: $taskId, error: $error, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $ExportRecordCopyWith<$Res>  {
  factory $ExportRecordCopyWith(ExportRecord value, $Res Function(ExportRecord) _then) = _$ExportRecordCopyWithImpl;
@useResult
$Res call({
 String? id, String? projectId, String format, String resolution, String status, String outputUrl, int fileSize, String taskId, String? error, int progress
});




}
/// @nodoc
class _$ExportRecordCopyWithImpl<$Res>
    implements $ExportRecordCopyWith<$Res> {
  _$ExportRecordCopyWithImpl(this._self, this._then);

  final ExportRecord _self;
  final $Res Function(ExportRecord) _then;

/// Create a copy of ExportRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? format = null,Object? resolution = null,Object? status = null,Object? outputUrl = null,Object? fileSize = null,Object? taskId = null,Object? error = freezed,Object? progress = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,resolution: null == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,outputUrl: null == outputUrl ? _self.outputUrl : outputUrl // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ExportRecord].
extension ExportRecordPatterns on ExportRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExportRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExportRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExportRecord value)  $default,){
final _that = this;
switch (_that) {
case _ExportRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExportRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ExportRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? projectId,  String format,  String resolution,  String status,  String outputUrl,  int fileSize,  String taskId,  String? error,  int progress)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExportRecord() when $default != null:
return $default(_that.id,_that.projectId,_that.format,_that.resolution,_that.status,_that.outputUrl,_that.fileSize,_that.taskId,_that.error,_that.progress);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? projectId,  String format,  String resolution,  String status,  String outputUrl,  int fileSize,  String taskId,  String? error,  int progress)  $default,) {final _that = this;
switch (_that) {
case _ExportRecord():
return $default(_that.id,_that.projectId,_that.format,_that.resolution,_that.status,_that.outputUrl,_that.fileSize,_that.taskId,_that.error,_that.progress);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? projectId,  String format,  String resolution,  String status,  String outputUrl,  int fileSize,  String taskId,  String? error,  int progress)?  $default,) {final _that = this;
switch (_that) {
case _ExportRecord() when $default != null:
return $default(_that.id,_that.projectId,_that.format,_that.resolution,_that.status,_that.outputUrl,_that.fileSize,_that.taskId,_that.error,_that.progress);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExportRecord extends ExportRecord {
  const _ExportRecord({this.id, this.projectId, this.format = 'mp4', this.resolution = '1080p', this.status = 'pending', this.outputUrl = '', this.fileSize = 0, this.taskId = '', this.error, this.progress = 0}): super._();
  factory _ExportRecord.fromJson(Map<String, dynamic> json) => _$ExportRecordFromJson(json);

@override final  String? id;
@override final  String? projectId;
@override@JsonKey() final  String format;
@override@JsonKey() final  String resolution;
@override@JsonKey() final  String status;
@override@JsonKey() final  String outputUrl;
@override@JsonKey() final  int fileSize;
@override@JsonKey() final  String taskId;
@override final  String? error;
@override@JsonKey() final  int progress;

/// Create a copy of ExportRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExportRecordCopyWith<_ExportRecord> get copyWith => __$ExportRecordCopyWithImpl<_ExportRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExportRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExportRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.format, format) || other.format == format)&&(identical(other.resolution, resolution) || other.resolution == resolution)&&(identical(other.status, status) || other.status == status)&&(identical(other.outputUrl, outputUrl) || other.outputUrl == outputUrl)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.error, error) || other.error == error)&&(identical(other.progress, progress) || other.progress == progress));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,format,resolution,status,outputUrl,fileSize,taskId,error,progress);

@override
String toString() {
  return 'ExportRecord(id: $id, projectId: $projectId, format: $format, resolution: $resolution, status: $status, outputUrl: $outputUrl, fileSize: $fileSize, taskId: $taskId, error: $error, progress: $progress)';
}


}

/// @nodoc
abstract mixin class _$ExportRecordCopyWith<$Res> implements $ExportRecordCopyWith<$Res> {
  factory _$ExportRecordCopyWith(_ExportRecord value, $Res Function(_ExportRecord) _then) = __$ExportRecordCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? projectId, String format, String resolution, String status, String outputUrl, int fileSize, String taskId, String? error, int progress
});




}
/// @nodoc
class __$ExportRecordCopyWithImpl<$Res>
    implements _$ExportRecordCopyWith<$Res> {
  __$ExportRecordCopyWithImpl(this._self, this._then);

  final _ExportRecord _self;
  final $Res Function(_ExportRecord) _then;

/// Create a copy of ExportRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? format = null,Object? resolution = null,Object? status = null,Object? outputUrl = null,Object? fileSize = null,Object? taskId = null,Object? error = freezed,Object? progress = null,}) {
  return _then(_ExportRecord(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,resolution: null == resolution ? _self.resolution : resolution // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,outputUrl: null == outputUrl ? _self.outputUrl : outputUrl // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
