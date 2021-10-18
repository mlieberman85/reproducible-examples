set -e
set -u

# NOTE: Naming scheme needs to be thought out more.

REPO=ghcr.io/mlieberman85/reproducible-examples
OUTPUT_NAME=rust-web-server

# Generates nix bundle
nix bundle

# Upload rust-web-server 
cosign upload blob -f $(readlink -f $OUTPUT_NAME) $REPO:$OUTPUT_NAME
cosign sign -key cosign.key $REPO:$OUTPUT_NAME

DIGEST=$(crane digest $REPO:$OUTPUT_NAME)
# Make the derivations content addressable to the hash of the binary
DRV_NAME=$(echo $DIGEST | sed s/:/-/).recursive_drvs

# Upload and sign the derivation
cosign upload blob -f <(nix show-derivation $(readlink -f $OUTPUT_NAME) -r) $REPO:$DRV_NAME
cosign sign -key cosign.key $REPO:$DRV_NAME
