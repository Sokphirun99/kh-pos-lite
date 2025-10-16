import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_dto.freezed.dart';
part 'sale_dto.g.dart';

@freezed
class SaleDto with _$SaleDto {
  const factory SaleDto({
    required String id,
    required String createdAt,
    required int total,
    required String updatedAt,
  }) = _SaleDto;

  factory SaleDto.fromJson(Map<String, dynamic> json) =>
      _$SaleDtoFromJson(json);
}
