# Spoke Dockerfile for {{template}}
# This is an example Spoke container Dockerfile. If your desired package is a
# standard package provided by the radial/distro operating system, then this
# trully is all you would need; just install the package. All application
# configuration as well as your Supervisor .ini file is added/cloned/managed by
# the Hub container.
FROM            radial/spoke-base
MAINTAINER      {{Brian Clements <radial@brianclements.net>}}

# Install packages
ENV             DEBIAN_FRONTEND noninteractive
RUN             apt-get -q update && apt-get -qyv install \
                    {{packagename}} \
                    {{packagename2}} &&\
                apt-get clean
RUN             env --unset=DEBIAN_FRONTEND
