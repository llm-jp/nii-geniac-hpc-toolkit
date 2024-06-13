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

variable "a3_maintenance_interval" {
  description = "Toolkit deployment variable: a3_maintenance_interval"
  type        = string
}

variable "a3_partition_name" {
  description = "Toolkit deployment variable: a3_partition_name"
  type        = string
}

variable "a3_static_cluster_size" {
  description = "Toolkit deployment variable: a3_static_cluster_size"
  type        = number
}

variable "deployment_name" {
  description = "Toolkit deployment variable: deployment_name"
  type        = string
}

variable "disk_size_gb" {
  description = "Toolkit deployment variable: disk_size_gb"
  type        = number
}

variable "enable_cleanup_compute" {
  description = "Toolkit deployment variable: enable_cleanup_compute"
  type        = bool
}

variable "enable_cleanup_subscriptions" {
  description = "Toolkit deployment variable: enable_cleanup_subscriptions"
  type        = bool
}

variable "enable_reconfigure" {
  description = "Toolkit deployment variable: enable_reconfigure"
  type        = bool
}

variable "final_image_family" {
  description = "Toolkit deployment variable: final_image_family"
  type        = string
}

variable "labels" {
  description = "Toolkit deployment variable: labels"
  type        = any
}

variable "local_mount_homefs" {
  description = "Toolkit deployment variable: local_mount_homefs"
  type        = string
}

variable "network_name_system" {
  description = "Toolkit deployment variable: network_name_system"
  type        = string
}

variable "project_id" {
  description = "Toolkit deployment variable: project_id"
  type        = string
}

variable "region" {
  description = "Toolkit deployment variable: region"
  type        = string
}

variable "remote_mount_homefs" {
  description = "Toolkit deployment variable: remote_mount_homefs"
  type        = string
}

variable "server_ip_homefs" {
  description = "Toolkit deployment variable: server_ip_homefs"
  type        = string
}

variable "slurm_cluster_name" {
  description = "Toolkit deployment variable: slurm_cluster_name"
  type        = string
}

variable "subnetwork_name_system" {
  description = "Toolkit deployment variable: subnetwork_name_system"
  type        = string
}

variable "zone" {
  description = "Toolkit deployment variable: zone"
  type        = string
}

variable "zones" {
  description = "Toolkit deployment variable: zones"
  type        = list(any)
}
