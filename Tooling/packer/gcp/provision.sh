#!/usr/bin/env bash

set -e
ROLE=$1
REGION=$2
STATE=$3
INSTANA_REGION=$4

region=${REGION}
state=${STATE}

echo " # Setting up APT"
echo "deb [arch=amd64] https://s3-${region}.amazonaws.com/packages-${state}.instana.io/fleet xenial main" \
    > /etc/apt/sources.list.d/instana-fleet.list
echo "deb [arch=amd64] https://s3-${region}.amazonaws.com/packages-${state}.instana.io/agent/deb generic main" \
    > /etc/apt/sources.list.d/instana-agent.list

export DEBIAN_FRONTEND='noninteractive'
wget -qO - "https://packages.instana.io/Instana.gpg" | apt-key add -
apt-get update
apt-get dist-upgrade -y
apt-get install -y chef-cascade fleet-cookbooks

echo " # Setting up Chef"
cat << EOF > /etc/chef/cascade.rb
secrets_path '/mnt/nfs/data/secrets/chef.yml'
ssl_verify_mode :verify_peer
verify_api_cert true
cookbook_path [
                '/opt/fleet-cookbooks/cookbooks'
              ]
role_path [
            '/opt/fleet-cookbooks/roles'
          ]
data_bag_path '/opt/chef-data/data_bags'

# Chef and cascade should be last
packages [
            'fleet-cookbooks',
            'chef-cascade'
         ]
EOF

cat << YAML > /etc/chef/roles.yml
---
- $ROLE
YAML

cat << YAML > /etc/chef/attrs.yml
---

instana_base:
  region: ${INSTANA_REGION}
  cloud: gcp
YAML


echo " # Running Chef"
chef-cascade
