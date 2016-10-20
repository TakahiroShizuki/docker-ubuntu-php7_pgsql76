#!/bin/sh
SHELL_PATH=$(cd "$(dirname "$0")"; pwd)
SHELL_PATH=`pwd`
DISPLAY=192.168.1.2:0
docker run -it --privileged --rm -e DISPLAY=$DISPLAY -e GIT_USER_NAME="Takahiro Shizuki" -e GIT_USER_EMAIL=shizu@futuregadget.com -v /$SHELL_PATH:/mnt/docke_dir -v /$HOME:/home/host_user -p 80:80 -p 5432:5432 local/caston
