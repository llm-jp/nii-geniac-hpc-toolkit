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

output "subnetwork_name_sysnet" {
  description = "Automatically-generated output exported for use by later deployment groups"
  value       = module.sysnet.subnetwork_name
  sensitive   = true
}

output "subnetwork_self_link_sysnet" {
  description = "Automatically-generated output exported for use by later deployment groups"
  value       = module.sysnet.subnetwork_self_link
  sensitive   = true
}

output "network_self_link_sysnet" {
  description = "Automatically-generated output exported for use by later deployment groups"
  value       = module.sysnet.network_self_link
  sensitive   = true
}

output "startup_script_image_build_script" {
  description = "Automatically-generated output exported for use by later deployment groups"
  value       = module.image_build_script.startup_script
  sensitive   = true
}
