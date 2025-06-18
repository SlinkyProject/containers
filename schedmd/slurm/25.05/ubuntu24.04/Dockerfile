# syntax=docker/dockerfile:1
# SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
# SPDX-License-Identifier: Apache-2.0

################################################################################

ARG SLURM_VERSION=25.05-latest
ARG SLURM_DIR="slurm-${SLURM_VERSION}"
ARG PARENT_IMAGE=ubuntu:24.04

# OpenMPI build arguments
ARG OPENMPI_VERSION="5.0.8"
ARG OPENMPI_CONFIGURE_OPTIONS="--with-pmix --with-slurm --enable-shared --disable-static"

################################################################################
FROM alpine:latest AS slurm-src

ARG SLURM_VERSION
ARG SLURM_DIR

WORKDIR /workspace/

ADD https://download.schedmd.com/slurm/${SLURM_DIR}.tar.bz2 ${SLURM_DIR}.tar.bz2

RUN <<EOR
# Unpack Slurm Source
set -xeuo pipefail
apk add --no-cache tar
mkdir -p ${SLURM_DIR}
tar --strip-components=1 -jxvf ${SLURM_DIR}.tar.bz2 -C ${SLURM_DIR}
rm ${SLURM_DIR}.tar.bz2
EOR

################################################################################
FROM ${PARENT_IMAGE} AS build

