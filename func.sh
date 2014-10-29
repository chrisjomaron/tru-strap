#!/bin/bash
#
# func.sh       Provision MSM/TSM trustrap services.
#
# Authors:      Jim Davies, <Jim.Davies@moneysupermarket.com>
#               Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Common bash fucntions.
# 
# Original:     https://github.com/MSMFG/tru-strap
# Git version:  https://github.com/pauldavidgilligan-msm/tru-strap
# Git branch:   handsome-vagrant-docker

VERSION=0.0.2
SCRIPTNAME=`basename $0`

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
function _line {
  length=40
  printf -v line '%*s' "$length"
  echo ${line// /=}
}

function _bold {
  echo -e "\e[1m$1 \e[21m"
}

function _err {
  length=40
  printf -v line '%*s' "$length"
  echo ${line// /-}
  echo -e "\e[31m$1 \e[39m"
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



