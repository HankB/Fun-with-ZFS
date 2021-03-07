#!/usr/bin/env bash

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

for i in A B C 
do
    # create disk file to use as physical devices
    truncate -s 64MiB ./fakedisk_${i}
    # create pool using these disk files
    sudo zpool create -m "$starting_point/${i}" "${i}" \
        "$starting_point/fakedisk_${i}"
    # delegate to user some operations
    sudo zfs allow -u ${USER} \
        compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot \
        ${i}
    # Make filesystem mount points world writable/executable
    sudo chmod a+rwx ${i} 
done

# No attemmpt is made to minimize delegated capabilities 


# create filesystems on pool A (Why does this requiire root?)
sudo zfs create A/a
sudo chown "${user}.${user}" A/a

# and populate with some files
cd "$starting_point"/A/a
dd bs=1M seek=1 of=somefile count=0

# snapshot 
zfs snap -r A/a@snap-a.1
zfs list -t snap -r A

# Create a filesystem on B
cd "$starting_point"
sudo zfs create B/b
sudo chown "${user}.${user}" B/b

# Send A to (nested) B
zfs send -R  A/a@snap-a.1 | zfs recv -o mountpoint=none B/b/a

# Now send B/b to C
zfs snap -r B/b@snap-b.1
zfs send -R  B/b@snap-b.1 | zfs recv -o mountpoint=none C/c
echo "before incremental send from A"
zfs list -t snap -r B

# Now create a new snapshot on A and send incremental update to B
zfs snap -r A/a@snap-a.2
zfs send -R -i A/a@snap-a.1  A/a@snap-a.2 | zfs recv  B/b/a
echo "after incremental send from A"
zfs list -t snap -r B

# Send incremental update from B to C
zfs snap -r B/b@snap-b.2
zfs send -R -i  B/b@snap-b.1 B/b@snap-b.2 | zfs recv C/c
zfs list -t snap -r C

# Once more around the loop
zfs snap -r A/a@snap-a.3
zfs send -R -i A/a@snap-a.2  A/a@snap-a.3 | zfs recv  B/b/a
zfs list -t snap -r B

zfs snap -r B/b@snap-b.3
zfs send -R -i  B/b@snap-b.2 B/b@snap-b.3 | zfs recv C/c
zfs list -t snap -r C

# cleanup
cd "$starting_point"
for i in A B C 
do
    sudo zpool destroy -f "$i"
    rm "fakedisk_${i}"
    sudo rm -r "$i"
done
