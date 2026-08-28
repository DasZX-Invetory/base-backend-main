## Tutorial Kubernetes (k3s) - Backend Template

Este guia e generico e funcional para primeiro deploy em k3s.

### 1. Estrutura dos manifests

Use os arquivos da pasta deploy/k8s/base.

Ordem de aplicacao recomendada:

1. namespace.yaml
2. configmap.yaml
3. secret.yaml
4. postgres.yaml
5. api.yaml

### 2. Aplicar manifests

```bash
kubectl apply -f deploy/k8s/base/
```

### 3. Verificar recursos

```bash
kubectl get all -n backend-template
kubectl get pvc -n backend-template
kubectl logs -f deploy/template-api -n backend-template
```

### 4. Exposicao da API

Padrao deste template:

- Service tipo ClusterIP
- Ingress NGINX para entrada HTTP

Se nao tiver ingress controller, troque para NodePort temporariamente.

### 5. Segredos e configuracoes

- ConfigMap: vars nao sensiveis
- Secret: JWT_KEY e DB_PASSWORD

Nunca commitar segredo real em texto puro.

### 6. Banco no cluster x banco externo

Para primeiro projeto: postgres no cluster funciona.

Para producao seria melhor:

- banco gerenciado
- backup e restore automatizados
- monitoramento

### 7. Rollout

Atualizar imagem:

```bash
kubectl set image deploy/template-api api=seu-registry/sua-api:1.0.1 -n backend-template
kubectl rollout status deploy/template-api -n backend-template
```

### 8. Troubleshooting rapido

- Pod CrashLoopBackOff: conferir envs e conectividade com DB.
- Erro de auth DB: conferir DB_USER/DB_PASSWORD/DB_SCHEMA.
- Ingress nao responde: conferir classe do ingress e DNS.
- API sem resposta JSON: conferir pipeline no main.dart.

### 9. Checklist pre-producao

- livenessProbe e readinessProbe ajustados
- limites de CPU/RAM definidos
- segredo externo configurado
- politica de backup do banco definida
- observabilidade (logs/metrics) habilitada
