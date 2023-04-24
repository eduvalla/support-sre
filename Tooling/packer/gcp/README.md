# Create base image in GCP

## Create auth and export as an env var

Create the file `account.json` in the folder `packer/gcp` (it's a gcp service account file)
export GOOGLE_APPLICATION_CREDENTIALS=account.json

## Install packer

`brew install packer`

## Run packer

`packer build -var-file=vars/green.pkrvars.hcl .`
`packer build -var-file=vars/orange.pkrvars.hcl .`

Wait until you see:

```sh
[...]
    googlecompute: [2019-11-20T21:29:56+00:00] INFO: Report handlers complete
==> googlecompute: Deleting instance...
    googlecompute: Instance has been deleted!
==> googlecompute: Creating image...
==> googlecompute: Deleting disk...
    googlecompute: Disk has been deleted!
Build 'googlecompute' finished.

==> Builds finished. The artifacts of successful builds are:
--> googlecompute: A disk image was created: base-bionic-1574285157
```

Enjoy!
