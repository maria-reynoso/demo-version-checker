.DEFAULT_GOAL := help

CLUSTER_NAME := demo-version-checker
PROJECT_ID := "$(shell gcloud config get-value project)"
M_TYPE := n1-standard-2
ZONE := europe-west2-a

cluster: ## Setup cluster
	gcloud services enable container.googleapis.com
	gcloud container clusters describe ${CLUSTER_NAME} || gcloud container clusters create ${CLUSTER_NAME} \
		--cluster-version latest \
		--machine-type=${M_TYPE} \
		--num-nodes 4 \
		--zone ${ZONE} \
		--project ${PROJECT_ID}
	gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE} --project ${PROJECT_ID}

install-addons: ## Install addons
	helm repo add jetstack https://charts.jetstack.io --force-update
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update
	helm install \
	cert-manager jetstack/cert-manager \
		--namespace cert-manager \
		--create-namespace \
		--version v1.15.5 \
		--set crds.enabled=true
	helm install -n monitoring --create-namespace prometheus prometheus-community/kube-prometheus-stack \
		--set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false,prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
	helm install grafana grafana/grafana --namespace monitoring

version-checker: ## Install version-checker
	helm repo add jetstack https://charts.jetstack.io
	helm repo update
	helm install version-checker jetstack/version-checker --namespace monitoring

cleanup: ## Cleaup
	gcloud container clusters delete ${CLUSTER_NAME}

help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m \t%s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
