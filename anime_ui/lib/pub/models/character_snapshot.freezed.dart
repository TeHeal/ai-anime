// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'character_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CharacterSnapshot {

 int? get id; int get characterId; int get projectId; String get startSceneId; String get endSceneId; String get triggerEvent; String get costume; String get hairstyle; String get physicalMarks; String get accessories; String get mentalState; String get demeanor; String get relationshipsJson; String get composedAppearance; int get sortIndex; String get source; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of CharacterSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterSnapshotCopyWith<CharacterSnapshot> get copyWith => _$CharacterSnapshotCopyWithImpl<CharacterSnapshot>(this as CharacterSnapshot, _$identity);

  /// Serializes this CharacterSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterSnapshot&&(identical(other.id, id) || other.id == id)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.startSceneId, startSceneId) || other.startSceneId == startSceneId)&&(identical(other.endSceneId, endSceneId) || other.endSceneId == endSceneId)&&(identical(other.triggerEvent, triggerEvent) || other.triggerEvent == triggerEvent)&&(identical(other.costume, costume) || other.costume == costume)&&(identical(other.hairstyle, hairstyle) || other.hairstyle == hairstyle)&&(identical(other.physicalMarks, physicalMarks) || other.physicalMarks == physicalMarks)&&(identical(other.accessories, accessories) || other.accessories == accessories)&&(identical(other.mentalState, mentalState) || other.mentalState == mentalState)&&(identical(other.demeanor, demeanor) || other.demeanor == demeanor)&&(identical(other.relationshipsJson, relationshipsJson) || other.relationshipsJson == relationshipsJson)&&(identical(other.composedAppearance, composedAppearance) || other.composedAppearance == composedAppearance)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,characterId,projectId,startSceneId,endSceneId,triggerEvent,costume,hairstyle,physicalMarks,accessories,mentalState,demeanor,relationshipsJson,composedAppearance,sortIndex,source,createdAt,updatedAt);

