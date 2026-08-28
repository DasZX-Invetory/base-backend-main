## Middleware de Status de Usuario

Este tutorial explica como o status do usuario e validado no template.

### 1. Middleware responsavel

Arquivo: lib/infra/security/security_service_imp.dart

Middleware: verifyStatus

### 2. Regras atuais

- active = 1 -> acesso permitido
- active = 2 -> bloqueia com USER_INACTIVE
- outro valor -> bloqueia com UNKNOWN_STATUS

### 3. De onde vem o status

O campo active e colocado no payload do access token no login:

- true no banco -> active 1
- false no banco -> active 2

### 4. Como isso afeta as rotas

Toda rota com isSecurity: true passa por verifyStatus.

Logo, mesmo token valido nao acessa rota se conta estiver inativa.

### 5. Como customizar

Voce pode trocar a logica para:

- usar string (active, blocked, pending)
- usar int com mais estados
- validar status ao vivo no banco para cada requisicao

### 6. Exemplo de customizacao simples

```dart
int? active = jwt.payload['active'] as int?;

if (active == 1) {
  return null;
}

if (active == 2) {
  return Response.forbidden('Usuario inativo');
}

if (active == 3) {
  return Response.forbidden('Usuario pendente de aprovacao');
}

return Response.forbidden('Status desconhecido');
```

### 7. Boas praticas

- Use codigos de erro estaveis para o frontend.
- Nao retorne detalhes sensiveis do motivo do bloqueio.
- Registre auditoria de bloqueio de acesso.
- Mantenha a regra centralizada em middleware.
