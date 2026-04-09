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
