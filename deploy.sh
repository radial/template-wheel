#!/bin/bash
# This script is meant for testing and procedural archival purposes. It is not
# a standard part of the 'Wheel' repository.
# This script assumes that 'build.sh' has been run.

# First we run our logs axle container
sudo docker run \
    --name logs \
    -v /log \
    radial/axle-base

# we can build/run our hub dynamically (make sure to disable static hub build in
# 'build.sh' if using) which pulls the Wheel configuration and/or Supervisor
# config for whatever repo we choose.
# (examples of the method are shown here using the default locations for each).

# sudo docker run \
    # -e "WHEEL_REPO=https://github.com/radial/tempalte-wheel.git" \
    # -e "WHEEL_BRANCH=config" \
    # -e "SUPERVISOR_REPO=https://github.com/radial/config-supervisor.git" \
    # -e "SUPERVISOR_BRANCH=master" \
    # --name cat-hub \
    # -v /config -v /data -v /log \
    # radial/hub-base

# This runs a hub container that is built from Dockerfile, not built dynamically
sudo docker run \
    --name cat-hub \
    --volumes-from logs \
    --detach \
    i-cat-hub

# run spoke container
sudo docker run \
    --name cat \
    --volumes-from cat-hub \
    --detach \
    i-cat
