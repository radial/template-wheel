FROM            radial/hub-base:latest
MAINTAINER      radial@brianclements.net

# The "radial/hub-base" image copies the entire context by default. Make sure to
# use a '.dockerignore' file to blacklist items you wish to not upload.

# Be advised that the '/config', '/data', '/log', and '/run' directories have
# been exposed as docker volumes. You cannot add files or do anything to
# existing files they contain in this Dockerfile. So this Dockerfile really
# should remain empty other then the top two lines shown here.
#
# Should you need to add files such as source code or a data set, you should
# either include those instructions as part of the entrypoint script of the
# Spoke container that requires them, or if this data is significant enough by
# itself, then it should occupy it's own Axle container. Either way, it should
# not originate in the Hub container (even though it will be made availble here
# through being exposed as a volume).
