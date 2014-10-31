#!/bin/bash
#
# init.sh       Provision MSM/TSM trustrap services.
#
# Authors:      Jim Davies, <Jim.Davies@moneysupermarket.com>
#               Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Install MSM/TSM based puppet provisioning software and provision
#               the required service (agg, aem, services, etc). This script has 
#               been modified from the original concept to allow many applications
#               to be provisioned under a vagrant/docker hosted solution.
#
#               This has beed designed to be re-entrant, i.e. it can be re-run.    
# 
# Original:     https://github.com/MSMFG/tru-strap
# Git version:  https://github.com/pauldavidgilligan-msm/tru-strap
# Git branch:   handsome-vagrant-docker

# Usage:        ./init.sh -s agg -e dev -u pauldavidgilligan-msm -n msm-provisioning -b handsome-vagrant-docker

VERSION=0.0.2
SCRIPTNAME=`basename $0`
RUBYVERSION="ruby-2.1.4"
TRUSTRAP_REPOPRIVKEYFILE="~/.ssh/id_rsa"
NOW=$(date "+%Y_%m_%d_%H")
PROGRESS_LOG=/tmp/progress_${NOW}.log

echo $(date "+%Y-%m-%d %H:%M:%S") "Docker Provision Start" > ${PROGRESS_LOG}

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
function _line {
  length=40
  printf -v line '%*s' "$length"
  echo ${line// /=}
  echo $(date "+%Y-%m-%d %H:%M:%S") $1 >> ${PROGRESS_LOG}
}

function _bold {
  echo -e "\e[30;1m$1 \e[21m"
  echo $(date "+%Y-%m-%d %H:%M:%S") $1 >> ${PROGRESS_LOG}
}

function _err {
  length=40
  printf -v line '%*s' "$length"
  echo ${line// /-}
  echo -e "\e[31m$1 \e[39m"
  echo $(date "+%Y-%m-%d %H:%M:%S") $1 >> ${PROGRESS_LOG}
}

# functions
function usage {
cat <<EOF

    Usage: $0 [options]
    -h| --help             this usage text.
    -v| --version          the version.
    -s| --service          the Service name, e.g. agg, aem, services.
    -e| --environment      the environment name.
    -u| --repouser         the git repository user name.
    -n| --reponame         the git repository name.
    -b| --repobranch       the git repository branch name.
    -k| --repoprivkeyfile  your git repository private key file
    
EOF
}

function print_version {
  echo $1 $2
}

# -----------------------------------------------------------------------------
# Reset console
# -----------------------------------------------------------------------------
echo -e "\e[0m"
_line

# -----------------------------------------------------------------------------
# Process Command Line Params
# -----------------------------------------------------------------------------
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
  --service|-s)
    TRUSTRAP_SERVICE=$2
    shift
    ;;
  --environment|-e)
    TRUSTRAP_ENV=$2
    shift
    ;;
  --repouser|-u)
    TRUSTRAP_REPOUSER=$2
    shift
    ;;
  --reponame|-n)
    TRUSTRAP_REPONAME=$2
    shift
    ;;
  --repobranch|-b)
    TRUSTRAP_REPOBRANCH=$2
    shift
    ;;
  --repoprivkeyfile|-k)
    TRUSTRAP_REPOPRIVKEYFILE=$2
    shift
    ;;

  *)
    _err ", unknown argument: $1"
    usage
    exit 1
    ;;
  esac
  shift
done

# -----------------------------------------------------------------------------
# Check
# -----------------------------------------------------------------------------
_bold "Verifying ${SCRIPTNAME}"
if [[ ${TRUSTRAP_SERVICE} == "" || ${TRUSTRAP_ENV} == "" || ${TRUSTRAP_REPOUSER} == "" || ${TRUSTRAP_REPONAME} == "" || ${TRUSTRAP_REPOBRANCH} == "" || ${TRUSTRAP_REPOPRIVKEYFILE} == "" ]]; then
  _err ", missing argument(s)."
  usage
  exit 1
fi

valid_services=('agg', 'aem', 'services')
if echo "${valid_services[@]}" | fgrep --word-regexp "${TRUSTRAP_SERVICE}"; then
  _bold "Building service for [${TRUSTRAP_SERVICE}]" 
else
  _err "Service ${TRUSTRAP_SERVICE} not valid, must be one of ${valid_services[*]}!" 
  exit 1
fi

# -----------------------------------------------------------------------------
# Run 
# -----------------------------------------------------------------------------
_bold "Running ${SCRIPTNAME}"
TRUSTRAP_REPODIR="/opt/${TRUSTRAP_REPONAME}"
if [[ -d "${TRUSTRAP_REPODIR}" ]]; then
  rm -rf "${TRUSTRAP_REPODIR}"
fi

_bold "Installing RVM"
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
curl -L get.rvm.io | bash -s stable
_bold "Installing RVM ruby ${RUBYVERSION}"
source /etc/profile.d/rvm.sh
rvm reload
rvm install ${RUBYVERSION}
rvm use ${RUBYVERSION}

_bold "Installing puppet"
yum install -y http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm 
yum install -y puppet 
yum install -y facter
bold "Cloning ${TRUSTRAP_REPOBRANCH} git@github.com:${TRUSTRAP_REPOUSER}/${TRUSTRAP_REPONAME}.git to ${TRUSTRAP_REPODIR}"
git clone -b ${TRUSTRAP_REPOBRANCH} git@github.com:${TRUSTRAP_REPOUSER}/${TRUSTRAP_REPONAME}.git $TRUSTRAP_REPODIR
_bold "Installing puppet gems"
gem install librarian-puppet --no-rdoc --no-ri --force
gem install hiera-eyaml --no-ri --no-rdoc


_line
_bold "${SCRIPTNAME} Complete"
_line

