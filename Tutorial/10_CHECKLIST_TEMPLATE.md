## Checklist de uso do Template

### 1. Preparacao inicial

- [ ] Atualizei nome e descricao no pubspec.yaml
- [ ] Criei/atualizei .env com valores reais
- [ ] Defini JWT_KEY forte
- [ ] Ajustei script SQL base

### 2. Novo modulo

- [ ] Model criado
- [ ] DAO criado
- [ ] Service criado
- [ ] API criada
- [ ] Rotas validadas
- [ ] Registro no DI feito
- [ ] Handler adicionado no main.dart

### 3. Banco

- [ ] SQL versionado
- [ ] Indices adicionados
- [ ] Regras de integridade aplicadas
- [ ] Campos sensiveis revisados

### 4. Seguranca

- [ ] Rotas publicas e privadas revisadas
- [ ] Roles revisadas por endpoint
- [ ] Mensagens de erro padronizadas
- [ ] Nao existem segredos hardcoded

### 5. Docker

- [ ] Build local funcionando
- [ ] Compose sobe sem falhas
- [ ] Logs da API e DB sem erro

### 6. Kubernetes/k3s

- [ ] Namespace criado
- [ ] Secret e ConfigMap aplicados
- [ ] Deploy e Service ativos
- [ ] Ingress respondendo
- [ ] Rollout validado

### 7. Liberacao

- [ ] Rotas criticas testadas manualmente
- [ ] Ambiente de staging validado
- [ ] Backup/restaure do DB planejado
- [ ] Observabilidade minima (logs/metricas) pronta
