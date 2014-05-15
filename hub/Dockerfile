FROM            radial/hub-base
MAINTAINER      {{radial@brianclements.net}}

# This is to demonstrate how to get other files into our hub. Docker allows us
# to ADD files into already shared volumes after they've been declared. So while
# the 'radial/hub-base' image makes no assumptions about these folders and only
# worries about '/config', we still have a way to add whatever we want to them
# after the fact; whether it's a large dataset or to store our application
# source code (even though the Hub container is just for configuration, it can
# also be for storing media and other data for our Spoke container to keep the
# size of our Spoke image small. One such example is by using a temporary
# "build" container to compile our app if it is neccesary and just use the Spoke
# to run the binary.) If persisting the source code is truly a concern, or the
# source code is needed by multiple containers, then It should have it's own
# Axle container.
ADD             /data /data

# Note, if you have a 'logs' Axle container just for housing all your containers
# logs and use the '--volumes-from logs' method to access them, adding files in
# this step won't work. But that's fine because I can't image any situation
# where one would need to add files to this folder.
ADD             /log /log

# If you wanted to
# cURL or git a dataset or other types of data from a remote location, you must
# add an ENTRYPOINT to the end of this file here with instructions to
# download/extract it.
#
# ENTRYPOINT curl http://some.opendataproject.org/dataset.tar
