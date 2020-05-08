// Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.

variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}

variable "vcn_display_name" {
  default = "testVCN"
}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

module "vcn" {
  source           = "../../"
  compartment_ocid = var.compartment_ocid
  vcn_display_name = var.vcn_display_name
  vcn_cidr         = var.vcn_cidr
}


terraform {
  backend "s3" {
    endpoint                    = "https://cintra.compat.objectstorage.us-phoenix-1.oraclecloud.com"
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    skip_credentials_validation = true
    bucket                      = "tf-fk-test-01"
    key                         = "terraform/state/oci/vcn/testVCN/terraform.tfstate"
    region                      = "us-phoenix-1"
  }
}
