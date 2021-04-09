#!/usr/bin/env bash

# Modified to use `sudo` where required and `zfs allow`
# so operations will be performed as a non-root user.

# probably skip these if copy/paste commands to shell
#set -o xtrace   # display commands as they are executed
set -o errexit  # bail on any errors
set -o nounset  # bail if undeclared variable

# create disk files to use as physical devices
readonly STARTING_POINT=$(pwd)
readonly POOL=fakedisk
readonly FAKEDISK="$STARTING_POINT/$POOL"
readonly MNT_POINT="${FAKEDISK}_mnt"
truncate -s 64MiB "$FAKEDISK"

# create pools using these devices
sudo zpool create -m "$MNT_POINT" "$POOL" "$FAKEDISK"
sudo chown ${USER}.${USER} "$MNT_POINT"


sudo zfs allow -u ${USER} \
    compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot \
    "$POOL"
# No attemmpt is made to minimize delegated capabilities 

zfs snap "$POOL"@created

echo send empty filesystem
zfs send -n -P "$POOL"@created

# create some filesystems
sudo zfs create "$POOL"/f
sudo zfs create "$POOL"/f/foo
sudo zfs create "$POOL"/f/baz
sudo zfs create "$POOL"/f/baz/bar
sudo chown -R ${USER}.${USER} "$MNT_POINT/f"

zfs snap -r "$POOL"@add-filesystems

echo 
echo send filesystems created
zfs send -n -P "$POOL"@add-filesystems
echo 
echo send/incremental filesystems created
zfs send -n -P -i "$POOL"@created "$POOL"@add-filesystems

# and populate with some files, random date
cd "${MNT_POINT}/f"
dd bs=1M  if=/dev/urandom of="$POOL-f" count=1 2>/dev/null
cd baz
dd bs=1M  if=/dev/urandom of="$POOL-f-baz" count=1 2>/dev/null
cd bar
dd bs=1M  if=/dev/urandom of="$POOL-f-baz-bar" count=1 2>/dev/null
tree ../..

zfs snap -r "$POOL"@populated

echo 
echo send filesystems populated
zfs send -R -n -P "$POOL"@populated
zfs send -R -n -v "$POOL"@populated
echo 
echo send/incremental filesystems populated
zfs send -n -P -i "$POOL"@add-filesystems "$POOL"@populated
zfs send -n -v -i "$POOL"@add-filesystems "$POOL"@populated

exit


# snapshot and create another file
zfs snap -r source@first
cd ../../foo
dd bs=1M seek=1 of=source-source-foo count=0
zfs snap -r source@second
ls -lR /source
zfs list -t snap -r source

echo "open shell to examine results so far (exit or <ctrl>D to proceed)"
/usr/bin/env bash

# Attempt to transfer the contents of source to destination.
# zfs send -R source@second|zfs receive -d destination # fails because filesystem destination exists

# Solution suggested by comrade meowski
# zfs send -vRw oldtank@bulk_xfer | zfs recv -eu -o mountpoint=none tank
zfs send -vRw source@second | zfs recv -eu -o mountpoint=none destination # mapped to test pools/filesystems
zfs list -r destination
zfs list -r destination -t snap

echo "open shell to examine results so far (exit or <ctrl>D to proceed)"
/usr/bin/env bash

# cleanup
cd "$starting_point"
sudo zpool destroy fakedisk
rm "$FAKEDISK"

