#!/bin/bash
# Copyright (c) 2023, NVIDIA CORPORATION.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#SBATCH --job-name=dcgmi-diag
#SBATCH --exclusive
#SBATCH --gpus-per-node=8
#SBATCH --time=1:00:00

set -x

# This is a Data Center GPU Manager container. This command will run GPU diagnostics.
# This script should not be called manually. It should only be called by cluster_validation.sh
srun -l \
  --container-image=./nvidia+cloud-native+dcgm+3.3.0-1-ubi9.sqsh \
  --container-mounts="/var/tmp:/var/tmp" \
  bash -c "dcgmi diag -r 3"
