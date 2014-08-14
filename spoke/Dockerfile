# Spoke Dockerfile for {{template}}
#
# This is an example Spoke container Dockerfile. If your desired application is
# a standard package provided by the radial/distro operating system (Ubuntu
# Trusty), then this trully is all you would need; just install the package. All
# application configuration as well as your application's .ini file is
# added/cloned/managed by the Hub container.
FROM            radial/spoke-base
MAINTAINER      Brian Clements <radial@brianclements.net>

# Install packages
ENV             DEBIAN_FRONTEND noninteractive
RUN             apt-get -q update && apt-get -qyV install \
                    htop &&\
                apt-get clean
RUN             env --unset=DEBIAN_FRONTEND

# The only modification you will need to make is if you intend to run your
# application (not Supervisor itself, but your application) as a user other than
# root. You will need to specify that here and make sure that this user is
# selected in your programs .ini file in '/config/supervisor/conf.d'. The group
# needs to be specified as well because the Spoke container will `chown` all
# files to your specified user:group.
ENV             CHOWN_USER myuser
ENV             CHOWN_GROUP myuser
RUN             groupadd $CHOWN_GROUP; \
                useradd --system -g $CHOWN_GROUP $CHOWN_USER

# GH_USER needs to be specified if you have a Github account and want your
# public keys automatically imported into your container for easy SSH support.
# This is 'secure' in that use of public keys are always secure, but it is not
# the wisest strategy to use the same key-pair for multiple venues (server
# cluster, public website, etc.). More robust key management is a feature for a
# future date. For now, this suffices for protypting and development on small
# clusters.
ENV             GH_USER brianclements

# Notice that there is no CMD or ENTRYPOINT. This is because a default
# ENTRYPOINT is already declared in the 'radial/spoke-base' image. It does many
# things that make this container work predictably, so take care when replacing
# it in this Spoke Dockerfile.
