#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

: "${BASE_DOMAIN:=onprem.qa.instana.rocks}"
: "${PROJECT:=instana-qa-enterprise}"
: "${REGION:=europe-west3}"
: "${ZONE:="${REGION}-a"}"
: "${ACME_SERVER_URL:=https://acme-staging-v02.api.letsencrypt.org/directory}"
: "${TOKEN_SECRET:=uQOkH+Y4wU0=}"
: "${INSTANA_REGISTRY:=containers.instana.io}"
: "${BACKEND_BRANCH:=release}"
: "${DEBUG:=false}"
: "${API_VERSION:=v1beta2}"
: "${KEEP_LEGACY:=true}"
: "${USE_WORKLOAD_IDENTITY:=true}"

: "${CERT_MANAGER_VERSION:=v1.7.1}"
: "${EXTERNAL_DNS_VERSION:=1.7.1}"
: "${MAILHOG_VERSION:=5.0.4}"

COLOR_BLUE='\e[0;34m'
COLOR_RED='\e[0;31m'
COLOR_NONE='\e[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

# shellcheck disable=SC2034
KUBECONFIG=$(mktemp)

main() {
    trap 'rm -f $KUBECONFIG' EXIT

    log '🚀 Setting up Instana...'

    local environment="${1?Environment is required}"

    pushd "$SCRIPT_DIR" > /dev/null

    source_env_file "../$environment.env"

    prepare_kube_config

    if [[ -n "${2:-}" ]]; then
        "apply_${2}"
    else
        apply_cert_manager
        apply_external_dns
        apply_mailhog
        apply_agent
        apply_operator
        apply_core_and_units
    fi

    log '🎉 Done.'

    popd > /dev/null
}

apply_cert_manager() {
    local chart=cert-manager

    log_start "$chart"

    local service_account
    service_account=$(get_tf_output 05_k8s-iam dns_access_service_account)

    helm upgrade "$chart" "$chart" --install --wait \
        --repo https://charts.jetstack.io \
        --namespace=infra \
        --history-max=2 \
        --create-namespace \
        --version="$CERT_MANAGER_VERSION" \
        --set-string="serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account=$service_account" \
        --set=installCRDs=true \
        --set-string=global.leaderElection.namespace=infra

    helm upgrade letsencrypt-dns ./charts/issuer --install \
        --namespace=infra \
        --create-namespace \
        --history-max=2 \
        --set-string="spec.acme.server=$ACME_SERVER_URL" \
        --set-string=spec.acme.email=self-hosted@instana.com \
        --set-string=spec.acme.privateKeySecretRef.name=letsencrypt-key \
        --set-string="spec.acme.solvers[0].dns01.cloudDNS.project=$PROJECT"

    log_finished "$chart"
}

apply_external_dns() {
    local chart="external-dns"

    log_start "$chart"

    local service_account
    service_account=$(get_tf_output 05_k8s-iam dns_access_service_account)

    helm upgrade "$chart" "$chart" --install --wait \
        --repo=https://kubernetes-sigs.github.io/external-dns \
        --namespace=infra \
        --create-namespace \
        --history-max=2 \
        --version="$EXTERNAL_DNS_VERSION" \
        --set-string="serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account=$service_account" \
        --set-string=provider=google \
        --set-string="txtOwnerId=external-dns-$environment" \
        --set-string="domainFilters[0]=$BASE_DOMAIN" \
        --set-string="extraArgs[0]=--google-project=$PROJECT"

    log_finished "$chart"
}

apply_mailhog() {
    local chart=mailhog

    log_start "$chart"

    helm upgrade "$chart" "$chart" --install --wait \
        --repo=https://codecentric.github.io/helm-charts \
        --namespace=infra \
        --create-namespace \
        --history-max=2 \
        --version="$MAILHOG_VERSION"

    log_finished "$chart"
}

apply_agent() {
    local chart=instana-agent

    log_start "$chart"

    helm upgrade "$chart" "$chart" --install --wait \
        --repo=https://agents.instana.io/helm \
        --namespace=agent \
        --create-namespace \
        --history-max=2 \
        --set-string=agent.key="$AGENT_KEY_K8S" \
        --set-string=agent.downloadKey="$DOWNLOAD_KEY_K8S" \
        --set-string="agent.endpointHost=ingress.$environment.$BASE_DOMAIN" \
        --set=agent.endpointPort=443 \
        --set-string=cluster.name=onprem \
        --set-string=zone.name=onprem

    log_finished "$chart"
}

