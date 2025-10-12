// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaleDtoImpl _$$SaleDtoImplFromJson(Map<String, dynamic> json) =>
    _$SaleDtoImpl(
      id: json['id'] as String,
      createdAt: json['createdAt'] as String,
      total: (json['total'] as num).toInt(),
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$SaleDtoImplToJson(_$SaleDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'total': instance.total,
      'updatedAt': instance.updatedAt,
    };
