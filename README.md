# Streaming Service - Kubernetes Live Config

GitOps repository for the Streaming Service application.

## Structure

```
├── base/           # Shared Helm values across all environments
│   └── values.yaml
└── envs/
    ├── dev/        # Development environment
    ├── tst/        # Test environment
    ├── acc/        # Acceptance environment
    └── prd/        # Production environment
```

## ArgoCD Configuration

Each environment is deployed via ArgoCD Application that references:

- Helm chart from the application source repo (or a shared chart repo)
- Values from `base/values.yaml` + `envs/<env>/values.yaml`

## Promotion Flow

```
dev → tst → acc → prd
```

1. CI pushes new image with SHA tag
2. Update `envs/dev/values.yaml` with new image tag
3. After validation, copy tag to `envs/tst/values.yaml`
4. Continue promotion through acc → prd

## Image Tags

| Environment | Tag Strategy                |
| ----------- | --------------------------- |
| dev         | `latest` or SHA             |
| tst         | SHA (validated in dev)      |
| acc         | SHA (validated in tst)      |
| prd         | Semver tag (e.g., `v1.0.0`) |
# xebia-demo-ingress-nginx-kube-live
# xebia-demo-ingress-nginx-kube-live
# xebia-demo-ingress-nginx-kube-live
