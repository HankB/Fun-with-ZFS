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

# create a filesystem
sudo zfs create "$POOL"/f
sudo chown ${USER}.${USER} "$MNT_POINT"/f

zfs snap -r "$POOL"@created

echo send empty filesystem
zfs send -n -P "$POOL"@created

# populate with some files, random data
cd "${MNT_POINT}/f"
pwd
dd bs=1M  if=/dev/urandom of="$POOL-f-1" count=1 
dd bs=1M  if=/dev/urandom of="$POOL-f-2" count=1 2>/dev/null
dd bs=1M  if=/dev/urandom of="$POOL-f-3" count=1 2>/dev/null
ls -l

zfs snap -r "$POOL"@populated

echo 
echo send filesystems populated
zfs send -R -n -P "$POOL"@populated
echo 
echo send/incremental filesystems populated
zfs send -R -n -P -i "$POOL"@created "$POOL"@populated

# hard link one file

echo
echo hard linking  "$POOL-f-1" "$POOL-f-2"
ln -f "$POOL-f-1" "$POOL-f-2"
ls -l 
zfs snap -r "$POOL"@hard-link
echo send filesystems populated
zfs send -R -n -P "$POOL"@hard-link
echo 
echo send/incremental filesystems hard-link
zfs send -R -n -P -i "$POOL"@created "$POOL"@hard-link
echo send/incremental filesystems populated to hard-link
zfs send -R -n -P -i "$POOL"@populated "$POOL"@hard-link

# move file 
echo 
echo "moving a file to a subdir"
mkdir sub
mv "$POOL-f-3" sub/
zfs snap -r "$POOL"@move
echo send filesystems move
zfs send -R -n -P "$POOL"@move
echo 
echo send/incremental filesystems move
zfs send -R -n -P -i "$POOL"@created "$POOL"@move
echo 
echo send/incremental filesystems hard-link to move
zfs send -R -n -P -i "$POOL"@hard-link "$POOL"@move

echo "open shell to examine results so far (exit or <ctrl>D to proceed)"
/usr/bin/env bash

# cleanup
cd "$STARTING_POINT"
sudo zpool destroy "$POOL"
sudo rm -rf "$FAKEDISK" "$MNT_POINT"

