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
    prefix = "slurm-a3-cluster-tky/slurm-a3-cluster-tky/cluster"
  }
}

module "sysnet" {
  source          = "./modules/embedded/modules/network/pre-existing-vpc"
  network_name    = var.network_name_system
  project_id      = var.project_id
  region          = var.region
  subnetwork_name = var.subnetwork_name_system
}

module "gpunets" {
  source                  = "./modules/embedded/modules/network/multivpc"
  deployment_name         = var.deployment_name
  global_ip_address_range = "10.4.0.0/14"
  network_count           = 4
  network_name_prefix     = "${var.deployment_name}-gpunet"
  project_id              = var.project_id
  region                  = var.region
  subnetwork_cidr_suffix  = 16
}

module "homefs" {
  source       = "./modules/embedded/modules/file-system/pre-existing-network-storage"
  local_mount  = var.local_mount_homefs
  remote_mount = var.remote_mount_homefs
  server_ip    = var.server_ip_homefs
}

module "debug_node_group" {
  source       = "./modules/embedded/community/modules/compute/schedmd-slurm-gcp-v5-node-group"
  disk_size_gb = var.disk_size_gb
  instance_image = {
    family  = var.final_image_family
    project = var.project_id
  }
  instance_image_custom  = true
  labels                 = var.labels
  machine_type           = "n2-standard-2"
  node_count_dynamic_max = 4
  node_count_static      = 0
  project_id             = var.project_id
}

module "debug_partition" {
  source               = "./modules/embedded/community/modules/compute/schedmd-slurm-gcp-v5-partition"
  deployment_name      = var.deployment_name
  enable_placement     = false
  enable_reconfigure   = var.enable_reconfigure
  exclusive            = false
  network_storage      = flatten([module.homefs.network_storage])
  node_groups          = flatten([module.debug_node_group.node_groups])
  partition_name       = "debug"
  project_id           = var.project_id
  region               = var.region
  slurm_cluster_name   = var.slurm_cluster_name
  subnetwork_self_link = module.sysnet.subnetwork_self_link
  zone                 = var.zone
  zones                = var.zones
}

