class ApiPaths {
  static const products = 'products';
  static const sales = 'sales';
  static const payments = 'payments';

  static const create = 'create';
  static const update = 'update';
  static const delete = 'delete';

  static String op(String entity, String operation) => '/$entity/$operation';
}

