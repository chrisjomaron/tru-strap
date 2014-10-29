#!/bin/bash

# Usage: ./init.sh -e dev -u pauldavidgilligan-msm -n msm-provisioning -b handsome-vagrant-docker

VERSION=0.0.2
SCRIPTNAME=`basename $0`

function _echo {
  tput sgr0
  length=40
  printf -v line '%*s' "$length"
  echo ${line// /-}
  echo -e "\e[0;32m$1 \e[0m"
}

# functions
function usage {
cat <<EOF

    Usage: $0 [options]
    -h| --help           this usage text.
    -v| --version        the version.
    -r| --role           the role name.
    -e| --environment    the environment name.
    -u| --repouser       the git repository user name.
    -n| --reponame       the git repository name.
    -b| --repobranch     the git repository branch name.
    
EOF
}

function print_version {
  echo $1 $2
}

# Process command line params
while test -n "$1"; do
  case "$1" in
  --help|-h)
    usage
    exit
    ;;
  --version|-v)
    print_version $SCRIPTNAME $VERSION
    exit
    ;;
  --role|-r)
    trustrap_role=$2
    shift
    ;;
  --environment|-e)
    trustrap_env=$2
    shift
    ;;
  --repouser|-u)
    trustrap_repouser=$2
    shift
    ;;
  --reponame|-n)
    trustrap_reponame=$2
    shift
    ;;
  --repobranch|-b)
    trustrap_repobranch=$2
    shift
    ;;

  *)
    echo "Unknown argument: $1"
    usage
    exit 1
    ;;
  esac
  shift
done

_echo "Running ${SCRIPTNAME}."
REPODIR="/opt/${trustrap_reponame}"

_echo "Installing RVM."
curl -L get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm reload
rvm install 2.1.0 
rvm use ruby

_echo "Installing puppet. Cloning repository to ${REPODIR}"
yum install -y http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm 
yum install -y puppet 
git clone -b ${trustrap_repobranch} git@github.com:${trustrap_repouser}/${trustrap_reponame}.git $REPODIR
gem install hiera-eyaml --no-ri --no-rdoc


