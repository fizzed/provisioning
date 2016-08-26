#!/bin/sh

if type apt-get; then
  apt-get update
  apt-get -y install ecryptfs-utils
fi