SHELL ["bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

ARG SLURM_VERSION
ENV SLURM_VERSION=${SLURM_VERSION}
ARG SLURM_DIR

USER root
WORKDIR /tmp/

COPY --from=slurm-src /workspace/${SLURM_DIR} ${SLURM_DIR}

COPY patches/ patches/

# Ref: https://slurm.schedmd.com/quickstart_admin.html#debuild
RUN <<EOR
# Patch and Build Slurm
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y upgrade
apt-get -qq -y install --no-install-recommends \
  build-essential fakeroot devscripts equivs
## Patch
find $(pwd)/patches/ -type f -name "*.patch" -print0 | sort -z | xargs -t0r -n1 patch -p1 -d ${SLURM_DIR} -i
## Build
mk-build-deps -ir --tool='apt-get -qq -y -o Debug::pkgProblemResolver=yes --no-install-recommends' ${SLURM_DIR}/debian/control
( cd ${SLURM_DIR} && debuild -b -uc -us >/dev/null )
## Cleanup
apt-get clean && rm -rf /var/lib/apt/lists/*
EOR

################################################################################
FROM ${PARENT_IMAGE} AS base

SHELL ["bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

ARG SLURM_VERSION
ENV SLURM_VERSION=${SLURM_VERSION}

USER root
WORKDIR /tmp/

ARG SLURM_USER=slurm
ARG SLURM_USER_UID=401
ARG SLURM_USER_GID=401

RUN <<EOR
# Create SlurmUser
set -xeuo pipefail
groupadd --system --gid=${SLURM_USER_GID} ${SLURM_USER}
useradd --system --no-log-init --uid=${SLURM_USER_UID} --gid=${SLURM_USER_GID} --shell=/usr/sbin/nologin ${SLURM_USER}
EOR

RUN <<EOR
# Remove Users
set -xeuo pipefail
for user in $(ls /home/); do
  userdel --remove $user
done
EOR

COPY --from=build /tmp/*.deb /tmp/

RUN <<EOR
# Install Dependencies
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y upgrade
# Init System
apt-get -qq -y install --no-install-recommends \
  supervisor tini
apt-get clean && rm -rf /var/lib/apt/lists/*
EOR

# Install OpenMPI with PMIx support
RUN <<EOR
# Install OpenMPI build dependencies
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y install --no-install-recommends \
  build-essential wget ca-certificates \
  libpmix-dev libpmix2t64 libhwloc-dev libevent-dev libssl-dev \
  zlib1g-dev flex
apt-get clean && rm -rf /var/lib/apt/lists/*
EOR

RUN <<EOR
# Build and install OpenMPI
set -xeuo pipefail
cd /tmp
wget -q https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-${OPENMPI_VERSION}.tar.gz
tar -xzf openmpi-${OPENMPI_VERSION}.tar.gz
cd openmpi-${OPENMPI_VERSION}
./configure --prefix=/usr/local ${OPENMPI_CONFIGURE_OPTIONS}
make -j$(nproc)
make install
ldconfig
cd /tmp
rm -rf openmpi-${OPENMPI_VERSION}*
EOR

# Set OpenMPI environment variables
ENV PATH="/usr/local/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

################################################################################
# SLURM: slurmctld
# BUILD: `docker build --target=slurmctld -t [<registry>/]slurmctld:<tag> .`
################################################################################
FROM base AS slurmctld

SHELL ["bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /tmp/

# Ref: https://slurm.schedmd.com/quickstart_admin.html#pkg_install
RUN <<EOR
# Install Slurm Packages
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y install --no-install-recommends --fix-broken \
  ./slurm-smd-client_[0-9]*.deb \
  ./slurm-smd-dev_[0-9]*.deb \
  ./slurm-smd-doc_[0-9]*.deb \
  ./slurm-smd-slurmctld_[0-9]*.deb \
  ./slurm-smd_[0-9]*.deb
rm *.deb && apt-get clean && rm -rf /var/lib/apt/lists/*
EOR

COPY files/slurmctld/ /

EXPOSE 6817/tcp
ENTRYPOINT ["entrypoint.sh"]

################################################################################
# SLURM: slurmd
# BUILD: `docker build --target=slurmd -t [<registry>/]slurmd:<tag> .`
################################################################################
FROM base AS slurmd

SHELL ["bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /tmp/

# Ref: https://slurm.schedmd.com/quickstart_admin.html#pkg_install
RUN <<EOR
# Install Slurm Packages
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y install --no-install-recommends --fix-broken \
  gawk \
  ./slurm-smd-client_[0-9]*.deb \
  ./slurm-smd-dev_[0-9]*.deb \
  ./slurm-smd-doc_[0-9]*.deb \
  ./slurm-smd-libnss-slurm_[0-9]*.deb \
  ./slurm-smd-libpam-slurm-adopt_[0-9]*.deb \
  ./slurm-smd-libpmi2-0_[0-9]*.deb \
  ./slurm-smd-slurmd_[0-9]*.deb \
  ./slurm-smd_[0-9]*.deb
rm *.deb && apt-get clean && rm -rf /var/lib/apt/lists/*
# Configure
mkdir -p /var/spool/slurmd/
cp -v /etc/nsswitch.conf{,.bak}
sed -i -E "s/^passwd:[[:space:]]+/&slurm /g" /etc/nsswitch.conf
sed -i -E "s/^group:[[:space:]]+/&slurm /g" /etc/nsswitch.conf
EOR

COPY files/slurmd/ /

EXPOSE 6818/tcp
ENTRYPOINT ["entrypoint.sh"]

################################################################################
# SLURM: slurmdbd
# BUILD: `docker build --target=slurmdbd -t [<registry>/]slurmdbd:<tag> .`
################################################################################
FROM base AS slurmdbd

SHELL ["bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /tmp/

# Ref: https://slurm.schedmd.com/quickstart_admin.html#pkg_install
RUN <<EOR
# Install Slurm Packages
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y install --no-install-recommends --fix-broken \
  ./slurm-smd-doc_[0-9]*.deb \
  ./slurm-smd-slurmdbd_[0-9]*.deb \
  ./slurm-smd_[0-9]*.deb
rm *.deb && apt-get clean && rm -rf /var/lib/apt/lists/*
EOR

EXPOSE 6819/tcp
ENTRYPOINT ["tini", "-g", "--", "slurmdbd", "-D"]

################################################################################
# SLURM: slurmrestd
# BUILD: `docker build --target=slurmrestd -t [<registry>/]slurmrestd:<tag> .`
################################################################################
FROM base AS slurmrestd

SHELL ["bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /tmp/

# Ref: https://slurm.schedmd.com/quickstart_admin.html#pkg_install
RUN <<EOR
# Install Slurm Packages
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y install --no-install-recommends --fix-broken \
  ./slurm-smd-doc_[0-9]*.deb \
  ./slurm-smd-slurmrestd_[0-9]*.deb \
  ./slurm-smd_[0-9]*.deb
rm *.deb && apt-get clean && rm -rf /var/lib/apt/lists/*
EOR

EXPOSE 6820/tcp
ENTRYPOINT ["tini", "-g", "--", "slurmrestd"]
CMD ["0.0.0.0:6820"]

################################################################################
# SLURM: sackd
# BUILD: `docker build --target=sackd -t [<registry>/]sackd:<tag> .`
################################################################################
FROM base AS sackd

SHELL ["bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /tmp/

ENV KUBECTL_VERSION=1.33

# Ref: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
RUN <<EOR
# Install kubectl
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y install --no-install-recommends \
  apt-transport-https ca-certificates curl gnupg
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
chmod 644 /etc/apt/sources.list.d/kubernetes.list
apt-get -qq update
apt-get -qq -y install --no-install-recommends kubectl
apt-get clean && rm -rf /var/lib/apt/lists/*
EOR

# Ref: https://slurm.schedmd.com/quickstart_admin.html#pkg_install
RUN <<EOR
# Install Slurm Packages
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y install --no-install-recommends --fix-broken \
  ./slurm-smd-client_[0-9]*.deb \
  ./slurm-smd-doc_[0-9]*.deb \
  ./slurm-smd-sackd_[0-9]*.deb \
  ./slurm-smd_[0-9]*.deb
# For: Helm Chart
apt-get -qq -y install --no-install-recommends \
  rsync gettext-base iputils-ping
rm *.deb && apt-get clean && rm -rf /var/lib/apt/lists/*
# Prepare Directories
mkdir -p /run/slurm/
EOR

COPY files/sackd/ /

ENTRYPOINT ["entrypoint.sh"]

################################################################################
# NAME : login
# BUILD: `docker build --target=login -t [<registry>/]login:<tag> .`
################################################################################
FROM sackd AS login

SHELL ["bash", "-c"]

ARG DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /tmp/

# Ref: https://slurm.schedmd.com/quickstart_admin.html#pkg_install
RUN <<EOR
# Install Packages
set -xeuo pipefail
apt-get -qq update
apt-get -qq -y install --no-install-recommends \
  openssh-server \
  dbus-daemon \
  oddjob-mkhomedir \
  authselect sssd sssd-ad sssd-ldap sssd-dbus libpam-sss libnss-sss
rm *.deb && apt-get clean && rm -rf /var/lib/apt/lists/*
# Configure
mkdir -p /etc/authselect
authselect select sssd with-mkhomedir --force
rm -f /etc/ssh/ssh_host_*
# Remove Packages
apt-get -qq -y remove \
  authselect
apt-get -qq -y autoremove
EOR

COPY files/login/ /

EXPOSE 22/tcp
ENTRYPOINT ["entrypoint.sh"]
