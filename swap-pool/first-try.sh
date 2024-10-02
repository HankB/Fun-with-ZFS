#!/usr/bin/env bash

# copied from ../chained-nested/chaining.sh as there is a fair bit 
# of duplication for initial setup.

# replicate A -> B/A and B -> C
# Following initial replication, repeat the cycle uysing incremental send/recv

# Modified to use `sudo` where required and `zfs allow`
# so operations will be performed as a non-root user.

# probably skip these if copy/past commands to shell
set -o xtrace   # display commands as they are executed
set -o errexit  # bail on any errors
set -o nounset  # bail if undeclared variable

starting_point=$(pwd)
user=$(whoami)

for i in A B Bp C 
do
    # create disk file to use as physical devices
    truncate -s 64MiB ./fakedisk_${i}
    # create pool using these disk files
    sudo zpool create -m "$starting_point/${i}" "${i}" \
        "$starting_point/fakedisk_${i}"
    # delegate to user some operations
    sudo zfs allow -u "${USER}" \
        compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot \
        ${i}
    # Make filesystem mount points world writable/executable
    sudo chmod a+rwx ${i} 
done

# No attemmpt is made to minimize delegated capabilities 


# create filesystems on pool A 
#   Q: Why does this require root?
#   A: Only root cam mount a filesystem.
sudo zfs create A/a
sudo chown "${user}:${user}" A/a

# and populate with some files
cd "$starting_point"/A/a
dd bs=1M seek=1 of=somefile count=0

# populate normal backup stream
syncoid -r  A/a B/a ; sleep 1
syncoid -r --keep-sync-snap B/a C/a ; sleep 1

# clone B to Bp
syncoid -r  B/a Bp/a ; sleep 1

zfs list -t snap -r A B Bp C 

# Can we now sync Bp to C ?
syncoid -r --keep-sync-snap Bp/a C/a
# Yes! Incremental backup succeeded.
zfs list -t snap -r A Bp C 

# And repeat the "backup chain" A -> Bp -> C
syncoid -r --keep-sync-snap A/a Bp/a ; sleep 1
syncoid -r Bp/a C/a ; sleep 1

# cleanup
cd "$starting_point"
for i in A B Bp C 
do
    sudo zpool destroy -f "$i"
    rm "fakedisk_${i}"
    sudo rm -r "$i"
done
