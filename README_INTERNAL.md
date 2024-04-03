# Blueprint for Slurm clusters with A3 compute nodes

## Minimum Toolkit release

These blueprints are compatible with [Cloud HPC Toolkit][hpctk] release 1.28.0
and above.

[hpctk]: https://github.com/GoogleCloudPlatform/hpc-toolkit

## Notes

The A3 blueprints provision 2 sets of infrastructure

- Base
  - VPCs and Filestore for `/home/` directory
- Cluster
  - Custom Slurm image based upon image including patched TCPx kernel
  - Slurm cluster itself

The blueprint must be used with appropriate settings for a3\_reservation\_name and
a3\_maintenance\_interval. In particular, a3\_maintenance\_interval must be
the empty string ("") in most ("General Fleet") projects and "PERIODIC" in
projects that have maintenance preview APIs enabled. _It is the responsibility
of Google staff to identify the environment for the customer and recommend the
appropriate value_!

Please refer to the [Google doc][google-doc] for further details regarding
provisioning. It can be shared with customers.

[google-doc]: https://docs.google.com/document/d/104f-6WRQwbTci42o4Q6IVZg7Uhq4PPKso4VNsCl0FTM/edit?tab=t.0#heading=h.xzptrog8pyxf
