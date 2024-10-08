#!/usr/bin/env bash

# copied from first-try.sh as there is a some duplication for initial setup.
# The primary difference is that B will be a RAIDZ pool.

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

# Create single file pools
for i in A C
do
    # create disk file to use as physical devices
    truncate -s 128MiB ./fakedisk_${i}
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

# create RAIDZ pool
for i in B1 B2 B3 
do
    # create disk file to use as physical devices
    truncate -s 64MiB ./fakedisk_${i}
    # create pool using these disk files
done

sudo zpool create -m "$starting_point/B" B raidz \
    "$starting_point/fakedisk_B1" \
    "$starting_point/fakedisk_B2" \
    "$starting_point/fakedisk_B3"
# delegate to user some operations
sudo zfs allow -u "${USER}" \
    compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot \
    B
# Make filesystem mount points world writable/executable
sudo chmod a+rwx B 

# create file to add to pool B
truncate -s 128MiB ./fakedisk_Bp

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

# Try to add Bp to RAIDZ B
sudo zpool attach -w B "$starting_point/fakedisk_B1" "$starting_point/fakedisk_Bp"

zpool status B

# cleanup
cd "$starting_point"
for i in A C 
do
    sudo zpool destroy -f "$i"
    rm "fakedisk_${i}"
    sudo rm -r "$i"
done

sudo zpool destroy -f B
rm -rf B fakedisk_B[123p]