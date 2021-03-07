# chained and nested send/recv

Explore send/recv between three datasets where filesystem A is replicated to B/A and B is replicated to C (all on their own pools.) This involves both bulk and incremental snapshots to replicate a scenario which might be useful for daily backups.

## Motivation

Explore the following statement from <https://openzfs.github.io/openzfs-docs/man/8/zfs-recv.8.html>

```text
If an incremental stream is received, then the destination file system must already exist, and its most recent snapshot must match the incremental stream's source.
```

## Requirements

`sudo`
