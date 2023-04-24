#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

: "${SALES_KEY?Environment variable must be set}"

curl "https://instana.io/onprem/license/download/v2/allValid?salesId=$SALES_KEY" | jq -r '.[]'
