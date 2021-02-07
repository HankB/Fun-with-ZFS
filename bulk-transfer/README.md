# Bulk Transfer

e.g. not incremental. Sending an entire filesystem or pool to another filesystem or pool.

## Issues

* Avoiding the need for the `-F` flag on the `zfs recv` command.
* Avoiding putting data in the top level of the receiving filesystem (bad practice.)

## Requirements

* Sufficient rights on the host system to create, manipulate and destroy filesystems. May require `root`/`sudo`.
* Sufficient disk space to create files to be used for filesystems.

## Status

Script developed, needs cleanup and add to the project.