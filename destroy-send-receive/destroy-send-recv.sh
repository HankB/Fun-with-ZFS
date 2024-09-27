#!/usr/bin/env bash

# Modified to use `sudo` where required and `zfs allow`
# so operations will be performed as a non-root user.

# probably skip these if copy/past commands to shell
set -o xtrace   # display commands as they are executed
set -o errexit  # bail on any errors
set -o nounset  # bail if undeclared variable

# create disk files to use as physical devices
starting_point=$(pwd)
truncate -s 64MiB ./fakedisk_local
truncate -s 64MiB ./fakedisk_remote

# create pools using these devices
sudo zpool create -m "$starting_point"/local local  \
    "$starting_point"/fakedisk_local
sudo zpool create -m "$starting_point"/remote remote \
    "$starting_point"/fakedisk_remote
sudo zfs allow -u ${USER} \
    compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot \
    local
sudo zfs allow -u ${USER} \
    compression,create,destroy,hold,mount,mountpoint,receive,send,snapshot \
    remote
# No attemmpt is made to minimize delegated capabilities 

# create filesystems on local pool 
################## Fails - see README #####################
sudo zfs create local/local
sudo zfs create local/local/foo
sudo zfs create local/local/baz
sudo zfs create local/local/baz/bar

# Make filesystem and direcories owned by user running test
sudo chown -R $USER.$USER local remote

echo "open shell to examine results so far (exit or <ctrl>D to proceed)"
/usr/bin/env bash

# and populate with some files
cd "$starting_point"/local/local
dd bs=1M seek=1 of=local-local count=0
cd baz
dd bs=1M seek=1 of=local-local-baz count=0
cd bar
dd bs=1M seek=1 of=local-local-baz-bar count=0
cd ../../foo
dd bs=1M seek=1 of=local-local-foo count=0
# first snapshot
zfs snap -r local@01
cd "$starting_point"
ls -lR local
zfs list -t snap -r local

echo "open shell to examine results so far (exit or <ctrl>D to proceed)"
/usr/bin/env bash

# Attempt to transfer the contents of local to remote.
# zfs send -R local@second|zfs receive -d remote # fails because filesystem remote exists

# "malware-encrypt" files
# find local -type f -exec gzip {} \;

#zfs send -vRw local@second | zfs recv -eu -o mountpoint=none remote # mapped to test pools/filesystems
# Pull first backup.
zfs recv -eu -o mountpoint=none remote | ssh localhost zfs send -vRw local@01
zfs list -r remote
zfs list -r remote -t snap

# set mountpoint so we can see the results in remote
# (Will be inherited by child filesystems.)
zfs set mountpoint=/remote/local remote/local
tree "$starting_point"/local "$starting_point"/remote

echo "open shell to examine results so far (exit or <ctrl>D to proceed)"
/usr/bin/env bash

# cleanup
cd "$starting_point"
sudo zpool destroy -f local
sudo zpool destroy -f remote

rm -rf ./fakedisk_local ./fakedisk_remote local remote
