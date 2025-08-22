// SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
// SPDX-License-Identifier: Apache-2.0

################################################################################

variable "DOCKER_BAKE_REGISTRY" {
  default = "ghcr.io/slinkyproject"
}

variable "DOCKER_BAKE_SUFFIX" {}

slurm_version = "24.05.8"

function "slurm_semantic_version" {
  params = [version]
  result = regex("^(?<major>[0-9]+)\\.(?<minor>[0-9]+)\\.(?<patch>[0-9]+)(?:-(?<rev>.+))?$", "${version}")
}

function "slurm_version" {
  params = [version]
  result = (
    length(regexall("^(?<major>[0-9]+)\\.(?<minor>[0-9]+)\\.(?<patch>[0-9]+)(?:-(?<rev>.+))?$", "${version}")) > 0
      ? "${format("%s.%s", "${slurm_semantic_version("${version}")["major"]}", "${slurm_semantic_version("${version}")["minor"]}")}"
      : "${version}"
  )
}

function "format_tag" {
  params = [registry, stage, version, flavor, suffix]
  result = format("%s:%s", join("/", compact([registry, stage])), join("-", compact([version, flavor, suffix])))
}

################################################################################

target "_slurm" {
  platforms = ["linux/amd64", "linux/arm64"]
  labels = {
    # Ref: https://github.com/opencontainers/image-spec/blob/v1.0/annotations.md
    "org.opencontainers.image.authors" = "slinky@schedmd.com"
    "org.opencontainers.image.documentation" = "https://slurm.schedmd.com/documentation.html"
    "org.opencontainers.image.license" = "GPL-2.0-or-later WITH openssl-exception"
    "org.opencontainers.image.vendor" = "SchedMD LLC."
    "org.opencontainers.image.version" = "${slurm_version}"
    "org.opencontainers.image.source" = "https://github.com/SlinkyProject/containers"
    # Ref: https://docs.redhat.com/en/documentation/red_hat_software_certification/2025/html/red_hat_openshift_software_certification_policy_guide/assembly-requirements-for-container-images_openshift-sw-cert-policy-introduction#con-image-metadata-requirements_openshift-sw-cert-policy-container-images
    "vendor" = "SchedMD LLC."
    "version" = "${slurm_version}"
    "release" = "https://github.com/SlinkyProject/containers"
  }
}

target "_slurmctld" {
  inherits = ["_slurm"]
  labels = {
    # Ref: https://github.com/opencontainers/image-spec/blob/v1.0/annotations.md
    "org.opencontainers.image.title" = "Slurm Control Plane"
    "org.opencontainers.image.description" = "slurmctld - The central management daemon of Slurm"
    "org.opencontainers.image.documentation" = "https://slurm.schedmd.com/slurmctld.html"
    # Ref: https://docs.redhat.com/en/documentation/red_hat_software_certification/2025/html/red_hat_openshift_software_certification_policy_guide/assembly-requirements-for-container-images_openshift-sw-cert-policy-introduction#con-image-metadata-requirements_openshift-sw-cert-policy-container-images
    "name" = "Slurm Control Plane"
    "summary" = "slurmctld - The central management daemon of Slurm"
    "description" = "slurmctld - The central management daemon of Slurm"
  }
}

target "_slurmd" {
  inherits = ["_slurm"]
  labels = {
    # Ref: https://github.com/opencontainers/image-spec/blob/v1.0/annotations.md
    "org.opencontainers.image.title" = "Slurm Worker Agent"
    "org.opencontainers.image.description" = "slurmd - The compute node daemon for Slurm"
    "org.opencontainers.image.documentation" = "https://slurm.schedmd.com/slurmd.html"
    # Ref: https://docs.redhat.com/en/documentation/red_hat_software_certification/2025/html/red_hat_openshift_software_certification_policy_guide/assembly-requirements-for-container-images_openshift-sw-cert-policy-introduction#con-image-metadata-requirements_openshift-sw-cert-policy-container-images
    "name" = "Slurm Worker Agent"
    "summary" = "slurmd - The compute node daemon for Slurm"
    "description" = "slurmd - The compute node daemon for Slurm"
  }
}

