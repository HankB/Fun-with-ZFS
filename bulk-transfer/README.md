# Bulk Transfer

e.g. not incremental. Sending an entire filesystem or pool to another filesystem or pool.

* `bulk-xfer.sh` Perform all operations as `root`.
* `bulk-xfer-allow.sh` Minimize need to perform operations as root using `zfs allow`.

## Issues

* Avoiding the need for the `-F` flag on the `zfs recv` command.
* Avoiding putting data in the top level of the receiving filesystem (bad practice.)
* `zpool create` and `zpool allow` require `root`.

## Requirements

* Sufficient rights on the host system to create, manipulate and destroy pools. Requires `root`/`sudo`. 
* Sufficient disk space to create files to be used for filesystems.
* `tree` command to display file hierarchies.
* `zfs send` command uses `-w` flag availble in ZFS 0.8.0 and later.
* 128 MiB free disk space to create files used for pools.

## Status

`bulk-xfer.sh` Working as desired.

`bulk-xfer-allow.sh` not working. Possible result of <https://github.com/openzfs/zfs/issues/7294>

## Usage

1. CD to a convenient directory.
1. `sudo` and copy/paste the appropriate lines of the script imnto the console.
1. Or run the script within a root shell. (e.g. `sudo ./bulk-xfer`)
1. Enjoy!