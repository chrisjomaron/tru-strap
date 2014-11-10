# Tru Strap
## What is this?
This is the MSM Public version of the 'tru-strap' script.  Ref: https://github.com/jimfdavies/tru-strap

We have made this repo public so that we can download and start 'tru-strapping' without needing any credentials.  
We will pass required credentials as parameters into tru-strap in order for it to download/clone the required private repo(s).

## How do I use it?
We run this version of tru-strap via Vagrant using Docker as the VM provider and a centos6 image has been provided.

Steps to start the agg (Aggregation Services):

```
git@github.com:pauldavidgilligan-msm/tru-strap.git
git checkout handsome-vagrant-docker
cd docker/centos6/agg/
vagrant up --no-parallel
```

### Documentation
More detailed documentation is maintained internally on confluence https://moneysupermarket.atlassian.net/wiki/pages/viewpage.action?pageId=23921911


### Git Authentication
No provide keys are stored in the VM and ssh key forwarding is being used. You will need to fork
msm-provisioning, in this example, and setup you own keys on your local machine.


### Environment Variables
This Vagrantfile requires a few environment variables to be set.

- ```export TRUSTRAP_ACCOUNT=msm``` The Account name.
- ```export TRUSTRAP_USERBASE=gb``` The User base.
- ```export TRUSTRAP_ENV=dev```     The Environment
- ```export TRUSTRAP_SERVICE=agg``` The Business Service name.

