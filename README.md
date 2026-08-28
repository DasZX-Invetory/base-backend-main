## Base Backend Template (Dart + Shelf + PostgreSQL)

Template de backend pronto para acelerar novos projetos, com:

- API REST usando Shelf e Shelf Router
- JWT com controle de autenticação, status e roles
- Arquitetura em camadas (API -> Service -> DAO -> DB)
- Injeção de dependência simples e extensível
- PostgreSQL com script SQL inicial
- Docker e docker-compose prontos
- Tutoriais de uso e extensão na pasta Tutorial

Este repositório foi convertido para ser um template genérico, reaproveitável em diferentes produtos.

### 1) Stack

- Dart SDK 3.10+
- shelf
- shelf_router
- postgres
- dart_jsonwebtoken
- dbcrypt

### 2) Estrutura

```txt
bin/
	main.dart                     # bootstrap do servidor
database/
	01_init.sql                   # schema inicial genérico
lib/
	api/                          # endpoints
	dao/                          # acesso a dados
	infra/                        # servidor, DI, segurança, banco
	models/                       # entidades
	services/                     # regras de negócio
	to/                           # transport objects (DTOs)
	utils/                        # utilitários
Tutorial/                       # guias de uso e extensão
deploy/k8s/                     # manifests Kubernetes/k3s
```

### 3) Configuração de ambiente

Copie o arquivo `.env.example` para `.env` e ajuste os valores:

- `SERVER_ADDRESS`
- `SERVER_PORT`
- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASSWORD`
- `DB_SCHEMA`
- `JWT_KEY`

### 4) Executar localmente (sem Docker)

```bash
dart pub get
dart run bin/main.dart
```

### 5) Executar com Docker Compose

```bash
docker compose up --build
```

API padrão: `http://localhost:8080`

### 6) Como transformar em novo projeto

1. Ajuste nome e descrição em `pubspec.yaml`
2. Atualize `database/01_init.sql` com o schema do seu domínio
3. Crie seus módulos seguindo os tutoriais da pasta `Tutorial/`
4. Registre novas dependências em `lib/infra/dependency_injector/injects.dart`
5. Exponha os handlers no `bin/main.dart`

### 7) Tutoriais recomendados

1. `Tutorial/01_TUTORIAL_COMPLETO.md`
2. `Tutorial/02_TUTORIAL_COMPLETO_PARTE2.md`
3. `Tutorial/09_EXEMPLOS_MODELS_SERVICES_APIS.md`
4. `Tutorial/03_TUTORIAL_LIBS_TEMPLATE.md`
5. `Tutorial/07_TUTORIAL_DOCKER_TEMPLATE.md`
6. `Tutorial/08_TUTORIAL_KUBERNETES_K3S_TEMPLATE.md`

### 8) Observações

- O projeto já está preparado para usar variáveis do `.env` local e também variáveis de ambiente injetadas pelo container/orquestrador.
- A autenticação JWT usa a variável `JWT_KEY`.
- A pasta `deploy/k8s` contém manifests base para uso com k3s.
