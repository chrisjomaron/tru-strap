#Tru Strap 

## handsome-vagrant-docker feature branch

![dockers](https://libcom.org/files/Dockers%20-%20North%20End%20King's%20Lynn.jpg)

## What is this?
This is the MSM/TSM public version of the 'tru-strap' script from https://github.com/jimfdavies/tru-strap. We have made this repo public so that we can download and start 'tru-strapping' without needing any credentials.  


## How do I use it?
We run this version of tru-strap via Vagrant using Docker as the VM provider on a centos 6 linux platform and space has been provided for both MSM and TSM company groups.

The base image used is **pauldavidgilligan/docker-centos6-base-image** this provides:

* centos 6
* supervisord
* supervisorctl
* default dev-opts user with sudo

### Vagrant Part

For example to start the agg (Aggregation Services):
```
export TRUSTRAP_ACCOUNT=msm
export TRUSTRAP_USERBASE=gb
export TRUSTRAP_ENV=dev
export TRUSTRAP_SERVICE=agg

git@github.com:pauldavidgilligan-msm/tru-strap.git
git checkout handsome-vagrant-docker
cd tru-strap/docker/msm/centos6/agg
vagrant up --no-parallel
```

Destroy the services with:
```
vagrant destroy
```

Access an individual docker container node with:
```
vagrant ssh <node name>
```

### Docker Part

See what is running with:
```
docker ps -a
```

Any stranded containers should be removed with:
```
docker rm -f <container ID>
```

Inspect docker logs:
```
docker logs <container ID>
```

List docker images:
```
docker images
```

### Install
This will run both network and business services under a common docker host that is configured to create a VM under Oracle's Virtual Box. Although it is possible to run this vagrant project under boot2docker on Mac OS X and windows it is recommended that you simply install an Oracle Virtual Box VM with centos 6.6 64bit iso image and run the project there. Some issues with the docker autofs limits have been seen under MAC OS X.

* http://isoredirect.centos.org/centos/6/isos/x86_64/
* https://www.virtualbox.org/wiki/Downloads
* http://www.liquidweb.com/kb/how-to-install-docker-on-centos-6/

After ensuring the the VM's network is running and installing vagrant the general steps are:

```
su -
rpm -iUvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum update
usermod -a -G docker dev-opts
docker search pauldavidgilligan
docker pull pauldavidgilligan/docker-centos6-base-image
```

### Issues
* https://github.com/docker/docker/issues/5135
* https://github.com/pauldavidgilligan-msm/go-skydns/issues/1
* https://github.com/pauldavidgilligan-msm/go-skydns/issues/2

### Network Services

Network services such as skydns, loggly, haproxy and others are required to support the business services that we run under the docker host. Currently an image is available that combines both skydns and etcd on one docker image.

* https://github.com/pauldavidgilligan-msm/go-skydns

### Business Services
These are defined in the services.yaml and the name represent not only the hostnames of the final docker containers but also the provisioning roles for puppet if required.

```
services:
  dev-agg:
    - domain: msm.internal
    - skydns: true
    - git:
      - reponame   : msm-provisioning
      - repouser   : pauldavidgilligan-msm
      - repobranch : handsome-vagrant-docker
    - roles:
      - data                        : agg-mongodb
        enabled                     : false
      - data                        : agg-lts-mongodb
        enabled                     : false
      - data                        : agg-redis
        enabled                     : false
      - app                         : agg-management-agent
        enabled                     : false
      - app                         : agg-private-api
        enabled                     : false
      - app                         : agg-public-api
        enabled                     : false
      - app                         : agg-performance-test-proxy
        enabled                     : false
      - app                         : agg_kafka
        enabled                     : false
```

* setting skydns to false allows the business containers to run alone for test purposes, normally due to the puppet provisioning both access to skydns and etcd are required.
* each role is then listened and the containers provisioned if enabled.

## Design Documentation
Main design ocumentation is maintained internally on confluence: 

https://moneysupermarket.atlassian.net/wiki/pages/viewpage.action?pageId=23921911

## Docker pull(s)

```
docker pull pauldavidgilligan/docker-centos6-base-image
```

Also as an image from go-skydns is required the build of go-skydns also pulls the base image for you.

## Git Authentication
No provide keys are stored in the VM and ssh key forwarding is being used. You will need to fork
msm-provisioning, in this example, and setup you own keys on your local machine.


## Environment Variables
This Vagrantfile requires a few environment variables to be set.

- ```export TRUSTRAP_ACCOUNT=msm``` The Account name.
- ```export TRUSTRAP_USERBASE=gb``` The User base.
- ```export TRUSTRAP_ENV=dev```     The Environment
- ```export TRUSTRAP_SERVICE=agg``` The Business Service name.

## Trustrap Original

The original init.sh trustrap init.sh has been extended slightly but with the aim of maintaining compatability with the original and RightScale deployments.

## TODO

* Work out how skydns does data setup.
* Add provisioning self tests.

## License

go-skydns is under the Apache 2.0 license. See the [LICENSE](LICENSE) file for details.