target "_slurmdbd" {
  inherits = ["_slurm"]
  labels = {
    # Ref: https://github.com/opencontainers/image-spec/blob/v1.0/annotations.md
    "org.opencontainers.image.title" = "Slurm Database Agent"
    "org.opencontainers.image.description" = "slurmdbd - Slurm Database Daemon"
    "org.opencontainers.image.documentation" = "https://slurm.schedmd.com/slurmdbd.html"
    # Ref: https://docs.redhat.com/en/documentation/red_hat_software_certification/2025/html/red_hat_openshift_software_certification_policy_guide/assembly-requirements-for-container-images_openshift-sw-cert-policy-introduction#con-image-metadata-requirements_openshift-sw-cert-policy-container-images
    "name" = "Slurm Database Agent"
    "summary" = "slurmdbd - Slurm Database Daemon"
    "description" = "slurmdbd - Slurm Database Daemon"
  }
}

target "_slurmrestd" {
  inherits = ["_slurm"]
  labels = {
    # Ref: https://github.com/opencontainers/image-spec/blob/v1.0/annotations.md
    "org.opencontainers.image.title" = "Slurm REST API Agent"
    "org.opencontainers.image.description" = "slurmrestd - Interface to Slurm via REST API"
    "org.opencontainers.image.documentation" = "https://slurm.schedmd.com/slurmrestd.html"
    # Ref: https://docs.redhat.com/en/documentation/red_hat_software_certification/2025/html/red_hat_openshift_software_certification_policy_guide/assembly-requirements-for-container-images_openshift-sw-cert-policy-introduction#con-image-metadata-requirements_openshift-sw-cert-policy-container-images
    "name" = "Slurm REST API Agent"
    "summary" = "slurmrestd - Interface to Slurm via REST API"
    "description" = "slurmrestd - Interface to Slurm via REST API"
  }
}

target "_sackd" {
  inherits = ["_slurm"]
  labels = {
    # Ref: https://github.com/opencontainers/image-spec/blob/v1.0/annotations.md
    "org.opencontainers.image.title" = "Slurm Auth/Cred Server"
    "org.opencontainers.image.description" = "sackd - Slurm Auth and Cred Kiosk Daemon"
    "org.opencontainers.image.documentation" = "https://slurm.schedmd.com/sackd.html"
    # Ref: https://docs.redhat.com/en/documentation/red_hat_software_certification/2025/html/red_hat_openshift_software_certification_policy_guide/assembly-requirements-for-container-images_openshift-sw-cert-policy-introduction#con-image-metadata-requirements_openshift-sw-cert-policy-container-images
    "name" = "Slurm Auth/Cred Server"
    "summary" = "sackd - Slurm Auth and Cred Kiosk Daemon"
    "description" = "sackd - Slurm Auth and Cred Kiosk Daemon"
  }
}

################################################################################

group "default" {
  targets = [
    "rockylinux9",
    "ubuntu2404",
  ]
}

group "rockylinux9" {
  targets = [
    "slurmctld_rockylinux9",
    "slurmd_rockylinux9",
    "slurmdbd_rockylinux9",
    "slurmrestd_rockylinux9",
    "sackd_rockylinux9",
  ]
}

target "_rockylinux9" {
  context = "rockylinux9"
  args = {
    SLURM_VERSION = "${slurm_version}"
  }
}

target "slurmctld_rockylinux9" {
  inherits = ["_slurmctld", "_rockylinux9"]
  target = "slurmctld"
  tags = [
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmctld", "${slurm_version("${slurm_version}")}", "rockylinux9", "${DOCKER_BAKE_SUFFIX}"),
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmctld", "${slurm_version}", "rockylinux9", "${DOCKER_BAKE_SUFFIX}"),
  ]
}

target "slurmd_rockylinux9" {
  inherits = ["_slurmd", "_rockylinux9"]
  target = "slurmd"
  tags = [
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmd", "${slurm_version("${slurm_version}")}", "rockylinux9", "${DOCKER_BAKE_SUFFIX}"),
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmd", "${slurm_version}", "rockylinux9", "${DOCKER_BAKE_SUFFIX}"),
  ]
}

