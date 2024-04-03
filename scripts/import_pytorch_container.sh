#!/bin/bash

# Usage: bash ./import_container.sh

# This creates a file named "nvidia+pytorch+21.10-py3.sqsh", which
# uses ~18 GB of disk space. This should be run on a filesystem that
# can be seen by all worker nodes
enroot import docker://nvcr.io#nvidia/pytorch:23.10-py3
