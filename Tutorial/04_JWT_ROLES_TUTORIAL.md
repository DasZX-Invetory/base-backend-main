## JWT e Roles no Template

Este documento explica como funciona a seguranca no projeto.

### 1. Onde tudo comeca

- Geracao/validacao de token: lib/infra/security/security_service_imp.dart
- Encadeamento de middlewares: lib/api/api.dart
- Uso nas rotas: cada API chama createHandler

### 2. Payload do access token

Campos usados hoje:

- iat
- exp
- userID
- role
- active

Tempo de expiracao do access token: 5 minutos.

Refresh token: 7 dias.

### 3. Ordem dos middlewares de seguranca

Quando isSecurity = true, o template adiciona:

1. authorization
2. verifyJwt
3. verifyStatus
4. requireRole(requiredRole) (se informado)

### 4. Como deixar rota publica

Na API:

```dart
return createHandler(router: router.call);
```

Ou explicitamente:

```dart
return createHandler(
  router: router.call,
  isSecurity: false,
);
```

### 5. Como proteger por token

```dart
return createHandler(
  router: router.call,
  isSecurity: true,
);
```

### 6. Como proteger por role

```dart
return createHandler(
  router: router.call,
  isSecurity: true,
  requiredRole: 'admin',
);
```

### 7. Hierarquia de role no projeto

Quanto menor o nivel, maior privilegio:

- owner -> nivel 1
- admin -> nivel 2
- technician -> nivel 3
- user -> nivel 4

Uma rota com requiredRole admin aceita owner e admin.

### 8. Erros comuns

- Token ausente: INVALID_TOKEN / MISSING_TOKEN
- Token expirado: INVALID_TOKEN
- Usuario inativo: USER_INACTIVE
- Permissao insuficiente: INSUFFICIENT_PERMISSION

### 9. Endpoint de login

Fluxo atual:

1. Recebe email/senha
2. Busca usuario
3. Verifica senha com DBCrypt
4. Verifica status
5. Gera access + refresh
6. Retorna user + tokens

### 10. Boas praticas para novos projetos

- Nunca colocar JWT_KEY hardcoded.
- Nunca confiar role enviada pelo frontend.
- Sempre validar usuario no banco para operacoes sensiveis.
- Reduzir tempo do access token em producao se necessario.
- Registrar logs de autenticacao (sem vazar token/senha).
