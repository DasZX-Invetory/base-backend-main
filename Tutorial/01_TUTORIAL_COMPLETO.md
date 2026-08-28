## Tutorial Completo - Base Backend Template

Este guia mostra como usar este backend como template para qualquer projeto.

### 1. O que este template entrega

- Estrutura por camadas: API -> Service -> DAO -> DB
- JWT com controle de autenticacao, status e role
- Multi-tenant basico (tenant + users)
- Inversao de dependencia simples
- PostgreSQL pronto para uso
- Docker e Kubernetes (k3s) com exemplos

### 2. Fluxo de requisicao

1. Requisicao entra no handler montado em bin/main.dart.
2. Pipeline global aplica log, content-type e CORS.
3. Router da API recebe a rota.
4. Se rota protegida, middlewares de seguranca validam token, status e role.
5. API chama Service.
6. Service aplica regra de negocio e chama DAO.
7. DAO executa SQL via DbConfiguration.
8. Resposta JSON volta para o cliente.

### 3. Arquivos chave

- bin/main.dart: sobe servidor e registra APIs.
- lib/api/api.dart: classe base para criar API publica/protegida.
- lib/infra/dependency_injector/injects.dart: registro de dependencias.
- lib/infra/security/security_service_imp.dart: JWT + middlewares.
- lib/infra/database/postgre_db_configuration.dart: conexao e queries.
- database/01_init.sql: schema base do template.

### 4. Setup rapido

1. Copie .env.example para .env.
2. Ajuste valores de banco e JWT_KEY.
3. Suba banco e API:

```bash
docker compose up --build
```

4. Ou rode local:

```bash
dart pub get
dart run bin/main.dart
```

### 5. Variaveis obrigatorias

- SERVER_ADDRESS
- SERVER_PORT
- DB_HOST
- DB_PORT
- DB_USER
- DB_PASSWORD
- DB_SCHEMA
- JWT_KEY

### 6. Rotas base existentes

- Auth (publica):
  - POST /api/auth/login
  - POST /api/auth/refresh
  - GET /api/auth/verify
- User owner (protegida role owner)
- Tenant owner/admin/user (protegidas)

Veja detalhes de JWT em 04_JWT_ROLES_TUTORIAL.md.

### 7. Como criar seu proprio dominio

Passo recomendado:

1. Defina tabelas no database/01_init.sql (ou em novos scripts versionados).
2. Crie Model no lib/models.
3. Crie DAO no lib/dao.
4. Crie Service no lib/services.
5. Crie API no lib/api/<modulo>.
6. Registre no Injects.
7. Adicione o handler no main.dart.

O passo a passo completo esta em 02_TUTORIAL_COMPLETO_PARTE2.md.

### 8. Padrao de resposta JSON

Padrao recomendado:

```json
{
  "success": true,
  "message": "Descricao curta",
  "data": {}
}
```

Em erro:

```json
{
  "success": false,
  "message": "Descricao do erro",
  "error_code": "CODIGO_ERRO",
  "data": null
}
```

### 9. Boas praticas para reaproveitar como template

- Nao misture regra de negocio na API.
- Nao acesse banco direto na API.
- Use Service para validacoes e regras.
- Use DAO para SQL.
- Mantenha nomes de rota consistentes.
- Centralize regras de autorizacao em middleware.
- Sempre valide body e query params.

### 10. Ordem de estudo sugerida

1. 01_TUTORIAL_COMPLETO.md (este arquivo)
2. 02_TUTORIAL_COMPLETO_PARTE2.md
3. 03_TUTORIAL_LIBS_TEMPLATE.md
4. 04_JWT_ROLES_TUTORIAL.md
5. 05_TUTORIAL_MIDDLEWARE_STATUS_USUARIO.md
6. 06_TUTORIAL_POSTGRESQL_MIGRACAO.md
7. 07_TUTORIAL_DOCKER_TEMPLATE.md
8. 08_TUTORIAL_KUBERNETES_K3S_TEMPLATE.md
9. 09_EXEMPLOS_MODELS_SERVICES_APIS.md
10. 10_CHECKLIST_TEMPLATE.md
