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
sudo chown "${user}.${user}" A/a

# and populate with some files
cd "$starting_point"/A/a
dd bs=1M seek=1 of=somefile count=0

exit

# cleanup
cd "$starting_point"
for i in A B Bp C 
do
    sudo zpool destroy -f "$i"
    rm "fakedisk_${i}"
    sudo rm -r "$i"
done
