#!/bin/bash
#
# supporting provsioning shell script.
# 
# shell.sh      Provision MSM/TSM trustrap services.
#
# Authors:      Paul Gilligan, <Paul.Gilligan@moneysupermarket.com>
#
# Description:  Provision  MSM/TSM Vagrant Docker container networks
#               including go-skydns configuations.
#
#               This has beed designed to be re-entrant, i.e. it can be re-run.    
# 
# Original:     https://github.com/MSMFG/tru-strap
# Git version:  https://github.com/pauldavidgilligan-msm/tru-strap
# Git branch:   handsome-vagrant-docker


NOW=$(date "+%Y_%m_%d_%H")
VERSION=0.2.0
SCRIPTNAME=`basename $0`

JBOSS_CLI="/opt/jboss-as-7.1.1.Final/bin/jboss-cli.sh --connect --user=admin --password=password01"

EJBCA_CLI="/opt/ejbca_ce_6_2_0/bin/ejbca.sh"
EJBCA_CHECKPOINT_FILE=/tmp/mysql-user-checkpoint

# -------------------------------------------
# Functions
# -------------------------------------------

function usage {
cat <<EOF

    Usage: $0 [options]
    -h| --help             this usage text.
    -v| --version          the version.
    -n| --name             the skydns name.
    -m| --mode             the processing mode (hosts, resolv, start, config, ejbca, app_client, web_client).
    -d| --domain           the dns domain name (msm.internal, tsm.internal).
    -o| --nameserver       the local DNS nameserver, resolv mode only.
    
EOF
}

function update_hosts {
  CONF=/etc/hosts
  ETCD="etcd.${DOMAIN_NAME}"
  echo "Processing ${CONF}"
  SKYDNS=$(ping -c 1 ${SKYDNS_NAME}|grep "PING" | sed -E 's/PING .* .([0-9.]+). .*/\1/g') > /dev/null
  if [[ ! -z "${SKYDNS}" ]]; then
    printf "Found ${SKYDNS_NAME} at ${SKYDNS}"
    grep -q "${ETCD}" "${CONF}"
    if [[ $? -eq 0 ]] ;
    then
      printf ", skipped ${CONF}"
    else
      echo "${SKYDNS}    ${ETCD}" >> "${CONF}"
      printf ", updated ${CONF}"
    fi
  else
    echo "Nothing changed, was unable to ping ${SKYDNS_NAME}!"
  fi
}

function update_resolv {
  CONF=/etc/resolv.conf
  echo "Processing ${CONF}"
  SKYDNS=$(ping -c 1 ${SKYDNS_NAME}|grep "PING" | sed -E 's/PING .* .([0-9.]+). .*/\1/g') > /dev/null
  if [[ ! -z "${SKYDNS}" ]]; then
    echo "Found ${SKYDNS_NAME} at ${SKYDNS}, updating ${CONF}"
    echo "nameserver ${NAMESERVER}"  > /tmp/resolv.conf
    echo "nameserver ${SKYDNS}"     >> /tmp/resolv.conf
    cp /tmp/resolv.conf ${CONF}
    chmod 644 ${CONF}
    chown root:root ${CONF}
  else
    echo "Nothing changed, was unable to ping ${SKYDNS_NAME}!"
  fi
}

function update_start {
  CONF=/etc/supervisord.conf
  echo "Processing ${CONF}"
  grep -q "${SKYDNS_NAME}" "${CONF}"
  if [[ $? -eq 0 ]] ;
  then
    #/usr/bin/supervisorctl start etcd
    /usr/bin/supervisorctl start skydns
  else
    printf ", skipped ${CONF}"
  fi
}

