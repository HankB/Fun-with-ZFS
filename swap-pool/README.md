# swap pool

Replace a pool in the middle of a backup chain such as

```text
A -> B -> C
```

without having to perform a complete backup of `B -> C`

## Motivation

`B` is a local file server and backup destination. `C` is a remote file server and mirrors much of the content on `B`. I wish to migrate the storage pool on `B` from a RAIDZ2 to a ZFS mirror. Because of the change in topology it is not possible to leverage some of my other strategies like replacing all of the drives (one at a time) with larger drives (but there may be a similar strategy to accomplish this.)

## Status

Working. First try using `syncoid` worked as desired. Note that since no flags were provided to `syncoid` to manage snapshot naming, it was necessary to pause following each invocation to prevent duplication of snapshot names and subsequent error exit.

## First try

### Steps

1. Create file based pools `A`, `B`, `C` and `Bp` ("B prime.")
1. Create some files in `A`.
1. Backup `A` to `B` and `B` to `C` using syncoid.
1. Copy `B` to `Bp`. export `B` and rename `Bp` as `B` (Note that subsequent references to `B` refer to what was created as `Bp` and then populated from the orioginal `B`. Yes, It will be confusing.)
1. Backup `A` to `B`.
1. Backup `B` to `C` and check if incremental backup works as desired.

Working example does w/out the rename of pool `Bp` and just performs the send, demonstrating that since it includes the snapshot from the copy from `B` to `C`, the send is incremental (and this is the desired result.)

### Repeat complete backup chain A -> Bp -> C

[successful results](./first-try.md)

## 2024-10-08 second try

Another strategy might provide a smoother transition. The "first try" strategy requires that the pool be exported and the new pool be imported. This presents potential issues with mounts and processes that use the pool such as NFS and Docker containers. It seems likely that it may not be possible to export the pool due to open file handles, requiring booting to a live USB environment.

Another strategy wouold be to add a new drive as a mirror to the existing vdev. Once resilvering is complete, remove the old vdev (consisting of a RAIDZ2) and the transition is complete without the need to export/import/rename to swap to the new configuration. `second-try.sh` will be an exploration to try that out.

No joy. As explained in the man page 

```text
cannot attach /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_Bp to /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_B1: can only attach to mirrors and top-level disks
```