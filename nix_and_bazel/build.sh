#!/bin/bash
set -e

# nix-channel --add https://nixos.org/channels/nixpkgs-21.05
nix-build default.nix
docker load < result
docker images --digests

example_dir=$(mktemp -d -t example-XXXXXX)
pushd $example_dir
git clone https://github.com/bazelbuild/examples
popd

cache_dir=$(mktemp -d -t cache-XXXXXX)

docker run \
    --rm \
    -v $example_dir/examples/cpp-tutorial/stage1/:/src:z \
    -v $cache_dir:/home/nobody/.cache \
    hello-world-build:pq8nqxz59k64kwh06gyr50c1synr36k2

sha256sum $cache_dir/bazel/_bazel_nobody/f8087e59fd95af1ae29e8fcb7ff1a3dc/execroot/__main__/bazel-out/k8-fastbuild/bin/main/hello-world

echo "You will need to remove $example_dir and $cache_dir manually"