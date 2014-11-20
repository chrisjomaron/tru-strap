FROM pauldavidgilligan/docker-centos6-puppet-ruby215
MAINTAINER Paul Gilligan<Paul.Gilligan@moneysupermarket.com>

# -----------------------------------------------------------------------------
# Get Centos-6 Update
# -----------------------------------------------------------------------------
RUN yum update -y

# -----------------------------------------------------------------------------
# Need to set LOCALE for puppet
# -----------------------------------------------------------------------------
ENV LC_ALL en_GB.utf8

# -----------------------------------------------------------------------------
# Finish up
# -----------------------------------------------------------------------------
VOLUME /var/lib/docker

EXPOSE 22

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]


