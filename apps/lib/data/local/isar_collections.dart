import 'package:isar/isar.dart';

part 'isar_collections.g.dart';

@collection
class ProductModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String uid;
  late String name;
  @Index(unique: true, replace: true)
  late String sku;
  late int unitCost; // riel
  late int price; // riel
  late int stock;
  @Index()
  late DateTime updatedAt;
}

@collection
class SaleModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String uid;
  late DateTime createdAt;
  late int total; // riel
  @Index()
  late DateTime updatedAt;
}

@collection
class PaymentModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String uid;
  @Index()
  late String saleUid;
  late String method;
  late int amount; // riel
  @Index()
  late DateTime updatedAt;
}

@collection
class OutboxOp {
  Id id = Isar.autoIncrement;
  @Index()
  late DateTime createdAt;
  // entity: product/sale/payment
  late String entity;
  // op: create/update/delete
  late String op;
  // json payload for remote
  late String payloadJson;
  int retryCount = 0;
}

@collection
class MetaKV {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String key;
  late String value;
}