@override
String toString() {
  return 'CharacterSnapshot(id: $id, characterId: $characterId, projectId: $projectId, startSceneId: $startSceneId, endSceneId: $endSceneId, triggerEvent: $triggerEvent, costume: $costume, hairstyle: $hairstyle, physicalMarks: $physicalMarks, accessories: $accessories, mentalState: $mentalState, demeanor: $demeanor, relationshipsJson: $relationshipsJson, composedAppearance: $composedAppearance, sortIndex: $sortIndex, source: $source, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CharacterSnapshotCopyWith<$Res>  {
  factory $CharacterSnapshotCopyWith(CharacterSnapshot value, $Res Function(CharacterSnapshot) _then) = _$CharacterSnapshotCopyWithImpl;
@useResult
$Res call({
 int? id, int characterId, int projectId, String startSceneId, String endSceneId, String triggerEvent, String costume, String hairstyle, String physicalMarks, String accessories, String mentalState, String demeanor, String relationshipsJson, String composedAppearance, int sortIndex, String source, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$CharacterSnapshotCopyWithImpl<$Res>
    implements $CharacterSnapshotCopyWith<$Res> {
  _$CharacterSnapshotCopyWithImpl(this._self, this._then);

  final CharacterSnapshot _self;
  final $Res Function(CharacterSnapshot) _then;

/// Create a copy of CharacterSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? characterId = null,Object? projectId = null,Object? startSceneId = null,Object? endSceneId = null,Object? triggerEvent = null,Object? costume = null,Object? hairstyle = null,Object? physicalMarks = null,Object? accessories = null,Object? mentalState = null,Object? demeanor = null,Object? relationshipsJson = null,Object? composedAppearance = null,Object? sortIndex = null,Object? source = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,characterId: null == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as int,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,startSceneId: null == startSceneId ? _self.startSceneId : startSceneId // ignore: cast_nullable_to_non_nullable
as String,endSceneId: null == endSceneId ? _self.endSceneId : endSceneId // ignore: cast_nullable_to_non_nullable
as String,triggerEvent: null == triggerEvent ? _self.triggerEvent : triggerEvent // ignore: cast_nullable_to_non_nullable
as String,costume: null == costume ? _self.costume : costume // ignore: cast_nullable_to_non_nullable
as String,hairstyle: null == hairstyle ? _self.hairstyle : hairstyle // ignore: cast_nullable_to_non_nullable
as String,physicalMarks: null == physicalMarks ? _self.physicalMarks : physicalMarks // ignore: cast_nullable_to_non_nullable
as String,accessories: null == accessories ? _self.accessories : accessories // ignore: cast_nullable_to_non_nullable
as String,mentalState: null == mentalState ? _self.mentalState : mentalState // ignore: cast_nullable_to_non_nullable
as String,demeanor: null == demeanor ? _self.demeanor : demeanor // ignore: cast_nullable_to_non_nullable
as String,relationshipsJson: null == relationshipsJson ? _self.relationshipsJson : relationshipsJson // ignore: cast_nullable_to_non_nullable
as String,composedAppearance: null == composedAppearance ? _self.composedAppearance : composedAppearance // ignore: cast_nullable_to_non_nullable
as String,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CharacterSnapshot].
extension CharacterSnapshotPatterns on CharacterSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CharacterSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CharacterSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CharacterSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _CharacterSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CharacterSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _CharacterSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int characterId,  int projectId,  String startSceneId,  String endSceneId,  String triggerEvent,  String costume,  String hairstyle,  String physicalMarks,  String accessories,  String mentalState,  String demeanor,  String relationshipsJson,  String composedAppearance,  int sortIndex,  String source,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CharacterSnapshot() when $default != null:
return $default(_that.id,_that.characterId,_that.projectId,_that.startSceneId,_that.endSceneId,_that.triggerEvent,_that.costume,_that.hairstyle,_that.physicalMarks,_that.accessories,_that.mentalState,_that.demeanor,_that.relationshipsJson,_that.composedAppearance,_that.sortIndex,_that.source,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int characterId,  int projectId,  String startSceneId,  String endSceneId,  String triggerEvent,  String costume,  String hairstyle,  String physicalMarks,  String accessories,  String mentalState,  String demeanor,  String relationshipsJson,  String composedAppearance,  int sortIndex,  String source,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CharacterSnapshot():
return $default(_that.id,_that.characterId,_that.projectId,_that.startSceneId,_that.endSceneId,_that.triggerEvent,_that.costume,_that.hairstyle,_that.physicalMarks,_that.accessories,_that.mentalState,_that.demeanor,_that.relationshipsJson,_that.composedAppearance,_that.sortIndex,_that.source,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int characterId,  int projectId,  String startSceneId,  String endSceneId,  String triggerEvent,  String costume,  String hairstyle,  String physicalMarks,  String accessories,  String mentalState,  String demeanor,  String relationshipsJson,  String composedAppearance,  int sortIndex,  String source,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CharacterSnapshot() when $default != null:
return $default(_that.id,_that.characterId,_that.projectId,_that.startSceneId,_that.endSceneId,_that.triggerEvent,_that.costume,_that.hairstyle,_that.physicalMarks,_that.accessories,_that.mentalState,_that.demeanor,_that.relationshipsJson,_that.composedAppearance,_that.sortIndex,_that.source,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CharacterSnapshot extends CharacterSnapshot {
  const _CharacterSnapshot({this.id, required this.characterId, required this.projectId, this.startSceneId = '', this.endSceneId = '', this.triggerEvent = '', this.costume = '', this.hairstyle = '', this.physicalMarks = '', this.accessories = '', this.mentalState = '', this.demeanor = '', this.relationshipsJson = '', this.composedAppearance = '', this.sortIndex = 0, this.source = 'ai', this.createdAt, this.updatedAt}): super._();
  factory _CharacterSnapshot.fromJson(Map<String, dynamic> json) => _$CharacterSnapshotFromJson(json);

@override final  int? id;
@override final  int characterId;
@override final  int projectId;
@override@JsonKey() final  String startSceneId;
@override@JsonKey() final  String endSceneId;
@override@JsonKey() final  String triggerEvent;
@override@JsonKey() final  String costume;
@override@JsonKey() final  String hairstyle;
@override@JsonKey() final  String physicalMarks;
@override@JsonKey() final  String accessories;
@override@JsonKey() final  String mentalState;
@override@JsonKey() final  String demeanor;
@override@JsonKey() final  String relationshipsJson;
@override@JsonKey() final  String composedAppearance;
@override@JsonKey() final  int sortIndex;
@override@JsonKey() final  String source;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of CharacterSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CharacterSnapshotCopyWith<_CharacterSnapshot> get copyWith => __$CharacterSnapshotCopyWithImpl<_CharacterSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CharacterSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CharacterSnapshot&&(identical(other.id, id) || other.id == id)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.startSceneId, startSceneId) || other.startSceneId == startSceneId)&&(identical(other.endSceneId, endSceneId) || other.endSceneId == endSceneId)&&(identical(other.triggerEvent, triggerEvent) || other.triggerEvent == triggerEvent)&&(identical(other.costume, costume) || other.costume == costume)&&(identical(other.hairstyle, hairstyle) || other.hairstyle == hairstyle)&&(identical(other.physicalMarks, physicalMarks) || other.physicalMarks == physicalMarks)&&(identical(other.accessories, accessories) || other.accessories == accessories)&&(identical(other.mentalState, mentalState) || other.mentalState == mentalState)&&(identical(other.demeanor, demeanor) || other.demeanor == demeanor)&&(identical(other.relationshipsJson, relationshipsJson) || other.relationshipsJson == relationshipsJson)&&(identical(other.composedAppearance, composedAppearance) || other.composedAppearance == composedAppearance)&&(identical(other.sortIndex, sortIndex) || other.sortIndex == sortIndex)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,characterId,projectId,startSceneId,endSceneId,triggerEvent,costume,hairstyle,physicalMarks,accessories,mentalState,demeanor,relationshipsJson,composedAppearance,sortIndex,source,createdAt,updatedAt);

@override
String toString() {
  return 'CharacterSnapshot(id: $id, characterId: $characterId, projectId: $projectId, startSceneId: $startSceneId, endSceneId: $endSceneId, triggerEvent: $triggerEvent, costume: $costume, hairstyle: $hairstyle, physicalMarks: $physicalMarks, accessories: $accessories, mentalState: $mentalState, demeanor: $demeanor, relationshipsJson: $relationshipsJson, composedAppearance: $composedAppearance, sortIndex: $sortIndex, source: $source, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CharacterSnapshotCopyWith<$Res> implements $CharacterSnapshotCopyWith<$Res> {
  factory _$CharacterSnapshotCopyWith(_CharacterSnapshot value, $Res Function(_CharacterSnapshot) _then) = __$CharacterSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int? id, int characterId, int projectId, String startSceneId, String endSceneId, String triggerEvent, String costume, String hairstyle, String physicalMarks, String accessories, String mentalState, String demeanor, String relationshipsJson, String composedAppearance, int sortIndex, String source, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$CharacterSnapshotCopyWithImpl<$Res>
    implements _$CharacterSnapshotCopyWith<$Res> {
  __$CharacterSnapshotCopyWithImpl(this._self, this._then);

  final _CharacterSnapshot _self;
  final $Res Function(_CharacterSnapshot) _then;

/// Create a copy of CharacterSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? characterId = null,Object? projectId = null,Object? startSceneId = null,Object? endSceneId = null,Object? triggerEvent = null,Object? costume = null,Object? hairstyle = null,Object? physicalMarks = null,Object? accessories = null,Object? mentalState = null,Object? demeanor = null,Object? relationshipsJson = null,Object? composedAppearance = null,Object? sortIndex = null,Object? source = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_CharacterSnapshot(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,characterId: null == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as int,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as int,startSceneId: null == startSceneId ? _self.startSceneId : startSceneId // ignore: cast_nullable_to_non_nullable
as String,endSceneId: null == endSceneId ? _self.endSceneId : endSceneId // ignore: cast_nullable_to_non_nullable
as String,triggerEvent: null == triggerEvent ? _self.triggerEvent : triggerEvent // ignore: cast_nullable_to_non_nullable
as String,costume: null == costume ? _self.costume : costume // ignore: cast_nullable_to_non_nullable
as String,hairstyle: null == hairstyle ? _self.hairstyle : hairstyle // ignore: cast_nullable_to_non_nullable
as String,physicalMarks: null == physicalMarks ? _self.physicalMarks : physicalMarks // ignore: cast_nullable_to_non_nullable
as String,accessories: null == accessories ? _self.accessories : accessories // ignore: cast_nullable_to_non_nullable
as String,mentalState: null == mentalState ? _self.mentalState : mentalState // ignore: cast_nullable_to_non_nullable
as String,demeanor: null == demeanor ? _self.demeanor : demeanor // ignore: cast_nullable_to_non_nullable
as String,relationshipsJson: null == relationshipsJson ? _self.relationshipsJson : relationshipsJson // ignore: cast_nullable_to_non_nullable
as String,composedAppearance: null == composedAppearance ? _self.composedAppearance : composedAppearance // ignore: cast_nullable_to_non_nullable
as String,sortIndex: null == sortIndex ? _self.sortIndex : sortIndex // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
