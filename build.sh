#!/bin/bash
# This script is meant for testing and procedural archival purposes. It is not
# a standard part of the 'Wheel' repository.

# build hub statically:

# If 'build-env' is empty, then the default Supervisor configuration is used
# from repository, and all configuration is aquired by ADDing it from the '/hub'
# folder during `docker build`.
echo "" > hub/build-env 

# for testing, we can add other values for the Wheel repository or use alternate 
# Supervisor configurations by assigning the information in 'build-env'.
# (examples of the method are shown here using the default locations for each).
# echo "WHEEL_REPO=https://github.com/radial/template-wheel.git
# WHEEL_BRANCH=config
# SUPERVISOR_REPO=https://github.com/radial/config-supervisor.git
# SUPERVISOR_BRANCH=master" > hub/build-env 


# build hub.
sudo docker build -t i-echo-hub hub

# build spoke
sudo docker build -t i-echo spoke
