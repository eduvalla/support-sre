# Create base image in AWS

## Make sure your AWS credentail has been configured

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

## Install packer

`brew install packer`

## Run packer

`packer build -var-file=vars/blue.pkrvars.hcl -var=purpose=fleet .`
`packer build -var-file=vars/red.pkrvars.hcl -var=purpose=fleet .`