function update_config {
  RESULT=`pgrep etcd`
  if [ "${RESULT:-null}" = null ]; then
    printf ", skipped config"
  else
    echo "Configuring skydns service at /v2/keys/skydns/config"
    /usr/bin/curl -XPUT http://127.0.0.1:4001/v2/keys/skydns/config \
      -d value="{\"dns_addr\":\"0.0.0.0:53\",\"ttl\":3600, \"domain\": \"${DOMAIN_NAME}\", \"nameservers\": [\"8.8.8.8:53\",\"8.8.4.4:53\"]}"
  fi
}

function update_puppet {
  # We need to simulate trustrap here, these values will be changed if the actual init.sh is ran.
  mkdir -m 0600 -p /etc/facter/facts.d
  echo "msmid_account=msm"                        >  /etc/facter/facts.d/init_custom_values.txt
  echo "msmid_env=hvd"                           >>  /etc/facter/facts.d/init_custom_values.txt
 
  # now install custom puppet modules
  mkdir -p /root/.ssh && touch /root/.ssh/known_hosts && ssh-keyscan -H github.com >> /root/.ssh/known_hosts && chmod 600 /root/.ssh/known_hosts
  cd /home/dev-ops/etc/puppet && librarian-puppet install --path modules-contrib
}

function update_skydns_client {
  puppet apply --modulepath=/home/dev-ops/etc/puppet/modules-contrib --hiera_config=/home/dev-ops/etc/puppet/hiera.yaml -e "include role::skydns_client"
}

function update_ife_toolbelt_client {
  puppet apply --evaltrace --modulepath=/home/dev-ops/etc/puppet/modules-contrib --hiera_config=/home/dev-ops/etc/puppet/hiera.yaml -e "include role::ife_toolbelt_client"
}

function update_ife_dropwizard {
  puppet apply --modulepath=/home/dev-ops/etc/puppet/modules-contrib --hiera_config=/home/dev-ops/etc/puppet/hiera.yaml -e "include role::ife_dropwizard"
}


function update_ejbca_mysql {
  RESULT=`pgrep mysqld`
  if [ "${RESULT:-null}" = null ]; then
    printf ", skipped config"
  else
    echo "Configuring ejbca mysql user data"
    runuser -l jboss -c '/usr/bin/mysql -u root < /tmp/mysql-user'
    echo "checkpoint: mysql user created" > ${EJBCA_CHECKPOINT_FILE}
    sleep 10 
    echo "Registering mysql driver with JBoss"
    runuser -l jboss -c "${JBOSS_CLI} --command=\"/subsystem=datasources/jdbc-driver=com.mysql.jdbc.Driver:add(driver-name=com.mysql.jdbc.Driver,driver-class-name=com.mysql.jdbc.Driver,driver-module-name=com.mysql,driver-xa-datasource-class-name=com.mysql.jdbc.jdbc.jdbc2.optional.MysqlXADataSource)\""
    sleep 10 # TODO: Jboss wait loop
  fi
}

function update_ejbca_deploy {
  RESULT=`pgrep java`
  if [ "${RESULT:-null}" = null ]; then
    printf ", skipped config"
  else
    echo "Configuring ejbca mysql service from ant deploy"
    echo "Running in background (approx 1 min), check /tmp/ant-deploy.log ..."
    runuser -l jboss -c 'cd /opt/ejbca_ce_6_2_0 && /opt/apache-ant-1.9.4/bin/ant deploy >> /tmp/ant-deploy.log  2>&1 & '
  fi
}

function update_ejbca_install {
  RESULT=`pgrep java`
  if [ "${RESULT:-null}" = null ]; then
    printf ", skipped config"
  else
    echo "Configuring ejbca mysql service from ant install"
    echo "Running (approx 2 mins), check /tmp/ant-install.log ..."
    runuser -l jboss -c 'cd /opt/ejbca_ce_6_2_0 && /opt/apache-ant-1.9.4/bin/ant install >> /tmp/ant-install.log  2>&1 '
    cp -f /opt/ejbca_ce_6_2_0/p12/superadmin.p12 /vagrant/
    echo "Superadmin keystore has been copied to your Vagrant directory, don't forget to import into Firefox!"
    echo "Add entry to /etc/hosts 127.0.0.1 ejbca.msm.internal"
    echo "Then from Firefox, you can access https://ejbca.msm.internal:8443/ejbca/"
  fi
}

