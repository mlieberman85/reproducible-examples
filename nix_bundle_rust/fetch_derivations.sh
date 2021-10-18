set -e
set -u

REPO=ghcr.io/mlieberman85/reproducible-examples
OUTPUT_NAME=rust-web-server
DIGEST=$(crane digest $REPO:$OUTPUT_NAME)
# Make the derivations content addressable to the hash of the binary
DRV_NAME=$(echo $DIGEST | sed s/:/-/).recursive_drvs

sget -key cosign.pub $REPO:$DRV_NAME
