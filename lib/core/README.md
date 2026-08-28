# Core do template

A pasta core concentra constantes de configuracao e seguranca para reduzir acoplamento e repeticao.

## Arquivos

- config/app_env_keys.dart
- security/app_roles.dart

## app_env_keys.dart

Centraliza as chaves de ambiente usadas no projeto.

Uso:

```dart
final address = await CustomEnv.getOrDefault<String>(
  key: AppEnvKeys.serverAddress,
  defaultValue: '0.0.0.0',
);
```

Beneficio:

- evita typo de chave em runtime
- facilita refactor de configuracao

## app_roles.dart

Centraliza os nomes de roles usados em autorizacao.

Uso:

```dart
requiredRole: AppRoles.admin,
```

Beneficio:

- evita typo de role
- padroniza regras de permissao

## Relacao com outros modulos

- CustomEnv (lib/utils/custom_env.dart) usa as chaves em runtime.
- SecurityServiceImpl (lib/infra/security/security_service_imp.dart) usa roles e chave JWT.
- main.dart usa ambos para bootstrap seguro e legivel.
