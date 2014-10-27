FROM centos:centos6
MAINTAINER Paul Gilligan<Paul.Gilligan@moneysupermarket.com>

# Install update tools
RUN yum update -y
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN sudo rpm -ivh https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.5_x86_64.rpm
RUN yum install docker.io
 
 
CMD ["bash"]

