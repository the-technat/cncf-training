# ICA (Istio Certificated Associate)

## Lab Env

```console
kind create cluster --name=istio
```

## Istio Installation

Source: https://istio.io/latest/docs/setup/install/helm/ && https://istio.io/latest/docs/setup/additional-setup/gateway/

```console
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm upgrade -i istio-base -n istio-system istio/base --set defaultRevision=1-27 --create-namespace
helm upgrade -i istiod -n istio-system istio/istiod --set revision=1-27 
# current helm versions (1.18.2+) seem to have a schema issue that prevents chart installation at all, simply skipping validation does the job for now
helm upgrade -i istio-ingressgateway istio/gateway -n istio-ingress --set revision=1-27 --create-namespace --skip-schema-validation
```

## Prometheus Installation

Source: https://istio.io/latest/docs/ops/integrations/prometheus/

While the "addon" config is the easiest way, we want customizability of Prometheus. Thus the official helm chart is used:

```console
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm upgrade -i prometheus -n monitoring --create-namespace prometheus-community/prometheus --set prometheus-pushgateway.enabled=false --set alertmanager.enabled=false
```

It works out of the box with Istio since Istio by default sets the defacto scrape annotations and the helm chart by default configures service discovery for these.

## Kiali

Source: https://istio.io/latest/docs/ops/integrations/kiali/

The UI for the mesh:

```console
helm repo add kiali https://kiali.org/helm-charts
helm upgrade -i kiali -n kiali --create-namespace kiali/kiali-server \
  --set external_services.istio.root_namespace=istio-system \
  --set external_services.prometheus.url="http://prometheus-server.monitoring.svc.cluster.local:80" \
  --set auth.strategy="anonymous"
```

## Exposing some services

Use the following YAML to expose Kiali and Prometheus UI over the default istio gateway:

```console
kubectl apply -f infra-uis.yaml
```

## Demo Workload

### Podinfo Canary

```console
kubectl create namespace podinfo
kubectl label namespace podinfo istio.io/rev=1-27
helm upgrade -i podinfo-6-8 -n podinfo oci://ghcr.io/stefanprodan/charts/podinfo --set replicaCount=3 --set ui.color="#3D0814" --set ui.message="Battleproofed Version" --version 6.8.0
helm upgrade -i podinfo-6-9 -n podinfo oci://ghcr.io/stefanprodan/charts/podinfo --set replicaCount=3 --set ui.color="#9A9B73" --set ui.message="New Version" --version 6.9.1
kubectl apply -f podinfo-istio.yaml
```
The app should now be accessible on `podinfo.kindccm-8fb065a4766b.orb.local` (replace the container name of the load balancer).

### Bookinfo

Source: https://istio.io/latest/docs/examples/bookinfo/

```console
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.27/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.27/samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.27/samples/bookinfo/networking/destination-rule-all.yaml
```