function update_ejbca_restart {
  /usr/bin/supervisorctl restart jboss
}

function update_ejbca_scep {
  echo "scep.operationmode = ca"    > /tmp/scepalias-camode.properties
  echo "uploaded.includeca = true" >> /tmp/scepalias-camode.properties
  runuser -l jboss -c "${EJBCA_CLI} config scep uploadfile --alias scep --file /tmp/scepalias-camode.properties" 
#  runuser -l jboss -c "${EJBCA_CLI} ra addendentity --username=routerMSM --password=foo123 --dn="CN=Device" --caname=MSMCA --type=1 --token=USERGENERATED"
}

# -------------------------------------------
# Process Command Line Params
# -------------------------------------------
while test -n "$1"; do
  case "$1" in
  --help|-h)
    usage
    exit
    ;;
  --version|-v)
    echo $SCRIPTNAME $VERSION
    exit
    ;;
  --name|-n)
    SKYDNS_NAME=$2
    shift
    ;;
  --mode|-m)
    SHELL_MODE=$2
    shift
    ;;

  --domain|-d)
    DOMAIN_NAME=$2
    shift
    ;;

  --nameserver|-o)
    NAMESERVER=$2
    shift
    ;;

  *)
    echo ", unknown argument: $1"
    usage
    exit 1
    ;;
  esac
  shift
done

# -------------------------------------------
# Check
# -------------------------------------------
if [[ ${SKYDNS_NAME} == "" || ${SHELL_MODE} == "" || ${DOMAIN_NAME} == "" ]]; then
  echo ", missing argument(s)."
  usage
  exit 1
fi

if [ "$SHELL_MODE" == "resolv" ]; then
  if [ -z "$NAMESERVER" ]; then
    echo "Parameter 'nameserver' cannot be empty for mode resolv"
    exit 1
  fi
  echo "Mode is resolv, using local nameserver entry ${NAMESERVER}"
fi

MODES="hosts resolv start config ejbca app_client web_client"
if echo "$MODES" | grep -q "$SHELL_MODE"; then
  echo "Mode is ${SHELL_MODE}"
else
  echo "${SHELL_MODE} mode must be one of [${MODES}]"
  exit 1
fi

DOMAINS="msm.internal tsm.internal"
if echo "$DOMAINS" | grep -q "$DOMAIN_NAME"; then
  echo "Domain is ${DOMAIN_NAME}"
else
  echo "${DOMAIN_NAME} mode must be one of [${DOMAINS}]"
  exit 1
fi

# -------------------------------------------
# Main
# -------------------------------------------
case "${SHELL_MODE}" in
  hosts) 
    update_hosts
    ;;
  resolv)  
    update_resolv
    ;;
  start) 
    update_start
    ;;
  config)
    update_config
    ;;

  ejbca)
     update_ejbca_mysql
     update_puppet  # do this here, give jboss some time to catchup
     update_skydns_client # and this
     update_ejbca_deploy
     regex_on='BUILD SUCCESSFUL'
     regex_off='BUILD FAILED'
     tail /tmp/ant-deploy.log -n0 -F | while read line; do
       if [[ $line =~ $regex_on ]]; then
         pkill -9 -P $$ tail
         update_ejbca_install
         update_ejbca_scep
         update_ejbca_restart
       elif [[ $line =~ $regex_off ]]; then
         pkill -9 -P $$ tail
         echo "Failed aborting, ${regex_off}"
       fi
     done    
    ;;

  app_client)
    update_puppet
    update_ife_toolbelt_client
    ;;

  web_client)
    update_puppet
    update_ife_dropwizard
    ;;

esac


