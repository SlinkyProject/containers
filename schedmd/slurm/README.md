# Slurm Container Images

This directory contains methods to build [Slurm] from [SchedMD].

## Build

```bash
cd $VERSION
export DOCKER_BAKE_REGISTRY=<REGISTRY_PREFIX>
docker buildx bake --print
docker buildx bake
docker buildx bake --push
```

## Multi-Architecture

Images support both `linux/amd64` and `linux/arm64` platforms:

```bash
# Multi-arch build
docker buildx bake --set "*.platform=linux/amd64,linux/arm64" ubuntu2404-core

# ARM64 only build
docker buildx bake --set "*.platform=linux/arm64" --push ubuntu2404-core
```

<!-- Links -->

[schedmd]: https://www.schedmd.com/
[slurm]: https://slurm.schedmd.com/overview.html
