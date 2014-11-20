FROM pauldavidgilligan/docker-centos6-puppet-ruby215
MAINTAINER Paul Gilligan<Paul.Gilligan@moneysupermarket.com>

# -----------------------------------------------------------------------------
# Get Centos-6 Update
# -----------------------------------------------------------------------------
RUN yum update -y
RUN yum reinstall -y glibc-common

# -----------------------------------------------------------------------------
# Some tools
# -----------------------------------------------------------------------------
RUN yum install -y htop figlet 

# -----------------------------------------------------------------------------
# Finish up
# -----------------------------------------------------------------------------
VOLUME /var/lib/docker

EXPOSE 22

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]


