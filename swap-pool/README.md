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

### trace of working execution

```text
hbarta@mars:~/Programming/Fun-with-ZFS/swap-pool $ ./first-try.sh 
+ set -o errexit
+ set -o nounset
++ pwd
+ starting_point=/home/hbarta/Programming/Fun-with-ZFS/swap-pool
++ whoami
+ user=hbarta
+ for i in A B Bp C
+ truncate -s 64MiB ./fakedisk_A
+ sudo zpool create -m /home/hbarta/Programming/Fun-with-ZFS/swap-pool/A A /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_A
+ sudo zfs allow -u hbarta compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot A
+ sudo chmod a+rwx A
+ for i in A B Bp C
+ truncate -s 64MiB ./fakedisk_B
+ sudo zpool create -m /home/hbarta/Programming/Fun-with-ZFS/swap-pool/B B /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_B
+ sudo zfs allow -u hbarta compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot B
+ sudo chmod a+rwx B
+ for i in A B Bp C
+ truncate -s 64MiB ./fakedisk_Bp
+ sudo zpool create -m /home/hbarta/Programming/Fun-with-ZFS/swap-pool/Bp Bp /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_Bp
+ sudo zfs allow -u hbarta compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot Bp
+ sudo chmod a+rwx Bp
+ for i in A B Bp C
+ truncate -s 64MiB ./fakedisk_C
+ sudo zpool create -m /home/hbarta/Programming/Fun-with-ZFS/swap-pool/C C /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_C
+ sudo zfs allow -u hbarta compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot C
+ sudo chmod a+rwx C
+ sudo zfs create A/a
+ sudo chown hbarta:hbarta A/a
+ cd /home/hbarta/Programming/Fun-with-ZFS/swap-pool/A/a
+ dd bs=1M seek=1 of=somefile count=0
0+0 records in
0+0 records out
0 bytes copied, 0.000101944 s, 0.0 kB/s
+ syncoid -r A/a B/a
INFO: Sending oldest full snapshot A/a@syncoid_mars_2024-10-01:15:18:37-GMT-05:00 (~ 12 KB) to new target filesystem:
45.3KiB 0:00:00 [2.70MiB/s] [===================================================================================================] 359%            
+ sleep 1
+ syncoid -r B/a C/a
INFO: Sending oldest full snapshot B/a@syncoid_mars_2024-10-01:15:18:37-GMT-05:00 (~ 12 KB) to new target filesystem:
45.3KiB 0:00:00 [2.60MiB/s] [===================================================================================================] 359%            
INFO: Updating new target filesystem with incremental B/a@syncoid_mars_2024-10-01:15:18:37-GMT-05:00 ... syncoid_mars_2024-10-01:15:18:38-GMT-05:00 (~ 7 KB):
6.27KiB 0:00:00 [ 184KiB/s] [=======================================================================================>            ] 88%            
+ sleep 1
+ syncoid -r B/a Bp/a
INFO: Sending oldest full snapshot B/a@syncoid_mars_2024-10-01:15:18:38-GMT-05:00 (~ 12 KB) to new target filesystem:
45.3KiB 0:00:00 [2.68MiB/s] [===================================================================================================] 359%            
INFO: Updating new target filesystem with incremental B/a@syncoid_mars_2024-10-01:15:18:38-GMT-05:00 ... syncoid_mars_2024-10-01:15:18:40-GMT-05:00 (~ 4 KB):
1.52KiB 0:00:00 [47.8KiB/s] [=====================================>                                                              ] 38%            
+ sleep 1
+ zfs list -t snap -r A B Bp C
NAME                                              USED  AVAIL  REFER  MOUNTPOINT
A/a@syncoid_mars_2024-10-01:15:18:37-GMT-05:00      0B      -    24K  -
B/a@syncoid_mars_2024-10-01:15:18:40-GMT-05:00      0B      -    24K  -
Bp/a@syncoid_mars_2024-10-01:15:18:38-GMT-05:00     0B      -    24K  -
Bp/a@syncoid_mars_2024-10-01:15:18:40-GMT-05:00     0B      -    24K  -
C/a@syncoid_mars_2024-10-01:15:18:37-GMT-05:00     13K      -    24K  -
C/a@syncoid_mars_2024-10-01:15:18:38-GMT-05:00      0B      -    24K  -
+ syncoid -r Bp/a C/a
Sending incremental Bp/a@syncoid_mars_2024-10-01:15:18:38-GMT-05:00 ... syncoid_mars_2024-10-01:15:18:41-GMT-05:00 (~ 4 KB):
2.13KiB 0:00:00 [59.7KiB/s] [====================================================>                                               ] 53%            
+ zfs list -t snap -r C
NAME                                             USED  AVAIL  REFER  MOUNTPOINT
C/a@syncoid_mars_2024-10-01:15:18:40-GMT-05:00     0B      -    24K  -
C/a@syncoid_mars_2024-10-01:15:18:41-GMT-05:00     0B      -    24K  -
+ cd /home/hbarta/Programming/Fun-with-ZFS/swap-pool
+ for i in A B Bp C
+ sudo zpool destroy -f A
+ rm fakedisk_A
+ sudo rm -r A
+ for i in A B Bp C
+ sudo zpool destroy -f B
+ rm fakedisk_B
+ sudo rm -r B
+ for i in A B Bp C
+ sudo zpool destroy -f Bp
+ rm fakedisk_Bp
+ sudo rm -r Bp
+ for i in A B Bp C
+ sudo zpool destroy -f C
+ rm fakedisk_C
+ sudo rm -r C
hbarta@mars:~/Programming/Fun-with-ZFS/swap-pool $ 
```