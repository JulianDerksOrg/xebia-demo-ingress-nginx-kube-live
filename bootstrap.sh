#!/bin/bash
set -euo pipefail

# Bootstrap ingress-nginx installation
# After initial install, ArgoCD will manage it via the ingress-nginx Application

PROJECT="sandbox-9456"
CLUSTER="gke-cluster-sandbox"
ZONE="europe-west4-a"
REGION="europe-west4"

NAMESPACE="ingress-nginx"
CHART_VERSION="4.12.2"  # https://github.com/kubernetes/ingress-nginx/releases
GAR_REGISTRY="${REGION}-docker.pkg.dev/${PROJECT}/helm"

echo "==> Authenticating to GKE cluster: ${CLUSTER}"
gcloud container clusters get-credentials "${CLUSTER}" \
  --zone "${ZONE}" \
  --project "${PROJECT}"

echo "==> Authenticating Helm to GAR..."
gcloud auth print-access-token | helm registry login -u oauth2accesstoken --password-stdin "https://${REGION}-docker.pkg.dev"

echo "==> Adding ingress-nginx Helm repo..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "==> Pulling ingress-nginx chart v${CHART_VERSION}..."
helm pull ingress-nginx/ingress-nginx --version "${CHART_VERSION}"

echo "==> Pushing ingress-nginx chart to GAR..."
helm push "ingress-nginx-${CHART_VERSION}.tgz" "oci://${GAR_REGISTRY}"

echo "==> Cleaning up downloaded chart..."
rm -f "ingress-nginx-${CHART_VERSION}.tgz"

echo "==> Installing ingress-nginx from GAR..."
helm upgrade --install ingress-nginx "oci://${GAR_REGISTRY}/ingress-nginx" \
  --namespace "${NAMESPACE}" \
  --version "${CHART_VERSION}" \
  --values envs/dev/values.yaml \
  --create-namespace \
  --wait

echo "==> ingress-nginx installed successfully!"

# Get external IP
echo ""
echo "==> External IP:"
kubectl -n "${NAMESPACE}" get svc ingress-nginx-controller -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
echo ""

# Apply ArgoCD Application
echo "==> Applying ingress-nginx ArgoCD Application..."
kubectl apply -f argocd-app.yaml

echo ""
echo "==> Bootstrap complete!"
echo "    ArgoCD will now manage ingress-nginx from git."
