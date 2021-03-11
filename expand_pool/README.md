# Expand Pool

This seems like a relatively straightforward operation but before screwing up an existing pool, I'll try it using test pools.

## single drive -> mirror

`mirror.sh` Create a single vdev pool and `attach` a vdev. This results in a mirror.

## Single drive, expand

`enlarge.sh` Create a single vdev pool and `add` a vdev. This results in a larger pool.
