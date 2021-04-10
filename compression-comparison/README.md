# Compression Comparison

The underlying question is whether `zstd` compression is improved enough over `lz4` (or whatever is in use) to warrant migration. Performance is measured in two dimensions, compression ratio and benchmark performance. The compression ratio is reported by ZFS and the benchmarks are beyond the scope of this effort since they are so usage dependant. The single metric measured here is to record the time needed to populate the test filesystem.

## Usage

Source filesystem, compession algorithm and (optionally) destination filesystem are determined by positional arguments.

cmp-cmp.sh ARG1 ARG2 [ARG3]

* ARG1 - required - compression algorithm. Must conform to one that can be specified on the `zfs create` command line.
* ARG2 - required - source filesystem.
* ARG3 - optional - destination filesystem. If not specified "_test" will be appended to the source filesystem name and used for the test filesystem.

Other settings for filesystem creation will be set to what is used for [Debian Buster Root on ZFS](https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/Debian%20Buster%20Root%20on%20ZFS.html#step-2-disk-formatting) and repeated below.

```text
zfs create -o canmount=off -o mountpoint=none rpool/ROOT
```

And in the case of this script canmount is now left on.

```text
zfs create  -o mountpoint=/mnt/poolname/filesystem \
    -o compression=ARG1 [ARG3|ARG2_test]
```

## Requirements

* `sudo`
* a pool created with mountable options

## Cleanup

This is a little problematic. The script can emit the command which can be used to destroy the filesystem. That may leave behind the directories where it was mounted and thoe locations may depend on properties with which the pool was created and are beyond this project.

## Status

First attempt working with no cleanup.

* Perhaps look for user supplied `benchmark.sh` to run benchmarks automatically.
* Probably need to mount destination dataset in order to run benchmarks.
* Could output a script (or echo a command) that would perform cleanup.
