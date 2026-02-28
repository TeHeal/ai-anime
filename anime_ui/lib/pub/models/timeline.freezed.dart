// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrackItem {

 String get id; String? get sourceId; String get sourceUrl; String get label; double get startAt; double get duration; double get volume; double get trim;
/// Create a copy of TrackItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackItemCopyWith<TrackItem> get copyWith => _$TrackItemCopyWithImpl<TrackItem>(this as TrackItem, _$identity);

  /// Serializes this TrackItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackItem&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.label, label) || other.label == label)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.trim, trim) || other.trim == trim));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceId,sourceUrl,label,startAt,duration,volume,trim);

@override
String toString() {
  return 'TrackItem(id: $id, sourceId: $sourceId, sourceUrl: $sourceUrl, label: $label, startAt: $startAt, duration: $duration, volume: $volume, trim: $trim)';
}


}

/// @nodoc
abstract mixin class $TrackItemCopyWith<$Res>  {
  factory $TrackItemCopyWith(TrackItem value, $Res Function(TrackItem) _then) = _$TrackItemCopyWithImpl;
@useResult
$Res call({
 String id, String? sourceId, String sourceUrl, String label, double startAt, double duration, double volume, double trim
});




}
/// @nodoc
class _$TrackItemCopyWithImpl<$Res>
    implements $TrackItemCopyWith<$Res> {
  _$TrackItemCopyWithImpl(this._self, this._then);

  final TrackItem _self;
  final $Res Function(TrackItem) _then;

/// Create a copy of TrackItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sourceId = freezed,Object? sourceUrl = null,Object? label = null,Object? startAt = null,Object? duration = null,Object? volume = null,Object? trim = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,trim: null == trim ? _self.trim : trim // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackItem].
extension TrackItemPatterns on TrackItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackItem value)  $default,){
final _that = this;
switch (_that) {
case _TrackItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackItem value)?  $default,){
final _that = this;
switch (_that) {
case _TrackItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? sourceId,  String sourceUrl,  String label,  double startAt,  double duration,  double volume,  double trim)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackItem() when $default != null:
return $default(_that.id,_that.sourceId,_that.sourceUrl,_that.label,_that.startAt,_that.duration,_that.volume,_that.trim);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? sourceId,  String sourceUrl,  String label,  double startAt,  double duration,  double volume,  double trim)  $default,) {final _that = this;
switch (_that) {
case _TrackItem():
return $default(_that.id,_that.sourceId,_that.sourceUrl,_that.label,_that.startAt,_that.duration,_that.volume,_that.trim);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? sourceId,  String sourceUrl,  String label,  double startAt,  double duration,  double volume,  double trim)?  $default,) {final _that = this;
switch (_that) {
case _TrackItem() when $default != null:
return $default(_that.id,_that.sourceId,_that.sourceUrl,_that.label,_that.startAt,_that.duration,_that.volume,_that.trim);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackItem implements TrackItem {
  const _TrackItem({required this.id, this.sourceId, this.sourceUrl = '', this.label = '', this.startAt = 0, this.duration = 0, this.volume = 1.0, this.trim = 0});
  factory _TrackItem.fromJson(Map<String, dynamic> json) => _$TrackItemFromJson(json);

@override final  String id;
@override final  String? sourceId;
@override@JsonKey() final  String sourceUrl;
@override@JsonKey() final  String label;
@override@JsonKey() final  double startAt;
@override@JsonKey() final  double duration;
@override@JsonKey() final  double volume;
@override@JsonKey() final  double trim;

/// Create a copy of TrackItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackItemCopyWith<_TrackItem> get copyWith => __$TrackItemCopyWithImpl<_TrackItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackItem&&(identical(other.id, id) || other.id == id)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.label, label) || other.label == label)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.volume, volume) || other.volume == volume)&&(identical(other.trim, trim) || other.trim == trim));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sourceId,sourceUrl,label,startAt,duration,volume,trim);

@override
String toString() {
  return 'TrackItem(id: $id, sourceId: $sourceId, sourceUrl: $sourceUrl, label: $label, startAt: $startAt, duration: $duration, volume: $volume, trim: $trim)';
}


}

/// @nodoc
abstract mixin class _$TrackItemCopyWith<$Res> implements $TrackItemCopyWith<$Res> {
  factory _$TrackItemCopyWith(_TrackItem value, $Res Function(_TrackItem) _then) = __$TrackItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? sourceId, String sourceUrl, String label, double startAt, double duration, double volume, double trim
});




}
/// @nodoc
class __$TrackItemCopyWithImpl<$Res>
    implements _$TrackItemCopyWith<$Res> {
  __$TrackItemCopyWithImpl(this._self, this._then);

  final _TrackItem _self;
  final $Res Function(_TrackItem) _then;

/// Create a copy of TrackItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sourceId = freezed,Object? sourceUrl = null,Object? label = null,Object? startAt = null,Object? duration = null,Object? volume = null,Object? trim = null,}) {
  return _then(_TrackItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sourceId: freezed == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as String?,sourceUrl: null == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,startAt: null == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as double,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,volume: null == volume ? _self.volume : volume // ignore: cast_nullable_to_non_nullable
as double,trim: null == trim ? _self.trim : trim // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Track {

 String get id; String get type; String get name; bool get muted; List<TrackItem> get items;
/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackCopyWith<Track> get copyWith => _$TrackCopyWithImpl<Track>(this as Track, _$identity);

  /// Serializes this Track to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Track&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.muted, muted) || other.muted == muted)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,muted,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'Track(id: $id, type: $type, name: $name, muted: $muted, items: $items)';
}


}

