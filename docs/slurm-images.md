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

<!-- mdformat-toc end -->

## Overview

This document explains how to use Slurm images.

## slurmctld

Pull a [slurmctld] image.

```sh
docker pull ghcr.io/slinkyproject/slurmctld:25.11-ubuntu24.04
```

### Environment

| Variable          | Description                      |
| ----------------- | -------------------------------- |
| SLURMCTLD_OPTIONS | Arguments passed to `slurmctld`. |

## slurmdbd

Pull a [slurmdbd] image.

```sh
docker pull ghcr.io/slinkyproject/slurmdbd:25.11-ubuntu24.04
```

### Environment

| Variable         | Description                     |
| ---------------- | ------------------------------- |
| SLURMDBD_OPTIONS | Arguments passed to `slurmdbd`. |

## slurmrestd

Pull a [slurmrestd] image.

```sh
docker pull ghcr.io/slinkyproject/slurmrestd:25.11-ubuntu24.04
```

### Environment

| Variable           | Description                       |
| ------------------ | --------------------------------- |
| SLURMRESTD_OPTIONS | Arguments passed to `slurmrestd`. |

## slurmd

Pull a [slurmd] image.

```sh
docker pull ghcr.io/slinkyproject/slurmd:25.11-ubuntu24.04
```

### Environment

| Variable                | Description                                  |
| ----------------------- | -------------------------------------------- |
| SLURMD_OPTIONS          | Arguments passed to `slurmd`.                |
| SSHD_OPTIONS            | Arguments passed to `sshd`.                  |
| SSSD_OPTIONS            | Arguments passed to `sssd`.                  |
| PAM_SLURM_ADOPT_OPTIONS | Options added to the `pam_slurm_adopt` line. |
| POD_CPUS                | Used to calculate slurmd `CoreSpecCount`.    |
| POD_MEMORY              | Used to calculate slurmd `MemSpecLimit`.     |
| POD_TOPOLOGY            | Used for slurmd dynamic topology.            |

## sackd

Pull a [sackd] image.

```sh
docker pull ghcr.io/slinkyproject/sackd:25.11-ubuntu24.04
```

### Environment

| Variable      | Description                  |
| ------------- | ---------------------------- |
| SACKD_OPTIONS | Arguments passed to `sackd`. |

## login

Pull a [login] image.

```sh
docker pull ghcr.io/slinkyproject/login:25.11-ubuntu24.04
```

### Environment

| Variable      | Description                  |
| ------------- | ---------------------------- |
| SACKD_OPTIONS | Arguments passed to `sackd`. |
| SSHD_OPTIONS  | Arguments passed to `sshd`.  |
| SSSD_OPTIONS  | Arguments passed to `sssd`.  |

<!-- Links -->

[login]: https://github.com/SlinkyProject/containers/pkgs/container/login
[sackd]: https://github.com/SlinkyProject/containers/pkgs/container/sackd
[slurmctld]: https://github.com/SlinkyProject/containers/pkgs/container/slurmctld
[slurmd]: https://github.com/SlinkyProject/containers/pkgs/container/slurmd
[slurmdbd]: https://github.com/SlinkyProject/containers/pkgs/container/slurmdbd
[slurmrestd]: https://github.com/SlinkyProject/containers/pkgs/container/slurmrestd
