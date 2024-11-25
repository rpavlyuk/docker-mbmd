#!/bin/bash

docker run --rm --name mbmd --hostname mbmd --tty --privileged \
  --volume /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --tmpfs /run \
  --tmpfs /run/lock \
  --tmpfs /tmp \
  -e "container=docker" \
  --security-opt seccomp=unconfined \
  --security-opt apparmor=unconfined \
  --cgroupns=host \
  -p 8080:8080 \
  $@ rpavlyuk/mbmd
