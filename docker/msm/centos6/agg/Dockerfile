FROM pauldavidgilligan/docker-centos6-base-image 
MAINTAINER Paul Gilligan<Paul.Gilligan@moneysupermarket.com>

# -----------------------------------------------------------------------------
# Get Centos-6 Update
# -----------------------------------------------------------------------------
RUN yum update -y

# -----------------------------------------------------------------------------
# Finish up
# -----------------------------------------------------------------------------
VOLUME /var/lib/docker

EXPOSE 22

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]


