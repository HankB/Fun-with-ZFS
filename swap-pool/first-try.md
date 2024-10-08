# First try results

Working as desired as of 2024-10-02.

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
0 bytes copied, 0.000128963 s, 0.0 kB/s
+ syncoid -r A/a B/a
INFO: Sending oldest full snapshot A/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00 (~ 12 KB) to new target filesystem:
45.3KiB 0:00:00 [2.82MiB/s] [===================================================================================================] 359%            
+ sleep 1
+ syncoid -r --keep-sync-snap B/a C/a
INFO: Sending oldest full snapshot B/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00 (~ 12 KB) to new target filesystem:
45.3KiB 0:00:00 [2.76MiB/s] [===================================================================================================] 359%            
INFO: Updating new target filesystem with incremental B/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00 ... syncoid_mars_2024-10-02:10:47:42-GMT-05:00 (~ 7 KB):
6.27KiB 0:00:00 [ 191KiB/s] [=======================================================================================>            ] 88%            
+ sleep 1
+ syncoid -r B/a Bp/a
INFO: Sending oldest full snapshot B/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00 (~ 12 KB) to new target filesystem:
45.3KiB 0:00:00 [2.73MiB/s] [===================================================================================================] 359%            
INFO: Updating new target filesystem with incremental B/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00 ... syncoid_mars_2024-10-02:10:47:43-GMT-05:00 (~ 7 KB):
6.88KiB 0:00:00 [ 198KiB/s] [========================================================================================>           ] 89%            
+ sleep 1
+ zfs list -t snap -r A B Bp C
NAME                                              USED  AVAIL  REFER  MOUNTPOINT
A/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00      0B      -    24K  -
B/a@syncoid_mars_2024-10-02:10:47:43-GMT-05:00      0B      -    24K  -
Bp/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00    13K      -    24K  -
Bp/a@syncoid_mars_2024-10-02:10:47:42-GMT-05:00     0B      -    24K  -
Bp/a@syncoid_mars_2024-10-02:10:47:43-GMT-05:00     0B      -    24K  -
C/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00     13K      -    24K  -
C/a@syncoid_mars_2024-10-02:10:47:42-GMT-05:00      0B      -    24K  -
+ syncoid -r --keep-sync-snap Bp/a C/a
Sending incremental Bp/a@syncoid_mars_2024-10-02:10:47:42-GMT-05:00 ... syncoid_mars_2024-10-02:10:47:44-GMT-05:00 (~ 4 KB):
2.13KiB 0:00:00 [62.6KiB/s] [====================================================>                                               ] 53%            
+ zfs list -t snap -r A Bp C
NAME                                              USED  AVAIL  REFER  MOUNTPOINT
A/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00      0B      -    24K  -
Bp/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00    13K      -    24K  -
Bp/a@syncoid_mars_2024-10-02:10:47:42-GMT-05:00     0B      -    24K  -
Bp/a@syncoid_mars_2024-10-02:10:47:43-GMT-05:00     0B      -    24K  -
Bp/a@syncoid_mars_2024-10-02:10:47:44-GMT-05:00     0B      -    24K  -
C/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00     13K      -    24K  -
C/a@syncoid_mars_2024-10-02:10:47:42-GMT-05:00      0B      -    24K  -
C/a@syncoid_mars_2024-10-02:10:47:43-GMT-05:00      0B      -    24K  -
C/a@syncoid_mars_2024-10-02:10:47:44-GMT-05:00      0B      -    24K  -
+ syncoid -r --keep-sync-snap A/a Bp/a
Sending incremental A/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00 ... syncoid_mars_2024-10-02:10:47:45-GMT-05:00 (~ 4 KB):
1.52KiB 0:00:00 [50.0KiB/s] [=====================================>                                                              ] 38%            
+ sleep 1
+ syncoid -r Bp/a C/a
Sending incremental Bp/a@syncoid_mars_2024-10-02:10:47:40-GMT-05:00 ... syncoid_mars_2024-10-02:10:47:46-GMT-05:00 (~ 4 KB):
2.13KiB 0:00:00 [64.3KiB/s] [====================================================>                                               ] 53%            
could not find any snapshots to destroy; check snapshot names.
could not find any snapshots to destroy; check snapshot names.
could not find any snapshots to destroy; check snapshot names.
WARNING:  sudo zfs destroy 'C/a'@syncoid_mars_2024-10-02:10:47:43-GMT-05:00; sudo zfs destroy 'C/a'@syncoid_mars_2024-10-02:10:47:40-GMT-05:00; sudo zfs destroy 'C/a'@syncoid_mars_2024-10-02:10:47:44-GMT-05:00; sudo zfs destroy 'C/a'@syncoid_mars_2024-10-02:10:47:42-GMT-05:00 failed: 256 at /usr/sbin/syncoid line 1380.
+ sleep 1
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

No joy. Need to think about this some more and perhaps try a different strategy. Or perhaps `--keep-sync-snap` may help. Yes, it does.
