#!/usr/bin/env bash

# probably skip these if copy/past commands to shell
set -o xtrace   # display commands as they are executed
set -o errexit  # bail on any errors
set -o nounset  # bail if undeclared variable

# create disk files to use as physical devices
starting_point=$(pwd)
truncate -s 64MiB ./fakedisk_source
truncate -s 64MiB ./fakedisk_destination

# create pools using these devices
zpool create -m "$starting_point/source" source "$starting_point/fakedisk_source"
zpool create -m "$starting_point/destination" destination "$starting_point/fakedisk_destination"

# create filesystems on source pool
zfs create source/source
zfs create source/source/foo
zfs create source/source/baz
zfs create source/source/baz/bar

echo "open shell to examine results so far (exit or <ctrl>D to proceed)"
/usr/bin/env bash

# and populate with some files
cd source/source
dd bs=1M seek=1 of=source-source count=0
cd baz
dd bs=1M seek=1 of=source-source-baz count=0
cd bar
dd bs=1M seek=1 of=source-source-baz-bar count=0
tree ../..

# snapshot and create another file
zfs snap -r source@first
cd "$starting_point/source/source/foo"
dd bs=1M seek=1 of=source-source-foo count=0
cd "$starting_point"
zfs snap -r source@second
tree source
zfs list -t snap -r source

echo "open shell to examine results so far (exit or <ctrl>D to proceed)"
/usr/bin/env bash

# Attempt to transfer the contents of source to destination.
# zfs send -R source@second|zfs receive -d destination # fails because filesystem destination exists

# Solution suggested by comrade meowski
# zfs send -vRw oldtank@bulk_xfer | zfs recv -eu -o mountpoint=none tank
zfs send -Rw source@second | zfs recv -duF -o mountpoint=none destination # mapped to test pools/filesystems
zfs list -r destination
zfs list -r destination -t snap

# set mountpoint so we can see the results in destination
# (Will be inherited by child filesystems.)
zfs set mountpoint="$starting_point/destination/source" destination/source
tree source destination

echo "open shell to examine results so far (exit or <ctrl>D to proceed)"
/usr/bin/env bash

# cleanup
cd "$starting_point"
zpool destroy -f source
zpool destroy -f destination

rm ./fakedisk_source ./fakedisk_destination
rm -r destination source
