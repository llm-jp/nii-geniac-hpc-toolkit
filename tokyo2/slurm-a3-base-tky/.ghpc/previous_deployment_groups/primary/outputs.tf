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

output "network_name_sysnet" {
  description = "Generated output from module 'sysnet'"
  value       = module.sysnet.network_name
}

output "subnetwork_name_sysnet" {
  description = "Generated output from module 'sysnet'"
  value       = module.sysnet.subnetwork_name
}

output "network_storage_homefs" {
  description = "Generated output from module 'homefs'"
  value       = module.homefs.network_storage
}