apply_operator() {
    log_start operator

    local output_dir="./outputs/$environment"
    local output_dir_bin="./outputs/$environment/bin"
    local output_dir_operator="./outputs/$environment/operator"

    mkdir -p "$output_dir_bin"
    OUTPUT_DIR="$output_dir_bin" OPERATOR_BRANCH="${OPERATOR_BRANCH:-$BACKEND_BRANCH}" OPERATOR_VERSION="$OPERATOR_VERSION" ./scripts/download_kubectl_plugin.sh

    local repository
    if [[ "$INSTANA_REGISTRY" == container.instana.io ]]; then
        repository=instana/release/selfhosted/operator
    else
        repository="instana-qa-enterprise/infrastructure/self-hosted-k8s-operator/${OPERATOR_BRANCH:-$BACKEND_BRANCH}"
    fi

    rm -rf "$output_dir_operator"

    local namespace=operator
    kubectl create namespace "$namespace" --dry-run=client --output=yaml --save-config | kubectl apply --filename=-
    kubectl label namespace "$namespace" "app.kubernetes.io/name=$namespace" --overwrite

    # We don't need Docker creds when pulling from gcr.io
    local pull_secret_item='[]'
    if [[ "$INSTANA_REGISTRY" == "container.instana.io" ]]; then
        kubectl create secret docker-registry instana-registry --namespace="$namespace" --dry-run=client --output=yaml --save-config \
            --docker-username="${DOCKER_USERNAME:-"_"}" \
            --docker-password="${DOCKER_PASSWORD:-"$AGENT_KEY_K8S"}" \
            --docker-server="$INSTANA_REGISTRY" |
            kubectl apply --filename=-

        pull_secret_item='[name: instana-registry]'
    fi

    local tag="$OPERATOR_VERSION"
    if [[ "$DEBUG" == true ]]; then
        tag="$tag-debug"
    fi

    "$output_dir/bin/kubectl-instana" operator template \
        --namespace="$namespace" \
        --output-dir="$output_dir_operator" \
        --values=<(echo "
image:
  registry: $INSTANA_REGISTRY
  repository: $repository
  tag: $tag
imagePullPolicy: Always
imagePullSecrets: $pull_secret_item
")

    kubectl apply --namespace="$namespace" --filename="$output_dir_operator"

    kubectl rollout status deployment instana-operator --namespace="$namespace" --timeout=1m

    log_finished "operator"
}

apply_core_and_units() {
    log_start 'core and units'

    apply_core
    apply_units

    log_finished 'core and units'
}

apply_core() {
    log_start core

    local namespace=core

    kubectl create namespace "$namespace" --dry-run=client --output=yaml --save-config | kubectl apply --filename=-
    kubectl label namespace "$namespace" "app.kubernetes.io/name=$namespace" --overwrite

    helm upgrade instana-tls ./charts/certificate --install \
        --namespace="$namespace" \
        --history-max=2 \
        --set-string="dnsNames[0]=*.$environment.$BASE_DOMAIN" \
        --set-string="dnsNames[1]=$environment.$BASE_DOMAIN" \
        --set-string=issuerRef.kind=ClusterIssuer \
        --set-string=issuerRef.name=letsencrypt-dns \
        --set-string=secretName=instana-tls \
        --set-string=secretTemplate.labels.app\\.kubernetes\\.io/name=instana

    kubectl create secret docker-registry instana-registry --namespace="$namespace" --dry-run=client --output=yaml --save-config \
        --docker-username="${DOCKER_USERNAME:-"_"}" \
        --docker-password="${DOCKER_PASSWORD:-"$AGENT_KEY_K8S"}" \
        --docker-server=containers.instana.io |
        kubectl apply --filename=-

    # comma must be escaped so Helm does not try and interpret this as multiple args
    local domains="$environment.$BASE_DOMAIN\\,unit0-tenant0.$environment.$BASE_DOMAIN\\,unit1-tenant1.$environment.$BASE_DOMAIN"

    local license="./outputs/$environment/license"
    SALES_KEY="$SALES_KEY" ./scripts/fetch_license.sh > "$license"

    local dhparams="./outputs/$environment/dhparams.pem"
    if [[ ! -f "$dhparams" ]]; then
        ./scripts/generate_dhparam.sh > "$dhparams"
    fi

    local sp_pem="./outputs/$environment/sp.pem"
    if [[ ! -f "$sp_pem" ]]; then
        SUBJECT="$environment.$BASE_DOMAIN" PASSWORD="$SERVICE_PROVIDER_KEY_PASSWORD" ./scripts/generate_sp_pem.sh > "$sp_pem"
    fi

    local extra_args=()
    if [[ "$BACKEND_BRANCH" != release ]]; then
        extra_args+=(--set-string="core.imageConfig.repository=instana/$BACKEND_BRANCH/product")
    fi
    if [[ "$USE_WORKLOAD_IDENTITY" == true ]]; then
        local service_account
        service_account=$(get_tf_output 05_k8s-iam raws_spans_service_account)
        extra_args+=(--set-string="core.serviceAccountAnnotations.iam\\.gke\\.io/gcp-service-account=$service_account")
    else
        local service_account_key="./outputs/$environment/serviceAccount.json"
        get_tf_output 05_k8s-iam raws_spans_service_account_key > "$service_account_key"
        extra_args+=(--set-file="secret.rawSpansStorageConfig.gcloudConfig.serviceAccountKey=$service_account_key")
    fi

    local bucket
    bucket=$(get_tf_output 03_storage raw_spans_bucket)

    local config_key
    if [[ "$API_VERSION" == v1beta2 ]]; then
        config_key=gcloudConfig
    else
        config_key=objectStorageConfig
    fi

    extra_args+=(--set-string="core.rawSpansStorageConfig.$config_key.bucket=$bucket")
    extra_args+=(--set-string="core.rawSpansStorageConfig.$config_key.bucketLongTerm=$bucket")
    extra_args+=(--set-string="core.rawSpansStorageConfig.$config_key.prefix=onprem")
    extra_args+=(--set-string="core.rawSpansStorageConfig.$config_key.prefixLongTerm=longterm-onprem")
    extra_args+=(--set-string="core.rawSpansStorageConfig.$config_key.storageClass=STANDARD")
    extra_args+=(--set-string="core.rawSpansStorageConfig.$config_key.storageClassLongTerm=STANDARD")

    if [[ "$KEEP_LEGACY" == true ]]; then
        extra_args+=(--set-string="legacy.rawSpansStorageConfig.objectStorageConfig.accessKeyId=$(get_tf_output 05_k8s-iam raws_spans_access_key_id)")
        extra_args+=(--set-string="legacy.rawSpansStorageConfig.objectStorageConfig.secretAccessKey=$(get_tf_output 05_k8s-iam raws_spans_secret_access_key)")
    fi

    helm upgrade instana-core ./charts/instana-core --install \
        --namespace="$namespace" \
        --history-max=2 \
        \
        --set-string=core.apiVersion="$API_VERSION" \
        --set=legacy.keep="$KEEP_LEGACY" \
        \
        --set-string=core.imagePullSecrets[0].name=instana-registry \
        --set-string="core.baseDomain=$environment.$BASE_DOMAIN" \
        --set-string="core.dataStoreHost=$(get_tf_output 02_datastores datastores_ip)" \
        --set-string=core.emailconfig.smtpConfig.from=no-reply@instana.com \
        --set-string=core.emailconfig.smtpConfig.host=mailhog.infra \
        --set=core.emailconfig.smtpConfig.port=1025 \
        --set-string=core.serviceProviderConfig.basePath=/auth \
        --set=core.serviceProviderConfig.maxAuthenticationLifetimeSeconds=604800 \
        --set=core.serviceProviderConfig.maxIDPMetadataSizeInBytes=200000 \
        --set-string=core.featureFlags[0].name=core.feature.beeinstana.infra.metrics.enabled \
        --set=core.featureFlags[0].enabled=true \
        --set-string=core.featureFlags[1].name=feature.logging.enabled \
        --set=core.featureFlags[1].enabled=true \
        \
        --set-string=services[0].nameSuffix=lb-acceptor \
        --set-string="services[0].annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname=ingress.$environment.$BASE_DOMAIN" \
        --set-string=services[0].type=LoadBalancer \
        --set-string=services[0].ports[0].name=https \
        --set=services[0].ports[0].port=443 \
        --set-string=services[0].ports[0].protocol=TCP \
        --set-string=services[0].ports[0].targetPort=http-service \
        --set-string=services[0].selectorLabels.app\\.kubernetes\\.io/component=acceptor \
        --set-string=services[0].selectorLabels.app\\.kubernetes\\.io/name=instana \
        --set-string=services[0].selectorLabels.instana\\.io/group=service \
        \
        --set-string=services[1].nameSuffix=lb-gateway \
        --set-string="services[1].annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname=$domains" \
        --set-string=services[1].type=LoadBalancer \
        --set-string=services[1].ports[0].name=https \
        --set-string=ports[0].name=https \
        --set=services[1].ports[0].port=443 \
        --set-string=services[1].ports[0].protocol=TCP \
        --set-string=services[1].ports[0].targetPort=https \
        --set-string=services[1].ports[1].name=http \
        --set=services[1].ports[1].port=80 \
        --set-string=services[1].ports[1].protocol=TCP \
        --set-string=services[1].ports[1].targetPort=http \
        --set-string=services[1].selectorLabels.app\\.kubernetes\\.io/component=gateway \
        --set-string=services[1].selectorLabels.app\\.kubernetes\\.io/name=instana \
        --set-string=services[1].selectorLabels.instana\\.io/group=service \
        \
        --set-string="secret.adminPassword=admin$environment" \
        --set-file="secret.dhParams=$dhparams" \
        --set-string="secret.downloadKey=$DOWNLOAD_KEY_K8S" \
        --set-string="secret.salesKey=$SALES_KEY" \
        --set-string="secret.tokenSecret=$TOKEN_SECRET" \
        --set-file="secret.license=$license" \
        --set-string="secret.serviceProviderConfig.keyPassword=$SERVICE_PROVIDER_KEY_PASSWORD" \
        --set-file="secret.serviceProviderConfig.pem=$sp_pem" \
        \
        "${extra_args[@]}"

    log_finished core
}

apply_units() {
    log_start units

    local namespace=units

    kubectl create namespace "$namespace" --dry-run=client --output=yaml --save-config | kubectl apply --filename=-
    kubectl label namespace "$namespace" "app.kubernetes.io/name=$namespace" --overwrite

    kubectl create secret docker-registry instana-registry --namespace="$namespace" --dry-run=client --output=yaml --save-config \
        --docker-username="${DOCKER_USERNAME:-"_"}" \
        --docker-password="${DOCKER_PASSWORD:-"$DOWNLOAD_KEY_K8S"}" \
        --docker-server=containers.instana.io |
        kubectl apply --filename=-

    local license="./outputs/$environment/license"
        SALES_KEY="$SALES_KEY" ./scripts/fetch_license.sh > "$license"

    helm upgrade instana-unit0 ./charts/instana-unit --install \
        --namespace="$namespace" \
        --history-max=2 \
        \
        --set-string=unit.apiVersion="$API_VERSION" \
        \
        --set-string=unit.coreName=instana-core \
        --set-string=unit.coreNamespace=core \
        --set-string=unit.tenantName=tenant0 \
        --set-string=unit.unitName=unit0 \
        \
        --set-file="secret.license=$license" \
        --set-string="secret.agentKeys[0]=$AGENT_KEY_K8S"

    helm upgrade instana-unit1 ./charts/instana-unit --install \
        --namespace="$namespace" \
        --history-max=2 \
        \
        --set-string=unit.apiVersion="$API_VERSION" \
        \
        --set-string=unit.coreName=instana-core \
        --set-string=unit.coreNamespace=core \
        --set-string=unit.tenantName=tenant1 \
        --set-string=unit.unitName=unit1 \
         \
        --set-file="secret.license=$license" \
        --set-string="secret.agentKeys[0]=$AGENT_KEY_K8S"

    log_finished units
}

source_env_file() {
    local env_file="$1"
    log "🛠 Sourcing env file [$env_file]..."

    if [[ ! -f "$env_file" ]]; then
        log_error "Env file does not exist: $env_file"
        exit 1
    fi

    # shellcheck disable=SC1090
    source "$env_file"

    log "✅  Successfully sourced env file [$env_file]."
}

prepare_kube_config() {
    log_start 'kube config'
    gcloud container clusters get-credentials --zone "$ZONE" --project "$PROJECT" "gke-$environment"
    log_finished 'kube config'
}

get_tf_output() {
    local module="${1?Module is required}"
    local output="${2?Output name is required}"
    gotf --config ../02_terraform/gotf.yaml --module-dir="../02_terraform/$module" --params="environment=$environment" --no-vars output -raw "$output"
}

log() {
    echo -e "$COLOR_BLUE$1$COLOR_NONE"
}

log_start() {
    echo -e "🛠 ${COLOR_BLUE}Applying $1...$COLOR_NONE"
}

log_finished() {
    echo -e "✅  ${COLOR_BLUE}Finished applying $1.$COLOR_NONE"
}

log_error() {
    echo -e "❎  ${COLOR_RED}$1${COLOR_NONE}"
}

main "$@"
