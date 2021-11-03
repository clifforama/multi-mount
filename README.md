# Multi-Mount

## Description

This Magisk module mounts one or more filesystems (e.g. CIFS/SMB, NFS, etc.).



## Requirements

- Magisk v20.4+

- Kernel support for filesystem(s) to be mounted (hint: `grep cifs /proc/filesystems`)



## Instructions

1. Create config file(s) with filename(s) ending in `.conf` and place them in `/sdcard/.multi-mount` (i.e. the
   `.multi-mount` directory resides in the same directory that typically contains DCIM, Documents, Download, etc.). Each
   config file corresponds to a distinct mount configuration and must adhere to the following example:

        mount_options="-t cifs -o vers=2.0,username=user,password=pass"
        mount_source="//host/share"
        mount_target="/mnt/cifs-share"
        mount_max_retries=20
        mount_retry_interval=15s

2. Install module via Magisk Manager, then reboot.



## Notes

- Every distinct mount requires its own config file. E.g. to mount multiple CIFS shares, create multiple config files
  (e.g. `cifs-1.conf`, `cifs-2.conf`, etc.). Filenames are arbitrary, but must end in `.conf`.

- Config files are read at boot. Reboot for changes to take effect.

- In order to mount a network share, the network must be reachable after boot within the timeframe defined by
  `mount_max_retries` and `mount_retry_interval`.

- If mounting a CIFS share fails, try specifying a different CIFS version.

- While any filesystem supported by the kernel should work, Multi-Mount has only been tested with CIFS on [KonstaKANG's
  LineageOS 18.1 Android TV (Android 11) for Raspberry Pi 4](https://konstakang.com/devices/rpi4/LineageOS18-ATV/),
  release 11.10.
