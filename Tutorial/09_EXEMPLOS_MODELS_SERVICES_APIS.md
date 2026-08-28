## Exemplos Rapidos - Model, DAO, Service e API

Este arquivo e um cheat sheet para nao esquecer o padrao.

### 1. Model

Responsabilidade:

- parse do banco (fromMap)
- parse do request (fromRequest)
- serializacao de resposta (toJson)

Modelo minimo:

```dart
class ExampleModel {
  int? id;
  String? name;

  ExampleModel({this.id, this.name});

  factory ExampleModel.fromMap(Map<String, dynamic> map) {
    return ExampleModel(
      id: map['id'] as int?,
      name: map['name'] as String?,
    );
  }

  factory ExampleModel.fromRequest(Map map) {
    return ExampleModel(
      id: map['id'] as int?,
      name: map['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
```

### 2. DAO

Responsabilidade:

- SQL puro
- mapear Result para Model

Contrato usado no projeto:

```dart
abstract class DAO<T, I> {
  Future<bool> create(T value);
  Future<bool> delete(I id);
  Future<List<T>> findAll();
  Future<T?> findOne(I id);
  Future<bool> update(T value);
}
```

### 3. Service

Responsabilidade:

- regra de negocio
- validacoes
- hash de senha
- orquestracao entre DAOs

Padrao save:

```dart
Future<bool> save(Entity value) {
  if (value.id != null) {
    return _dao.update(value);
  }
  return _dao.create(value);
}
```

### 4. API

Responsabilidade:

- receber request
- validar input
- chamar service
- retornar JSON padrao

Boilerplate:

```dart
class ExampleApi extends Api {
  final ExampleService _service;
  ExampleApi(this._service);

  @override
  Handler getHandler({
    List<Middleware>? middlewares,
    bool isSecurity = false,
    String? requiredRole,
  }) {
    final router = Router();

    router.get('/api/example/search', (Request req) async {
      final list = await _service.findAll();
      return Response.ok(jsonEncode({
        'success': true,
        'message': 'Itens encontrados',
        'data': {'items': list.map((e) => e.toJson()).toList()},
      }));
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

### 5. Registro no Injects

```dart
di.register<ExampleDao>(() => ExampleDao(di<DbConfiguration>()));
di.register<ExampleService>(() => ExampleService(di<ExampleDao>()));
di.register<ExampleApi>(() => ExampleApi(di<ExampleService>()));
```

### 6. Registro no main

```dart
.add(di<ExampleApi>().getHandler(isSecurity: true, requiredRole: 'admin'))
```

### 7. Erros comuns

- esquecer de registrar no DI
- esquecer de adicionar no cascade do main
- usar campo SQL diferente do model
- retornar erro sem error_code
