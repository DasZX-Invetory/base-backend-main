## Tutorial das libs de template

Este documento explica as libs utilitarias adicionadas para deixar o projeto plug-and-play.

### 1. AppEnvKeys

Arquivo: lib/core/config/app_env_keys.dart

Responsabilidade:

- Centralizar nomes de variaveis de ambiente.
- Evitar strings repetidas no codigo.

Como usar:

```dart
final address = await CustomEnv.getOrDefault<String>(
  key: AppEnvKeys.serverAddress,
  defaultValue: '0.0.0.0',
);
```

Chaves disponiveis:

- serverAddress
- serverPort
- dbHost
- dbPort
- dbUser
- dbPassword
- dbSchema
- jwtKey

### 2. AppRoles

Arquivo: lib/core/security/app_roles.dart

Responsabilidade:

- Definir roles oficiais em um unico lugar.
- Evitar erro de digitacao em permissao.

Como usar:

```dart
di<UserOwnerApi>().getHandler(
  isSecurity: true,
  requiredRole: AppRoles.owner,
)
```

Roles disponiveis:

- owner
- admin
- technician
- user

### 3. HealthApi

Arquivo: lib/api/system/health_api.dart

Responsabilidade:

- Fornecer endpoint de saude para monitoramento.

Endpoint:

- GET /health

Resposta:

```json
{
  "success": true,
  "message": "API online",
  "data": { "status": "ok" }
}
```

Uso pratico:

- readiness/liveness em Docker/Kubernetes
- monitoramento por uptime tools

### 4. CustomEnv.getOrDefault

Arquivo: lib/utils/custom_env.dart

Responsabilidade:

- Ler env com fallback padrao.
- Facilitar bootstrap local sem falha de start por env ausente.

Como usar:

```dart
final port = await CustomEnv.getOrDefault<int>(
  key: AppEnvKeys.serverPort,
  defaultValue: 8080,
);
```

Quando usar:

- Valores obrigatorios com default seguro em dev.
- Configs opcionais de runtime.

### 5. MiddlewareInterception

Arquivo: lib/infra/middleware_intercepton.dart

Responsabilidade:

- Middleware global de content-type JSON.
- Middleware CORS com suporte a OPTIONS.

Observacao:

- A classe antiga MiddlewareIntercepton continua disponivel por compatibilidade.
- Em codigo novo, use MiddlewareInterception.

### 6. Resultado pratico dessas libs

Com essas libs, voce ganha:

- Menos boilerplate
- Menos erro por typo
- Bootstrap mais rapido
- Melhor padrao para escalar modulos
