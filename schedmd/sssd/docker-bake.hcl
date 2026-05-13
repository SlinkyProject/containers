// SPDX-FileCopyrightText: Copyright (C) SchedMD LLC.
// SPDX-License-Identifier: Apache-2.0

################################################################################

variable "REGISTRY" {
  default = "ghcr.io/slinkyproject"
}

variable "SUFFIX" {}

linux_flavor = "ubuntu26.04"
context = linux_flavor

################################################################################

function "format_tag" {
  params = [registry, stage, flavor, suffix]
  result = format("%s:%s", join("/", compact([registry, stage])), join("-", compact([flavor, suffix])))
}

################################################################################

target "_sssd" {
  labels = {
    # Ref: https://github.com/opencontainers/image-spec/blob/v1.0/annotations.md
    "org.opencontainers.image.authors" = "slinky@schedmd.com"
    "org.opencontainers.image.title" = "SSSD"
    "org.opencontainers.image.description" = "sssd - System Security Services Daemon"
    "org.opencontainers.image.documentation" = "https://sssd.io/docs/"
    "org.opencontainers.image.vendor" = "SchedMD LLC."
    "org.opencontainers.image.source" = "https://github.com/SlinkyProject/containers"
    # Ref: https://docs.redhat.com/en/documentation/red_hat_software_certification/2025/html/red_hat_openshift_software_certification_policy_guide/assembly-requirements-for-container-images_openshift-sw-cert-policy-introduction#con-image-metadata-requirements_openshift-sw-cert-policy-container-images
    "vendor" = "SchedMD LLC."
    "release" = "https://github.com/SlinkyProject/containers"
    "name" = "SSSD"
    "summary" = "sssd - System Security Services Daemon"
    "description" = "sssd - System Security Services Daemon"
  }
}

################################################################################

group "default" {
  targets = [
    "sssd",
  ]
}

group "all" {
  targets = [
    "sssd",
  ]
}

target "sssd" {
  inherits = ["_sssd"]
  context = context
  target = "sssd"
  tags = [
    format_tag(REGISTRY, "sssd", linux_flavor, SUFFIX),
  ]
}

################################################################################

group "multiarch" {
  targets = [
    "sssd_multiarch",
  ]
}

group "all-multiarch" {
  targets = [
    "sssd_multiarch",
  ]
}

target "_multiarch" {
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "sssd_multiarch" {
  inherits = ["sssd", "_multiarch"]
}
