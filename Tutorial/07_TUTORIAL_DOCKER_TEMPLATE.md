## Tutorial Docker - Backend Template

Este guia mostra como rodar o template em containers.

### 1. Arquivos usados

- Dockerfile
- docker-compose.yml
- .env (opcional para local)

### 2. Build e run

```bash
docker compose up --build
```

Para rodar em background:

```bash
docker compose up --build -d
```

### 3. Parar ambiente

```bash
docker compose down
```

Apagar volumes (cuidado: remove dados do banco):

```bash
docker compose down -v
```

### 4. Logs

```bash
docker compose logs -f api
docker compose logs -f postgres
```

### 5. Portas padrao

- API: 8080
- PostgreSQL: 5432

### 6. Variaveis no compose

A API recebe:

- SERVER_ADDRESS=0.0.0.0
- SERVER_PORT=8080
- DB_HOST=postgres
- DB_PORT=5432
- DB_USER=app_user
- DB_PASSWORD=app_password
- DB_SCHEMA=app_db
- JWT_KEY=troque_esta_chave_em_producao

### 7. Trocar para producao

- Trocar JWT_KEY
- Trocar DB_PASSWORD
- Nao expor porta 5432 publicamente se nao necessario
- Usar imagens com tag fixa
- Adicionar healthchecks de API

### 8. Dica de produtividade

Durante desenvolvimento, voce pode manter banco no Docker e rodar API local:

```bash
docker compose up -d postgres
dart run bin/main.dart
```

Ajuste DB_HOST no .env para localhost nesse caso.
