# Slurm Images

## Table of Contents

<!-- mdformat-toc start --slug=github --no-anchors --maxlevel=6 --minlevel=1 -->

- [Slurm Images](#slurm-images)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [slurmctld](#slurmctld)
    - [Environment](#environment)
  - [slurmdbd](#slurmdbd)
    - [Environment](#environment-1)
  - [slurmrestd](#slurmrestd)
    - [Environment](#environment-2)
  - [slurmd](#slurmd)
    - [Environment](#environment-3)
  - [sackd](#sackd)
    - [Environment](#environment-4)
  - [login](#login)
    - [Environment](#environment-5)
  - [sssd](#sssd)

<!-- mdformat-toc end -->

## Overview

This document explains how to use Slurm images.

## slurmctld

Pull a [slurmctld] image.

```sh
docker pull ghcr.io/slinkyproject/slurmctld:26.05-ubuntu26.04
```

### Environment

| Variable          | Description                      |
| ----------------- | -------------------------------- |
| SLURMCTLD_OPTIONS | Arguments passed to `slurmctld`. |

## slurmdbd

Pull a [slurmdbd] image.

```sh
docker pull ghcr.io/slinkyproject/slurmdbd:26.05-ubuntu26.04
```

### Environment

| Variable         | Description                     |
| ---------------- | ------------------------------- |
| SLURMDBD_OPTIONS | Arguments passed to `slurmdbd`. |

## slurmrestd

Pull a [slurmrestd] image.

```sh
docker pull ghcr.io/slinkyproject/slurmrestd:26.05-ubuntu26.04
```

### Environment

| Variable           | Description                       |
| ------------------ | --------------------------------- |
| SLURMRESTD_OPTIONS | Arguments passed to `slurmrestd`. |

## slurmd

Pull a [slurmd] image.

```sh
docker pull ghcr.io/slinkyproject/slurmd:26.05-ubuntu26.04
```

### Environment

| Variable                | Description                                   |
| ----------------------- | --------------------------------------------- |
| SLURMD_OPTIONS          | Arguments passed to `slurmd`.                 |
| SSHD_OPTIONS            | Arguments passed to `sshd`.                   |
| SSSD_OPTIONS            | Arguments passed to `sssd`.                   |
| SSSD_MODE               | SSSD mode: `embedded`, `sidecar`, `disabled`. |
| PAM_SLURM_ADOPT_OPTIONS | Options added to the `pam_slurm_adopt` line.  |
| POD_CPUS                | Used to calculate slurmd `CoreSpecCount`.     |
| POD_MEMORY              | Used to calculate slurmd `MemSpecLimit`.      |
| POD_TOPOLOGY            | Used for slurmd dynamic topology.             |

## sackd

Pull a [sackd] image.

```sh
docker pull ghcr.io/slinkyproject/sackd:26.05-ubuntu26.04
```

### Environment

| Variable      | Description                  |
| ------------- | ---------------------------- |
| SACKD_OPTIONS | Arguments passed to `sackd`. |

## login

Pull a [login] image.

```sh
docker pull ghcr.io/slinkyproject/login:26.05-ubuntu26.04
```

### Environment

| Variable      | Description                                    |
| ------------- | ---------------------------------------------- |
| SACKD_OPTIONS | Arguments passed to embedded `sackd`.          |
| SACKD_MODE    | sackd mode: `embedded`, `sidecar`, `disabled`. |
| SSHD_OPTIONS  | Arguments passed to `sshd`.                    |
| SSSD_OPTIONS  | Arguments passed to `sssd`.                    |
| SSSD_MODE     | SSSD mode: `embedded`, `sidecar`, `disabled`.  |

`SACKD_MODE` controls whether the [login] image starts sackd. When set to
`embedded`, the main container starts sackd by enabling the supervisord sackd
configuration. When set to `sidecar`, the main container does not start sackd;
sackd is expected to run in a sidecar container. When set to `disabled`, the
main container does not start sackd and no sidecar is expected.

`SSSD_MODE` has the same behavior for the [slurmd] and [login] images. When set
to `embedded`, the main container starts SSSD by enabling the supervisord SSSD
configuration. When set to `sidecar`, the main container does not start SSSD;
SSSD is expected to run in a sidecar container. When set to `disabled`, the main
container does not start SSSD and no sidecar is expected.

## sssd

Pull a [sssd] image.

```sh
docker pull ghcr.io/slinkyproject/sssd:ubuntu26.04
```

When running the [sssd] image as a sidecar for [slurmd], [login], or [sackd],
share the SSSD runtime sockets with the client container by mounting the same
volumes at `/run/sssd` and `/var/lib/sss/pipes`. Do not mount over all of
`/var/lib/sss`; doing so hides SSSD's image-provided `/var/lib/sss/db`
directory.

When running the [sssd] image as a sidecar for [slurmd] or [login], share the
SSSD runtime sockets with the main container by mounting the same volumes at
`/run/sssd` and `/var/lib/sss/pipes`. Do not mount over all of `/var/lib/sss`;
doing so hides SSSD's image-provided `/var/lib/sss/db` directory.

<!-- Links -->

[login]: https://github.com/SlinkyProject/containers/pkgs/container/login
[sackd]: https://github.com/SlinkyProject/containers/pkgs/container/sackd
[slurmctld]: https://github.com/SlinkyProject/containers/pkgs/container/slurmctld
[slurmd]: https://github.com/SlinkyProject/containers/pkgs/container/slurmd
[slurmdbd]: https://github.com/SlinkyProject/containers/pkgs/container/slurmdbd
[slurmrestd]: https://github.com/SlinkyProject/containers/pkgs/container/slurmrestd
[sssd]: https://github.com/SlinkyProject/containers/pkgs/container/sssd
