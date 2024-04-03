#!/bin/bash

# For DCGM tests
enroot import docker://nvcr.io#nvidia/cloud-native/dcgm:3.3.0-1-ubi9

# For NCCL tests
enroot import docker://nvcr.io#nvidia/pytorch:23.10-py3
