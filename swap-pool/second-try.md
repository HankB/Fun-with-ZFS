# second try (attach) result

```text
hbarta@mars:~/Programming/Fun-with-ZFS/swap-pool $ ./second-try.sh 
+ set -o errexit
+ set -o nounset
++ pwd
+ starting_point=/home/hbarta/Programming/Fun-with-ZFS/swap-pool
++ whoami
+ user=hbarta
+ for i in A C
+ truncate -s 128MiB ./fakedisk_A
+ sudo zpool create -m /home/hbarta/Programming/Fun-with-ZFS/swap-pool/A A /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_A
+ sudo zfs allow -u hbarta compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot A
+ sudo chmod a+rwx A
+ for i in A C
+ truncate -s 128MiB ./fakedisk_C
+ sudo zpool create -m /home/hbarta/Programming/Fun-with-ZFS/swap-pool/C C /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_C
+ sudo zfs allow -u hbarta compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot C
+ sudo chmod a+rwx C
+ for i in B1 B2 B3
+ truncate -s 64MiB ./fakedisk_B1
+ for i in B1 B2 B3
+ truncate -s 64MiB ./fakedisk_B2
+ for i in B1 B2 B3
+ truncate -s 64MiB ./fakedisk_B3
+ sudo zpool create -m /home/hbarta/Programming/Fun-with-ZFS/swap-pool/B B raidz /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_B1 /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_B2 /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_B3
+ sudo zfs allow -u hbarta compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot B
+ sudo chmod a+rwx B
+ truncate -s 128MiB ./fakedisk_Bp
+ sudo zfs create A/a
+ sudo chown hbarta:hbarta A/a
+ cd /home/hbarta/Programming/Fun-with-ZFS/swap-pool/A/a
+ dd bs=1M seek=1 of=somefile count=0
0+0 records in
0+0 records out
0 bytes copied, 3.5315e-05 s, 0.0 kB/s
+ syncoid -r A/a B/a
INFO: Sending oldest full snapshot A/a@syncoid_mars_2024-10-08:10:42:59-GMT-05:00 (~ 12 KB) to new target filesystem:
45.3KiB 0:00:00 [2.84MiB/s] [===================================================================================================] 359%            
+ sleep 1
+ syncoid -r --keep-sync-snap B/a C/a
INFO: Sending oldest full snapshot B/a@syncoid_mars_2024-10-08:10:42:59-GMT-05:00 (~ 12 KB) to new target filesystem:
45.3KiB 0:00:00 [2.63MiB/s] [===================================================================================================] 359%            
INFO: Updating new target filesystem with incremental B/a@syncoid_mars_2024-10-08:10:42:59-GMT-05:00 ... syncoid_mars_2024-10-08:10:43:00-GMT-05:00 (~ 7 KB):
6.27KiB 0:00:00 [ 139KiB/s] [=======================================================================================>            ] 88%            
+ sleep 1
+ sudo zpool attach -w B /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_B1 /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_Bp
cannot attach /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_Bp to /home/hbarta/Programming/Fun-with-ZFS/swap-pool/fakedisk_B1: can only attach to mirrors and top-level disks
hbarta@mars:~/Programming/Fun-with-ZFS/swap-pool $ 
```