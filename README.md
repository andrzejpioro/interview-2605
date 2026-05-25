# AKS Interview Project - README

This document provides step-by-step instructions for deploying a simple Python application to Azure Kubernetes Service (AKS).

## Prerequisites

- Azure CLI installed
- Docker installed
- kubectl installed
- kubelogin installed
- Service Principal credentials

## Setup Instructions

### 1. Azure Authentication

Set your service principal password:

```bash
SP_PASSWORD=<TO_BE_PROVIDED>
```

Login to Azure Cloud using service principal:

```bash
az login --service-principal \
  -u cc964e60-6446-42d2-93af-d2d94b228b02 \
  -p $SP_PASSWORD \
  --tenant f25493ae-1c98-41d7-8a33-0be75f5fe603
```

### 2. Set Azure Subscription

```bash
az account set --subscription efe36eab-e65c-4800-81b5-d77bd9aeb6bd
```

### 3. Configure AKS Access

Get credentials for AKS cluster:

```bash
az aks get-credentials \
  --name aks-interview-cluster \
  --resource-group rg-aks-interview
```

Convert kubeconfig to use Azure CLI authentication:

```bash
kubelogin convert-kubeconfig -l azurecli
```

### 4. Login to Azure Container Registry

```bash
az acr login \
  --name aksinterviewacr \
  --username cc964e60-6446-42d2-93af-d2d94b228b02 \
  --password $SP_PASSWORD
```

## Application Files

### app.py

```python
from datetime import datetime
print(f'Hello world - {datetime.now()}')
```

### requirements.txt

```
requests==2.33.1
```

### Dockerfile

```dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY app.py .
COPY requirements.txt .

RUN pip install -r requirements.txt --upgrade

RUN useradd -m myuser
USER myuser

CMD ["python", "app.py"]
```

## Build and Deploy

### 1. Build Container Image

```bash
docker build -t aksinterviewacr.azurecr.io/hello-world:latest .
```

### 2. Push Container Image to ACR

```bash
docker push aksinterviewacr.azurecr.io/hello-world:latest
```

### 3. Run Pod in AKS

```bash
kubectl run hello-world \
  --image aksinterviewacr.azurecr.io/hello-world:latest \
  --restart=Never \
  --attach
```

## Verification

Check pod status:

```bash
kubectl get pods
```

View pod logs:

```bash
kubectl logs hello-world
```

Describe pod for details:

```bash
kubectl describe pod hello-world
```

## Cleanup

Delete the pod:

```bash
kubectl delete pod hello-world
```

## Troubleshooting

- If authentication fails, verify service principal credentials
- If image pull fails, ensure ACR login was successful
- If pod fails to start, check logs with `kubectl logs <pod-name>`
- For detailed pod information, use `kubectl describe pod <pod-name>`

## Resource Information

- **Tenant ID**: `f25493ae-1c98-41d7-8a33-0be75f5fe603`
- **Subscription ID**: `efe36eab-e65c-4800-81b5-d77bd9aeb6bd`
- **Resource Group**: `rg-aks-interview`
- **AKS Cluster**: `aks-interview-cluster`
- **ACR Name**: `aksinterviewacr`
- **Service Principal ID**: `cc964e60-6446-42d2-93af-d2d94b228b02`

## Notes

- The application runs as a non-root user (`myuser`) for security best practices
- The pod uses `restart=Never` policy, meaning it runs once and terminates
- Docker image is tagged with `latest` for simplicity
- For production deployments, consider using specific version tags instead of `latest`

