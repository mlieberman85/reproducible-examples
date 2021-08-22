# reproducible-examples
Examples of reproducible builds

## Nix + Bazel + Docker

Inspired by:

* https://www.tweag.io/blog/2018-03-15-bazel-nix/
* https://github.com/kpcyrd/i-probably-didnt-backdoor-this

### Requirements

* Nix package manager installed (or on NixOS) and availble in $PATH. See: 
* Docker, Podman or other docker compatible container manager
    * Your user should also be added to any particular groups in order to run docker without sudo.
    * Note: Podman seems to accurately generate the digest. With Docker it looks like you need to rely compairing the image id.
* (temporarily) Running on Linux. I don't have logic to run this right now on Darwin (i.e. MacOS) Nix.
* (temporarily) Git. This is required temporarily since I'm pulling the examples from bazel examples repo. Eventually I want to write my own.
    * https://github.com/bazelbuild/examples
    * Using stage 1 cpp-tutorial

A key piece of this allows you to only require Nix to be installed on the machine generating the container images. You can distribute the resultant image out.

### How it works

1. Nix will reproducibly build a docker image container Bazel and a compiler with no other binaries.
2. Running the container build will share source code with the container and reproducibly build binary.

See https://www.tweag.io/blog/2018-03-15-bazel-nix/ for more info on how Nix reproducibly generates a build environment but the basic idea is that a given version/hash of Nixpkgs should generate the same build enviornment each time. Same versions, compiled with the same flags, etc. This means you can rely that the build toolchain hasn't been modified between container builds.

Bazel is the next piece. It can reproducibly build C++, Java and some other langauges given some assumptions like you're not execing random other code as part of your build. Bazel generates a DAG of the dependencies and knows exactly what needs to be built and rebuilt during code changes.

The reason why Nix is required in addition to Bazel is that Bazel still relies on compilers and in some cases other dependencies to exist in the build environment. Something like a minor compiler revision will break the reproducibility of the build. You could just use the Nix environment itself like in the above tweag article but this method allows you to generate and distribute the hermetic environment that the Bazel builds operate in, without requiring Nix, while still allowing others to generate the build container from scratch as well.

### How to run

```bash
cd nix_and_bazel/
./build.sh
```

After running you should compare the hashes by taking the checksums (e.g. sha256sum) of the resultant artifact. You can the image itself as well by checking the digest/image id.

### How to cleanup

```bash
cd nix_and_bazel/
./cleanup.sh
```

This will delete docker images,

### How to reproduce

1. Run "How To Run"
2. Run "Cleanup"
3. Check hashes of artifacts under releases as well as image info in the packages or repeat steps 1 and 2 and check hashes

*Note*: If the artifact hashes don't line up please open up an issue with what distro Linux + Kernel version of the host is.

For reference the released artifacts were built using RHEL 8 and Kernel version is: 4.18.0-305.3.1.el8_4.x86_64

### Caveats

* I'm not sure if the docker image will be reproducible in all cases, e.g. if you're on a different kernel version.
* Reproducibility expects you to not change Nixpkgs versions between runs as that would pull in updates to the build toolchains.
* NOTE: Since I'm not 100% sure that all hashes will align depending