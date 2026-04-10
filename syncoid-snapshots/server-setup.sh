#!/usr/bin/env bash

# Try out different patterns that backup A to B and C

# probably skip these if copy/past commands to shell
set -o xtrace   # display commands as they are executed
set -o errexit  # bail on any errors
set -o nounset  # bail if undeclared variable

starting_point=$(pwd)
user=$(whoami)

for i in $@
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
