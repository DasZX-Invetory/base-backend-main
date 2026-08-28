## PostgreSQL e Migracoes no Template

Este guia mostra como manter o banco organizado para projetos novos.

### 1. Configuracao atual

- Driver: package postgres
- Conexao: lib/infra/database/postgre_db_configuration.dart
- SQL inicial: database/01_init.sql

### 2. Variaveis de ambiente

- DB_HOST
- DB_PORT
- DB_USER
- DB_PASSWORD
- DB_SCHEMA

### 3. Como o template executa SQL

No compose, a pasta database e montada em:

- /docker-entrypoint-initdb.d

No primeiro start do container postgres, os scripts .sql sao executados.

### 4. Estrategia recomendada de migracao

Para evoluir schema sem apagar dados:

1. Crie pasta database/migrations.
2. Nomeie arquivos com prefixo sequencial:
   - 001_create_products.sql
   - 002_add_index_products_name.sql
3. Execute esses scripts com ferramenta de migracao (Flyway, Liquibase, Dbmate, Goose etc) no pipeline.

### 5. Padrao SQL recomendado

- Sempre use IF NOT EXISTS quando possivel.
- Crie indices para colunas de busca frequente.
- Prefira soft delete quando historico importa.
- Garanta unicidade com UNIQUE.

### 6. Exemplo de migracao

```sql
ALTER TABLE users
ADD COLUMN phone VARCHAR(20);

CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
```

### 7. Conversao de placeholders

No DAO, o template usa ? em SQL.

A classe PostgreDbConfiguration converte automaticamente para parametros nomeados do postgres (@p1, @p2, ...).

Exemplo no DAO:

```dart
await _db.execQuery(
  'SELECT * FROM users WHERE id = ? AND tenant_id = ?',
  [id, tenantId],
);
```

### 8. Erros comuns

- Banco sobe sem script: pasta database nao montada no compose.
- Erro de auth: DB_USER/DB_PASSWORD divergentes entre API e postgres.
- Campo inexistente: SQL alterado sem atualizar Model/DAO.

### 9. Checklist de alteracao de schema

- Script SQL criado
- Model atualizado
- DAO atualizado
- Service ajustado
- API validando campos novos
- Teste manual da rota realizado