/// @nodoc
abstract mixin class $TrackCopyWith<$Res>  {
  factory $TrackCopyWith(Track value, $Res Function(Track) _then) = _$TrackCopyWithImpl;
@useResult
$Res call({
 String id, String type, String name, bool muted, List<TrackItem> items
});




}
/// @nodoc
class _$TrackCopyWithImpl<$Res>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._self, this._then);

  final Track _self;
  final $Res Function(Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? muted = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<TrackItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Track].
extension TrackPatterns on Track {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Track value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Track value)  $default,){
final _that = this;
switch (_that) {
case _Track():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Track value)?  $default,){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String name,  bool muted,  List<TrackItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.muted,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String name,  bool muted,  List<TrackItem> items)  $default,) {final _that = this;
switch (_that) {
case _Track():
return $default(_that.id,_that.type,_that.name,_that.muted,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String name,  bool muted,  List<TrackItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.muted,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Track implements Track {
  const _Track({required this.id, required this.type, this.name = '', this.muted = false, final  List<TrackItem> items = const []}): _items = items;
  factory _Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

@override final  String id;
@override final  String type;
@override@JsonKey() final  String name;
@override@JsonKey() final  bool muted;
 final  List<TrackItem> _items;
@override@JsonKey() List<TrackItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackCopyWith<_Track> get copyWith => __$TrackCopyWithImpl<_Track>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Track&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.muted, muted) || other.muted == muted)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,muted,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Track(id: $id, type: $type, name: $name, muted: $muted, items: $items)';
}


}

/// @nodoc
abstract mixin class _$TrackCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$TrackCopyWith(_Track value, $Res Function(_Track) _then) = __$TrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String name, bool muted, List<TrackItem> items
});




}
/// @nodoc
class __$TrackCopyWithImpl<$Res>
    implements _$TrackCopyWith<$Res> {
  __$TrackCopyWithImpl(this._self, this._then);

  final _Track _self;
  final $Res Function(_Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? muted = null,Object? items = null,}) {
  return _then(_Track(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<TrackItem>,
  ));
}


}


