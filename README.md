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
export TRUSTRAP_ENV=hvd
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
* https://github.com/pauldavidgilligan-msm/go-skydns/issues/3

### Network Services

Network services such as skydns, loggly, haproxy and others are required to support the business services that we run under the docker host. Currently an image is available that combines both skydns and etcd on one docker image.

Etcd /skydns/config is used for the configuration for skydns rather than the environment, and during provisioning of the go-skydns node you will see for example:

```
==> go-skydns: Configuring skydns
==> go-skydns: {"action":"set","node":{"key":"/skydns/config","value":"{\"dns_addr\":\"0.0.0.0:53\",\"ttl\":3600, \"domain\":\"msm.internal\", \"nameservers\": [\"8.8.8.8:53\",\"8.8.4.4:53\"]}","modifiedIndex":3,"createdIndex":3}}
```
And then from a docker container as a business node you can test the dns with:

```
dig SRV agg-redis1.agg.dev.gb.msm.internal

[dev-opts@redis ~]$ dig SRV agg-redis1.agg.dev.gb.msm.internal

; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.30.rc1.el6 <<>> SRV agg-redis1.agg.dev.gb.msm.internal
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 51486
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;agg-redis1.agg.dev.gb.msm.internal. IN	SRV

;; ANSWER SECTION:
agg-redis1.agg.dev.gb.msm.internal. 17 IN SRV	10 100 80 n1.agg-redis1.agg.dev.gb.msm.internal.

;; ADDITIONAL SECTION:
n1.agg-redis1.agg.dev.gb.msm.internal. 17 IN A	172.17.0.8

```


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
docker pull pauldavidgilligan/go-skydns
docker pull pauldavidgilligan/docker-centos6-puppet-ruby215
```

Also as an image from go-skydns is required the build of go-skydns also pulls the base image for you.

## Git Authentication
No provide keys are stored in the VM and ssh key forwarding is being used. You will need to fork
msm-provisioning, in this example, and setup you own keys on your local machine.

## Environment Variables
This Vagrantfile requires a few environment variables to be set.

- ```export TRUSTRAP_ACCOUNT=msm``` The Account name.
- ```export TRUSTRAP_USERBASE=gb``` The User base.
- ```export TRUSTRAP_ENV=hvd```     The Environment(hvd for this project needed in msm-provisioning)
- ```export TRUSTRAP_SERVICE=agg``` The Business Service name.

## Testing

You can monitor progress from a business node for example:

```
[dev-opts@redis ~]$ tail -f /tmp/progress_2014_11_17_15.log  
2014-11-17 15:36:20 Docker Provision Start
2014-11-17 15:36:20 Verifying vagrant-shell
2014-11-17 15:36:20 Running vagrant-shell
2014-11-17 15:36:20 Installing RVM
2014-11-17 15:36:29 Installing RVM Ruby ruby-2.1.4
2014-11-17 15:40:16 Installing puppet tools
2014-11-17 15:40:41 Git: git clone --progress -b handsome-vagrant-docker git@github.com:pauldavidgilligan-msm/msm-provisioning.git /opt/msm-provisioning
2014-11-17 15:40:50 Installing puppet gems
2014-11-17 15:41:59 Installing trustrap puppet from /opt/msm-provisioning/puppet
2014-11-17 15:41:59 Installing trustrap puppet security from /opt/msm-provisioning/puppet
2014-11-17 15:42:00 Installing puppet role agg-redis
2014-11-17 15:42:56 Set Facter values
2014-11-17 15:42:56 Provison with puppet apply
2014-11-17 15:45:35 vagrant-shell Complete
```

### Test Run - go test -v ./... -race

From the go-skydns host you can run a self test:

```
export GOPATH=/go
go test -v ./... -race
dig @127.0.0.1  www.miek.nl
```
Then from one business node you can test DNS:
```
[dev-opts@redis ~]$  dig  www.miek.nl

; <<>> DiG 9.8.2rc1-RedHat-9.8.2-0.30.rc1.el6 <<>> www.miek.nl
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 21872
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;www.miek.nl.			IN	A

;; ANSWER SECTION:
www.miek.nl.		20893	IN	CNAME	a.miek.nl.
a.miek.nl.		21434	IN	A	176.58.119.54

;; Query time: 22 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Mon Nov 17 15:37:28 2014
;; MSG SIZE  rcvd: 61

```

## Trustrap Original

The original init.sh trustrap init.sh has been extended slightly but with the aim of maintaining compatability with the original and RightScale deployments.

## License

go-skydns is under the Apache 2.0 license. See the [LICENSE](LICENSE) file for details.

