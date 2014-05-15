# Spoke Dockerfile for {{template}}
#
# This is an example Spoke container Dockerfile. If your desired application is
# a standard package provided by the radial/distro operating system (Ubuntu
# Trusty), then this trully is all you would need; just install the package. All
# application configuration as well as your application's .ini file is
# added/cloned/managed by the Hub container.
FROM            radial/spoke-base
MAINTAINER      {{Brian Clements <radial@brianclements.net>}}

# Install packages
ENV             DEBIAN_FRONTEND noninteractive
RUN             apt-get -q update && apt-get -qyv install \
                    htop \
                    git &&\
                apt-get clean
RUN             env --unset=DEBIAN_FRONTEND

# The only modification you will need to make is if you intend to run your
# application (not Supervisor itself, but your application) as a user other than
# root. You will need to specify that here and make sure that this user is
# selected in your programs .ini file in '/config/supervisor/conf.d'. GROUP
# needs to be specified as well because the Spoke container will `chown` all
# files to your specified user:group.
ENV             USER myworker
ENV             GROUP workergroup
RUN             groupadd $GROUP; \
                useradd --system -G $GROUP $USER

# Notice that there is no CMD or ENTRYPOINT. This is because a default
# ENTRYPOINT is already declared in the 'radial/spoke-base' image. It does many
# things that make this container work predictably, so take care when replacing
# it in this Spoke Dockerfile. 
