# syncoid snapshots

## 2026-04-09 Motivation

Using `syncoid` for backups, I find I am running into warnings and errors typified by:

```text
could not find any snapshots to destroy; check snapshot names.
WARNING:   zfs destroy 'pool/data/set'@syncoid_host_timestamp;  zfs destroy 'pool/data/set'@syncoid_host_timestamp failed: 256 at /sbin/syncoid line 1380.
```

and

```text
CRITICAL ERROR: Target pool/data/set exists but has no snapshots matching with pool/data/set!
```

The former seems harmless but mildly concerning. The latter results in that particular dataset not being backed up. The purpose of this exercise is to determine what operations provoke these situations and how to see that they do not happen again.

## 2026-04-09 Plan

It is possible that different hosts pulling from the same pool may be interfering with each others' snapshots. The initial effort will be to explore that possibility. Three file based pools will be created `A`, `B` and `C` and backups will be run from `A` to `B` andf `A` to `C`. Pool creation will be copied from `../chained-nested/chaining.sh` and put in `setup.sh` and cleanup, similarly copied, will be in `cleanup.sh`. It is anticipated that sevreral backup scenarios will be tested following setup and before the need to cleanup.

## CLI testing

Just try out some commands:

```text
hbarta@olive:~/Programming/Fun-with-ZFS/syncoid-snapshots$ syncoid A B/A
INFO: Sending oldest full snapshot A@syncoid_olive_2026-04-09:16:32:41-GMT-05:00 (~ 12 KB) to new target filesystem:
45.8KiB 0:00:00 [2.15MiB/s] [============================================================] 363%            
hbarta@olive:~/Programming/Fun-with-ZFS/syncoid-snapshots$ syncoid A C/A
INFO: Sending oldest full snapshot A@syncoid_olive_2026-04-09:16:32:41-GMT-05:00 (~ 12 KB) to new target filesystem:
45.8KiB 0:00:00 [2.28MiB/s] [============================================================] 363%            
INFO: Updating new target filesystem with incremental A@syncoid_olive_2026-04-09:16:32:41-GMT-05:00 ... syncoid_olive_2026-04-09:16:32:49-GMT-05:00 (~ 4 KB):
1.52KiB 0:00:00 [38.4KiB/s] [=====================>                                      ]  38%            
hbarta@olive:~/Programming/Fun-with-ZFS/syncoid-snapshots$ syncoid A B/A

CRITICAL ERROR: Target B/A exists but has no snapshots matching with A!
                Replication to target would require destroying existing
                target. Cowardly refusing to destroy your existing target.

          NOTE: Target B/A dataset is < 64MB used - did you mistakenly run
                `zfs create B/A` on the target? ZFS initial
                replication must be to a NON EXISTENT DATASET, which will
                then be CREATED BY the initial replication process.

hbarta@olive:~/Programming/Fun-with-ZFS/syncoid-snapshots$ 
```

That was surprisingly easy. Now encode that in a shell script and list snapshots as we go.