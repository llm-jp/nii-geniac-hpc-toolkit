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
    prefix = "slurm-a3-cluster/slurm-a3-cluster/cluster"
  }
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
  machine_type           = "n2-standard-8"
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
  subnetwork_self_link = var.subnetwork_self_link_sysnet
  zone                 = var.zone
  zones                = var.zones
}

module "a3_node_group" {
  source = "./modules/embedded/community/modules/compute/schedmd-slurm-gcp-v5-node-group"
  additional_disks = [{
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-0"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-1"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-2"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-3"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-4"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-5"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-6"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-7"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-8"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-9"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-10"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-11"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-12"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-13"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-14"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
    }, {
    auto_delete  = true
    boot         = false
    device_name  = "local-ssd-15"
    disk_labels  = {}
    disk_name    = null
    disk_size_gb = 375
    disk_type    = "local-ssd"
  }]
  additional_networks = [{
    access_config      = []
    alias_ip_range     = []
    ipv6_access_config = []
    network            = null
    network_ip         = ""
    nic_type           = "GVNIC"
    queue_count        = null
    stack_type         = "IPV4_ONLY"
    subnetwork         = var.subnetwork_self_link_gpunet0
    subnetwork_project = var.project_id
    }, {
    access_config      = []
    alias_ip_range     = []
    ipv6_access_config = []
    network            = null
    network_ip         = ""
    nic_type           = "GVNIC"
    queue_count        = null
    stack_type         = "IPV4_ONLY"
    subnetwork         = var.subnetwork_self_link_gpunet1
    subnetwork_project = var.project_id
    }, {
    access_config      = []
    alias_ip_range     = []
    ipv6_access_config = []
    network            = null
    network_ip         = ""
    nic_type           = "GVNIC"
    queue_count        = null
    stack_type         = "IPV4_ONLY"
    subnetwork         = var.subnetwork_self_link_gpunet2
    subnetwork_project = var.project_id
    }, {
    access_config      = []
    alias_ip_range     = []
    ipv6_access_config = []
    network            = null
    network_ip         = ""
    nic_type           = "GVNIC"
    queue_count        = null
    stack_type         = "IPV4_ONLY"
    subnetwork         = var.subnetwork_self_link_gpunet3
    subnetwork_project = var.project_id
  }]
  bandwidth_tier     = "gvnic_enabled"
  disable_public_ips = true
  disk_size_gb       = var.disk_size_gb
  disk_type          = "pd-ssd"
  enable_smt         = true
  instance_image = {
    family  = var.final_image_family
    project = var.project_id
  }
  instance_image_custom = true
  labels                = var.labels
  machine_type          = "a3-highgpu-8g"
  maintenance_interval  = var.a3_maintenance_interval
  node_conf = {
    CoresPerSocket = 104
    Sockets        = 2
  }
  node_count_dynamic_max = 0
  node_count_static      = 74
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
  partition_name       = "a3"
  project_id           = var.project_id
  region               = var.region
  slurm_cluster_name   = var.slurm_cluster_name
  subnetwork_self_link = var.subnetwork_self_link_sysnet
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
    destination = "/tmp/scripts.tgz"
    source      = "/tmp/scripts.tgz"
    type        = "data"
    }, {
    content     = "#!/bin/bash\ntar --no-same-owner -xvf /tmp/scripts.tgz -C /opt/apps/\nmv /opt/apps/scripts/adm /opt/apps\nfind /opt/apps/adm/ -type d -exec chmod 0755 {} +\nfind /opt/apps/scripts/ -type d -exec chmod 0755 {} +\nfind /opt/apps/scripts/ -type f -exec chmod 0755 {} +\nfind /opt/apps/adm/slurm -type f -exec chmod 0755 {} +\n"
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
  compute_startup_script       = "#!/bin/bash\n# Setup sudo for slurm job users\nmkdir -m 750 /var/slurm-sudoers.d\n(umask 117; echo '#includedir /var/slurm-sudoers.d' > /etc/sudoers.d/slurm-job-user)\n# Apply fix to common_account PAM config if not already applied.\nif ! grep -q '^account[[:blank:]].*[[:blank:]]pam_unix.so.*broken_shadow' /etc/pam.d/common-account; then\n  sed -i '/^account[[:blank:]].*[[:blank:]]pam_unix.so[[:blank:]]*/ s/$/ broken_shadow/' /etc/pam.d/common-account\nfi\n"
  controller_startup_script    = module.controller_startup.startup_script
  deployment_name              = var.deployment_name
  disk_size_gb                 = var.disk_size_gb
  enable_cleanup_compute       = var.enable_cleanup_compute
  enable_cleanup_subscriptions = var.enable_cleanup_subscriptions
  enable_reconfigure           = var.enable_reconfigure
  epilog_scripts = [{
    content  = "#!/bin/bash\nif [[ -x /opt/apps/adm/slurm/slurm_epilog ]]; then\n  exec /opt/apps/adm/slurm/slurm_epilog\nfi\n"
    filename = "external-epilog.sh"
  }]
  instance_image = {
    family  = var.final_image_family
    project = var.project_id
  }
  instance_image_custom = true
  labels                = var.labels
  machine_type          = "c2-standard-8"
  network_self_link     = var.network_self_link_sysnet
  network_storage       = flatten([module.homefs.network_storage])
  partition             = flatten([module.debug_partition.partition, flatten([module.a3_partition.partition])])
  project_id            = var.project_id
  prolog_scripts = [{
    content  = "#!/bin/bash\nif [[ -x /opt/apps/adm/slurm/slurm_prolog ]]; then\n  exec /opt/apps/adm/slurm/slurm_prolog\nfi\n"
    filename = "external-prolog.sh"
  }]
  region               = var.region
  slurm_cluster_name   = var.slurm_cluster_name
  slurm_conf_tpl       = "modules/embedded/community/modules/scheduler/schedmd-slurm-gcp-v5-controller/etc/long-prolog-slurm.conf.tpl"
  subnetwork_self_link = var.subnetwork_self_link_sysnet
  zone                 = var.zone
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
  network_self_link     = var.network_self_link_sysnet
  project_id            = var.project_id
  pubsub_topic          = module.slurm_controller.pubsub_topic
  region                = var.region
  slurm_cluster_name    = var.slurm_cluster_name
  startup_script        = "#!/bin/bash\n# reset enroot to defaults of files under /home and running under /run\n# allows basic enroot testing on login node (reduced I/O)\nrm -f /etc/enroot/enroot.conf\n"
  subnetwork_self_link  = var.subnetwork_self_link_sysnet
  zone                  = var.zone
}
