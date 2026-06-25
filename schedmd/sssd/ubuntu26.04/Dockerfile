# syntax=docker/dockerfile:1
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

ARG PARENT_IMAGE=ubuntu:26.04

################################################################################
FROM ${PARENT_IMAGE} AS sssd

SHELL ["bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

USER root

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked <<EOR
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y upgrade
apt-get -qq -y install --no-install-recommends \
  sssd sssd-ad sssd-ldap
mkdir -p /etc/sssd /run/sssd /var/lib/sss/pipes
EOR

COPY files/usr/local/bin/sssd-entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
