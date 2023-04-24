#!/usr/bin/env bash

ROLE=$1
REGION=$2

set -e

azone=$(ec2metadata|grep availability-zone|cut -d' ' -f2)
region="${azone::-1}"
state=$(echo $azone | cut -d'-' -f1)
kernel=$(uname -r)

# APT
echo " ## Setting up APT"
sed -i -e "s,${region}.ec2.,${state}.archive.,g" /etc/apt/sources.list
echo "deb [arch=amd64] https://s3-${region}.amazonaws.com/packages-${state}.instana.io/fleet xenial main" \
    > /etc/apt/sources.list.d/instana-fleet.list
echo "deb [arch=amd64] https://s3-${region}.amazonaws.com/packages-${state}.instana.io/agent/deb generic main" \
    > /etc/apt/sources.list.d/instana-agent.list

wget -qO - https://s3-${region}.amazonaws.com/packages-${state}.instana.io/Instana.gpg | apt-key add - # Instana
apt-get update
export DEBIAN_FRONTEND='noninteractive'
apt-get dist-upgrade -y
apt-get install -y chef-cascade fleet-cookbooks linux-aws

# Setup Chef
echo " ## Setting up Chef"
cat << EOF > /etc/chef/cascade.rb
secrets_path '/mnt/efs/data/secrets/chef.yml'
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
  region: ${REGION}
  cloud: aws
YAML

# Move secrets
mv /tmp/secrets.yml /etc/chef
chmod 600 /etc/chef/secrets.yml

# Required for ec2 ohai vars
if [[ $(dmidecode | grep -i amazon) ]] ; then
 mkdir -p /etc/chef/ohai/hints && touch ${_}/ec2.json 
fi

# Bypass removing ubuntu user resource in instana-base-common::user 
export BUILDING_AMI='true'
# Run Chef
chef-cascade
