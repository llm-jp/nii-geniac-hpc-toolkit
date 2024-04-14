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
    prefix = "slurm-a3-cluster/slurm-a3-cluster/build_script"
  }
}

module "sysnet" {
  source          = "./modules/embedded/modules/network/pre-existing-vpc"
  network_name    = var.network_name_system
  project_id      = var.project_id
  region          = var.region
  subnetwork_name = var.subnetwork_name_system
}

module "image_build_script" {
  source                      = "./modules/embedded/modules/scripts/startup-script"
  configure_ssh_host_patterns = ["10.0.0.*", "10.1.0.*", "10.2.0.*", "10.3.0.*", "${var.slurm_cluster_name}*"]
  deployment_name             = var.deployment_name
  install_ansible             = true
  labels                      = var.labels
  project_id                  = var.project_id
  region                      = var.region
  runners = [{
    content     = "#!/bin/bash\nset -e -o pipefail\nrm -f /etc/apt/sources.list.d/kubernetes.list\napt-get update --allow-releaseinfo-change\n"
    destination = "workaround_apt_change.sh"
    type        = "shell"
    }, {
    content     = "#!/bin/bash\n# many extra services are being started via /etc/rc.local; disable\n# them on future boots of image\necho -e '#!/bin/bash\\n/usr/bin/nvidia-persistenced --user root\\nexit 0' > /etc/rc.local\n# disable jupyter and notebooks-collection-agent services\nsystemctl stop jupyter.service notebooks-collection-agent.service\nsystemctl disable jupyter.service notebooks-collection-agent.service\n"
    destination = "disable_dlvm_builtin_services.sh"
    type        = "shell"
    }, {
    content     = "#!/bin/bash\n# apt-get update is run above; add here if needed\napt-get install --assume-yes libpmix-dev\n"
    destination = "install_pmix.sh"
    type        = "shell"
    }, {
    content     = "{\n  \"reboot\": false,\n  \"slurm_version\": \"23.02.7\",\n  \"install_cuda\": false,\n  \"nvidia_version\": \"latest\",\n  \"install_ompi\": true,\n  \"install_lustre\": true,\n  \"install_gcsfuse\": true,\n  \"monitoring_agent\": \"cloud-ops\"\n}\n"
    destination = "/var/tmp/slurm_vars.json"
    type        = "data"
    }, {
    content     = "#!/bin/bash\nset -e -o pipefail\nansible-galaxy role install googlecloudplatform.google_cloud_ops_agents\nansible-pull \\\n    -U https://github.com/GoogleCloudPlatform/slurm-gcp -C 5.10.4 \\\n    -i localhost, --limit localhost --connection=local \\\n    -e @/var/tmp/slurm_vars.json \\\n    ansible/playbook.yml\n"
    destination = "install_slurm.sh"
    type        = "shell"
    }, {
    content     = "* - memlock unlimited\n* - nproc unlimited\n* - stack unlimited\n* - nofile 1048576\n* - cpu unlimited\n* - rtprio unlimited\n"
    destination = "/etc/security/limits.d/99-unlimited.conf"
    type        = "data"
    }, {
    content     = "[Service]\nLimitNOFILE=infinity\n"
    destination = "/etc/systemd/system/slurmd.service.d/file_ulimit.conf"
    type        = "data"
    }, {
    content     = "[Unit]\nDescription=Delay A3 boot until all network interfaces are routable\nAfter=network-online.target\nWants=network-online.target\nBefore=google-startup-scripts.service\n\n[Service]\nExecCondition=/bin/bash -c '/usr/bin/curl -s -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/machine-type | grep -q \"/a3-highgpu-8g$\"'\nExecStart=/usr/lib/systemd/systemd-networkd-wait-online -i enp6s0 -i enp12s0 -i enp134s0 -i enp140s0 -o routable --timeout=120\nExecStartPost=/bin/sleep 60\n\n[Install]\nWantedBy=multi-user.target\n"
    destination = "/etc/systemd/system/delay-a3.service"
    type        = "data"
    }, {
    content     = "#!/bin/bash\nset -e -o pipefail\n# allow any user to use Docker\nDOCKER_SOCKET_DROPIN_DIR=\"/etc/systemd/system/docker.socket.d\"\nif [ ! -d \"$${DOCKER_SOCKET_DROPIN_DIR}\" ]; then\n    mkdir \"$${DOCKER_SOCKET_DROPIN_DIR}\"\nfi\nDOCKER_SOCKET_DROPIN_FILE=\"group-override.conf\"\nif [ ! -f \"$${DOCKER_SOCKET_DROPIN_DIR}/$${DOCKER_SOCKET_DROPIN_FILE}\" ]; then\n    # indentation matters in EOT below; do not blindly edit!\n    cat <<EOT > \"$${DOCKER_SOCKET_DROPIN_DIR}/$${DOCKER_SOCKET_DROPIN_FILE}\"\n[Socket]\nSocketMode=0666\nEOT\nfi\n"
    destination = "configure_docker.sh"
    type        = "shell"
    }, {
    content     = "#!/bin/bash\nset -e -o pipefail\n### Setting up Enroot\nif ! dpkg -l enroot &>/dev/null; then\n    arch=$(dpkg --print-architecture)\n    curl -fSsL -O https://github.com/NVIDIA/enroot/releases/download/v3.4.1/enroot_3.4.1-1_$${arch}.deb\n    curl -fSsL -O https://github.com/NVIDIA/enroot/releases/download/v3.4.1/enroot+caps_3.4.1-1_$${arch}.deb # optional\n    apt-get update\n    apt-get install --assume-yes ./*.deb\n    rm enroot*.deb\nfi\n# configure enroot\n# use single quotes around EOT to avoid shell interpolation\ncat <<'EOT' > /etc/enroot/enroot.conf\nENROOT_RUNTIME_PATH    /mnt/localssd/$${UID}/enroot/runtime\nENROOT_CACHE_PATH      /mnt/localssd/$${UID}/enroot/cache\nENROOT_DATA_PATH       /mnt/localssd/$${UID}/enroot/data\nEOT\n### Install Pyxis\nif [ ! -f \"/usr/local/lib/slurm/spank_pyxis.so\" ]; then\n    git clone --depth 1 https://github.com/NVIDIA/pyxis.git\n    cd pyxis && make install && cd -\n    rm -rf pyxis\n    echo \"required /usr/local/lib/slurm/spank_pyxis.so\" > /etc/slurm/plugstack.conf\nfi\n"
    destination = "install_enroot_pyxis.sh"
    type        = "shell"
    }, {
    content     = "#!/bin/bash\napt-get update\napt-get install mdadm --no-install-recommends --assume-yes\n"
    destination = "install_mdadm.sh"
    type        = "shell"
    }, {
    content     = "#!/bin/bash\nset -e -o pipefail\n\nRAID_DEVICE=/dev/md0\nDST_MNT=/mnt/localssd\nDISK_LABEL=LOCALSSD\nOPTIONS=discard,defaults\n\n# if mount is successful, do nothing\nif mount --source LABEL=\"$DISK_LABEL\" --target=\"$DST_MNT\" -o \"$OPTIONS\"; then\n        exit 0\nfi\n\n# Create new RAID, format ext4 and mount\n# TODO: handle case of zero or 1 local SSD disk\n# TODO: handle case when /dev/md0 exists but was not mountable for\n# some reason\nDEVICES=`nvme list | grep nvme_ | grep -v nvme_card-pd | awk '{print $1}' | paste -sd ' '`\nNB_DEVICES=`nvme list | grep nvme_ | grep -v nvme_card-pd | awk '{print $1}' | wc -l`\nmdadm --create \"$RAID_DEVICE\" --level=0 --raid-devices=$NB_DEVICES $DEVICES\nmkfs.ext4 -F \"$RAID_DEVICE\"\ntune2fs \"$RAID_DEVICE\" -r 131072\ne2label \"$RAID_DEVICE\" \"$DISK_LABEL\"\nmkdir -p \"$DST_MNT\"\nmount --source LABEL=\"$DISK_LABEL\" --target=\"$DST_MNT\" -o \"$OPTIONS\"\nchmod 1777 \"$DST_MNT\"\n"
    destination = "/usr/local/ghpc/mount_localssd.sh"
    type        = "data"
    }, {
    content     = "[Unit]\nDescription=Assemble local SSDs as software RAID; then format and mount\n\n[Service]\nExecCondition=bash -c '/usr/bin/curl -s -H \"Metadata-Flavor: Google\" http://metadata.google.internal/computeMetadata/v1/instance/machine-type | grep -q \"/a3-highgpu-8g$\"'\nExecStart=/bin/bash /usr/local/ghpc/mount_localssd.sh\n\n[Install]\nWantedBy=local-fs.target\n"
    destination = "/etc/systemd/system/mount-local-ssd.service"
    type        = "data"
    }, {
    content     = "#!/bin/bash\nset -e -o pipefail\n# workaround b/309016676 (systemd-resolved restarts 4 times causing DNS\n# resolution failures during google-startup-scripts.service)\nsystemctl daemon-reload\nsystemctl enable delay-a3.service\nsystemctl enable mount-local-ssd.service\n"
    destination = "systemctl_services.sh"
    type        = "shell"
    }, {
    content     = "#!/bin/bash\n# THIS RUNNER MUST BE THE LAST RUNNER BECAUSE IT WILL BREAK GSUTIL IN\n# PARENT SCRIPT OF STARTUP-SCRIPT MODULE\nset -e -o pipefail\n# Remove original DLVM gcloud, lxds install due to conflict with snapd and NFS\nsnap remove google-cloud-cli lxd\n# Install key and google-cloud-cli from apt repo\nGCLOUD_APT_SOURCE=\"/etc/apt/sources.list.d/google-cloud-sdk.list\"\nif [ ! -f \"$${GCLOUD_APT_SOURCE}\" ]; then\n    # indentation matters in EOT below; do not blindly edit!\n    cat <<EOT > \"$${GCLOUD_APT_SOURCE}\"\ndeb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt cloud-sdk main\nEOT\nfi\ncurl -o /usr/share/keyrings/cloud.google.asc https://packages.cloud.google.com/apt/doc/apt-key.gpg\napt-get update\napt-get install --assume-yes google-cloud-cli\n# Clean up the bash exceutable hash for subsequent steps using gsutil\nhash -r\n"
    destination = "remove_snap_gcloud.sh"
    type        = "shell"
  }]
}