/// @nodoc
mixin _$ProjectTimeline {

 String? get id; String? get projectId; double get duration; List<Track> get tracks;
/// Create a copy of ProjectTimeline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectTimelineCopyWith<ProjectTimeline> get copyWith => _$ProjectTimelineCopyWithImpl<ProjectTimeline>(this as ProjectTimeline, _$identity);

  /// Serializes this ProjectTimeline to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectTimeline&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.duration, duration) || other.duration == duration)&&const DeepCollectionEquality().equals(other.tracks, tracks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,duration,const DeepCollectionEquality().hash(tracks));

@override
String toString() {
  return 'ProjectTimeline(id: $id, projectId: $projectId, duration: $duration, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class $ProjectTimelineCopyWith<$Res>  {
  factory $ProjectTimelineCopyWith(ProjectTimeline value, $Res Function(ProjectTimeline) _then) = _$ProjectTimelineCopyWithImpl;
@useResult
$Res call({
 String? id, String? projectId, double duration, List<Track> tracks
});




}
/// @nodoc
class _$ProjectTimelineCopyWithImpl<$Res>
    implements $ProjectTimelineCopyWith<$Res> {
  _$ProjectTimelineCopyWithImpl(this._self, this._then);

  final ProjectTimeline _self;
  final $Res Function(ProjectTimeline) _then;

/// Create a copy of ProjectTimeline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? projectId = freezed,Object? duration = null,Object? tracks = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,tracks: null == tracks ? _self.tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<Track>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectTimeline].
extension ProjectTimelinePatterns on ProjectTimeline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectTimeline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectTimeline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectTimeline value)  $default,){
final _that = this;
switch (_that) {
case _ProjectTimeline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectTimeline value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectTimeline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? projectId,  double duration,  List<Track> tracks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectTimeline() when $default != null:
return $default(_that.id,_that.projectId,_that.duration,_that.tracks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? projectId,  double duration,  List<Track> tracks)  $default,) {final _that = this;
switch (_that) {
case _ProjectTimeline():
return $default(_that.id,_that.projectId,_that.duration,_that.tracks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? projectId,  double duration,  List<Track> tracks)?  $default,) {final _that = this;
switch (_that) {
case _ProjectTimeline() when $default != null:
return $default(_that.id,_that.projectId,_that.duration,_that.tracks);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectTimeline implements ProjectTimeline {
  const _ProjectTimeline({this.id, this.projectId, this.duration = 0, final  List<Track> tracks = const []}): _tracks = tracks;
  factory _ProjectTimeline.fromJson(Map<String, dynamic> json) => _$ProjectTimelineFromJson(json);

@override final  String? id;
@override final  String? projectId;
@override@JsonKey() final  double duration;
 final  List<Track> _tracks;
@override@JsonKey() List<Track> get tracks {
  if (_tracks is EqualUnmodifiableListView) return _tracks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tracks);
}


/// Create a copy of ProjectTimeline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectTimelineCopyWith<_ProjectTimeline> get copyWith => __$ProjectTimelineCopyWithImpl<_ProjectTimeline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectTimelineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectTimeline&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.duration, duration) || other.duration == duration)&&const DeepCollectionEquality().equals(other._tracks, _tracks));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,duration,const DeepCollectionEquality().hash(_tracks));

@override
String toString() {
  return 'ProjectTimeline(id: $id, projectId: $projectId, duration: $duration, tracks: $tracks)';
}


}

/// @nodoc
abstract mixin class _$ProjectTimelineCopyWith<$Res> implements $ProjectTimelineCopyWith<$Res> {
  factory _$ProjectTimelineCopyWith(_ProjectTimeline value, $Res Function(_ProjectTimeline) _then) = __$ProjectTimelineCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? projectId, double duration, List<Track> tracks
});




}
/// @nodoc
class __$ProjectTimelineCopyWithImpl<$Res>
    implements _$ProjectTimelineCopyWith<$Res> {
  __$ProjectTimelineCopyWithImpl(this._self, this._then);

  final _ProjectTimeline _self;
  final $Res Function(_ProjectTimeline) _then;

/// Create a copy of ProjectTimeline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? projectId = freezed,Object? duration = null,Object? tracks = null,}) {
  return _then(_ProjectTimeline(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as double,tracks: null == tracks ? _self._tracks : tracks // ignore: cast_nullable_to_non_nullable
as List<Track>,
  ));
}


}

// dart format on
