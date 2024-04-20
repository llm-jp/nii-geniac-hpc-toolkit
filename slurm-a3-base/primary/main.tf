/**
  * Copyright 2023 Google LLC
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
  * You may obtain a copy of the License at
  *
  *      http://www.apache.org/licenses/LICENSE-2.0
  *
  * Unless required by applicable law or agreed to in writing, software
  * distributed under the License is distributed on an "AS IS" BASIS,
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  */

terraform {
  backend "gcs" {
    bucket = "geniac-tf-state-bucket"
    prefix = "slurm-a3-base/slurm-a3-base/primary"
  }
}

module "sysnet" {
  source                          = "./modules/embedded/modules/network/vpc"
  default_primary_subnetwork_size = 4
  deployment_name                 = var.deployment_name
  mtu                             = 8244
  network_address_range           = var.sys_net_range
  network_name                    = "slurm-sys-net"
  project_id                      = var.project_id
  region                          = var.region
  subnetwork_name                 = "slurm-sys-subnet"
}

module "gpunet0" {
  source                          = "./modules/embedded/modules/network/vpc"
  default_primary_subnetwork_size = 4
  deployment_name                 = var.deployment_name
  mtu                             = 8244
  network_address_range           = var.gpu_net0_range
  network_name                    = "slurm-gpu-net0"
  project_id                      = var.project_id
  region                          = var.region
  subnetwork_name                 = "slurm-gpu-subnet0"
}

module "gpunet1" {
  source                          = "./modules/embedded/modules/network/vpc"
  default_primary_subnetwork_size = 4
  deployment_name                 = var.deployment_name
  mtu                             = 8244
  network_address_range           = var.gpu_net1_range
  network_name                    = "slurm-gpu-net1"
  project_id                      = var.project_id
  region                          = var.region
  subnetwork_name                 = "slurm-gpu-subnet1"
}

module "gpunet2" {
  source                          = "./modules/embedded/modules/network/vpc"
  default_primary_subnetwork_size = 4
  deployment_name                 = var.deployment_name
  mtu                             = 8244
  network_address_range           = var.gpu_net2_range
  network_name                    = "slurm-gpu-net2"
  project_id                      = var.project_id
  region                          = var.region
  subnetwork_name                 = "slurm-gpu-subnet2"
}

module "gpunet3" {
  source                          = "./modules/embedded/modules/network/vpc"
  default_primary_subnetwork_size = 4
  deployment_name                 = var.deployment_name
  mtu                             = 8244
  network_address_range           = var.gpu_net3_range
  network_name                    = "slurm-gpu-net3"
  project_id                      = var.project_id
  region                          = var.region
  subnetwork_name                 = "slurm-gpu-subnet3"
}

module "homefs" {
  source          = "./modules/embedded/modules/file-system/filestore"
  deployment_name = var.deployment_name
  filestore_tier  = "HIGH_SCALE_SSD"
  labels          = var.labels
  local_mount     = "/home"
  network_id      = module.sysnet.network_id
  project_id      = var.project_id
  region          = var.region
  size_gb         = 102400
  zone            = var.zone
}

module "lustrefs" {
  source       = "./modules/embedded/modules/file-system/pre-existing-network-storage"
  fs_type      = "lustre"
  local_mount  = "/lustre"
  remote_mount = "/lustre"
  server_ip    = "172.16.0.29@tcp"
}
