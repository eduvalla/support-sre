#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

: "${OPERATOR_BRANCH?Environment variable must be set}"
: "${OPERATOR_VERSION?Environment variable must be set}"
: "${OUTPUT_DIR?Environment variable must be set}"

mkdir -p "$OUTPUT_DIR"
curl "https://instana-onprem-installer-internal.s3.amazonaws.com/kubectl/$OPERATOR_BRANCH/kubectl-instana-darwin_amd64-release-$OPERATOR_VERSION.tar.gz" | tar -xz -C "$OUTPUT_DIR"
