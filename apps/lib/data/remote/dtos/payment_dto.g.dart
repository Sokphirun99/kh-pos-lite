// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentDtoImpl _$$PaymentDtoImplFromJson(Map<String, dynamic> json) =>
    _$PaymentDtoImpl(
      id: json['id'] as String,
      saleId: json['saleId'] as String,
      method: json['method'] as String,
      amount: json['amount'] as int,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$PaymentDtoImplToJson(_$PaymentDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'method': instance.method,
      'amount': instance.amount,
      'updatedAt': instance.updatedAt,
    };
