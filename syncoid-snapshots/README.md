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

## 2026-04-09 CLI testing

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

That was surprisingly easy. Now encode that in a shell script and list snapshots as we go. (`test-0.sh`)

## 2026-04-09 A partial solution

Adding an identifier to the snapshot name (`--identifier=,EXTRA/`) disambiguates the snapshots between the two destinations but introduces a different problem. The snapshots for the "other" destination are also copied. The result can be seen after two runs of `test-01.sh`:

```text
hbarta@olive:~/Programming/Fun-with-ZFS/syncoid-snapshots$ ./test-0.sh 
/sbin/syncoid version 2.2.0
(Getopt::Long::GetOptions version 2.57, Perl version 5.40.1)

Copy A to B/A
A snapshots
A@syncoid_A2C_olive_2026-04-09:20:42:58-GMT-05:00
A@syncoid_A2B_olive_2026-04-09:20:43:02-GMT-05:00
B snapshots
B/A@syncoid_A2C_olive_2026-04-09:20:42:58-GMT-05:00
B/A@syncoid_A2B_olive_2026-04-09:20:43:02-GMT-05:00

Copy A to C/A

A snapshots
A@syncoid_A2B_olive_2026-04-09:20:43:02-GMT-05:00
A@syncoid_A2C_olive_2026-04-09:20:43:03-GMT-05:00
C snapshots
C/A@syncoid_A2B_olive_2026-04-09:20:42:57-GMT-05:00
C/A@syncoid_A2B_olive_2026-04-09:20:43:02-GMT-05:00
C/A@syncoid_A2C_olive_2026-04-09:20:43:03-GMT-05:00

Copy A to B/A
A snapshots
A@syncoid_A2C_olive_2026-04-09:20:43:03-GMT-05:00
A@syncoid_A2B_olive_2026-04-09:20:43:05-GMT-05:00
B snapshots
B/A@syncoid_A2C_olive_2026-04-09:20:42:58-GMT-05:00
B/A@syncoid_A2C_olive_2026-04-09:20:43:03-GMT-05:00
B/A@syncoid_A2B_olive_2026-04-09:20:43:05-GMT-05:00
hbarta@olive:~/Programming/Fun-with-ZFS/syncoid-snapshots$ 
```

Pool `B` includes `A2C` snapshots and `C` includes `A2B` snapshots.

## 2026-04-09 A better solution

`test-1.sh` adds the option `--no-stream` which causes the intermediate snapshots not to be copied to the destination and allows `syncoid` to manage only the snapshots it creates. I suppose a consequence of this is that other (`sanoid`) snapshots will not also be copied. If that is not desired, then a script could be written to delete any "foreign" `syncoid` snapshots, though I see potential issues with this with backup streams such as `A -> B -> C` or similar.

## 2026-04-09 multiple hosts

`A` on one host and `B` and `C` on other hosts, identified as `client` and `server`. The server setup and cleanup scripts take an argument to identify which pool(s) to create.