target "slurmdbd_rockylinux9" {
  inherits = ["_slurmdbd", "_rockylinux9"]
  target = "slurmdbd"
  tags = [
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmdbd", "${slurm_version("${slurm_version}")}", "rockylinux9", "${DOCKER_BAKE_SUFFIX}"),
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmdbd", "${slurm_version}", "rockylinux9", "${DOCKER_BAKE_SUFFIX}"),
  ]
}

target "slurmrestd_rockylinux9" {
  inherits = ["_slurmrestd", "_rockylinux9"]
  target = "slurmrestd"
  tags = [
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmrestd", "${slurm_version("${slurm_version}")}", "rockylinux9", "${DOCKER_BAKE_SUFFIX}"),
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmrestd", "${slurm_version}", "rockylinux9", "${DOCKER_BAKE_SUFFIX}"),
  ]
}

target "sackd_rockylinux9" {
  inherits = ["_sackd", "_rockylinux9"]
  target = "sackd"
  tags = [
    format_tag("${DOCKER_BAKE_REGISTRY}", "sackd", "${slurm_version("${slurm_version}")}", "rockylinux9", "${DOCKER_BAKE_SUFFIX}"),
    format_tag("${DOCKER_BAKE_REGISTRY}", "sackd", "${slurm_version}", "rockylinux9", "${DOCKER_BAKE_SUFFIX}"),
  ]
}

group "ubuntu2404" {
  targets = [
    "slurmctld_ubuntu2404",
    "slurmd_ubuntu2404",
    "slurmdbd_ubuntu2404",
    "slurmrestd_ubuntu2404",
    "sackd_ubuntu2404",
  ]
}

target "_ubuntu2404" {
  context = "ubuntu24.04"
  args = {
    SLURM_VERSION = "${slurm_version}"
  }
}

target "slurmctld_ubuntu2404" {
  inherits = ["_slurmctld", "_ubuntu2404"]
  target = "slurmctld"
  tags = [
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmctld", "${slurm_version("${slurm_version}")}", "ubuntu24.04", "${DOCKER_BAKE_SUFFIX}"),
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmctld", "${slurm_version}", "ubuntu24.04", "${DOCKER_BAKE_SUFFIX}"),
  ]
}

target "slurmd_ubuntu2404" {
  inherits = ["_slurmd", "_ubuntu2404"]
  target = "slurmd"
  tags = [
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmd", "${slurm_version("${slurm_version}")}", "ubuntu24.04", "${DOCKER_BAKE_SUFFIX}"),
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmd", "${slurm_version}", "ubuntu24.04", "${DOCKER_BAKE_SUFFIX}"),
  ]
}

target "slurmdbd_ubuntu2404" {
  inherits = ["_slurmdbd", "_ubuntu2404"]
  target = "slurmdbd"
  tags = [
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmdbd", "${slurm_version("${slurm_version}")}", "ubuntu24.04", "${DOCKER_BAKE_SUFFIX}"),
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmdbd", "${slurm_version}", "ubuntu24.04", "${DOCKER_BAKE_SUFFIX}"),
  ]
}

target "slurmrestd_ubuntu2404" {
  inherits = ["_slurmrestd", "_ubuntu2404"]
  target = "slurmrestd"
  tags = [
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmrestd", "${slurm_version("${slurm_version}")}", "ubuntu24.04", "${DOCKER_BAKE_SUFFIX}"),
    format_tag("${DOCKER_BAKE_REGISTRY}", "slurmrestd", "${slurm_version}", "ubuntu24.04", "${DOCKER_BAKE_SUFFIX}"),
  ]
}

target "sackd_ubuntu2404" {
  inherits = ["_sackd", "_ubuntu2404"]
  target = "sackd"
  tags = [
    format_tag("${DOCKER_BAKE_REGISTRY}", "sackd", "${slurm_version("${slurm_version}")}", "ubuntu24.04", "${DOCKER_BAKE_SUFFIX}"),
    format_tag("${DOCKER_BAKE_REGISTRY}", "sackd", "${slurm_version}", "ubuntu24.04", "${DOCKER_BAKE_SUFFIX}"),
  ]
}
