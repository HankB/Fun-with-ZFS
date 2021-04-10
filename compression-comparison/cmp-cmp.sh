#!/usr/bin/env bash

# probably skip these if copy/past commands to shell
#set -o xtrace   # display commands as they are executed
set -o errexit  # bail on any errors
set -o nounset  # bail if undeclared variable

# Check args
if ! [[ $# = 2 || $# = 3 ]]
then
cat <<EOF
xcmp-cmp.sh ARG1 ARG2 [ARG3]

* ARG1 - required - compression algorithm. Must conform to one that can
         be specified on the zfs create command line.
* ARG2 - required - source filesystem.
* ARG3 - optional - destination filesystem. If not specified "_test" will 
         be appended to the source filesystem name and used for the test filesystem.
EOF
exit
fi

# useful nales/unpack args
readonly COMPRESSION=$1
readonly SOURCE=$2
if [[ $# = 2 ]]
then
    readonly DESTINATION=${SOURCE}_test
else
    readonly DESTINATION=$3
fi

echo $COMPRESSION $SOURCE $DESTINATION

# Create the destination filesystem
sudo zfs create -o canmount=off -o mountpoint=none \
    -o compression="$COMPRESSION" "$DESTINATION"

# snapshot the pool
readonly SNAPSHOT=${SOURCE}@test-$(date +%Y-%m-%d-%H:%M:%S)
zfs snap "${SNAPSHOT}"

# copy the dat
sudo zfs send "${SNAPSHOT}" | mbuffer | sudo zfs receive -F "$DESTINATION"

# mbuffer outputs some statistics including size, elapsed time
# and bandwidth (along with buffer usage.)

zfs get compressratio "$SOURCE" "$DESTINATION"

echo "cleanup: sudo zfs destroy -r \"$DESTINATION\""