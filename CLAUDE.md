# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Single Helm chart repository published as `prosperi-charts` at `https://zimran-tech.github.io/helm-charts`. Contains one chart (`charts/app/`) used to deploy applications on AWS EKS with ArgoCD.

## Common Commands

```bash
# Lint the chart
helm lint charts/app/

# Render templates locally (debug)
helm template my-release charts/app/ -f charts/app/values.yaml

# Render with value overrides
helm template my-release charts/app/ --set image.tag=2.0.0 --set environment=production

# Install from local chart
helm install my-release charts/app/ -f custom-values.yaml

# Dry-run install (validate against cluster)
helm install my-release charts/app/ --dry-run
```

There is no Makefile, test suite, or local build script. Releases are automated via GitHub Actions (Helm Chart Releaser) on push to `main`.

## Architecture

### Chart: `app` (charts/app/)

A single self-contained application chart (no dependencies, no `_helpers.tpl`) that generates up to 6 Kubernetes resource types:

- **Deployment** (`app-deployment.yaml`) — Iterates over `.Values.apps[]` array; each entry produces a separate Deployment. Mounts AWS Secrets Manager secrets via CSI driver.
- **HPA** (`hpa.yaml`) — Crated per app wheen `autoscaling.enabled: true`. Supports CPU/memory metrics and custom scale-up/scale-down behavior policies.
- **Ingress** (`ingress.yaml`) — Created when `ingress.enabled: true`. Configured for AWS ALB. Supports single `domain` (legacy) or `domains[]` array.
- **Service** (`service.yaml`) — Created when `network.serviceEnabled: true`.
- **Job** (`job.yaml`) — Iterates over `.Values.jobs[]`. Jobs named "migration" get ArgoCD sync-wave `-1`; others get `0`.
- **SecretProviderClass** (`secret-provider-class.yaml`) — AWS Secrets Manager integration via CSI. Supports per-app secrets and optional shared secrets (`sharedSecrets.enabled`).

### Key Design Patterns

- **Multi-app via range loops**: `apps[]` and `jobs[]` arrays each produce multiple resources from a single template using `{{- range }}`.
- **All template logic is inline** — no named templates or helper files. Conditionals and defaults are used directly in manifests.
- **ArgoCD-aware**: Sync-wave annotations control deployment ordering (jobs before deployments).
- **AWS-native**: Assumes EKS with IRSA (IAM Roles for Service Accounts), ALB Ingress Controller, and Secrets Store CSI Driver.

### Secret Management

Secrets flow from AWS Secrets Manager → CSI SecretProviderClass → Kubernetes Secret → env vars in pods. The naming convention for AWS secrets is `APP/ENVIRONMENT/SECRET_NAME`. Shared secrets (`APP/ENVIRONMENT/shared`) are optional and controlled by `sharedSecrets.enabled`.

## Branching & Release

- **`develop`** — main development branch (default for PRs)
- **`main`** — release branch; pushing here triggers Chart Releaser GitHub Action which publishes the chart to GitHub Pages
- Chart version is tracked in `charts/app/Chart.yaml` field `version`; bump this when making changes
