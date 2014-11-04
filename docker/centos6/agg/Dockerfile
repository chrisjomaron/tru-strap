FROM centos:centos6
MAINTAINER Paul Gilligan<Paul.Gilligan@moneysupermarket.com>

# -----------------------------------------------------------------------------
# Get Centos-6 Update
# -----------------------------------------------------------------------------
RUN yum update -y
RUN yum install -y http://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

# -----------------------------------------------------------------------------
# Base Install
# -----------------------------------------------------------------------------
RUN yum install -y --enablerepo=centosplus \
	vim-minimal \
	sudo \
        tar \
        which \
        git \
	openssh \
	openssh-server \
	openssh-clients \
	python-pip \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all

# -----------------------------------------------------------------------------
# Install supervisord (required to run more than a single process in a container)
# Note: EPEL package lacks /usr/bin/pidproxy
# We require supervisor-stdout to allow output of services started by 
# supervisord to be easily inspected with "docker logs".
# -----------------------------------------------------------------------------
RUN pip install --upgrade 'pip >= 1.4, < 1.5' \
	&& pip install --upgrade supervisor supervisor-stdout \
	&& mkdir -p /var/log/supervisor/

# -----------------------------------------------------------------------------
# UTC Timezone & Networking
# -----------------------------------------------------------------------------
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network

# -----------------------------------------------------------------------------
# Configure SSH for non-root public key authentication
# -----------------------------------------------------------------------------
RUN sed -i \
        -e 's/^UsePAM yes/#UsePAM yes/g' \
	-e 's/^#UsePAM no/UsePAM no/g' \
	-e 's/^PasswordAuthentication yes/PasswordAuthentication no/g' \
	-e 's/^#PermitRootLogin yes/PermitRootLogin no/g' \
	-e 's/^#UseDNS yes/UseDNS no/g' \
	/etc/ssh/sshd_config

# -----------------------------------------------------------------------------
# Docker lxc specfic devices 
# -----------------------------------------------------------------------------
RUN yum install -y libcgroup

# -----------------------------------------------------------------------------
# Cron Provider
# -----------------------------------------------------------------------------
RUN yum install -y vixie-cron

# -----------------------------------------------------------------------------
# Enable the wheel sudoers group
# -----------------------------------------------------------------------------
RUN sed -i 's/^# %wheel\tALL=(ALL)\tALL/%wheel\tALL=(ALL)\tALL/g' /etc/sudoers

# -----------------------------------------------------------------------------
# Make the custom configuration directory
# -----------------------------------------------------------------------------
RUN mkdir -p /etc/services-config/{supervisor,ssh}

# -----------------------------------------------------------------------------
# Copy SSH files into place
# -----------------------------------------------------------------------------
ADD etc/ssh-bootstrap /etc/
ADD etc/services-config/ssh/authorized_keys /etc/services-config/ssh/
ADD etc/services-config/ssh/sshd_config /etc/services-config/ssh/
ADD etc/services-config/ssh/ssh-bootstrap.conf /etc/services-config/ssh/
ADD etc/services-config/supervisor/supervisord.conf /etc/services-config/supervisor/

RUN chmod 600 /etc/services-config/ssh/sshd_config \
	&& chmod +x /etc/ssh-bootstrap \
	&& ln -sf /etc/services-config/supervisor/supervisord.conf /etc/supervisord.conf \
	&& ln -sf /etc/services-config/ssh/sshd_config /etc/ssh/sshd_config \
	&& ln -sf /etc/services-config/ssh/ssh-bootstrap.conf /etc/ssh-bootstrap.conf

# -----------------------------------------------------------------------------
# Purge
# -----------------------------------------------------------------------------
RUN rm -rf /etc/ld.so.cache \ 
	; rm -rf /sbin/sln \
	; rm -rf /usr/{{lib,share}/locale,share/{man,doc,info,gnome/help,cracklib,il8n},{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive} \
	; rm -rf /var/cache/{ldconfig,yum}/*

# -----------------------------------------------------------------------------
# GPG key for RVM
# -----------------------------------------------------------------------------
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3

# -----------------------------------------------------------------------------
# Finish up
# -----------------------------------------------------------------------------
EXPOSE 22

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]


