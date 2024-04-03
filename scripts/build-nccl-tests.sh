#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --partition=a3
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=8

# Usage: sbatch build-nccl-tests.sh

set -x

CONTAINER_IMAGE=./nvidia+pytorch+23.10-py3.sqsh

# Install nccl-tests using openmpi from within pytorch container
srun --container-mounts="$PWD:/nccl" \
     --container-image=${CONTAINER_IMAGE} \
     --container-name="nccl" \
     bash -c "
     export LD_LIBRARY_PATH=/var/lib/tcpx/lib64:$LD_LIBRARY_PATH &&
       cd /nccl &&
       git clone https://github.com/NVIDIA/nccl-tests.git &&
       cd /nccl/nccl-tests/ &&
       MPI=1 CC=mpicc CXX=mpicxx make -j
    "
