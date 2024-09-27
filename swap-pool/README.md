# swap pool

Replace a pool in the middle of a backup chain such as

```text
A -> B -> C
```

without having to perform a complete backup of `B -> C`

## Motivation

`B` is a local file server and backup destination. `C` is a remote file server and mirrors much of the content on `B`. I wish to migrate the storage pool on `B` from a RAIDZ2 to a ZFS mirror. Because of the change in topology it is not possible to leverage some of my other strategies like replacing all of the drives (one at a time) with larger drives (but there may be a similar strategy to accomplish this.)

## First try

### Steps

1. Create file based pools `A`, `B`, `C` and `Bp` ("B prime.")
1. Create some files in `A`.
1. Backup `A` to `B` and `B` to `C` using syncoid.
1. Copy `B` to `Bp`. export `B` and rename `Bp` as `B` (Note that subsequent references to `B` refer to what was created as `Bp` and then populated from the orioginal `B`. Yes, It will be confusing.)
1. Backup `A` to `B`.
1. Backup `B` to `C` and check if incremental backup works as desired.


