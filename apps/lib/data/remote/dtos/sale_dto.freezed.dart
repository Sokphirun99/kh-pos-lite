// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SaleDto _$SaleDtoFromJson(Map<String, dynamic> json) {
  return _SaleDto.fromJson(json);
}

/// @nodoc
mixin _$SaleDto {
  String get id => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SaleDtoCopyWith<SaleDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SaleDtoCopyWith<$Res> {
  factory $SaleDtoCopyWith(SaleDto value, $Res Function(SaleDto) then) =
      _$SaleDtoCopyWithImpl<$Res, SaleDto>;
  @useResult
  $Res call({String id, String createdAt, int total, String updatedAt});
}

/// @nodoc
class _$SaleDtoCopyWithImpl<$Res, $Val extends SaleDto>
    implements $SaleDtoCopyWith<$Res> {
  _$SaleDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? total = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SaleDtoImplCopyWith<$Res> implements $SaleDtoCopyWith<$Res> {
  factory _$$SaleDtoImplCopyWith(
          _$SaleDtoImpl value, $Res Function(_$SaleDtoImpl) then) =
      __$$SaleDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String createdAt, int total, String updatedAt});
}

/// @nodoc
class __$$SaleDtoImplCopyWithImpl<$Res>
    extends _$SaleDtoCopyWithImpl<$Res, _$SaleDtoImpl>
    implements _$$SaleDtoImplCopyWith<$Res> {
  __$$SaleDtoImplCopyWithImpl(
      _$SaleDtoImpl _value, $Res Function(_$SaleDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? total = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SaleDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SaleDtoImpl implements _SaleDto {
  const _$SaleDtoImpl(
      {required this.id,
      required this.createdAt,
      required this.total,
      required this.updatedAt});

  factory _$SaleDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SaleDtoImplFromJson(json);

  @override
  final String id;
  @override
  final String createdAt;
  @override
  final int total;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'SaleDto(id: $id, createdAt: $createdAt, total: $total, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaleDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, total, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SaleDtoImplCopyWith<_$SaleDtoImpl> get copyWith =>
      __$$SaleDtoImplCopyWithImpl<_$SaleDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SaleDtoImplToJson(
      this,
    );
  }
}

abstract class _SaleDto implements SaleDto {
  const factory _SaleDto(
      {required final String id,
      required final String createdAt,
      required final int total,
      required final String updatedAt}) = _$SaleDtoImpl;

  factory _SaleDto.fromJson(Map<String, dynamic> json) = _$SaleDtoImpl.fromJson;

  @override
  String get id;
  @override
  String get createdAt;
  @override
  int get total;
  @override
  String get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$SaleDtoImplCopyWith<_$SaleDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
