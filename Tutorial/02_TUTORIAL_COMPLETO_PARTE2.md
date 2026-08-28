## Tutorial Completo Parte 2 - Criando um modulo novo

Este guia mostra como criar uma feature completa no template.

Exemplo: modulo Product.

### 1. Criar Model

Arquivo sugerido: lib/models/product_model.dart

```dart
class ProductModel {
  int? id;
  String? tenantId;
  String? name;
  double? price;
  bool? active;

  ProductModel({this.id, this.tenantId, this.name, this.price, this.active});

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      tenantId: map['tenant_id']?.toString(),
      name: map['name'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      active: map['is_active'] as bool?,
    );
  }

  factory ProductModel.fromRequest(Map map) {
    return ProductModel(
      id: map['id'] as int?,
      tenantId: map['tenant_id']?.toString(),
      name: map['name'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      active: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'name': name,
      'price': price,
      'is_active': active,
    };
  }
}
```

### 2. Criar tabela SQL

Exemplo para adicionar no schema:

```sql
CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  name VARCHAR(255) NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_products_tenant ON products(tenant_id);
```

### 3. Criar DAO

Arquivo sugerido: lib/dao/product_dao.dart

```dart
import 'package:backend_daszx_inventory/dao/dao.dart';
import 'package:backend_daszx_inventory/infra/database/db_configuration.dart';
import 'package:backend_daszx_inventory/models/product_model.dart';
import 'package:postgres/postgres.dart';

class ProductDao implements DAO<ProductModel, int> {
  final DbConfiguration _db;
  ProductDao(this._db);

  @override
  Future<bool> create(ProductModel value) async {
    final Result result = await _db.execQuery(
      'INSERT INTO products (tenant_id, name, price, is_active) VALUES (?, ?, ?, ?)',
      [value.tenantId, value.name, value.price, value.active ?? true],
    );
    return result.affectedRows > 0;
  }

  @override
  Future<bool> delete(int id) async {
    final Result result = await _db.execQuery(
      'UPDATE products SET is_active = false WHERE id = ?',
      [id],
    );
    return result.affectedRows > 0;
  }

  @override
  Future<List<ProductModel>> findAll() async {
    final Result result = await _db.execQuery('SELECT * FROM products');
    return result.map((r) => ProductModel.fromMap(r.fields)).toList();
  }

  @override
  Future<ProductModel?> findOne(int id) async {
    final Result result = await _db.execQuery(
      'SELECT * FROM products WHERE id = ?',
      [id],
    );
    return result.isEmpty ? null : ProductModel.fromMap(result.first.fields);
  }

  @override
  Future<bool> update(ProductModel value) async {
    final Result result = await _db.execQuery(
      'UPDATE products SET name = ?, price = ?, is_active = ? WHERE id = ?',
      [value.name, value.price, value.active, value.id],
    );
    return result.affectedRows > 0;
  }
}
```

### 4. Criar Service

Arquivo sugerido: lib/services/product_service.dart

```dart
import 'package:backend_daszx_inventory/models/product_model.dart';
import 'package:backend_daszx_inventory/dao/product_dao.dart';
import 'package:backend_daszx_inventory/services/generic_service.dart';

class ProductService implements GenericService<ProductModel, int> {
  final ProductDao _dao;
  ProductService(this._dao);

  @override
  Future<bool> delete(int id) => _dao.delete(id);

  @override
  Future<List<ProductModel>> findAll() => _dao.findAll();

  @override
  Future<ProductModel?> findOne(int id) => _dao.findOne(id);

  @override
  Future<bool> save(ProductModel value) {
    if (value.id != null) {
      return _dao.update(value);
    }
    return _dao.create(value);
  }
}
```

### 5. Criar API

Arquivo sugerido: lib/api/products/product_api.dart

```dart
import 'dart:convert';
import 'package:backend_daszx_inventory/api/api.dart';
import 'package:backend_daszx_inventory/models/product_model.dart';
import 'package:backend_daszx_inventory/services/product_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ProductApi extends Api {
  final ProductService _service;
  ProductApi(this._service);

  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  }) {
    final router = Router();

    router.get('/api/product/search', (Request req) async {
      final products = await _service.findAll();
      return Response.ok(
        jsonEncode({
          'success': true,
          'message': 'Produtos encontrados',
          'data': {'products': products.map((e) => e.toJson()).toList()},
        }),
      );
    });

    router.post('/api/product/create', (Request req) async {
      final body = await req.readAsString();
      final map = jsonDecode(body) as Map<String, dynamic>;
      final product = ProductModel.fromRequest(map);

      final result = await _service.save(product);
      if (!result) {
        return Response.internalServerError(
          body: jsonEncode({
            'success': false,
            'message': 'Erro ao criar produto',
            'error_code': 'CREATE_PRODUCT_ERROR',
            'data': null,
          }),
        );
      }

      return Response(
        201,
        body: jsonEncode({
          'success': true,
          'message': 'Produto criado com sucesso',
          'data': null,
        }),
      );
    });

    return createHandler(
      router: router.call,
      middlewares: middlewares,
      isSecurity: isSecurity,
      requiredRole: requiredRole,
    );
  }
}
```

### 6. Registrar no DI

Arquivo: lib/infra/dependency_injector/injects.dart

```dart
di.register<ProductDao>(() => ProductDao(di<DbConfiguration>()));
di.register<ProductService>(() => ProductService(di<ProductDao>()));
di.register<ProductApi>(() => ProductApi(di<ProductService>()));
```

### 7. Expor no main.dart

```dart
.add(
  di<ProductApi>().getHandler(
    isSecurity: true,
    requiredRole: 'admin',
  ),
)
```

### 8. Publica x protegida x role

- Publica: isSecurity: false
- Protegida por token: isSecurity: true
- Protegida por role: isSecurity: true + requiredRole

### 9. Checklist rapido por modulo

- Model criado
- SQL criado
- DAO criado
- Service criado
- API criada
- DI registrado
- Handler adicionado no main
- Validacoes de entrada implementadas
- Respostas padronizadas