module "a3_node_group" {
  source              = "./modules/embedded/community/modules/compute/schedmd-slurm-gcp-v5-node-group"
  additional_networks = flatten([module.gpunets.additional_networks])
  bandwidth_tier      = "gvnic_enabled"
  disable_public_ips  = true
  disk_size_gb        = var.disk_size_gb
  disk_type           = "pd-ssd"
  enable_smt          = true
  instance_image = {
    family  = var.final_image_family
    project = var.project_id
  }
  instance_image_custom = true
  labels                = var.labels
  machine_type          = "a3-highgpu-8g"
  maintenance_interval  = var.a3_maintenance_interval
  node_conf = {
    CoresPerSocket = 52
    ThreadsPerCore = 2
  }
  node_count_dynamic_max = 0
  node_count_static      = var.a3_static_cluster_size
  on_host_maintenance    = "TERMINATE"
  project_id             = var.project_id
  service_account = {
    email  = "874088236606-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

module "a3_partition" {
  source             = "./modules/embedded/community/modules/compute/schedmd-slurm-gcp-v5-partition"
  deployment_name    = var.deployment_name
  enable_placement   = false
  enable_reconfigure = var.enable_reconfigure
  exclusive          = false
  is_default         = true
  network_storage    = flatten([module.homefs.network_storage])
  node_groups        = flatten([module.a3_node_group.node_groups])
  partition_conf = {
    OverSubscribe = "EXCLUSIVE"
  }
  partition_name       = var.a3_partition_name
  project_id           = var.project_id
  region               = var.region
  slurm_cluster_name   = var.slurm_cluster_name
  subnetwork_self_link = module.sysnet.subnetwork_self_link
  zone                 = var.zone
  zones                = var.zones
}

module "controller_startup" {
  source          = "./modules/embedded/modules/scripts/startup-script"
  deployment_name = var.deployment_name
  labels          = var.labels
  project_id      = var.project_id
  region          = var.region
  runners = [{
    content     = "#!/bin/bash\ncurl -s --create-dirs -o /opt/apps/adm/slurm/scripts/receive-data-path-manager \\\n    https://raw.githubusercontent.com/GoogleCloudPlatform/slurm-gcp/v5/tools/prologs-epilogs/receive-data-path-manager\nchmod 0755 /opt/apps/adm/slurm/scripts/receive-data-path-manager\nmkdir -p /opt/apps/adm/slurm/partition-${var.a3_partition_name}-prolog_slurmd.d\nmkdir -p /opt/apps/adm/slurm/partition-${var.a3_partition_name}-epilog_slurmd.d\nln -s /opt/apps/adm/slurm/scripts/receive-data-path-manager /opt/apps/adm/slurm/partition-${var.a3_partition_name}-prolog_slurmd.d/start-rxdm.prolog_slurmd\nln -s /opt/apps/adm/slurm/scripts/receive-data-path-manager /opt/apps/adm/slurm/partition-${var.a3_partition_name}-epilog_slurmd.d/stop-rxdm.epilog_slurmd\n"
    destination = "stage_scripts.sh"
    type        = "shell"
    }, {
    content     = "#!/bin/bash\n# reset enroot to defaults of files under /home and running under /run\n# allows basic enroot testing on login/controller nodes (reduced I/O)\nrm -f /etc/enroot/enroot.conf\n"
    destination = "reset_enroot.sh"
    type        = "shell"
  }]
}

module "slurm_controller" {
  source = "./modules/embedded/community/modules/scheduler/schedmd-slurm-gcp-v5-controller"
  cloud_parameters = {
    no_comma_params = false
    resume_rate     = 0
    resume_timeout  = 900
    suspend_rate    = 0
    suspend_timeout = 600
  }
  controller_startup_script     = module.controller_startup.startup_script
  deployment_name               = var.deployment_name
  disk_size_gb                  = var.disk_size_gb
  enable_cleanup_compute        = var.enable_cleanup_compute
  enable_cleanup_subscriptions  = var.enable_cleanup_subscriptions
  enable_external_prolog_epilog = true
  enable_reconfigure            = var.enable_reconfigure
  instance_image = {
    family  = var.final_image_family
    project = var.project_id
  }
  instance_image_custom = true
  labels                = var.labels
  machine_type          = "c2-standard-8"
  network_self_link     = module.sysnet.network_self_link
  network_storage       = flatten([module.homefs.network_storage])
  partition             = flatten([module.debug_partition.partition, flatten([module.a3_partition.partition])])
  project_id            = var.project_id
  region                = var.region
  slurm_cluster_name    = var.slurm_cluster_name
  slurm_conf_tpl        = "modules/embedded/community/modules/scheduler/schedmd-slurm-gcp-v5-controller/etc/long-prolog-slurm.conf.tpl"
  subnetwork_self_link  = module.sysnet.subnetwork_self_link
  zone                  = var.zone
}

module "slurm_login" {
  source                 = "./modules/embedded/community/modules/scheduler/schedmd-slurm-gcp-v5-login"
  controller_instance_id = module.slurm_controller.controller_instance_id
  deployment_name        = var.deployment_name
  disk_size_gb           = var.disk_size_gb
  disk_type              = "pd-balanced"
  enable_reconfigure     = var.enable_reconfigure
  instance_image = {
    family  = var.final_image_family
    project = var.project_id
  }
  instance_image_custom = true
  labels                = var.labels
  machine_type          = "c2-standard-16"
  network_self_link     = module.sysnet.network_self_link
  project_id            = var.project_id
  pubsub_topic          = module.slurm_controller.pubsub_topic
  region                = var.region
  slurm_cluster_name    = var.slurm_cluster_name
  startup_script        = "#!/bin/bash\n# reset enroot to defaults of files under /home and running under /run\n# allows basic enroot testing on login node (reduced I/O)\nrm -f /etc/enroot/enroot.conf\n"
  subnetwork_self_link  = module.sysnet.subnetwork_self_link
  zone                  = var.zone
}
