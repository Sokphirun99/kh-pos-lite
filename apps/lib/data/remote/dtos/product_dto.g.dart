// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductDtoImpl _$$ProductDtoImplFromJson(Map<String, dynamic> json) =>
    _$ProductDtoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      unitCost: json['unitCost'] as int,
      price: json['price'] as int,
      stock: json['stock'] as int,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$ProductDtoImplToJson(_$ProductDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sku': instance.sku,
      'unitCost': instance.unitCost,
      'price': instance.price,
      'stock': instance.stock,
      'updatedAt': instance.updatedAt,
    };
