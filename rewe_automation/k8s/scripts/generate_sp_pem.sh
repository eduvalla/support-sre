#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

: "${SUBJECT?Environment variable must be specified}"
: "${PASSWORD?Environment variable must be specified}"

key=$(openssl genrsa -aes128 -passout "pass:$PASSWORD" 2048)
cert=$(openssl req -new -x509 -passin "pass:$PASSWORD" -passout "pass:$PASSWORD" -key <(echo "$key") -days 365 -subj "/CN=$SUBJECT")

echo "$key"
echo "$cert"
