#!/bin/bash

docker run --rm --name mbmd --hostname mbmd --tty --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup -p 8080:8080 rpavlyuk/mbmd
